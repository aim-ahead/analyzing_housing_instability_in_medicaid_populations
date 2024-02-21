--------------------------------
------ Inclusion criteria T2 ---
--- adult (18+ yrs)          ---
--- all type of payors       ---
--- period: 2016-2021        ---

---- note that intermediate table names start with r1 while final tables to be exported start with f1


--- first we create a table with all the patients with an SDH code of housing instability
--- using as input observation fact table
--- add the quantity 1 filter to identify the ones screened
select * 
into S36.dbo.r1_obs_fact_housingInstability
from FellowsSample.s36.OBSERVATION_FACT 
where concept_cd in (select concept_cd from s36.dbo.r1_housing_sdh_concepts) and 
 QUANTITY_NUM = 1; --- the ones tested for the SDH concept have the value 1 on column quantity_num;

--- then we merge this information with the data in visit dimension
--- to add the payor type for each encounter
select a.ENCOUNTER_NUM, a.patient_num, a.concept_cd,a.start_date, b.PAYOR_TYPE_RESEARCH
into s36.dbo.f1_all_payors_housingInstability_encounter_rownum44660
from  S36.dbo.r1_obs_fact_housingInstability a
inner join FellowsSample.S36.VISIT_DIMENSION b 
on a.ENCOUNTER_NUM = b.ENCOUNTER_NUM;


--- finally we get the demographic information from these patients
--- using as input patient dimension and filtering by patients on the previous r1_all_payors_housingInstability table
select * 
into S36.dbo.f1_all_payors_housingInstability_demographics_rownum31288
from FellowsSample.S36.PATIENT_DIMENSION
where patient_num in (select distinct(patient_num) from S36.dbo.f1_all_payors_housingInstability_encounter_screened_rownum44660);


