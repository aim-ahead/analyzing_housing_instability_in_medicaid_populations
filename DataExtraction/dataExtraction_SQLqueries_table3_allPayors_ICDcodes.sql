--------------------------------
------ Inclusion criteria T3 ---
--- adult (18+ yrs)          ---
--- all type of payors       ---
--- period: 2016-2021        ---
--- Z codes for housing ins  ---

---- note that intermediate table names start with r1 while final tables to be exported start with f1

--- identify the ICD codes for housing in concept dimension (dictionary)
select concept_cd, name_char 
into S36.dbo.r1_icdZ59codes
from FellowsSample.common.CONCEPT_DIMENSION
where concept_cd like 'ICD10CM:Z59%'



--- first we create a table with all the patients with an ICD Z code of housing instability
--- using as input observation fact table 
select * 
into S36.dbo.r1_obs_fact_ICD_housingInstability
from FellowsSample.s36.OBSERVATION_FACT 
where concept_cd in (select concept_cd from s36.dbo.r1_icdZ59codes);

--- then we merge this information with the data in visit dimension
--- to add the payor type for each encounter
select a.ENCOUNTER_NUM, a.patient_num, a.concept_cd,a.start_date, b.PAYOR_TYPE_RESEARCH
into s36.dbo.f1_all_payors_housingInstability_Zcodes_encounter_rownum4914
from  S36.dbo.r1_obs_fact_ICD_housingInstability a
inner join FellowsSample.S36.VISIT_DIMENSION b 
on a.ENCOUNTER_NUM = b.ENCOUNTER_NUM;


--- finally we get the demographic information from these patients
--- using as input patient dimension and filtering by patients on the previous f1_all_payors_housingInstability_Zcodes_encounter_rownum4914 table
select * 
into S36.dbo.f1_all_payors_housingInstability_Zcodes_demographics_rownum4725
from FellowsSample.S36.PATIENT_DIMENSION
where patient_num in (select distinct(patient_num) from S36.dbo.f1_all_payors_housingInstability_Zcodes_encounter_rownum4914);





