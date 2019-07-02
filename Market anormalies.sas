PROC IMPORT OUT= riskfree 
            DATAFILE= "/home/u37560128/my_courses/xz400/FF_Research_Data_Factors_daily_19262017.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

/*test market anormalies for the fama french data of 1990 to 2015. get the data from 1990 to 2015*/
DATA riskfree1;
  SET riskfree;
  DATE1 = INPUT(PUT(DATE,8.),YYMMDD8.);
  FORMAT DATE1 YYMMDD8.;
RUN;

data riskfree9015;
set riskfree1;
year=year(date1);
month=month(date1);
WEEKDAY=WEEKDAY(date1);
run;

data riskfree9015;
set riskfree9015;
where (year>=1990) and (year<=2015); 
run;

data riskfree9015;
set riskfree9015;
rename date=origdate;
/*fama french data omits the percentage. we convert the data to decimals*/
mrt_rf_d=Mkt_RF/100;
SMB_d=smb/100;
HML_d=hml/100;
RF_d=rf/100;
run;

/*Calendar Anomalies*/
data riskfree9015;
set riskfree9015;
if month=1 then d_jan=1;
else d_jan=0;
if month=12 then d_dec=1;
else d_dec=0;
if (weekday=2) then d_monday=1;
else d_monday=0;
if (weekday=6) then d_friday=1;
else d_friday=0;
/*where 1=Sunday, 2=Monday, . . . , 7=Saturday.*/
if month=12 then d_dec_jan=1;
else if month=1 then d_dec_jan=0;/*months_feb-nov will be missing values*/
run;

/*get the average of daily return for weekdays*/
proc sort data=riskfree9015;
by weekday;
run;
proc means data=riskfree9015;
var mrt_rf_d;
by weekday;
run;

/*get the average of daily return for every month. The returns in Dec were larger. */
proc sort data=riskfree9015;
by month;
run;
proc means data=riskfree9015;
var mrt_rf_d;
by month;
run;

/*Cochran option in order to use the Cochran approximation 
(in addition to the Satterthwaite approximation, which is included by default). 
PROC TTEST for the case of unequal variances, 
along with both types of confidence limits for the pooled standard deviation.*/

/*not rejected mrt_rf and HML, not reject SMB*/
ods graphics on;   
proc ttest data=riskfree9015 cochran ci=equal umpu;
      class d_dec;
      var mrt_rf_d SMB_d HML_d;
   run;
ods graphics off;

ods graphics on;   /*reject SMB*/
proc ttest data=riskfree9015 cochran ci=equal umpu;
      class d_jan;
      var mrt_rf_d SMB_d HML_d;
   run;
ods graphics off;

/* one side test. SIDES=L

h0: smb in non jan (0) - smb in jan (1) =0
ha: smb in non jan (0) - smb in jan (1) <0

specifies lower one-sided tests, 
in which the alternative hypothesis indicates a mean less than the null value, 
and lower one-sided confidence intervals between minus infinity and the upper confidence limit. */
proc ttest data=riskfree9015 sides=l cochran ci=equal umpu;
      class d_jan;
      var mrt_rf_d SMB_d HML_d;
   run;

/* one side test. 
SIDES=U
h0: smb in non jan (0) - smb in jan (1) =0
ha: smb in non jan (0) - smb in jan (1) >0
specifies upper one-sided tests, 
in which the alternative hypothesis indicates a mean greater than the null value, 
and upper one-sided confidence intervals between the lower confidence limit and infinity.*/
proc ttest data=riskfree9015 sides=u cochran ci=equal umpu;
      class d_jan;
      var mrt_rf_d SMB_d HML_d;
   run;

proc sort data=riskfree9015;
   by d_friday;
ods graphics on;   /*smb not reject friday smd has a higher stock return*/
proc ttest data=riskfree9015 cochran ci=equal umpu;
      class d_friday;
      var mrt_rf_d SMB_d HML_d;
   run;
ods graphics off;

ods graphics on;   /*reject smb*/
proc ttest data=riskfree9015 cochran ci=equal umpu;
      class d_monday;
      var mrt_rf_d SMB_d HML_d;
   run;
ods graphics off;

ods graphics on;   /*not rejected*/
proc ttest data=riskfree9015 cochran ci=equal umpu;
      class d_dec_jan;
      var mrt_rf_d SMB_d HML_d;
   run;
ods graphics off;

proc sort data=riskfree9015;
by month;
proc ttest data=riskfree9015 cochran ci=equal umpu;
      by month;
      var mrt_rf_d SMB_d HML_d;
   run;

proc sort data=riskfree9015;
   by weekday;
proc ttest data=riskfree9015 cochran ci=equal umpu;
      by weekday;
      var mrt_rf_d SMB_d HML_d;
   run;


