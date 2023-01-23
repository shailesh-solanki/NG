--------------------------------------------------------
--  DDL for Procedure PR_MSM1_PUB_HOLIDAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_PUB_HOLIDAY" (PI_LOAD_SEQ_NBR IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_MSM1_PUB_HOLIDAY
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :22-03-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M tables.
                          And it transpers the data from ASB_PH_STG To Two different tables(CI_CAL_HOL,CI_CAL_HOL_L) of MSM_STG1 Schema
*                        
*
* Calling Program        :None
* Called Program         :PR_PUBLIC_HOD_MAIN
*                         
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS
BEGIN

INSERT INTO MSM_STG1.CI_CAL_HOL(LOAD_SEQ_NBR,HOLIDAY_DT,CALENDAR_CD,VERSION,HOLIDAY_ST_DT,HOLIDAY_END_DT,DATE_CREATED)
SELECT pi_load_seq_nbr,HOLIDAY_DT,'STOR',99,HOLIDAY_DT,HOLIDAY_DT+1,DATE_CREATED FROM ASB_STG.ASB_PH_STG WHERE  WORK_FLAG <> 1  AND LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

INSERT INTO MSM_STG1.CI_CAL_HOL(LOAD_SEQ_NBR,HOLIDAY_DT,CALENDAR_CD,VERSION,HOLIDAY_ST_DT,HOLIDAY_END_DT,DATE_CREATED)
SELECT pi_load_seq_nbr,HOLIDAY_DT,'GLOBAL',99,HOLIDAY_DT,HOLIDAY_DT+1,DATE_CREATED FROM ASB_STG.ASB_PH_STG 
WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;


INSERT INTO MSM_STG1.CI_CAL_HOL_L(LOAD_SEQ_NBR,HOLIDAY_DT,CALENDAR_CD,LANGUAGE_CD,HOLIDAY_NAME,VERSION,DATE_CREATED)
SELECT pi_load_seq_nbr,HOLIDAY_DT,'STOR','ENG',HOLIDAY_NAME,99,DATE_CREATED FROM ASB_STG.ASB_PH_STG 
WHERE WORK_FLAG <> 1  AND LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

INSERT INTO MSM_STG1.CI_CAL_HOL_L(LOAD_SEQ_NBR,HOLIDAY_DT,CALENDAR_CD,LANGUAGE_CD,HOLIDAY_NAME,VERSION,DATE_CREATED)
SELECT pi_load_seq_nbr,HOLIDAY_DT,'GLOBAL','ENG',HOLIDAY_NAME,99,DATE_CREATED FROM ASB_STG.ASB_PH_STG
WHERE  LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;


PR_PROCESS_LOG('PR_MSM1_PUB_HOLIDAY',PI_LOAD_SEQ_NBR,'SUCCESS', 'Publc holiday data migrated successfully from ASB_STG to MSM_STG1 schema');

  EXCEPTION
    WHEN OTHERS then

    PR_PROCESS_LOG('PR_MSM1_PUB_HOLIDAY',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from ASB_STG to MSM_STG1 schema');
END;

/

