/*********************************************************************/
/* Study:        Generic                                             */
/* Program Name: Call_Definexml.sas                                   */
/* Description:  Create meta dataset of SDTM variables from CDISC    */
/*********************************************************************/
/* Disclaimer:   This program is the sole property of LEO Pharma A/S */
/*               and may not be copied or made available to any      */
/*               third party without written consent.                */
/*********************************************************************/
/* PARAM_DESCRIPTIONS
inputfile  ..\..\Data\Define Data\*.*
inputfile  ..\..\Data\Define Data\SDTM_IG.xls
inputfile  ..\..\Data\Define Data\SDTM Terminology.xls
inputfile  ..\..\Data\SDTM NDA 2017\*.sas7bdat
inputfile  ..\..\Data\Define Data\CRF_Codes.xlsx
outputfile ..\..\Data\Define Data\new_define.xlsx
**********************************************************************/;
libname nda  '..\..\Data\SDTM NDA 2017';
libname meta '..\..\Programs\DefineXML';
%include "..\..\Programs\DefineXML\DefineXML.sas";
*Macro to retrive latest define-* file from the Define data folder -Code starts;

%global lastfile;

%macro memlistd(curlib);
  %if %sysfunc(fexist(&curlib.)) %then %do;
    data templist;
      length memname $50   ;
      %let did=%sysfunc(dopen(&curlib)); /*open the directory*/
      %let memcount=%sysfunc(dnum(&did));/*count the members*/
      %if &memcount > 0 %then
        %do;
          %put NOTE: creating templist with list of members in &curlib.:;
          %do i=1 %to &memcount;/*list the members  */
            memname = "%sysfunc(dread(&did,&i.)) "; output;
        %end;
        %let rc=%sysfunc(dclose(&did));/*close the directory*/
    run;
    proc sort data=templist (where=( memname like 'define-%' )); 
      by descending memname;
    run;
    data _null_;
      set templist (obs=1);
      call symput ('lastfile', memname);
    run;
  %end;
  %else %do;
    %put NOTE: &curlib is empty;
    stop;run;
  %end;
  %let rc=%sysfunc(dclose(&did));  /* close the directory*/
  %end;  
  %else %do;
  %put NOTE: &curlib does not exist;
  %end;
%mend;
*macro code ends;
filename defdata "..\..\data\Define Data"; 
%memlistd(defdata);
%put &lastfile.;

%defineXML (indata=%str(&lastfile.));
