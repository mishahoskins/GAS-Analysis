
/*
 *------------------------------------------------------------------------------
 * Program Name:  GAS_analysis_20250409 
 * Author:        Mikhail Hoskins
 * Date Created:  04/09/2025
 * Date Modified: 05/06/2025
 * Description:   We want to evaluate GAS over the last decade + in NC. Recent study showed an increase year over year, can we replicate for NC.
 *				  (https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2831512#)
 *
 * Inputs:       case.sas7bdat , case_phi.sas7bdat , Admin_question_package_addl.sas7bdat : Z:\YYYYMMDD
 * Output:       .
 * Notes:        Program pulls GAS. CRE, Cauris, and GAS.
 *				 Annotations are between /* to help guide. If the code doesn't work or numbers don't align, check here: 
 *				 https://github.com/NC-DPH/Communicable-Disease-Dashboards/blob/main/NCD3v2%20In%20Progress.sas
 *
 *------------------------------------------------------------------------------
 */


/*Step 1: set your pathway. Must have Z drive (or however you are mapped to denormalized tables) access.*/
libname denorm 'Z:\20250301'; /*Select the file name you want from the Z drive. Format is YYYYMMDD. Tables are created monthly*/
libname analysis 'T:\HAI\Code library\Epi curve example\ncedss extracts\Datasets';/*Path to export your dataset so we don't have to import denormalized tables every time*/
/*Step 1a: set your date range in the format specified.*/
%let start_dte = 01JAN12; /*Set your start date for range of values DDMMYY*/
%let end_dte = 31DEC24; /*Set your end date for range of values DDMMMYY*/

/*Unless you are pulling new data skip step 2 and import the saved dataset in step 3*/

/*Step 2a: Table 1 GAS and administrative package questions (date reported variable)*/
proc sql;
create table CASE_COMBO as
select 
	s.*, a.EVENT_STATE,
	b.RPTI_SOURCE_DT_SUBMITTED

from denorm.case 

	as s left join denorm.case_PHI as a on s.case_id=a.case_id
	left join denorm.Admin_question_package_addl as b on s.case_id=b.case_id

where s.CLASSIFICATION_CLASSIFICATION in ("Confirmed", "Probable")
	and s.type in ("STRA") 
	and s.REPORT_TO_CDC = 'Yes';

quit;

/*Step 4: Table 3: Confine to certain key variables. You can add and subtract variables here to fit your needs if necessary*/
proc sql;
create table GAS_updated as
select 
		OWNING_JD,
		TYPE, 
		TYPE_DESC, 
		CLASSIFICATION_CLASSIFICATION, 
		CASE_ID,
		REPORT_TO_CDC,

		input(MMWR_YEAR, 4.) as MMWR_YEAR, 
		MMWR_DATE_BASIS, 

		count(distinct CASE_ID) as Case_Ct label = 'Counts', 
		'Healthcare Acquired Infection' as Disease_Group,
		AGE, 
		GENDER, 
		HISPANIC, 
		RACE1, 
		RACE2, 
		RACE3, 
		RACE4, 
		RACE5, 
		RACE6,
/*This piece should match exactly or almost exactly to the dashboard code found here: https://github.com/NC-DPH/Communicable-Disease-Dashboards/blob/main/NCD3v2%20In%20Progress.sas
		some of the variable names may be different but the counts need to align*/

		/*don't delete this section, it's a logic path for how the state creates an event date based on submission, lab, and symptom dates*/
	case 
	    when MMWR_DATE_BASIS ne . then MMWR_DATE_BASIS
		when SYMPTOM_ONSET_DATE ne . then SYMPTOM_ONSET_DATE
	    when (SYMPTOM_ONSET_DATE = . ) and  RPTI_SOURCE_DT_SUBMITTED  ne . then RPTI_SOURCE_DT_SUBMITTED
	    else datepart(CREATE_DT)
	    end as EVENT_DATE format=DATE9., 

	year(calculated EVENT_DATE) as Year, 
	month(calculated EVENT_DATE) as Month, 
	QTR(calculated EVENT_DATE) as Quarter,
/*Additional variables for MDRO report*/
	SYMPTOM_ONSET_DATE, 
	DISEASE_ONSET_QUALIFIER, 
	DATE_FOR_REPORTING,
	RPTI_SOURCE_DT_SUBMITTED, 
	CREATE_DT, 
	STATUS

