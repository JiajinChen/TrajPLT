DROP TABLE IF EXISTS eicu_derived.first_day_vitals_other CASCADE;

  select patientunitstayid
  , min(pasystolic) as pasystolic_min
  , max(pasystolic) as pasystolic_max
  , min(padiastolic) as padiastolic_min
  , max(padiastolic) as padiastolic_max
  , min(pamean) as pamean_min
  , max(pamean) as pamean_max
  , min(sv) as sv_min
  , max(sv) as sv_max
  , min(co) as co_min
  , max(co) as co_max
  , min(svr) as svr_min
  , max(svr) as svr_max
  , min(icp) as icp_min
  , max(icp) as icp_max
  , min(ci) as ci_min
  , max(ci) as ci_max
  , min(svri) as svri_min
  , max(svri) as svri_max
  , min(cpp) as cpp_min
  , max(cpp) as cpp_max
  , min(svo2) as svo2_min
  , max(svo2) as svo2_max
  , min(paop) as paop_min
  , max(paop) as paop_max
  , min(pvr) as pvr_min
  , max(pvr) as pvr_max
  , min(pvri) as pvri_min
  , max(pvri) as pvri_max
  , min(iap) as iap_min
  , max(iap) as iap_max
  into eicu_derived.first_day_vitals_other
  from eicu_derived.pivoted_vital_other
  where chartoffset <= 1440  AND chartoffset >= 0
  group by patientunitstayid
