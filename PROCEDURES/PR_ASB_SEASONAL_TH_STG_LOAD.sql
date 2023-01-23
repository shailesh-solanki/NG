--------------------------------------------------------
--  DDL for Procedure PR_ASB_SEASONAL_TH_STG_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_SEASONAL_TH_STG_LOAD" 
/**************************************************************************************
*
* Program Name           :PR_ASB_SEASONAL_TH_STG_LOAD
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Seasonal threshold data to C2M system.
*
* Calling Program        :None
* Called Program         :PR_SEASONAL_THRESHOLD_MAIN
*
*
* Input files            :PI_LOAD_SEQ_NBR
* Output files           :None
* Input Parameter        :NOne
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(PI_LOAD_SEQ_NBR IN VARCHAR2)
AS

LV_VC_REC_PROCESSED NUMBER(10);
v_CNT_REC NUMBER:=0;

BEGIN


    MERGE INTO SRS_SEASONAL_THRESHOLD_STG S2--target table
      using (select EFFECTIVE,THRESHOLD from SRS_SEASONAL_THRESHOLD) S1
      ON(S2.EFFECTIVE_DATE=S1.EFFECTIVE)
    when matched then
      UPDATE SET LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR,THRESHOLD= S1.THRESHOLD, DATE_CREATED = SYSDATE
      WHERE S1.THRESHOLD <> S2.THRESHOLD

    WHEN NOT MATCHED THEN
      insert(LOAD_SEQ_NBR,EFFECTIVE_DATE,THRESHOLD,DATE_CREATED)
      values(PI_LOAD_SEQ_NBR,S1.EFFECTIVE,S1.THRESHOLD,sysdate);


      MERGE into SRS_METER_TOLERANCE_STG S2--target table
      USING (SELECT EFFECTIVE,METER_TOLERANCE FROM SRS_METER_TOLERANCE) S1
      ON(S2.EFFECTIVE_DATE = S1.EFFECTIVE)
    when matched then
      UPDATE SET LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR, METER_TOLERANCE= S1.METER_TOLERANCE, DATE_CREATED = SYSDATE
      WHERE S1.METER_TOLERANCE <> S2.METER_TOLERANCE

    WHEN NOT MATCHED THEN
      INSERT(LOAD_SEQ_NBR,EFFECTIVE_DATE,METER_TOLERANCE,DATE_CREATED)
      VALUES(PI_LOAD_SEQ_NBR,S1.EFFECTIVE,S1.METER_TOLERANCE,SYSDATE);

      MERGE into SRS_ACPT_PENALTY_STG S2--target table
      USING (SELECT EFFECTIVE,ACPT_PENALTY_DURATION FROM SRS_ACPT_PENALTY) S1
      ON(S2.EFFECTIVE_DATE = S1.EFFECTIVE)
    when matched then
      UPDATE SET LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR, ACCEPTED_PENALTY_DURATION  = S1.ACPT_PENALTY_DURATION , DATE_CREATED = SYSDATE
      WHERE S2.ACCEPTED_PENALTY_DURATION <>S1.ACPT_PENALTY_DURATION

    WHEN NOT MATCHED THEN
      insert(LOAD_SEQ_NBR,EFFECTIVE_DATE,ACCEPTED_PENALTY_DURATION,DATE_CREATED)
      VALUES(PI_LOAD_SEQ_NBR,S1.EFFECTIVE,S1.ACPT_PENALTY_DURATION,SYSDATE);

  V_CNT_REC := 0;
  select count(distinct effective_date) into v_CNT_REC from SRS_SEASONAL_THRESHOLD_STG  where load_seq_nbr = PI_LOAD_SEQ_NBR;

  lv_vc_rec_processed := v_CNT_REC;

  SELECT COUNT(DISTINCT EFFECTIVE_DATE) INTO v_CNT_REC FROM  SRS_METER_TOLERANCE_STG  WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

  lv_vc_rec_processed := lv_vc_rec_processed + v_CNT_REC;

  SELECT COUNT(DISTINCT EFFECTIVE_DATE) INTO v_CNT_REC FROM SRS_METER_TOLERANCE_STG  WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

  lv_vc_rec_processed := lv_vc_rec_processed + v_CNT_REC;

  UPDATE LOAD_DETAILS SET REC_PROCESSED = LV_VC_REC_PROCESSED, REC_REJECTED = 0 WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR
  AND LOAD_DESC = 'PR_SEASONAL_THRESHOLD_MAIN';

  PROC_PROCESS_LOG('PR_ASB_SEASONAL_TH_STG_LOAD',PI_LOAD_SEQ_NBR,'SUCCESS', 'Seasonal threshold data migrated successfully from legacy to ASB_STG schema','SEASONAL_THRESHOLD');

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    PROC_PROCESS_LOG('PR_ASB_SEASONAL_TH_STG_LOAD',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema','SEASONAL_THRESHOLD');

END;

/