from CASE_COMBO
where calculated EVENT_DATE >= "&start_dte."d and calculated EVENT_DATE <= "&end_dte."d
	and STATUS = 'Closed'
	/*and STATE in ('NC' ' ')*/
order by TYPE_DESC, YEAR, OWNING_JD;
quit;

proc sql;
/*patient outcome, surgical experience, LTCF residency, IV drug use variables add here*/
create table GAS_updated_2 as
select 

	a.*,
	b.PAT_OCM, /*Patient outcome*/
	c.HCE, /*Surgical experience*/
	d.TF_USED_INJECTION_RXS /*Injection drug use*/

from GAS_updated as a 

	left join denorm.clinic_outcomes_cd as b on a.case_id=b.case_id
	left join denorm.risk_misc_one_time_cd as d on a.case_id=d.case_id

	left join denorm.risk_health_care_exp_cd as c on a.case_id=c.case_id

;
quit;


proc freq data=GAS_updated_2; tables PAT_OCM HCE TF_USED_INJECTION_RXS/norow nocol nopercent nocum;run;


/*Missing values by variable*/
proc format; 
   value $missfmt ' '='Missing' other='Not Missing'; 
   value missfmt .  ='Missing' other='Not Missing'; 
run;


proc freq data=GAS_updated_2;  
format _CHAR_ $missfmt.; 
tables PAT_OCM HCE TF_USED_INJECTION_RXS/ missing missprint nocum nopercent; 
run; 




/*Save dataset so we don't have run import step every time (very useful on VPN)*/
data analysis.GAS_2012_2024;
set GAS_updated_2;
run;


/*------------------------------------------------------------------BEGIN ANALYSIS HERE UNLESS CHANGING DENORMALIZED INPUTS------------------------------------------------------------------*/

/*Step 3: Import dataset unless you have made changes prior*/

data GAS_updated_2;
set analysis.GAS_2012_2024;
run;



proc contents data=GAS_updated_2;run;
/*Begin cleaning and analysis*/

/*General trends*/
proc sql;
create table GAS_trend as 
select

	YEAR as report_yr "Report Year",
	/*intnx("month", (MMWR_DATE_BASIS), 0, "end") as testreportqtr "Quarter Ending Date" format=date11., */

	sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') then 1 else 0 end) as GAS "Annual Count, GAS",
/*Clinical Outcome*/
	sum (case when PAT_OCM in ('Died') then 1 else 0 end) as GAS_died_y "Died",
/*Ethnicity*/
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and HISPANIC in ('Yes') then 1 else 0 end) as 
			GAS_hisp "Annual Count, GAS Hispanic Eth.",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and HISPANIC in ('No') then 1 else 0 end) as 
			GAS_nonhisp "Annual Count, GAS Non-Hispanic Eth.",
/*Gender*/
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and GENDER in ('Male') then 1 else 0 end) as 
			GAS_male "Annual Count, GAS Gender: Male",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and GENDER in ('Female') then 1 else 0 end) as 
			GAS_female "Annual Count, GAS Gender: Female",
/*Race*/
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and RACE1 in ('White') then 1 else 0 end) as 
			GAS_white "Annual Count, GAS Race: White",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and RACE1 in ('Black or African American') then 1 else 0 end) 
			as GAS_blk "Annual Count, GAS Race: Black/A.A.",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and RACE1 in ('Asian') then 1 else 0 end) as 
			GAS_asian "Annual Count, GAS Race: Asian",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and RACE1 in ('American Indian Alaskan Native') then 1 else 0 end) as 
			GAS_AIAN "Annual Count, GAS Race: A.I./A.N.",
		sum (case when TYPE_DESC in ('Streptococcal invasive infection, Group A (61)') and RACE1 in ('Other') then 1 else 0 end) as 
			GAS_other "Annual Count, GAS Race: Other",
/*Invasive procedure*/
		sum (case when HCE not in ('', 'No') then 1 else 0 end) as GAS_surg "Annual Count, GAS post invasive procedure",
/*Injection drug use*/
		sum (case when (TF_USED_INJECTION_RXS in ('Yes') and YEAR in (2018,2019, 2020, 2021, 2022, 2023, 2024)) then 1 else . end) as GAS_inj "Annual Count, GAS injection drug use",
