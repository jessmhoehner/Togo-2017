/*Jessica Randall
Graduate Research Assistant
Centers for Disease Control and Prevention*/

/*******************************************************/
libname t "H:\Practicum_Thesis\TOGO\TogoData\Datasets";
ods graphics on;

/*create dummy variables for positivity and negativity by antigen*/
data work.lab;
set t.lab;
label Pgp3pos="Positive by Pgp3, 1=positive 0=negative"
	  Ct694pos="Positive by CT694, 1=positive, 0=negative"
	  ;
run;
data work.field;
set t.field;
label Pgp3pos="Positive by Pgp3, 1=positive 0=negative"
	  Ct694pos="Positive by CT694, 1=positive, 0=negative"
	  ;
run;

/*check contents of created datasets*/
proc contents data=work.lab;
run;
proc contents data=work.field;
run;

***************************************;
*demographics*;
proc freq data=work.lab;
tables age sex*eu age*eu sex*eu;
run;
proc freq data=work.field;
tables age sex*eu age*eu sex*eu;
run;
******************************************;
*Lab data*
*seroprevalence*;
PROC LOGISTIC DATA=work.lab PLOTS(ONLY)=ROC simple alpha=0.05;
	class age; 
    MODEL Pgp3pos (EVENT='1') = age /ctable ridging=none; *where 1 is seropositivity by Pgp3;
	OUTPUT OUT=work.labp P=Pgp3phat XBETA=logitp ;
RUN;
/*CT694*/
PROC LOGISTIC DATA=work.lab PLOTS(ONLY)=ROC simple alpha=0.05;
    class age; 
	MODEL Ct694pos (EVENT='1') = age/ ctable ridging=none; *where 1 is seropositivity by CT694;
	OUTPUT OUT=work.labc P=CT694phat XBETA=logitc;
RUN;
/*Dipstick LFA*/
PROC LOGISTIC DATA=work.lab PLOTS(ONLY)=ROC simple alpha=0.05;
	class age; 
	MODEL LabLFA (EVENT='1') = age/ctable ridging=none; *where 1 is seropositivity by CT694;
	OUTPUT OUT=work.labl P=LabLFAphat XBETA=logitl ;
RUN;
/*merge work.labp, work.labc, and work.labl and export by CSV*/
/*from CSV, graph these in python to graph*/
proc sort data=work.labp;
by ID;
run;
proc sort data=work.labc;
by ID;
run;
proc sort data=work.labl;
by ID;
run;
data work.phats (drop=agerand pgp3 ct694 logpgp3 logct694);
merge work.labp work.labc work.labl;
by ID;
run;
proc sort data=work.phats;
by age;
run;

/*get the mean predicted rates of positivity for each age and antigen*/
title 'Age Seroprevalence by each Antigen';
proc means data=work.phats alpha=0.05;
var Pgp3phat CT694phat  lablfaphat;
by age;
run;
title;

/*Field Data*/
*seroprevalence*;
PROC LOGISTIC DATA=work.field PLOTS(ONLY)=ROC simple alpha=0.05;
	class age; 
    MODEL Pgp3pos (EVENT='1') = age /ctable ridging=none; *where 1 is seropositivity by Pgp3;
	OUTPUT OUT=work.fieldp P=Pgp3phat2 XBETA=logit1 ;
RUN;
/*CT694*/
PROC LOGISTIC DATA=work.field PLOTS(ONLY)=ROC simple alpha=0.05;
    class age; 
	MODEL Ct694pos (EVENT='1') = age/ ctable ridging=none; *where 1 is seropositivity by CT694;
	OUTPUT OUT=work.fieldc P=CT694phat2 XBETA=logit2;
RUN;
/*Dipstick LFA*/
PROC LOGISTIC DATA=work.field PLOTS(ONLY)=ROC simple alpha=0.05;
	class age; 
	MODEL LabLFA (EVENT='1') = age/ctable ridging=none; *where 1 is seropositivity by CT694;
	OUTPUT OUT=work.fieldl P=LabLFAphat2 XBETA=logit3 ;
RUN;
/*Casette LFA*/
PROC LOGISTIC DATA=work.field PLOTS(ONLY)=ROC simple alpha=0.05;
	class age; 
	MODEL FieldLFA (EVENT='1') = age/ctable ridging=none; *where 1 is seropositivity by CT694;
	OUTPUT OUT=work.fieldlf P=fieldLFAphat XBETA=logit4 ;
RUN;
/*merge*/
proc sort data=work.fieldp;
by ID;
run;
proc sort data=work.fieldc;
by ID;
run;
proc sort data=work.fieldl;
by ID;
run;
proc sort data=work.fieldlf;
by ID;
run;
data work.phatsf (drop=agerand pgp3 ct694 logpgp3 logct694);
merge work.fieldp work.fieldc work.fieldl work.fieldlf;
by ID;
run;
proc sort data=work.phatsf;
by age;
run;

/*get the mean predicted rates of positivity for each age and antigen*/
title 'Age Seroprevalence by each Antigen';
proc means data=work.phatsf alpha=0.05;
var Pgp3phat2 CT694phat2  lablfaphat2 fieldlfaphat;
by age;
run;
title;

********************************************;
/*agreement*/
proc freq data=work.lab;
tables Pgp3pos*Ct694pos labLFA*Pgp3pos labLFA*Ct694pos/exact agree nocum;
run;

/*save work datasets as permanent sets and export*/
data t.lab;
set work.lab;
run;

data t.field;
set work.field;
run;
