-- This query extracts dose+durations of epinephrine administration
select
stay_id, linkorderid
, rate as vaso_rate
, amount as vaso_amount
, starttime
, endtime
into mimic_derived.epinephrine
from mimic_icu.inputevents
where itemid = 221289 -- epinephrine