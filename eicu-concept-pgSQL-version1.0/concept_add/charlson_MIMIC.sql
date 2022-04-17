-- ------------------------------------------------------------------
-- This query extracts Charlson Comorbidity Index (CCI) based on the recorded ICD-9 and ICD-10 codes.
--
-- Reference for CCI:
-- (1) Charlson ME, Pompei P, Ales KL, MacKenzie CR. (1987) A new method of classifying prognostic 
-- comorbidity in longitudinal studies: development and validation.J Chronic Dis; 40(5):373-83.
--
-- (2) Charlson M, Szatrowski TP, Peterson J, Gold J. (1994) Validation of a combined comorbidity 
-- index. J Clin Epidemiol; 47(11):1245-51.
-- 
-- Reference for ICD-9-CM and ICD-10 Coding Algorithms for Charlson Comorbidities:
-- (3) Quan H, Sundararajan V, Halfon P, et al. Coding algorithms for defining Comorbidities in ICD-9-CM
-- and ICD-10 administrative data. Med Care. 2005 Nov; 43(11): 1130-9.
-- ------------------------------------------------------------------
-- create table eicu.diagnosis_uni AS
-- (
--     (SELECT *,TRIM(unnest(string_to_array(icd9code,','))) as icd9code_uni
--     FROM eicu.diagnosis
-- 	where icd9code <> '')
-- 	union ALL
-- 	(SELECT *,TRIM(icd9code) as icd9code_uni FROM eicu.diagnosis
-- 	where icd9code = '')
-- )

