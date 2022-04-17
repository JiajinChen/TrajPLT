DROP TABLE IF EXISTS eicu_derived.first_day_gcs CASCADE;

  select patientunitstayid
  , min(gcs) as gcs_min
  , max(gcs) as gcs_max
  , min(gcsmotor) as gcsmotor_min
  , max(gcsmotor) as gcsmotor_max
  , min(gcsverbal) as gcsverbal_min
  , max(gcsverbal) as gcsverbal_max
  , min(gcseyes) as gcseyes_min
  , max(gcseyes) as gcseyes_max
  
  into eicu_derived.first_day_gcs
  from eicu_derived.pivoted_gcs
  where chartoffset <= 1440 AND chartoffset >= 0
  group by patientunitstayid

