with step_id as (
	select distinct plt.uniquepid,plt.patienthealthsystemstayid,plt.patientunitstayid,plt.unitvisitnumber,plt.hospitalid,
	unitadmitsource
	from public.eicu_plt_duplicated plt
	left join eicu.patient pat
	on plt.patientunitstayid = pat.patientunitstayid
), step1 as(
	select step_id.*,
	region,unittype,hospitaladmitoffset,hospitaldischargeoffset,unitadmitoffset,
	unitdischargeoffset,apache_iv,hospitaldischargeyear,age,hosp_mort,gender,ethnicity,admissionheight,
	admissionweight,dischargeweight,icu_los_hours	
	from step_id
	left join eicu_derived.icustay_detail as icu
	on step_id.patientunitstayid = icu.patientunitstayid
), step2 as(
	select step1.*,apacheadmissiondx,hosp_mortality
	from step1
	left join eicu_derived.demographics as demo
	on step1.patientunitstayid = demo.patientunitstayid
),step3 as(
	select step2.*,
	albumin_min as first_day_lab_albumin_min,albumin_max as first_day_lab_albumin_max,bilirubin_min as first_day_lab_bilirubin_min,bilirubin_max as first_day_lab_bilirubin_max,bun_min as first_day_lab_bun_min,bun_max as first_day_lab_bun_max,calcium_min as first_day_lab_calcium_min,calcium_max as first_day_lab_calcium_max,chloride_min as first_day_lab_chloride_min,chloride_max as first_day_lab_chloride_max,creatinine_min as first_day_lab_creatinine_min,creatinine_max as first_day_lab_creatinine_max,glucose_min as first_day_lab_glucose_min,glucose_max as first_day_lab_glucose_max,bicarbonate_min as first_day_lab_bicarbonate_min,bicarbonate_max as first_day_lab_bicarbonate_max,totalco2_min as first_day_lab_totalco2_min,totalco2_max as first_day_lab_totalco2_max,hematocrit_min as first_day_lab_hematocrit_min,hematocrit_max as first_day_lab_hematocrit_max,hemoglobin_min as first_day_lab_hemoglobin_min,hemoglobin_max as first_day_lab_hemoglobin_max,inr_min as first_day_lab_inr_min,inr_max as first_day_lab_inr_max,lactate_min as first_day_lab_lactate_min,lactate_max as first_day_lab_lactate_max,platelets_min as first_day_lab_platelets_min,platelets_max as first_day_lab_platelets_max,potassium_min as first_day_lab_potassium_min,potassium_max as first_day_lab_potassium_max,ptt_min as first_day_lab_ptt_min,ptt_max as first_day_lab_ptt_max,sodium_min as first_day_lab_sodium_min,sodium_max as first_day_lab_sodium_max,wbc_min as first_day_lab_wbc_min,wbc_max as first_day_lab_wbc_max,bands_min as first_day_lab_bands_min,bands_max as first_day_lab_bands_max,alt_min as first_day_lab_alt_min,alt_max as first_day_lab_alt_max,ast_min as first_day_lab_ast_min,ast_max as first_day_lab_ast_max,alp_min as first_day_lab_alp_min,alp_max as first_day_lab_alp_max
	from step2
	left join eicu_derived.first_day_lab as lab
	on step2.patientunitstayid = lab.patientunitstayid
),step4 as(
	select step3.*,
	heartrate_min as first_day_vitals_heartrate_min,heartrate_max as first_day_vitals_heartrate_max,respiratoryrate_min as first_day_vitals_respiratoryrate_min,respiratoryrate_max as first_day_vitals_respiratoryrate_max,spo2_min as first_day_vitals_spo2_min,spo2_max as first_day_vitals_spo2_max,nibp_systolic_min as first_day_vitals_nibp_systolic_min,nibp_systolic_max as first_day_vitals_nibp_systolic_max,nibp_diastolic_min as first_day_vitals_nibp_diastolic_min,nibp_diastolic_max as first_day_vitals_nibp_diastolic_max,nibp_mean_min as first_day_vitals_nibp_mean_min,nibp_mean_max as first_day_vitals_nibp_mean_max,temperature_min as first_day_vitals_temperature_min,temperature_max as first_day_vitals_temperature_max,ibp_systolic_min as first_day_vitals_ibp_systolic_min,ibp_systolic_max as first_day_vitals_ibp_systolic_max,ibp_diastolic_min as first_day_vitals_ibp_diastolic_min,ibp_diastolic_max as first_day_vitals_ibp_diastolic_max,ibp_mean_min as first_day_vitals_ibp_mean_min,ibp_mean_max as first_day_vitals_ibp_mean_max
	from step3
	left join eicu_derived.first_day_vitals as vital
	on step3.patientunitstayid = vital.patientunitstayid
),step5 as(
	select step4.*,
	pasystolic_min as first_day_vitals_other_pasystolic_min,pasystolic_max as first_day_vitals_other_pasystolic_max,padiastolic_min as first_day_vitals_other_padiastolic_min,padiastolic_max as first_day_vitals_other_padiastolic_max,pamean_min as first_day_vitals_other_pamean_min,pamean_max as first_day_vitals_other_pamean_max,sv_min as first_day_vitals_other_sv_min,sv_max as first_day_vitals_other_sv_max,co_min as first_day_vitals_other_co_min,co_max as first_day_vitals_other_co_max,svr_min as first_day_vitals_other_svr_min,svr_max as first_day_vitals_other_svr_max,icp_min as first_day_vitals_other_icp_min,icp_max as first_day_vitals_other_icp_max,ci_min as first_day_vitals_other_ci_min,ci_max as first_day_vitals_other_ci_max,svri_min as first_day_vitals_other_svri_min,svri_max as first_day_vitals_other_svri_max,cpp_min as first_day_vitals_other_cpp_min,cpp_max as first_day_vitals_other_cpp_max,svo2_min as first_day_vitals_other_svo2_min,svo2_max as first_day_vitals_other_svo2_max,paop_min as first_day_vitals_other_paop_min,paop_max as first_day_vitals_other_paop_max,pvr_min as first_day_vitals_other_pvr_min,pvr_max as first_day_vitals_other_pvr_max,pvri_min as first_day_vitals_other_pvri_min,pvri_max as first_day_vitals_other_pvri_max,iap_min as first_day_vitals_other_iap_min,iap_max as first_day_vitals_other_iap_max
	from step4
	left join eicu_derived.first_day_vitals_other as vital_other
	on step4.patientunitstayid = vital_other.patientunitstayid
),step6 as(
	select step5.*,
	pao2_min as first_day_bg_pao2_min,pao2_max as first_day_bg_pao2_max,fio2_min as first_day_bg_fio2_min,fio2_max as first_day_bg_fio2_max,pao2fio2_min as first_day_bg_pao2fio2_min,pao2fio2_max as first_day_bg_pao2fio2_max,paco2_min as first_day_bg_paco2_min,paco2_max as first_day_bg_paco2_max,ph_min as first_day_bg_ph_min,ph_max as first_day_bg_ph_max,aniongap_min as first_day_bg_aniongap_min,aniongap_max as first_day_bg_aniongap_max,basedeficit_min as first_day_bg_basedeficit_min,basedeficit_max as first_day_bg_basedeficit_max,baseexcess_min as first_day_bg_baseexcess_min,baseexcess_max as first_day_bg_baseexcess_max,peep_min as first_day_bg_peep_min,peep_max as first_day_bg_peep_max
	from step5
	left join eicu_derived.first_day_bg as bg
	on step5.patientunitstayid = bg.patientunitstayid
),step7 as(
	select step6.*,
	gcs_min as first_day_gcs_gcs_min,gcs_max as first_day_gcs_gcs_max,gcsmotor_min as first_day_gcs_gcsmotor_min,gcsmotor_max as first_day_gcs_gcsmotor_max,gcsverbal_min as first_day_gcs_gcsverbal_min,gcsverbal_max as first_day_gcs_gcsverbal_max,gcseyes_min as first_day_gcs_gcseyes_min,gcseyes_max as first_day_gcs_gcseyes_max
	from step6
	left join eicu_derived.first_day_gcs as bg
	on step6.patientunitstayid = bg.patientunitstayid
),step8 as(
	select step7.*,
	sofa_cv as first_day_sofa_oxy_sofa_cv,sofa_respi as first_day_sofa_oxy_sofa_respi,sofarenal as first_day_sofa_oxy_sofarenal,sofacoag as first_day_sofa_oxy_sofacoag,sofaliver as first_day_sofa_oxy_sofaliver,sofacns as first_day_sofa_oxy_sofacns,sofatotal as first_day_sofa_oxy_sofatotal
	from step7
	left join eicu_derived.first_day_sofa_oxy as sofa
	on step7.patientunitstayid = sofa.patientunitstayid
),
step9 as(
	select step8.*,
	age_score as charlson_pasthistory_age_score,myocardial_infarct as charlson_pasthistory_myocardial_infarct,congestive_heart_failure as charlson_pasthistory_congestive_heart_failure,peripheral_vascular_disease as charlson_pasthistory_peripheral_vascular_disease,cerebrovascular_disease as charlson_pasthistory_cerebrovascular_disease,dementia as charlson_pasthistory_dementia,chronic_pulmonary_disease as charlson_pasthistory_chronic_pulmonary_disease,rheumatic_disease as charlson_pasthistory_rheumatic_disease,peptic_ulcer_disease as charlson_pasthistory_peptic_ulcer_disease,mild_liver_disease as charlson_pasthistory_mild_liver_disease,diabetes_without_cc as charlson_pasthistory_diabetes_without_cc,diabetes_with_cc as charlson_pasthistory_diabetes_with_cc,diabetes_all as charlson_pasthistory_diabetes_all,paraplegia as charlson_pasthistory_paraplegia,renal_disease as charlson_pasthistory_renal_disease,malignant_cancer as charlson_pasthistory_malignant_cancer,severe_liver_disease as charlson_pasthistory_severe_liver_disease,metastatic_solid_tumor as charlson_pasthistory_metastatic_solid_tumor,aids as charlson_pasthistory_aids,charlson_comorbidity_index as charlson_pasthistory_charlson_comorbidity_index
	from step8
	left join eicu_derived.comorbidity_charlson_pasthistory as charlson
	on step8.patientunitstayid = charlson.patientunitstayid
),step10 as(
	select step9.*,
	(
		step9.patientunitstayid IN
		(select patientunitstayid from eicu_derived.pivoted_treatment_vasopressor
		where chartoffset <= 1440 AND chartoffset >= -60*6)
	)::int as VASOPRESSOR
	from step9
),step11 as(
	select step10.*,
	case when oOBventDay1 = 1 AND oOBIntubDay1 = 1 then 1 else 0 end as vent_invasive,dialysis
	from step10
	left join eicu.apachepredvar as apacheiv
	on step10.patientunitstayid = apacheiv.patientunitstayid
	left join eicu.apacheApsVar as apache
	on step10.patientunitstayid = apache.patientunitstayid
), step_temp as (
	select patientunitstayid,max(acutePhysiologyScore) as acutePhysiologyScore from eicu.apachePatientResult
	group by patientunitstayid
),step12 as(
	select step11.*,
	acutePhysiologyScore as APS
	from step11
	left join step_temp as APS
	on step11.patientunitstayid = APS.patientunitstayid
),step13 as(
	select step12.*,
	case when step12.patientunitstayid IN (
		(
			select patientunitstayid from eicu_derived.apache_groups
			where apachedxgroup = 'Sepsis'
		)
		union all
		(
			select distinct patientunitstayid from eicu.diagnosis_uni
			where diagnosisoffset <= 1440 AND 
			diagnosisoffset >= -60*6 AND 
			(SUBSTR(icd9code_uni, 1, 5) IN ('038.9')
			 OR SUBSTR(icd9code_uni, 1, 6) IN ('995.92','785.52')

			 OR SUBSTR(icd9code_uni, 1, 5) IN ('A41.9')
			 OR SUBSTR(icd9code_uni, 1, 6) IN ('R65.20','R65.21'))
		)
	) then 1 else 0 END as Sepsis	
	from step12
)
select * into Covar_eicu_plt from step13