with com AS
(
    SELECT
        icu.patientunitstayid

        -- Myocardial infarction
        , MAX(CASE WHEN
            SUBSTR(icd9code_uni, 1, 3) IN ('410','412')
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('I21','I22')
            OR
            SUBSTR(icd9code_uni, 1, 5) = 'I25.2'
			-- From pasthistory
			OR mi1 = 1
-- 			OR
-- 			diagnosisstring IN ('cardiovascular|diseases of the aorta|aortic dissection|with myocardial infarction',
-- 								'cardiovascular|shock / hypotension|cardiogenic shock|due to myocardial infarction')
			THEN 1 
            ELSE 0 END) AS myocardial_infarct
	
		-- Congestive heart failure
        , MAX(CASE WHEN
            SUBSTR(icd9code_uni, 1, 3) = '428'
            OR
            SUBSTR(icd9code_uni, 1, 6) IN ('398.91','402.01','402.11','402.91','404.01','404.03',
                          '404.11','404.13','404.91','404.93')
            OR 
            SUBSTR(icd9code_uni, 1, 5) BETWEEN '425.4' AND '425.9'
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('I43','I50')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('I09.9','I11.0','I13.0','I13.2','I25.5','I42.0',
                                                   'I42.5','I42.6','I42.7','I42.8','I42.9','P29.0')
			-- From pasthistory
			OR chf1 = 1
-- 			OR
-- 			diagnosisstring IN ('cardiovascular|ventricular disorders|congestive heart failure|left-sided|EF < 25%',
-- 								'cardiovascular|ventricular disorders|congestive heart failure|left-sided|EF 25-40%',
-- 							   'endocrine|fluids and electrolytes|hyponatremia|due to congestive heart failure',
-- 							   'renal|electrolyte imbalance|hyponatremia|due to congestive heart failure',
-- 							   'endocrine|fluids and electrolytes|hyponatremia|due to congestive heart failure',
-- 							   'renal|electrolyte imbalance|hyponatremia|due to congestive heart failure',
-- 							   'cardiovascular|ventricular disorders|congestive heart failure|cor pulmonale|acute',
-- 							   'cardiovascular|ventricular disorders|congestive heart failure|cor pulmonale|chronic')			
            THEN 1 
            ELSE 0 END) AS congestive_heart_failure
	
		-- Peripheral vascular disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('440','441')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('093.0','437.3','447.1','557.1','557.9','V43.4')
            OR
            SUBSTR(icd9code_uni, 1, 5) BETWEEN '443.1' AND '443.9'
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('I70','I71')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('I73.1','I73.8','I73.9','I77.1','I79.0',
                                                   'I79.2','K55.1','K55.8','K55.9','Z95.8','Z95.9')
			-- From pasthistory
			OR pvd1 = 1
			
-- 			OR
-- 			diagnosisstring IN ('cardiovascular|vascular disorders|peripheral vascular ischemia')			
            THEN 1 
            ELSE 0 END) AS peripheral_vascular_disease
	
		-- Cerebrovascular disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN '430' AND '438'
            OR
            SUBSTR(icd9code_uni, 1, 6) = '362.34'
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('G45','G46')
            OR 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'I60' AND 'I69'
            OR
            SUBSTR(icd9code_uni, 1, 5) = 'H34.0'
			  
			-- From pasthistory
			OR tia1 = 1 OR stroke2 = 1
			  
            THEN 1 
            ELSE 0 END) AS cerebrovascular_disease
	
		-- Dementia
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) = '290'
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('294.1','331.2')
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('F00','F01','F02','F03','G30')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('F05.1','G31.1')
			  			
			-- From pasthistory
			OR dementia1 = 1
			  
            THEN 1 
            ELSE 0 END) AS dementia
	
		-- Chronic pulmonary disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN '490' AND '505'
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('416.8','416.9','506.4','508.1','508.8')
            OR 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'J40' AND 'J47'
            OR 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'J60' AND 'J67'
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('I27.8','I27.9','J68.4','J70.1','J70.3')
			  
			-- From pasthistory
			OR copd1 = 1
			  
            THEN 1 
            ELSE 0 END) AS chronic_pulmonary_disease
	
		-- Rheumatic disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) = '725'
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('446.5','710.0','710.1','710.2','710.3',
                                                  '710.4','714.0','714.1','714.2','714.8')
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('M05','M06','M32','M33','M34')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('M31.5','M35.1','M35.3','M36.0')
			  			
			-- From pasthistory
			OR ctd1 = 1
			  
            THEN 1 
            ELSE 0 END) AS rheumatic_disease
	
		-- Peptic ulcer disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('531','532','533','534')
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('K25','K26','K27','K28')
			  
			-- From pasthistory
			OR pud1 = 1
			  
            THEN 1 
            ELSE 0 END) AS peptic_ulcer_disease
	
	    -- Mild liver disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('570','571')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('070.6','070.9','573.3','573.4','573.8','573.9','V42.7')
            OR
            SUBSTR(icd9code_uni, 1, 6) IN ('070.22','070.23','070.32','070.33','070.44','070.54')
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('B18','K73','K74')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('K70.0','K70.1','K70.2','K70.3','K70.9','K71.3',
                                                   'K71.4','K71.5','K71.7','K76.0','K76.2',
                                                   'K76.3','K76.4','K76.8','K76.9','Z94.4')
			  
			-- From pasthistory
			OR liver1 = 1
			  
            THEN 1 
            ELSE 0 END) AS mild_liver_disease
	
		-- Diabetes without chronic complication
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 5) IN ('250.0','250.1','250.2','250.3','250.8','250.9') 
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('E10.0','E10.l','E10.6','E10.8','E10.9','E11.0','E11.1',
                                                   'E11.6','E11.8','E11.9','E12.0','E12.1','E12.6','E12.8',
                                                   'E12.9','E13.0','E13.1','E13.6','E13.8','E13.9','E14.0',
                                                   'E14.1','E14.6','E14.8','E14.9')
            THEN 1 
            ELSE 0 END) AS diabetes_without_cc

        -- Diabetes with chronic complication
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 5) IN ('250.4','250.5','250.6','250.7')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('E10.2','E10.3','E10.4','E10.5','E10.7','E11.2','E11.3',
                                                   'E11.4','E11.5','E11.7','E12.2','E12.3','E12.4','E12.5',
                                                   'E12.7','E13.2','E13.3','E13.4','E13.5','E13.7','E14.2',
                                                   'E14.3','E14.4','E14.5','E14.7')
            THEN 1 
            ELSE 0 END) AS diabetes_with_cc
	
		-- Diabetes All
		, MAX(CASE WHEN
		SUBSTR(icd9code_uni, 1, 5) IN ('250.0','250.1','250.2','250.3','250.8','250.9') 
          OR
        SUBSTR(icd9code_uni, 1, 5) IN ('E10.0','E10.l','E10.6','E10.8','E10.9','E11.0','E11.1',
                                                   'E11.6','E11.8','E11.9','E12.0','E12.1','E12.6','E12.8',
                                                   'E12.9','E13.0','E13.1','E13.6','E13.8','E13.9','E14.0',
                                                   'E14.1','E14.6','E14.8','E14.9')
			OR
            SUBSTR(icd9code_uni, 1, 5) IN ('250.4','250.5','250.6','250.7')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('E10.2','E10.3','E10.4','E10.5','E10.7','E11.2','E11.3',
                                                   'E11.4','E11.5','E11.7','E12.2','E12.3','E12.4','E12.5',
                                                   'E12.7','E13.2','E13.3','E13.4','E13.5','E13.7','E14.2',
                                                   'E14.3','E14.4','E14.5','E14.7')
			OR
			dm = 1 
			THEN 1
			ELSE 0 END
		) AS diabetes_all
	
		-- Hemiplegia or paraplegia
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('342','343')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('334.1','344.0','344.1','344.2',
                                                  '344.3','344.4','344.5','344.6','344.9')
            OR 
            SUBSTR(icd9code_uni, 1, 3) IN ('G81','G82')
            OR 
            SUBSTR(icd9code_uni, 1, 5) IN ('G04.1','G11.4','G80.1','G80.2','G83.0',
                                                   'G83.1','G83.2','G83.3','G83.4','G83.9')
            THEN 1 
            ELSE 0 END) AS paraplegia
	
		-- Renal disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('582','585','586','V56')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('588.0','V42.0','V45.1')
            OR
            SUBSTR(icd9code_uni, 1, 5) BETWEEN '583.0' AND '583.7'
            OR
            SUBSTR(icd9code_uni, 1, 6) IN ('403.01','403.11','403.91','404.02',
										   '404.03','404.12','404.13','404.92','404.93')          
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('N18','N19')
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('I12.0','I13.1','N03.2','N03.3','N03.4',
                                                   'N03.5','N03.6','N03.7','N05.2','N05.3',
                                                   'N05.4','N05.5','N05.6','N05.7','N25.0',
                                                   'Z49.0','Z49.1','Z49.2','Z94.0','Z99.2')
			  
			-- From pasthistory
			OR renal2 = 1
			  
            THEN 1 
            ELSE 0 END) AS renal_disease
	
		-- Any malignancy, including lymphoma and leukemia, except malignant neoplasm of skin
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) BETWEEN '140' AND '172'
            OR
            SUBSTR(icd9code_uni, 1, 5) BETWEEN '174.0' AND '195.8'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN '200' AND '208'
            OR
            SUBSTR(icd9code_uni, 1, 5) = '238.6'
            OR
            SUBSTR(icd9code_uni, 1, 3) IN ('C43','C88')
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C00' AND 'C26'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C30' AND 'C34'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C37' AND 'C41'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C45' AND 'C58'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C60' AND 'C76'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C81' AND 'C85'
            OR
            SUBSTR(icd9code_uni, 1, 3) BETWEEN 'C90' AND 'C97'
			  
			-- From pasthistory
			OR lymphoma2 = 1 OR cancer2 = 1 OR leukemia2 = 1
			  
            THEN 1 
            ELSE 0 END) AS malignant_cancer
	
		-- Moderate or severe liver disease
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 5) IN ('456.0','456.1','456.2')
            OR
            SUBSTR(icd9code_uni, 1, 5) BETWEEN '572.2' AND '572.8'
            OR
            SUBSTR(icd9code_uni, 1, 5) IN ('I85.0','I85.9','I86.4','I98.2','K70.4','K71.1',
                                                   'K72.1','K72.9','K76.5','K76.6','K76.7')
			  
			-- From pasthistory
			OR liver3 = 1
	
            THEN 1 
            ELSE 0 END) AS severe_liver_disease
	
		-- Metastatic solid tumor
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('196','197','198','199')
            OR 
            SUBSTR(icd9code_uni, 1, 3) IN ('C77','C78','C79','C80')
			  
			-- From pasthistory
			OR mets6 = 1
			  
            THEN 1 
            ELSE 0 END) AS metastatic_solid_tumor
	
		-- AIDS/HIV
        , MAX(CASE WHEN 
            SUBSTR(icd9code_uni, 1, 3) IN ('042','043','044')
            OR 
            SUBSTR(icd9code_uni, 1, 3) IN ('B20','B21','B22','B24')
			
			-- From pasthistory
			OR aids6 = 1
			  
            THEN 1 
            ELSE 0 END) AS aids
	
    FROM eicu_derived.icustay_detail icu
	left join eicu.diagnosis_uni diag
	on icu.patientunitstayid = diag.patientunitstayid
	left join eicu_derived.charlson
	on icu.patientunitstayid = charlson.patientunitstayid
    GROUP BY icu.patientunitstayid
)
-- select sum(myocardial_infarct),sum(congestive_heart_failure),sum(peripheral_vascular_disease),sum(cerebrovascular_disease),
-- sum(dementia),sum(chronic_pulmonary_disease),sum(rheumatic_disease),sum(peptic_ulcer_disease),
-- sum(mild_liver_disease),sum(diabetes_without_cc),sum(diabetes_with_cc),sum(paraplegia),
-- sum(renal_disease),sum(malignant_cancer),sum(severe_liver_disease),sum(metastatic_solid_tumor),sum(aids) from com