/*At or above median age*/
		sum (case when AGE GE (55) and AGE not in (.) then 1 else 0 end) as GAS_age_med "Age Greater-Than-or-Equal-To Median Age of Infection (55)",


	/*IR: 2023 NC population constants by race
			Gender
			%let male_pop =5538969;
			%let female_pop =5296522;
			Race pop.
			%let white_pop = 7564526;
			%let blackaa_pop = 2392417;
			%let asian_pop = 399358;
			%let napi_pop = 16677; Native Hawaiian/Pacific Islander in CDC census
			%let other_race_pop = 289706; Two or more races in Census track data
			%let aian_pop = 172807;
			Hispanic
			%let hisp_yes = 1238421;
			%let hisp_no = 9597070;*/


	(calculated GAS / 10835491) * 100000 as GAS_IR "Annual Estimated GAS IR" format 10.2,
	(calculated GAS_died_Y / 10835491) * 100000 as GAS_IR_mort "Annual Estimated GAS Mortality Rate**" format 10.2,
		(calculated GAS_Hisp / 1238421) * 100000 as GAS_IR_hisp "Annual Estimated GAS IR Hispanic" format 10.2,
		(calculated GAS_nonhisp / 9597070) * 100000 as GAS_IR_nonhisp "Annual Estimated GAS IR Non-Hispanic" format 10.2,
		(calculated GAS_male / 5538969) * 100000 as GAS_IR_male "Annual Estimated GAS IR Male" format 10.2,
		(calculated GAS_female / 5296522) * 100000 as GAS_IR_female "Annual Estimated GAS IR Female" format 10.2,
		(calculated GAS_white / 7564526) * 100000 as GAS_IR_white "Annual Estimated GAS IR White" format 10.2,
		(calculated GAS_blk / 2392417) * 100000 as GAS_IR_blk "Annual Estimated GAS IR Black/A.A." format 10.2,
		(calculated GAS_asian / 399358) * 100000 as GAS_IR_asian "Annual Estimated GAS IR Asian**" format 10.2,
		(calculated GAS_AIAN / 172807) * 100000 as GAS_IR_AIAN "Annual Estimated GAS IR A.I./A.N.**" format 10.2,
		(calculated GAS_other / 289706) * 100000 as GAS_IR_other "Annual Estimated GAS IR Other Race**" format 10.2,
		(calculated GAS_surg / 10835491) * 100000 as GAS_IR_surg "Annual Estimated GAS IR Invasive Surgery**" format 10.2,
		(calculated GAS_inj / 10835491) * 100000 as GAS_IR_inj "Annual Estimated GAS IR Injection Druge Use**" format 10.2, /*need appropriate denominator here*/
		(calculated GAS_age_med / 10835491) * 100000 as GAS_age_med_IR "Annual Estimated GAS IR Age Above Median" format 10.2

/** = Not linear*/

from GAS_updated_2
	group by report_yr
;
quit;

proc print data=GAS_trend noobs label;run;



data GAS_clean;
set GAS_updated_2;
/*Make all classifications binary with 0 = reference*/
/*Hispanic ethnicity groups*/
	hispanic_new=.;
		if HISPANIC in ('Yes') then hispanic_new = 1;
		if HISPANIC	in ('No') then hispanic_new = 0;
/*Gender groups*/
	gender_new=.;
		if GENDER in ('Male') then gender_new = 1;
		if GENDER in ('Female') then gender_new = 0;
/*Race groups*/
	white_binary=.;
		if RACE1 in ('White') then white_binary = 1;
		if RACE1 not in ('White', '') then white_binary = 0;

	black_binary=.;
		if RACE1 in ('Black or African American') then black_binary = 1;
		if RACE1 not in ('Black or African American', '') then black_binary = 0;

	asian_binary=.;
		if RACE1 in ('Asian') then asian_binary = 1;
		if RACE1 not in ('Asian', '') then asian_binary = 0;

	AIAN_binary=.;
		if RACE1 in ('American Indian Alaskan Native') then AIAN_binary = 1;
		if RACE1 not in ('American Indian Alaskan Native', '') then AIAN_binary = 0;

	other_binary=.;
		if RACE1 in ('Other') then other_binary = 1;
		if RACE1 not in ('Other', '') then other_binary = 0;
/*Median Age (55)*/

	age_med=.;
	if AGE GE (55) then age_med = 1;
	if (AGE LT (55)) or (AGE in (.)) then age_med = 0;

