--------------------------------------------------------
--  DDL for Procedure PR_PUBLIC_HOD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_PUBLIC_HOD" (PI_LOAD_SEQ_NBR IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_PUBLIC_HOD
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :22-03-2021
* Description            :This is a PL/SQL procedure. This procedure takes data from
                          ASB_PUBLIC_HOLIDAY(ASB Legacy system) and loads into ASB_PH_STG
*                        
*
* Calling Program        :None
* Called Program         PR_PUBLIC_HOD_MAIN
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

lv_vc_rec_processed number(10);

BEGIN

MERGE INTO ASB_PH_STG S2--target table
  USING (SELECT HOLIDAY_DATE,HOLIDAY_DESC,WORK_FLAG FROM ASB_PUBLIC_HOLIDAY) S1
  ON(s2.HOLIDAY_DT=s1.HOLIDAY_DATE )
WHEN MATCHED THEN
  UPDATE SET LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR, HOLIDAY_NAME = s1.HOLIDAY_DESC, DATE_CREATED = SYSDATE  WHERE HOLIDAY_NAME <>S1.HOLIDAY_DESC
WHEN NOT MATCHED THEN
  INSERT(LOAD_SEQ_NBR,HOLIDAY_DT,HOLIDAY_NAME,WORK_FLAG,DATE_CREATED)
  VALUES(PI_LOAD_SEQ_NBR,S1.HOLIDAY_DATE,S1.HOLIDAY_DESC,S1.WORK_FLAG,SYSDATE);

select count(distinct holiday_dt) into lv_vc_rec_processed from ASB_PH_STG  where load_seq_nbr = PI_LOAD_SEQ_NBR;  
  UPDATE LOAD_DETAILS SET REC_PROCESSED = lv_vc_rec_processed, REC_REJECTED = 0 WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

  PR_PROCESS_LOG('PR_PUBLIC_HOD',PI_LOAD_SEQ_NBR,'SUCCESS', 'Publc holiday data migrated successfully from legacy to ASB_STG schema');

  EXCEPTION
    WHEN OTHERS then

    PR_PROCESS_LOG('PR_PUBLIC_HOD',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');
end;

/

