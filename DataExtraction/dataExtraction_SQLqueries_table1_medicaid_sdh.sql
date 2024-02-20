--------------------------------
------ Inclusion criteria T1 ---
--- adult (18+ yrs)          ---
--- Medicaid recipients      ---
--- period: 2016-2021        ---
--- had housing insecurity   ---

---- note that intermediate table names start with r1 while final tables to be exported start with f1


--- filtering the visit dimention by payor type to identify medicaid encounters in 2016-2021
--- using as input Visit dimension that is wher the payor info for each encounter is 
 select * , year(start_date) as year_encounter
 into S36.dbo.r1_medicaid_encounters_period
 from FellowsSample.S36.VISIT_DIMENSION 
 where PAYOR_TYPE_RESEARCH = 'Medicaid' and ( year(start_date) > 2015 and year(start_date) < 2023);

 --- identify in patient_dimension which are these patients and filtering by birth year
 --- using as input the patient_dimension table that is where all the demographic information of the patients is located
select * 
into S36.dbo.r1_medicaid_adult_patients
from FellowsSample.S36.patient_dimension 
where patient_num in ( select distinct( patient_num) from S36.dbo.r1_medicaid_encounters_period)
and year(birth_date) <= 1998; 

--- filter the r1_medicaid_encounters_period table for adult patients only 
select * 
into S36.dbo.r1_medicaid_encounters_period_adults
from S36.dbo.r1_medicaid_encounters_period
where patient_num in ( select distinct( patient_num) from  r1_medicaid_adult_patients);

select count(*) from S36.dbo.r1_medicaid_encounters_period;
select count(*) from S36.dbo.r1_medicaid_encounters_period_adults;

-- to avoid having duplicate information remove the first table
drop table S36.dbo.r1_medicaid_encounters_period;

--- identify the patients with housing instability based on the SDH
select  * 
into S36.dbo.r1_housing_sdh_concepts 
from FellowsSample.common.CONCEPT_DIMENSION where CONCEPT_PATH like '\i2b2\SDH\Housing Instability%';

--- identify the patients that have a 1 in some of these concepts, and that are medicaid and adults in our period of interest 

--- first check, double-check that all the patients in visit dimension where on patient dimension
select count(distinct(patient_num)) from S36.dbo.r1_medicaid_encounters_period_adults;
select count(distinct(patient_num)) from S36.dbo.r1_medicaid_adult_patients;

 --- using as input the observation fact table that is where all the concepts are located
 --- we filter by the patients with at least one of the SDH codes and that the concept was during a medicaid encounter on our patients of interest

select *
into S36.dbo.r1_observation_housing_medicaid_adults
from FellowsSample.S36.OBSERVATION_FACT
where CONCEPT_CD in ( select concept_cd from S36.dbo.r1_housing_sdh_concepts ) 
and QUANTITY_NUM = 1 --- the ones tested for the SDH concept have the value 1 on column quantity_num
and encounter_num in (select distinct(encounter_num) from S36.dbo.r1_medicaid_encounters_period_adults);

--- to filter by the age, we can take different approaches
--- we will estimate it using the first encounter visit for the encounters of interest

select patient_num, min(start_date) as firstDate
into S36.dbo.f1_first_encounter_date
from S36.dbo.r1_medicaid_encounters_period_adults
group by patient_num; 


--- create 3 final tables, one with the overall population, one with pre-pandemic only and one with post-pandemic only
--- considering pre-pandemic 2016-2019 and post pandemic 2020-2022
select *
into S36.dbo.f1_overall_population_rownum21816
from S36.dbo.r1_medicaid_adult_patients 
where patient_num in (select distinct( PATIENT_NUM) from S36.dbo.r1_observation_housing_medicaid_adults);

select *
into S36.dbo.f1_pre_pandemic_population_rownum11100
from S36.dbo.r1_medicaid_adult_patients 
where patient_num in (select distinct( PATIENT_NUM) from S36.dbo.r1_observation_housing_medicaid_adults where  year(start_date) < 2020);

select *
into S36.dbo.f1_post_pandemic_population_rownum11558
from S36.dbo.r1_medicaid_adult_patients 
where patient_num in (select distinct( PATIENT_NUM) from S36.dbo.r1_observation_housing_medicaid_adults where  year(start_date) >= 2020);
