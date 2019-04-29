libname t "H:\Practicum_Thesis\TOGO\TogoData\Datasets";
PROC IMPORT OUT= t.togodemo 
            DATAFILE= "H:\Practicum_Thesis\TOGO\TogoData\Datasets\demography.xlsx" 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*2925 obs and 4 vars*/
proc contents data=t.togodemo;
run;
/*create temp set*/
data work.demo;
label sex="Sex, Male=0, Female=1"
      age="Age in Years"
	  ID="Unique Participant ID Number"
	  EU="Province"
	  ;
set t.togodemo;
run;
/*2925 obs and 4 vars*/
/*check dataset visually*/
proc print data=work.demo;
run;

********************************************************/
*clean MBA and Lab LFA data*;

PROC IMPORT OUT= t.lab
            DATAFILE= "H:\Practicum_Thesis\TOGO\TogoData\Datasets\LabData.xlsx" 
            DBMS=EXCEL REPLACE;
     sheet="Combined"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*2976 obs, 4 vars*/

data work.lab;
set t.lab;
label Pgp3="MFI-BG for Pgp3"
	  Ct694="MFI-BG for Ct694"
	  logPgp3='log transformed Pgp3 values'
	  logCt694='log transformed Ct694 values'
	  ;
if Pgp3 gt 0 then logPgp3=log10(Pgp3);else logPgp3=.; /*create new vars for log transformed Pgp3 and Ct694 and set new var to . when values are below 0*/
if Ct694 gt 0 then logCt694=log10(Ct694);else logCt694=.;
/*create cutoff variables*/
if Pgp3>1647 then PgP3pos=1;
else Pgp3pos=0;
if Ct694>357 then Ct694pos=1;
else Ct694pos=0;
if Pgp3=. then Pgp3pos=.;
if Ct694=. then Ct694pos=.;
run;
/*2976 obs and 8 vars*/
/*check set visually*/
proc print data=work.lab;
run;
/*2976 complete lab observations*/ 


******************************
*cleaning field LFA data*;

PROC IMPORT OUT= t.fieldlfa
            DATAFILE= "H:\Practicum_Thesis\TOGO\TogoData\Datasets\fieldlfa.xlsx" 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc contents;
run;

data work.field;
set t.fieldlfa;
label ID="Unique Participant ID Number"
	  fieldlfa="Result of Cassette LFA";
if fieldlfa=9 then fieldlfa=.; /*recategorize samples from 9 to missing*/
run;
*1976 observations and 2 vars*;
proc print data=work.field;
run;


/*sort datasets*/
proc sort data=work.lab;
by ID;
run;
proc sort data=work.demo;
by ID;
run;
proc sort data=work.field;
by ID;
run;

/*create lab set*/
data work.labx;
merge work.lab work.demo;
by ID;
if _n_ le 3 then delete;/*here observations 1-3 had no data at all, no IDs or anything, entry error*/
run;
proc print data=work.labx;
run;
/*2982 observations retained and 11 vars retained*/;

/*examine missing data*/
/*for lab set*/
data work.missinglab;
set work.labx;
where id=. or age=. or Pgp3=. or lablfa=.;/*examine any additional missing data*/
run;
/*67 missing obs*/
proc freq data=work.missinglab;
tables sex Pgp3pos Lablfa /missing;
run;
data work.labclean;
set work.labx;
if id=. or eu=. or sex=. or age=. or Ct694=. or Pgp3=. or lablfa=. then delete ;/*delete any additional missing data*/
run;
proc print data=work.labclean;
where logPgp3=. or logCt694=.;
run;
/*108 obs where no log value was created, will not be included in graphs using log transformed data, the heatmap*/

/*67 observations with additional missing data
57 without demographic info
10 without lab results (5 duplicates and 5 invalid) with one
1 with only ID, no demographic or lab results
work.labclean has 2915 obs nd 11 vars*/


/*create field set*/
data work.fieldx;
merge work.labclean work.field;
by ID;
run;
proc print data=work.fieldx;
run;
/*2963 observations retained and 11 vars retained*/;
/*examine missing data*/
/*for field set*/
data work.missingf;
set work.fieldx;
where id=. or age=. or Pgp3=. or lablfa=. or fieldlfa=.;/*examine any additional missing data*/
run;
/*1049 missing obs*/
proc freq data=work.missingf;
tables sex Pgp3pos Lablfa fieldlfa /missing;
run;
proc print data=work.missingf;
run;
data work.fieldclean;
set work.fieldx;
if id=. or eu=. or sex=. or age=. or Ct694=. or Pgp3=. or lablfa=. or fieldlfa=. then delete ;/*delete any additional missing data*/
run;
proc print data=work.fieldclean;
run;
proc print data=work.fieldclean;
where logPgp3=. or logCt694=.;
run;
/*68 obs where Pgp3 and Ct694 couldnot be log transformed because readings were lt 0*/

/*1049 observations with missing data
48 without demographic or lab results(these were removed in cleaning the lab set)
1002 not run on field lfa
work.fieldclean has 1914 obs nd 11 vars*/

/*save as perm datasets*/

data t.lab;
set work.labclean; /*add in age cat and age rand variables*/
agerand=rand('normal', 5.11,2.52); *(type,mean of var, standard deviation of var)*;
if age=1 or age=2 or age=3 then agecat=1;
if age=4 or age=5 or age=6 then agecat=2;
if age=7 or age=8 or age=9 then agecat=3;
run;
/*2915 obs and 13 vars*/


data t.field;
set work.fieldclean;
run;
/*1914 obs and 12 vars*/


**********************
*export datasets*;


