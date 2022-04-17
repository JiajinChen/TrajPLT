with step0 as (
	SELECT 	
		ad.subject_id
		, ad.hadm_id
-- 		, DATETIME_DIFF(ad.admittime, DATETIME(pa.anchor_year, 1, 1, 0, 0, 0), 'YEAR') + pa.anchor_age AS age
		, pa.gender
		, ad.admittime
		, ad.dischtime
		, ad.deathtime
		, pa.dod
		, pa.anchor_age
		, pa.anchor_year
		, ad.admission_type
		, ad.admission_location
		, ad.discharge_location
		, ad.insurance
		, ad.language
		, ad.marital_status
		, ad.ethnicity
		, ad.edregtime
		, ad.edouttime
		, ad.hospital_expire_flag
	FROM mimiciv.mimic_core.admissions ad
	INNER JOIN mimiciv.mimic_core.patients pa
	ON ad.subject_id = pa.subject_id
-- 	where DATETIME_DIFF(ad.admittime, DATETIME(pa.anchor_year, 1, 1, 0, 0, 0), 'YEAR') + pa.anchor_age >= 18
	order by ad.subject_id,ad.admittime
-- 	523740 hospitation 
), step0_1 as (
	select step0.*,icu_stay.stay_id,icu_stay.intime,icu_stay.outtime,
	DATETIME_DIFF(icu_stay.intime, DATETIME(step0.anchor_year, 1, 1, 0, 0, 0), 'YEAR') + step0.anchor_age AS age,
	icu_stay.los
	from step0
	right join mimic_icu.icustays icu_stay
	on step0.subject_id = icu_stay.subject_id AND step0.hadm_id = icu_stay.hadm_id
-- 	76540 ICU admission
)
,step1 as (
	select * from step0_1
	where age >= 18
-- 	Keep Age >= 18: 76540 - 76540 = 0
-- 	All ICU admission Age >= 18
),step1_2 as (
	select * from step1
	order by subject_id, intime
),step2 as (
	select distinct on(subject_id) * from step1_2
-- 	Drop duplicated admission: 76540 - 53150  = 23390
)
,step3 as (
	select * from step2
	where los > 3
-- 	Drop ICU-stay < 72h: 53150 - 16186 = 36964
)
-- select * from step3
,step4 as (
	select step3.subject_id,step3.hadm_id,step3.stay_id,step3.intime,hosp_event.itemid,hosp_event.charttime,hosp_event.valuenum
	from step3
	left join mimic_hosp.labevents hosp_event
	on step3.subject_id = hosp_event.subject_id AND step3.hadm_id = hosp_event.hadm_id	
	where itemid = '51265' AND valuenum is not null AND valuenum != 999999
),
step5 as (
	select step3.subject_id,step3.hadm_id,step3.stay_id,step3.intime,icu_event.itemid,icu_event.charttime,icu_event.valuenum
	from step3
	left join mimic_icu.chartevents icu_event
	on step3.subject_id = icu_event.subject_id AND step3.hadm_id = icu_event.hadm_id AND step3.stay_id = icu_event.stay_id	
	where itemid = '227457' AND valuenum is not null AND valuenum != 999999
),
step6 as (
	select *, trunc(DATETIME_DIFF(step4.charttime, step4.intime, 'DAY')) as Day_index from step4
	union
	select *, trunc(DATETIME_DIFF(step5.charttime, step5.intime, 'DAY')) as Day_index from step5
	order by subject_id, hadm_id, stay_id
),
step7 as (
	select subject_id,hadm_id,stay_id,day_index,min(valuenum) as min_PLT, max(valuenum) as max_PLT, avg(valuenum) as avg_PLT
	from step6
	where day_index >= -2
	group by subject_id,hadm_id,stay_id,day_index	
),
step8 as (
	select step3.*,day_index,min_PLT,max_PLT,avg_PLT
	from step3
	right join step7	
	on step3.subject_id = step7.subject_id AND step3.hadm_id = step7.hadm_id AND step3.stay_id = step7.stay_id
	order by subject_id,hadm_id,stay_id,day_index
),
step9 as (
	select * from step8
	where subject_id in (
		select subject_id from step8
		where day_index <= 3 AND day_index >= 0
		group by subject_id,hadm_id,stay_id
		having count(day_index) >= 4
	)
)

select * into Data_ana_MIMIC from step9

select * into Data_MIMIC_plt from PLT_step8_duplicated
where subject_id in (
		select subject_id from PLT_step8_duplicated
		where day_index <= 3 AND day_index >= 0
		group by subject_id,hadm_id,stay_id
		having count(day_index) >= 4
	)