, ag AS
(
    SELECT 
        patientunitstayid
        , age
        , CASE WHEN age = '> 89' THEN 4
	WHEN age = '' THEN NULL
	WHEN age::numeric <= 40 THEN 0
    WHEN age::numeric <= 50 THEN 1
    WHEN age::numeric <= 60 THEN 2
    WHEN age::numeric <= 70 THEN 3
    ELSE 4 END AS age_score
    FROM eicu_derived.icustay_detail
)
-- select distinct age from  eicu.patient
SELECT 
    ad.patientunitstayid
    , ag.age_score
    , myocardial_infarct
    , congestive_heart_failure
    , peripheral_vascular_disease
    , cerebrovascular_disease
    , dementia
    , chronic_pulmonary_disease
    , rheumatic_disease
    , peptic_ulcer_disease
    , mild_liver_disease
    , diabetes_without_cc
    , diabetes_with_cc
	, diabetes_all
    , paraplegia
    , renal_disease
    , malignant_cancer
    , severe_liver_disease 
    , metastatic_solid_tumor 
    , aids
    -- Calculate the Charlson Comorbidity Score using the original
    -- weights from Charlson, 1987.
    , age_score
    + myocardial_infarct + congestive_heart_failure + peripheral_vascular_disease
    + cerebrovascular_disease + dementia + chronic_pulmonary_disease
    + rheumatic_disease + peptic_ulcer_disease
    + GREATEST(mild_liver_disease, 3*severe_liver_disease)
    + GREATEST(2*diabetes_with_cc, diabetes_without_cc)
    + GREATEST(2*malignant_cancer, 6*metastatic_solid_tumor)
    + 2*paraplegia + 2*renal_disease 
    + 6*aids
    AS charlson_comorbidity_index
	into eicu_derived.comorbidity_charlson_pasthistory
FROM eicu_derived.icustay_detail ad
LEFT JOIN com
ON ad.patientunitstayid = com.patientunitstayid
LEFT JOIN ag
ON com.patientunitstayid = ag.patientunitstayid
;
