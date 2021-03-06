-- This query extracts dose+durations of norepinephrine administration
select
  stay_id, linkorderid
  , rate as vaso_rate
  , amount as vaso_amount
  , starttime
  , endtime
  into mimic_derived.norepinephrine
from mimic_icu.inputevents
where itemid = 221906 -- norepinephrine