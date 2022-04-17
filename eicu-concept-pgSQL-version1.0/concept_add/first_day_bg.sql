-- This script extracts highest/lowest labs, as appropriate, for the first 24 hours of a patient's stay.

DROP TABLE IF EXISTS eicu_derived.first_day_bg CASCADE;

  select patientunitstayid
  , min(pao2) as PaO2_min
  , max(pao2) as PaO2_max
  , min(fio2) as fio2_min
  , max(fio2) as fio2_max
  , min(pao2/fio2) as pao2fio2_min
  , max(pao2/fio2) as pao2fio2_max
  , min(paco2) as PaCO2_min
  , max(paco2) as PaCO2_max
  , min(ph) as ph_min
  , max(ph) as ph_max
  , min(aniongap) as aniongap_min
  , max(aniongap) as aniongap_max
  , min(basedeficit) as basedeficit_min
  , max(basedeficit) as basedeficit_max
  , min(baseexcess) as baseexcess_min
  , max(baseexcess) as baseexcess_max
  , min(peep) as peep_min
  , max(peep) as peep_max
  into eicu_derived.first_day_bg
  from eicu_derived.pivoted_bg
  where chartoffset <= 1440 AND chartoffset >= 0
  group by patientunitstayid
