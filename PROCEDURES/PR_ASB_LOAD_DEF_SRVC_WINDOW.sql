--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_DEF_SRVC_WINDOW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_DEF_SRVC_WINDOW" (PI_LOAD_SEQ_NBR NUMBER)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_DEF_SRVC_WINDOW
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :28-06-2021
* Description            :This is a PL/SQL procedure. This procedure loads Default service window data 
*                         From ASB legacy system to  asb_stg schema
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_DSW_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS 
BEGIN

 --Loads data into ASB_SEASON_STG Table in ASB_STG schema
    MERGE INTO ASB_SEASON_STG S2
    USING (SELECT SEASON_SEQ,SERVICE_CODE,fn_convert_gmt_bst1(EFFECTIVE) as effective,FINANCIAL_YEAR,SEASON_NUMBER,SUPPLEMENTARY FROM ASB_SEASON  
            WHERE SERVICE_CODE IN('SRBM','SRNM')) S1
    ON(S2.SEASON_SEQ=S1.SEASON_SEQ)
       WHEN MATCHED THEN 
   UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,SERVICE_CODE=S1.SERVICE_CODE,EFFECTIVE=S1.EFFECTIVE,FINANCIAL_YEAR=S1.FINANCIAL_YEAR,
               SEASON_NUMBER=S1.SEASON_NUMBER, SUPPLEMENTARY=S1.SUPPLEMENTARY
                WHERE  (nvl(S2.SERVICE_CODE,'checknull') <> nvl(S1.SERVICE_CODE,'checknull')) Or 
                (nvl(s2.EFFECTIVE,'checknull')<>nvl(s1.EFFECTIVE,'checknull')) or  
                (nvl(s2.FINANCIAL_YEAR,'checknull')<>nvl(s1.FINANCIAL_YEAR,'checknull')) or
                (nvl(s2.SEASON_NUMBER,'checknull')<> nvl(s1.SEASON_NUMBER,'checknull'))
       WHEN NOT MATCHED THEN
    INSERT( LOAD_SEQ_NBR,SEASON_SEQ,SERVICE_CODE,EFFECTIVE,FINANCIAL_YEAR,SEASON_NUMBER,SUPPLEMENTARY,DATE_CREATED )
    VALUES(PI_LOAD_SEQ_NBR,S1.SEASON_SEQ,S1.SERVICE_CODE,S1.EFFECTIVE,S1.FINANCIAL_YEAR,S1.SEASON_NUMBER,S1.SUPPLEMENTARY,SYSDATE);

 --Loads data into ASB_DUTY_WINDOW_STG Table in ASB_STG schema
    MERGE INTO ASB_DUTY_WINDOW_STG S2
     USING (SELECT SEASON_SEQ,DAY_CODE,START_LOCAL,END_LOCAL,SERVICE_PERIOD,CONTRACT_SEQ,WEEK_DAY_CODE FROM ASB_DUTY_WINDOW 
                   WHERE DAY_CODE IN ('WD','NWD')) S1
     ON(S2.SEASON_SEQ=S1.SEASON_SEQ AND S2.DAY_CODE=S1.DAY_CODE AND S2.WEEK_DAY_CODE=S1.WEEK_DAY_CODE AND S2.CONTRACT_SEQ=S1.CONTRACT_SEQ AND
        S2.START_LOCAL=S1.START_LOCAL)
     WHEN MATCHED THEN 
   UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,END_LOCAL=S1.END_LOCAL,SERVICE_PERIOD=S1.SERVICE_PERIOD
         WHERE (nvl(s2.END_LOCAL,'checknull')<>nvl(s1.END_LOCAL,'checknull')) or 
               (nvl(s2.SERVICE_PERIOD,'checknull')<>nvl(s1.SERVICE_PERIOD,'checknull'))
      WHEN NOT MATCHED THEN
    INSERT( LOAD_SEQ_NBR,SEASON_SEQ,DAY_CODE,START_LOCAL,END_LOCAL,SERVICE_PERIOD,CONTRACT_SEQ,WEEK_DAY_CODE,DATE_CREATED )
    VALUES(PI_LOAD_SEQ_NBR,S1.SEASON_SEQ,S1.DAY_CODE,S1.START_LOCAL,S1.END_LOCAL,S1.SERVICE_PERIOD,S1.CONTRACT_SEQ,S1.WEEK_DAY_CODE,SYSDATE);


   ASB_STG.PROC_PROCESS_LOG(' PR_ASB_LOAD_DEF_SRVC_WINDOW',pi_load_seq_nbr,'SUCCESS', 'Default service window  data migrated successfully from ASB legacy system to ASB_STG schema','DSW');
--Exception
  EXCEPTION
   WHEN OTHERS then
        ASB_STG.PROC_PROCESS_LOG(' PR_ASB_LOAD_DEF_SRVC_WINDOW',pi_load_seq_nbr,'FAILURE', 'Failed while migrating Default service window  data from ASB legacy system to ASB_STG schema','DSW');

 END PR_ASB_LOAD_DEF_SRVC_WINDOW;

/

