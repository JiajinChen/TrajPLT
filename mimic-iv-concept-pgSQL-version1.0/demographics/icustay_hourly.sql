-- This query generates a row for every hour the patient is in the ICU.
-- The hours are based on clock-hours (i.e. 02:00, 03:00).
-- The hour clock starts 24 hours before the first heart rate measurement.
-- Note that the time of the first heart rate measurement is ceilinged to the hour.

-- this query extracts the cohort and every possible hour they were in the ICU
-- this table can be to other tables on ICUSTAY_ID and (ENDTIME - 1 hour,ENDTIME]

-- get first/last measurement time
with all_hours as
(
select
  it.stay_id

  -- ceiling the intime to the nearest hour by adding 59 minutes then truncating
  -- note thart we truncate by parsing as string, rather than using DATETIME_TRUNC
  -- this is done to enable compatibility with psql
  , PARSE_DATETIME(
      '%Y-%m-%d %H:00:00',
      FORMAT_DATETIME(
        '%Y-%m-%d %H:00:00',
          DATETIME_ADD(it.intime_hr, INTERVAL '59' MINUTE)
  )) AS endtime

  -- create integers for each charttime in hours from admission
  -- so 0 is admission time, 1 is one hour after admission, etc, up to ICU disch
  --  we allow 24 hours before ICU admission (to grab labs before admit)
  , CAST(generate_series(-24, CEIL(DATETIME_DIFF(it.outtime_hr, it.intime_hr, 'HOUR'))) AS bigint) as hrs

  from mimic_derived.icustay_times it
)
-- select * from all_hours limit 100
SELECT stay_id
, hrs as hr
, endtime +  hrs * INTERVAL '1' HOUR as endtime
into mimic_derived.icustay_hourly
FROM all_hours
-- CROSS JOIN UNNEST(all_hours.hrs) AS hr;