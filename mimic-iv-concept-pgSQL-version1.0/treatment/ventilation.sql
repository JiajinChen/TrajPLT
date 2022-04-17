-- Calculate duration of mechanical ventilation.
-- Some useful cases for debugging:
--  stay_id = 30019660 has a tracheostomy placed in the ICU
--  stay_id = 30000117 has explicit documentation of extubation
-- classify vent settings into modes
WITH tm AS
(
  SELECT stay_id, charttime
  FROM mimic_derived.ventilator_setting
  UNION DISTINCT
  SELECT stay_id, charttime
  FROM mimic_derived.oxygen_delivery
)
, vs AS
(
    SELECT tm.stay_id, tm.charttime
    -- source data columns, here for debug
    , o2_delivery_device_1
    , COALESCE(ventilator_mode, ventilator_mode_hamilton) AS vent_mode
    -- case statement determining the type of intervention
    -- done in order of priority: trach > mech vent > NIV > high flow > o2
    , CASE
    -- tracheostomy
    WHEN o2_delivery_device_1 IN
    (
        'Tracheostomy tube'
    -- 'Trach mask ' -- 16435 observations
    )
        THEN 'Trach'
    -- mechanical ventilation
    WHEN o2_delivery_device_1 IN
    (
        'Endotracheal tube'
    )
    OR ventilator_mode IN
    (
        '(S) CMV',
        'APRV',
        'APRV/Biphasic+ApnPress',
        'APRV/Biphasic+ApnVol',
        'APV (cmv)',
        'Ambient',
        'Apnea Ventilation',
        'CMV',
        'CMV/ASSIST',
        'CMV/ASSIST/AutoFlow',
        'CMV/AutoFlow',
        'CPAP/PPS',
        'CPAP/PSV+Apn TCPL',
        'CPAP/PSV+ApnPres',
        'CPAP/PSV+ApnVol',
        'MMV',
        'MMV/AutoFlow',
        'MMV/PSV',
        'MMV/PSV/AutoFlow',
        'P-CMV',
        'PCV+',
        'PCV+/PSV',
        'PCV+Assist',
        'PRES/AC',
        'PRVC/AC',
        'PRVC/SIMV',
        'PSV/SBT',
        'SIMV',
        'SIMV/AutoFlow',
        'SIMV/PRES',
        'SIMV/PSV',
        'SIMV/PSV/AutoFlow',
        'SIMV/VOL',
        'SYNCHRON MASTER',
        'SYNCHRON SLAVE',
        'VOL/AC'
    )
    OR ventilator_mode_hamilton IN
    (
        'APRV',
        'APV (cmv)',
        'Ambient',
        '(S) CMV',
        'P-CMV',
        'SIMV',
        'APV (simv)',
        'P-SIMV',
        'VS',
        'ASV'
    )
        THEN 'InvasiveVent'
    -- NIV
    WHEN o2_delivery_device_1 IN
    (
        'Bipap mask ', -- 8997 observations
        'CPAP mask ' -- 5568 observations
    )
    OR ventilator_mode_hamilton IN
    (
        'DuoPaP',
        'NIV',
        'NIV-ST'
    )
        THEN 'NonInvasiveVent'
    -- high flow
    when o2_delivery_device_1 IN
    (
        'High flow neb', -- 10785 observations
        'High flow nasal cannula' -- 925 observations
    )
        THEN 'HighFlow'
    -- normal oxygen delivery
    WHEN o2_delivery_device_1 in
    (
        'Nasal cannula', -- 153714 observations
        'Face tent', -- 24601 observations
        'Aerosol-cool', -- 24560 observations
        'Non-rebreather', -- 5182 observations
        'Venti mask ', -- 1947 observations
        'Medium conc mask ', -- 1888 observations
        'T-piece', -- 1135 observations
        'Ultrasonic neb', -- 9 observations
        'Vapomist', -- 3 observations
        'Oxymizer' -- 1301 observations
    )
        THEN 'Oxygen'
    -- Not categorized:
    -- 'Other', 'None'
    ELSE NULL END AS ventilation_status
  FROM tm
  LEFT JOIN mimic_derived.ventilator_setting vs
      ON tm.stay_id = vs.stay_id
      AND tm.charttime = vs.charttime
  LEFT JOIN mimic_derived.oxygen_delivery od
      ON tm.stay_id = od.stay_id
      AND tm.charttime = od.charttime
)
, vd0 AS
(
    SELECT
      stay_id, charttime
      -- source data columns, here for debug
      , o2_delivery_device_1
      , vent_mode
      -- carry over the previous charttime which had the same state
      , LAG(charttime, 1) OVER (PARTITION BY stay_id, ventilation_status ORDER BY charttime) AS charttime_lag
      -- bring back the next charttime, regardless of the state
      -- this will be used as the end time for state transitions
      , LEAD(charttime, 1) OVER w AS charttime_lead
      , ventilation_status
      , LAG(ventilation_status, 1) OVER w AS ventilation_status_lag
    FROM vs
    WHERE ventilation_status IS NOT NULL
    WINDOW w AS (PARTITION BY stay_id ORDER BY charttime)
)
, vd1 as
(
    SELECT
        stay_id
        -- source data columns, here for debug
        , o2_delivery_device_1
        , vent_mode
        , charttime_lag
        , charttime
        , charttime_lead
        , ventilation_status

        -- calculate the time since the last event
        , DATETIME_DIFF(charttime, charttime_lag, 'MINUTE')/60 as ventduration

        -- now we determine if the current ventilation status is "new", or continuing the previous
        , CASE
            -- a 14 hour gap always initiates a new event
            WHEN DATETIME_DIFF(charttime, charttime_lag, 'HOUR') >= 14 THEN 1
            WHEN ventilation_status_lag IS NULL THEN 1
            -- not a new event if identical to the last row
            WHEN ventilation_status_lag != ventilation_status THEN 1
          ELSE 0
          END AS new_status
    FROM vd0
)
, vd2 as
(
    SELECT vd1.*
    -- create a cumulative sum of the instances of new ventilation
    -- this results in a monotonic integer assigned to each instance of ventilation
    , SUM(new_status) OVER (PARTITION BY stay_id ORDER BY charttime) AS vent_num
    FROM vd1
)
-- create the durations for each ventilation instance
SELECT stay_id
  , MIN(charttime) AS starttime
  -- for the end time of the ventilation event, the time of the *next* setting
  -- i.e. if we go NIV -> O2, the end time of NIV is the first row with a documented O2 device
  -- ... unless it's been over 14 hours, in which case it's the last row with a documented NIV.
  , MAX(
        CASE
            WHEN charttime_lead IS NULL
            OR DATETIME_DIFF(charttime_lead, charttime, 'HOUR') >= 14
                THEN charttime
        ELSE charttime_lead
        END
   ) AS endtime
   -- all rows with the same vent_num will have the same ventilation_status
   -- for efficiency, we use an aggregate here, but we could equally well group by this column
  , MAX(ventilation_status) AS ventilation_status
  into mimic_derived.ventilation
FROM vd2
GROUP BY stay_id, vent_num
HAVING min(charttime) != max(charttime)
;