--------------------------------------------------------
--  DDL for Procedure PR_MSM1_TO_MSM2_MSRMT_MEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_TO_MSM2_MSRMT_MEL" (PI_LOAD_SEQ_NBR IN NUMBER,p_MEASR_COMP_TYPE_CD IN VARCHAR2)AS
BEGIN
/**************************************************************************************
*
* Program Name           :PR_MSM1_TO_MSM2_MSRMT_MEL
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :04-09-2021
* Description            :This is a PL/SQL procedure. This procedure transfer D1_MSRMT_MEL OF MEL data
*                         from MSM_STG1 tables to MSM_STG2 tables.
*
* Calling Program        :PR_ASB_LOAD_OPR_MEL_MAIN
* Called Program         :None
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :pi_load_seq_nbr
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
  DELETE FROM MSM_STG2.D1_MSRMT_MEL;
  -- Truncate Table D1_MSRMT
  --MSM_STG2.do_truncate('D1_MSRMT_MEL');

  --Inserting records into D1_MSRMT TABlE in MSM_STG2 schema
  INSERT INTO MSM_STG2.D1_MSRMT_MEL
  SELECT MEASR_COMP_ID,MSRMT_DTTM,BO_STATUS_CD,MSRMT_COND_FLG,MSRMT_USE_FLG,MSRMT_LOCAL_DTTM,MSRMT_VAL,' ',PREV_MSRMT_DTTM
        ,MSRMT_VAL1,MSRMT_VAL2,MSRMT_VAL3,MSRMT_VAL4,MSRMT_VAL5,MSRMT_VAL6,MSRMT_VAL7,MSRMT_VAL8,MSRMT_VAL9,MSRMT_VAL10,BUS_OBJ_CD,CRE_DTTM,
         STATUS_UPD_DTTM,USER_EDITED_FLG,VERSION,LAST_UPDATE_DTTM,READING_VAL,COMBINED_MULTIPLIER,READING_COND_FLG
  FROM MSM_STG1.D1_MSRMT_MEL
  WHERE LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR
  AND trim(ORIG_INIT_MSRMT_ID)=p_MEASR_COMP_TYPE_CD;

  ASB_STG.PR_PROCESS_LOG('PR_MSM1_TO_MSM2_MSRMT_MEL',pi_load_seq_nbr,'SUCCESS', 'Measurement data migrated successfully from MSM_STG1 to MSM_STG2 schema');
--EXCEPTIONS
EXCEPTION
   WHEN OTHERS then
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_TO_MSM2_MSRMT_MEL',pi_load_seq_nbr,'FAILURE', 'Failed while migrating Measurement data  from MSM_STG1 to MSM_STG2 schema');

END PR_MSM1_TO_MSM2_MSRMT_MEL;

/

