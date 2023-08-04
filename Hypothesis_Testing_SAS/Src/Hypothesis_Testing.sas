/******************
Input: weight.sav
Output: Just some testing on using SAS to convert sav data into data used for excel and SPSS
Written by:Tingwei Adeck
Date: Sep 18 2022
Description: Introduction to hypothesis testing in SAS
Requirements: Need library called project, weight.sav file.
Dataset description: Data obtained from Dr. Gaddis (small dataset)
Input: weight.sav
Output: Hypothesis_Testing_SAS.pdf
******************/

/*DATA models (The way to read files when working locally, notice I am working on the SAS cloud)
INFILE 'c:\MyRawData\Models.dat' TRUNCOVER;
INPUT Model $ 1-12 Class $ Price Frame $ 28-38;
RUN;*/

%let path=/home/u40967678/sasuser.v94;


libname project
    "&path/sas_umkc/input";
    
filename weight
    "&path/sas_umkc/input/weight.sav";   

ods pdf file=
    "&path/sas_umkc/output/Hypothesis_Testing_SAS.pdf";
    
options papersize=(8in 4in) nonumber nodate;

proc import file= weight
	out=project.weight
	dbms=sav
	replace;
run;

/*proc ttest data=sashelp.class plots=none;*/
proc ttest data=project.weight alpha=0.05 H0=140 plots = none;
    var Student_Weight;

%macro cohens_ttest(data=,var=,H0=);
proc sql;
    create table project.mean_weight as
        select avg(&var) as mean, std(&var) as stdev
	from &data;
quit;

title 'Cohens D';
data project.cohens_d;
set project.mean_weight;
cohens_d = (mean-&H0)/stdev;
proc print data=project.cohens_d;
run;

%mend cohens_ttest;

%cohens_ttest(data=project.weight,var=Student_Weight,H0=140);
 
***Power analysis with default null is 0;
title 'Power Analysis default Null';
proc power; 
  onesamplemeans test=t 
  mean = 166
  stddev = 24.24
  ntotal = 32
  power = .; 
run;

***Power analysis with null=20;
title 'Power Analysis Hypothesized population mean=140';
proc power; 
  onesamplemeans test=t 
  nullmean = 140
  mean = 166
  stddev = 24.24
  ntotal = 32
  power = .; 
run;

title 'N Analysis Hypothesized population mean=166';
proc power; 
  onesamplemeans test=t 
  mean = 166
  stddev = 24.24
  ntotal = . 
  power = .99; 
run;

proc power plotonly;
  ods output plotcontent=PlotData;
  onesamplemeans test=t
  nullmean = 140
  mean = 166
  stddev = 24.24
  ntotal = 32
  power  = .;
  plot x=n min=10 max=100 npoints=20;
run;

title 'Summary of observations';   
proc print data=project.weight (obs=5);
run;

ods pdf close;
