with step0_a as (
	SELECT * FROM eicu_derived.icustay_detail  -- 200859
	where unitvisitnumber = 1 --200859 - 158442 = 42417
), step0_b as (	
	select uniquepid, count(uniquepid) as count_id from step0_a
	group by uniquepid
), step0_c as (
	select * from step0_a -- 158442 - 115929 = 42513
	where uniquepid in (
		select uniquepid from step0_b
		where count_id = 1
	)
)
, step0 as (
	SELECT * FROM step0_c
	where NULLIF(regexp_replace(age, '\D','','g'), '')::numeric >= 18 --115929 - 115450 = 479
 	AND icu_los_hours >= 72 --115450-28175 = 87275
)
-- select * from step0
-- ,step0_1 as (
-- 	select step0.*, patient.hospitaldischargeoffset
-- 	from step0
-- 	left join eicu.patient patient
-- 	on step0.patientunitstayid = patient.patientunitstayid
,step1 as(
	SELECT patientunitstayid, trunc(chartoffset/1440.0) as day_index,platelets 
	FROM eicu_derived.pivoted_lab lab
	where platelets is not null
), step2 as(
	SELECT patientunitstayid, day_index, cast(min(platelets) AS numeric(10,0)) as min_PLT,
	cast(max(platelets) AS numeric(10,0)) as max_PLT, cast(avg(platelets) AS numeric(10,2)) as avg_PLT
	FROM step1
	where day_index >= 0 
	group by patientunitstayid, day_index
), step3 as(
	select * from step2
	where patientunitstayid IN (
		select distinct(patientunitstayid) from step2
		where day_index <= 3
		group by patientunitstayid
		having count(day_index) >= 4 -- 28175 - 19361 = 8814
	)
), step4 as(
	select step0.*, day_index, min_PLT, max_PLT, avg_PLT
	from step0
	join step3
	on step0.patientunitstayid = step3.patientunitstayid
)
-- select count(distinct patientunitstayid) from step4

select * into Data_eicu_PLT from step4