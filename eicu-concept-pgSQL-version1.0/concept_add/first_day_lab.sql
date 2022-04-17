-- This script extracts highest/lowest labs, as appropriate, for the first 24 hours of a patient's stay.
DROP TABLE IF EXISTS eicu_derived.first_day_lab CASCADE;

  select patientunitstayid
  , min(albumin) as albumin_min
  , max(albumin) as albumin_max
  , min(bilirubin) as bilirubin_min
  , max(bilirubin) as bilirubin_max
  , min(bun) as bun_min
  , max(bun) as bun_max
  , min(calcium) as calcium_min
  , max(calcium) as calcium_max
  , min(chloride) as chloride_min
  , max(chloride) as chloride_max
  , min(creatinine) as creatinine_min
  , max(creatinine) as creatinine_max
  , min(glucose) as glucose_min
  , max(glucose) as glucose_max
  , min(bicarbonate) as bicarbonate_min
  , max(bicarbonate) as bicarbonate_max
  , min(totalco2) as totalco2_min
  , max(totalco2) as totalco2_max
  , min(hematocrit) as hematocrit_min
  , max(hematocrit) as hematocrit_max
  , min(hemoglobin) as hemoglobin_min
  , max(hemoglobin) as hemoglobin_max
  , min(inr) as inr_min
  , max(inr) as inr_max
  , min(lactate) as lactate_min
  , max(lactate) as lactate_max
  , min(platelets) as platelets_min
  , max(platelets) as platelets_max
  , min(potassium) as potassium_min
  , max(potassium) as potassium_max
  , min(ptt) as ptt_min
  , max(ptt) as ptt_max
  , min(sodium) as sodium_min
  , max(sodium) as sodium_max
  , min(wbc) as wbc_min
  , max(wbc) as wbc_max
  , min(bands) as bands_min
  , max(bands) as bands_max
  , min(alt) as alt_min
  , max(alt) as alt_max
  , min(ast) as ast_min
  , max(ast) as ast_max
  , min(alp) as alp_min
  , max(alp) as alp_max
  into eicu_derived.first_day_lab
  from eicu_derived.pivoted_lab
  where chartoffset <= 60*24 AND chartoffset >= -6*60
  group by patientunitstayid
