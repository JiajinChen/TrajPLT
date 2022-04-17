with step0 as(
-- 	19272 observation
	select distinct plt_step9_duplicated.subject_id,plt_step9_duplicated.hadm_id,plt_step9_duplicated.stay_id,age,gender,
	plt_step9_duplicated.intime,plt_step9_duplicated.outtime,plt_step9_duplicated.los,admittime,dischtime,deathtime,
	DATETIME_DIFF(deathtime, plt_step9_duplicated.intime, 'DAY') as death_days, 
	DATETIME_DIFF(dischtime, plt_step9_duplicated.intime, 'DAY') as disch_days,
	admission_type,first_careunit,insurance,language,marital_status,ethnicity,hospital_expire_flag
	from plt_step9_duplicated
	left join mimic_icu.icustays icu_stay
	on plt_step9_duplicated.stay_id = icu_stay.stay_id
), step1 as(
	select step0.*,height from step0
	left join mimic_derived.first_day_height he
	on step0.stay_id = he.stay_id
), step2 as(
	select step1.*,weight_admit,weight,weight_min,weight_max
	from step1
	left join mimic_derived.first_day_weight we
	on step1.stay_id = we.stay_id
),step3 as(
	select step2.*,
	lactate_min as bg_lactate_min,lactate_max as bg_lactate_max,ph_min as bg_ph_min,ph_max as bg_ph_max,so2_min as bg_so2_min,so2_max as bg_so2_max,po2_min as bg_po2_min,po2_max as bg_po2_max,pco2_min as bg_pco2_min,pco2_max as bg_pco2_max,aado2_min as bg_aado2_min,aado2_max as bg_aado2_max,aado2_calc_min as bg_aado2_calc_min,aado2_calc_max as bg_aado2_calc_max,pao2fio2ratio_min as bg_pao2fio2ratio_min,pao2fio2ratio_max as bg_pao2fio2ratio_max,baseexcess_min as bg_baseexcess_min,baseexcess_max as bg_baseexcess_max,bicarbonate_min as bg_bicarbonate_min,bicarbonate_max as bg_bicarbonate_max,totalco2_min as bg_totalco2_min,totalco2_max as bg_totalco2_max,hematocrit_min as bg_hematocrit_min,hematocrit_max as bg_hematocrit_max,hemoglobin_min as bg_hemoglobin_min,hemoglobin_max as bg_hemoglobin_max,carboxyhemoglobin_min as bg_carboxyhemoglobin_min,carboxyhemoglobin_max as bg_carboxyhemoglobin_max,methemoglobin_min as bg_methemoglobin_min,methemoglobin_max as bg_methemoglobin_max,temperature_min as bg_temperature_min,temperature_max as bg_temperature_max,chloride_min as bg_chloride_min,chloride_max as bg_chloride_max,calcium_min as bg_calcium_min,calcium_max as bg_calcium_max,glucose_min as bg_glucose_min,glucose_max as bg_glucose_max,potassium_min as bg_potassium_min,potassium_max as bg_potassium_max,sodium_min as bg_sodium_min,sodium_max as bg_sodium_max
	from step2
	left join mimic_derived.first_day_bg bg
	on step2.stay_id = bg.stay_id
),step4 as(
	select step3.*,
	lactate_min as bg_art_lactate_min,lactate_max as bg_art_lactate_max,ph_min as bg_art_ph_min,ph_max as bg_art_ph_max,so2_min as bg_art_so2_min,so2_max as bg_art_so2_max,po2_min as bg_art_po2_min,po2_max as bg_art_po2_max,pco2_min as bg_art_pco2_min,pco2_max as bg_art_pco2_max,aado2_min as bg_art_aado2_min,aado2_max as bg_art_aado2_max,aado2_calc_min as bg_art_aado2_calc_min,aado2_calc_max as bg_art_aado2_calc_max,pao2fio2ratio_min as bg_art_pao2fio2ratio_min,pao2fio2ratio_max as bg_art_pao2fio2ratio_max,baseexcess_min as bg_art_baseexcess_min,baseexcess_max as bg_art_baseexcess_max,bicarbonate_min as bg_art_bicarbonate_min,bicarbonate_max as bg_art_bicarbonate_max,totalco2_min as bg_art_totalco2_min,totalco2_max as bg_art_totalco2_max,hematocrit_min as bg_art_hematocrit_min,hematocrit_max as bg_art_hematocrit_max,hemoglobin_min as bg_art_hemoglobin_min,hemoglobin_max as bg_art_hemoglobin_max,carboxyhemoglobin_min as bg_art_carboxyhemoglobin_min,carboxyhemoglobin_max as bg_art_carboxyhemoglobin_max,methemoglobin_min as bg_art_methemoglobin_min,methemoglobin_max as bg_art_methemoglobin_max,temperature_min as bg_art_temperature_min,temperature_max as bg_art_temperature_max,chloride_min as bg_art_chloride_min,chloride_max as bg_art_chloride_max,calcium_min as bg_art_calcium_min,calcium_max as bg_art_calcium_max,glucose_min as bg_art_glucose_min,glucose_max as bg_art_glucose_max,potassium_min as bg_art_potassium_min,potassium_max as bg_art_potassium_max,sodium_min as bg_art_sodium_min,sodium_max as bg_art_sodium_max
	from step3
	left join mimic_derived.first_day_bg_art bg_art
	on step3.stay_id = bg_art.stay_id
),step5 as(
	select step4.*,
	gcs_min,gcs_motor,gcs_verbal,gcs_eyes,gcs_unable
	from step4
	left join mimic_derived.first_day_gcs gcs
	on step4.stay_id = gcs.stay_id
),step6 as(
	select step5.*,
	hematocrit_min as lab_hematocrit_min,hematocrit_max as lab_hematocrit_max,hemoglobin_min as lab_hemoglobin_min,hemoglobin_max as lab_hemoglobin_max,platelets_min as lab_platelets_min,platelets_max as lab_platelets_max,wbc_min as lab_wbc_min,wbc_max as lab_wbc_max,albumin_min as lab_albumin_min,albumin_max as lab_albumin_max,globulin_min as lab_globulin_min,globulin_max as lab_globulin_max,total_protein_min as lab_total_protein_min,total_protein_max as lab_total_protein_max,aniongap_min as lab_aniongap_min,aniongap_max as lab_aniongap_max,bicarbonate_min as lab_bicarbonate_min,bicarbonate_max as lab_bicarbonate_max,bun_min as lab_bun_min,bun_max as lab_bun_max,calcium_min as lab_calcium_min,calcium_max as lab_calcium_max,chloride_min as lab_chloride_min,chloride_max as lab_chloride_max,creatinine_min as lab_creatinine_min,creatinine_max as lab_creatinine_max,glucose_min as lab_glucose_min,glucose_max as lab_glucose_max,sodium_min as lab_sodium_min,sodium_max as lab_sodium_max,potassium_min as lab_potassium_min,potassium_max as lab_potassium_max,basophils_abs_min as lab_basophils_abs_min,basophils_abs_max as lab_basophils_abs_max,eosinophils_abs_min as lab_eosinophils_abs_min,eosinophils_abs_max as lab_eosinophils_abs_max,lymphocytes_abs_min as lab_lymphocytes_abs_min,lymphocytes_abs_max as lab_lymphocytes_abs_max,monocytes_abs_min as lab_monocytes_abs_min,monocytes_abs_max as lab_monocytes_abs_max,neutrophils_abs_min as lab_neutrophils_abs_min,neutrophils_abs_max as lab_neutrophils_abs_max,atyps_min as lab_atyps_min,atyps_max as lab_atyps_max,bands_min as lab_bands_min,bands_max as lab_bands_max,imm_granulocytes_min as lab_imm_granulocytes_min,imm_granulocytes_max as lab_imm_granulocytes_max,metas_min as lab_metas_min,metas_max as lab_metas_max,nrbc_min as lab_nrbc_min,nrbc_max as lab_nrbc_max,d_dimer_min as lab_d_dimer_min,d_dimer_max as lab_d_dimer_max,fibrinogen_min as lab_fibrinogen_min,fibrinogen_max as lab_fibrinogen_max,thrombin_min as lab_thrombin_min,thrombin_max as lab_thrombin_max,inr_min as lab_inr_min,inr_max as lab_inr_max,pt_min as lab_pt_min,pt_max as lab_pt_max,ptt_min as lab_ptt_min,ptt_max as lab_ptt_max,alt_min as lab_alt_min,alt_max as lab_alt_max,alp_min as lab_alp_min,alp_max as lab_alp_max,ast_min as lab_ast_min,ast_max as lab_ast_max,amylase_min as lab_amylase_min,amylase_max as lab_amylase_max,bilirubin_total_min as lab_bilirubin_total_min,bilirubin_total_max as lab_bilirubin_total_max,bilirubin_direct_min as lab_bilirubin_direct_min,bilirubin_direct_max as lab_bilirubin_direct_max,bilirubin_indirect_min as lab_bilirubin_indirect_min,bilirubin_indirect_max as lab_bilirubin_indirect_max,ck_cpk_min as lab_ck_cpk_min,ck_cpk_max as lab_ck_cpk_max,ck_mb_min as lab_ck_mb_min,ck_mb_max as lab_ck_mb_max,ggt_min as lab_ggt_min,ggt_max as lab_ggt_max,ld_ldh_min as lab_ld_ldh_min,ld_ldh_max as lab_ld_ldh_max
	from step5
	left join mimic_derived.first_day_lab lab
	on step5.stay_id = lab.stay_id
),step7 as(
	select step6.*,
	dialysis_present as rrt_dialysis_present,dialysis_active as rrt_dialysis_active,dialysis_type as rrt_dialysis_type
	from step6
	left join mimic_derived.first_day_rrt rrt
	on step6.stay_id = rrt.stay_id
), step8 as(
	select step7.*,
	sofa as sofa_sofa,respiration as sofa_respiration,coagulation as sofa_coagulation,liver as sofa_liver,cardiovascular as sofa_cardiovascular,cns as sofa_cns,renal as sofa_renal
	from step7
	left join mimic_derived.first_day_sofa sofa
	on step7.stay_id = sofa.stay_id
),step9 as(
	select step8.*,
	urineoutput 
	from step8
	left join mimic_derived.first_day_urine_output urine
	on step8.stay_id = urine.stay_id
),step10 as(
	select step9.*,
	heart_rate_min as vital_heart_rate_min,heart_rate_max as vital_heart_rate_max,heart_rate_mean as vital_heart_rate_mean,sbp_min as vital_sbp_min,sbp_max as vital_sbp_max,sbp_mean as vital_sbp_mean,dbp_min as vital_dbp_min,dbp_max as vital_dbp_max,dbp_mean as vital_dbp_mean,mbp_min as vital_mbp_min,mbp_max as vital_mbp_max,mbp_mean as vital_mbp_mean,resp_rate_min as vital_resp_rate_min,resp_rate_max as vital_resp_rate_max,resp_rate_mean as vital_resp_rate_mean,temperature_min as vital_temperature_min,temperature_max as vital_temperature_max,temperature_mean as vital_temperature_mean,spo2_min as vital_spo2_min,spo2_max as vital_spo2_max,spo2_mean as vital_spo2_mean,glucose_min as vital_glucose_min,glucose_max as vital_glucose_max,glucose_mean as vital_glucose_mean
	from step9
	left join mimic_derived.first_day_vitalsign vital
	on step9.stay_id = vital.stay_id
),step11 as(
	select step10.*,
	age_score as charlson_age_score,myocardial_infarct as charlson_myocardial_infarct,congestive_heart_failure as charlson_congestive_heart_failure,peripheral_vascular_disease as charlson_peripheral_vascular_disease,cerebrovascular_disease as charlson_cerebrovascular_disease,dementia as charlson_dementia,chronic_pulmonary_disease as charlson_chronic_pulmonary_disease,rheumatic_disease as charlson_rheumatic_disease,peptic_ulcer_disease as charlson_peptic_ulcer_disease,mild_liver_disease as charlson_mild_liver_disease,diabetes_without_cc as charlson_diabetes_without_cc,diabetes_with_cc as charlson_diabetes_with_cc,paraplegia as charlson_paraplegia,renal_disease as charlson_renal_disease,malignant_cancer as charlson_malignant_cancer,severe_liver_disease as charlson_severe_liver_disease,metastatic_solid_tumor as charlson_metastatic_solid_tumor,aids as charlson_aids,charlson_comorbidity_index as charlson_charlson_comorbidity_index
	from step10
	left join mimic_derived.comorbidity_charlson charlson
	on step10.subject_id = charlson.subject_id AND step10.hadm_id = charlson.hadm_id
),step12 as(
	select step11.*,
	apsiii.apsiii as apsiii_apsiii,apsiii.apsiii_prob as apsiii_apsiii_prob,apsiii.hr_score as apsiii_hr_score,apsiii.mbp_score as apsiii_mbp_score,apsiii.temp_score as apsiii_temp_score,apsiii.resp_rate_score as apsiii_resp_rate_score,apsiii.pao2_aado2_score as apsiii_pao2_aado2_score,apsiii.hematocrit_score as apsiii_hematocrit_score,apsiii.wbc_score as apsiii_wbc_score,apsiii.creatinine_score as apsiii_creatinine_score,apsiii.uo_score as apsiii_uo_score,apsiii.bun_score as apsiii_bun_score,apsiii.sodium_score as apsiii_sodium_score,apsiii.albumin_score as apsiii_albumin_score,apsiii.bilirubin_score as apsiii_bilirubin_score,apsiii.glucose_score as apsiii_glucose_score,apsiii.acidbase_score as apsiii_acidbase_score,apsiii.gcs_score as apsiii_gcs_score,
	lods.lods as lods_lods,lods.neurologic as lods_neurologic,lods.cardiovascular as lods_cardiovascular,lods.renal as lods_renal,lods.pulmonary as lods_pulmonary,lods.hematologic as lods_hematologic,lods.hepatic as lods_hepatic,
	sapsii.starttime as sapsii_starttime,sapsii.endtime as sapsii_endtime,sapsii.sapsii as sapsii_sapsii,sapsii.sapsii_prob as sapsii_sapsii_prob,sapsii.age_score as sapsii_age_score,sapsii.hr_score as sapsii_hr_score,sapsii.sysbp_score as sapsii_sysbp_score,sapsii.temp_score as sapsii_temp_score,sapsii.pao2fio2_score as sapsii_pao2fio2_score,sapsii.uo_score as sapsii_uo_score,sapsii.bun_score as sapsii_bun_score,sapsii.wbc_score as sapsii_wbc_score,sapsii.potassium_score as sapsii_potassium_score,sapsii.sodium_score as sapsii_sodium_score,sapsii.bicarbonate_score as sapsii_bicarbonate_score,sapsii.bilirubin_score as sapsii_bilirubin_score,sapsii.gcs_score as sapsii_gcs_score,sapsii.comorbidity_score as sapsii_comorbidity_score,sapsii.admissiontype_score as sapsii_admissiontype_score,
	sirs.sirs as sirs_sirs,sirs.temp_score as sirs_temp_score,sirs.heart_rate_score as sirs_heart_rate_score,sirs.resp_score as sirs_resp_score,sirs.wbc_score as sirs_wbc_score
	from step11
	left join mimic_derived.apsiii apsiii
	on step11.stay_id = apsiii.stay_id
	left join mimic_derived.lods lods
	on step11.stay_id = lods.stay_id
	left join mimic_derived.sapsii sapsii
	on step11.stay_id = sapsii.stay_id
	left join mimic_derived.sirs sirs
	on step11.stay_id = sirs.stay_id
),step13 as(
	select step12.*,
	oasis.oasis as oasis_oasis,oasis.oasis_prob as oasis_oasis_prob,oasis.age as oasis_age,oasis.age_score as oasis_age_score,oasis.preiculos as oasis_preiculos,oasis.preiculos_score as oasis_preiculos_score,oasis.gcs as oasis_gcs,oasis.gcs_score as oasis_gcs_score,oasis.heartrate as oasis_heartrate,oasis.heart_rate_score as oasis_heart_rate_score,oasis.meanbp as oasis_meanbp,oasis.mbp_score as oasis_mbp_score,oasis.resprate as oasis_resprate,oasis.resp_rate_score as oasis_resp_rate_score,oasis.temp as oasis_temp,oasis.temp_score as oasis_temp_score,oasis.urineoutput as oasis_urineoutput,oasis.urineoutput_score as oasis_urineoutput_score,oasis.mechvent as oasis_mechvent,oasis.mechvent_score as oasis_mechvent_score,oasis.electivesurgery as oasis_electivesurgery,oasis.electivesurgery_score as oasis_electivesurgery_score
	from step12
	left join mimic_derived.oasis oasis
	on step12.stay_id = oasis.stay_id
),step14 as (
-- 	Treatment
	SELECT step13.*,
	--ventilation
	case when step13.stay_id in (select distinct vent.stay_id from mimic_derived.ventilation vent
							left join mimic_derived.icu_detail icu
							on vent.stay_id = icu.stay_id
							where ventilation_status in ('InvasiveVent')
								 AND DATETIME_DIFF(starttime, icu_intime, 'DAY') <= 1
								 AND DATETIME_DIFF(starttime, icu_intime, 'HOUR') >= -6
						   )
	then 1 ELSE 0 END AS vent_invasive,
	--dialysis
	case when step13.stay_id in (select distinct stay_id from mimic_derived.first_day_rrt 
								 where dialysis_present = 1)
	then 1 ELSE 0 END AS dialysis,
	--vasopression
	case when step13.stay_id in (select distinct vaso.stay_id from mimic_derived.vasopressin vaso
						left join mimic_derived.icu_detail icu
						on vaso.stay_id = icu.stay_id
						where DATETIME_DIFF(starttime, icu_intime, 'DAY') <= 1
								 AND DATETIME_DIFF(starttime, icu_intime, 'HOUR') >= -6
						)
	then 1 ELSE 0 END AS vasopression	
	FROM step13
),step15 as(
	select step14.*,
-- 	Sepsis
	case when step14.stay_id IN (
		select stay.stay_id from mimic_derived.sepsis3 sepsis_ds
		left join mimic_icu.icustays stay
		on sepsis_ds.stay_id = stay.stay_id
-- 		Time for the occurrence of both SOFA >= 2 AND suspected_infection
		where greatest(sofa_time,suspected_infection_time) >= intime - interval '6' HOUR
		AND greatest(sofa_time,suspected_infection_time) <= intime + interval '1' DAY
		AND stay.stay_id IN (select distinct(stay_id) from plt_step9_duplicated)
-- 		where sofa_time >= intime
-- 		AND sofa_time <= intime + interval '1' DAY
-- 		AND suspected_infection_time >= intime
-- 		AND suspected_infection_time <= intime + interval '1' DAY
	) then 1 else 0 END as Sepsis	
	from step14
)

select * into Covar_MIMIC_plt from step15