/*Pt. Outcome*/
	died=.;
	if PAT_OCM in ('Survived') then died = 0;
	if PAT_OCM in ('Died') then died = 1;

/*Invasive Proc.*/
	surg=.;
	if HCE in ('No') then surg = 0;
	if HCE in ('Surgery (besides oral surgery), obstetrical or invasive procedure') then surg = 1;

/*Injection drug use*/
	inj_drug=.;
	if TF_USED_INJECTION_RXS in ('No') then inj_drug = 0;
	if TF_USED_INJECTION_RXS in ('Yes') then inj_drug = 1; /*Dropped ALL missing and classified as "Unknown"*/

run;

proc freq data=GAS_clean; tables  age_med/norow nocol nocum;run;

proc reg data=GAS_trend;
	model GAS = report_yr / noprint;
	plot GAS*report_yr / ;
run;






/*Export dataset*/
data analysis.GAS_clean_20250418;
	set GAS_clean;
run;

/*And as a CSV*/

proc export data=GAS_trend 
dbms=csv
outfile="T:\HAI\Code library\Epi curve example\ncedss extracts\Datasets\gas_trends_20250418.csv"
replace;
run;





title; footnote;
/*Set your output pathway here*/
ods excel file="T:\HAI\Code library\Epi curve example\analysis\GAS_analysis_tables_&sysdate..xlsx";

ods excel options (sheet_interval = "now" sheet_name = "case/ir tables" embedded_titles='Yes');
proc print data=GAS_trend noobs label;run;

ods excel options (sheet_interval = "now" sheet_name = "Cochran-Armitage " embedded_titles='Yes');

proc freq data=GAS_clean; 

	table   gender_new*YEAR hispanic_new*YEAR white_binary*YEAR black_binary*YEAR 
			age_med*YEAR / trend norow nocol nopercent scores=table
															    plots=freqplot(twoway=stacked); 
		
run; 
ods excel options (sheet_interval = "none" sheet_name = "linear test" embedded_titles='Yes');
proc reg data=GAS_trend;
	model GAS_inj = report_yr / noprint;
	plot GAS_inj*report_yr / ;
run;

ods excel options (sheet_interval = "none" sheet_name = "linear test" embedded_titles='Yes');
proc reg data=GAS_trend;
	model GAS = report_yr / noprint;
	plot GAS*report_yr / ;

	model GAS_died_y = report_yr / noprint;
	plot GAS_died_y*report_yr / ;

	model GAS_hisp = report_yr / noprint;
	plot GAS_hisp*report_yr / ;

	model GAS_nonhisp = report_yr / noprint;
	plot GAS_nonhisp*report_yr / ;

	model GAS_male = report_yr / noprint;
	plot GAS_male*report_yr / ;

	model GAS_female = report_yr / noprint;
	plot GAS_female*report_yr / ;

	model GAS_white = report_yr / noprint;
	plot GAS_white*report_yr / ;

	model GAS_blk = report_yr / noprint;
	plot GAS_blk*report_yr / ;

	model GAS_Asian = report_yr / noprint;
	plot GAS_Asian*report_yr / ;

	model GAS_AIAN = report_yr / noprint;
	plot GAS_AIAN*report_yr / ;

	model GAS_other = report_yr / noprint;
	plot GAS_other*report_yr / ;

	model GAS_surg = report_yr / noprint;
	plot GAS_surg*report_yr / ;

	model GAS_age_med = report_yr / noprint;
	plot GAS_age_med*report_yr / ;
run;



/*Cochran-Armitage Analysis here: (linear variables GE 0.50 R-sq)
GAS (overall) no C-A analysis but linearity tested
	Age:
age_med
	Race classes:
White
African American/Black
Other
	Gender:
Male
Female
	Ethnicity:
Hispanic 
Non-Hispanic


Mann-Kendall Analysis in R: (non-linear variables LT 0.50 R-sq)
Mortality
	Risk factors:
Injection drug use
Surgery
	Race classes:
American Indian/Alaska Native
Asian
*/




ods excel close;

/*Quick interpretation of C/A analysis: Row 1 level, value = 0 (not target), DECREASES as YEAR increases. So as we move forward in years there is a
  statistically significant increase in value = 1 for injection drug use GAS events, gender, ethnicity, and race (except 'Asian' and 'American Indian/Alaska Native'). */



