-- This query extracts dose+durations of dopamine administration
select
stay_id, linkorderid
, rate as vaso_rate
, amount as vaso_amount
, starttime
, endtime
into mimic_derived.dobutamine
from mimic_icu.inputevents
where itemid = 221653 -- dobutamine