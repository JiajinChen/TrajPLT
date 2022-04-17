DROP TABLE IF EXISTS eicu_derived.first_day_vitals CASCADE;

  select patientunitstayid
  , min(heartrate) as heartrate_min
  , max(heartrate) as heartrate_max
  , min(respiratoryrate) as respiratoryrate_min
  , max(respiratoryrate) as respiratoryrate_max
  , min(spo2) as spo2_min
  , max(spo2) as spo2_max
  , min(nibp_systolic) as nibp_systolic_min
  , max(nibp_systolic) as nibp_systolic_max
  , min(nibp_diastolic) as nibp_diastolic_min
  , max(nibp_diastolic) as nibp_diastolic_max
  , min(nibp_mean) as nibp_mean_min
  , max(nibp_mean) as nibp_mean_max
  , min(temperature) as temperature_min
  , max(temperature) as temperature_max
  , min(ibp_systolic) as ibp_systolic_min
  , max(ibp_systolic) as ibp_systolic_max
  , min(ibp_diastolic) as ibp_diastolic_min
  , max(ibp_diastolic) as ibp_diastolic_max
  , min(ibp_mean) as ibp_mean_min
  , max(ibp_mean) as ibp_mean_max
  into eicu_derived.first_day_vitals
  from eicu_derived.pivoted_vital
  where chartoffset <= 1440 AND chartoffset >= 0
  group by patientunitstayid
 