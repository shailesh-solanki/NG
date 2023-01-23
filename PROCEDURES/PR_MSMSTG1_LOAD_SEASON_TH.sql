--------------------------------------------------------
--  DDL for Procedure PR_MSMSTG1_LOAD_SEASON_TH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSMSTG1_LOAD_SEASON_TH" 
/**************************************************************************************
*
* Program Name           :PR_MSMSTG1_LOAD_SEASON_TH
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M tables.
                          And it transpers the data from ASB_STG Schema  To MSM_STG1 Schema
*                        
*
* Calling Program        :None
* Called Program         :PR_SEASONAL_THRESHOLD_MAIN
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(PI_LOAD_SEQ_NBR IN VARCHAR2)

AS
LV_VC_REC_PROCESSED NUMBER(10);
IC_EFF_DTTM date;
input_date  DATE;


BEGIN
--Inserting data into D1_FACTOR_VALUE From srs_seasonal_threshold_stg table
  INSERT INTO  MSM_STG1.D1_FACTOR_VALUE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
SELECT PI_LOAD_SEQ_NBR,'SRP_STOR_SEASON_THRESHOLD','CM-NA','NA',
FN_CONVERT_GMT_BST1 (EFFECTIVE_DATE),'D1-FactorValueNumber',THRESHOLD,' ',' ',99,' ',' ',SYSDATE FROM ASB_STG.srs_seasonal_threshold_stg WHERE LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR;

  --Inserting data into D1_FACTOR_VALUE From srs_seasonal_threshold_stg table
 INSERT INTO MSM_STG1.D1_FACTOR_VALUE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
  SELECT PI_LOAD_SEQ_NBR,'SRP_STOR_METER_TOLERANCE','CM-NA','NA',
   FN_CONVERT_GMT_BST1 (EFFECTIVE_DATE),'D1-FactorValueNumber',METER_TOLERANCE,' ',' ',99,' ',' ',SYSDATE FROM ASB_STG.SRS_METER_TOLERANCE_STG where load_seq_nbr=pi_load_seq_nbr;

  INSERT INTO MSM_STG1.D1_FACTOR_VALUE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
   SELECT PI_LOAD_SEQ_NBR,'SRP_STOR_ACPT_PENALTY','CM-NA','NA',
   FN_CONVERT_GMT_BST1 (EFFECTIVE_DATE) ,'D1-FactorValueNumber',ACCEPTED_PENALTY_DURATION,' ',' ',99,' ',' ',SYSDATE FROM ASB_STG.SRS_ACPT_PENALTY_STG where load_seq_nbr=pi_load_seq_nbr;


   SELECT COUNT(EFF_DTTM) INTO LV_VC_REC_PROCESSED FROM MSM_STG1.D1_FACTOR_VALUE 
   WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR; 


  UPDATE LOAD_DETAILS SET REC_PROCESSED = LV_VC_REC_PROCESSED, REC_REJECTED = 0   
  WHERE LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;


  PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_SEASON_TH',PI_LOAD_SEQ_NBR,'SUCCESS', 'Seasonal threshold data migrated successfully from ASB_STG to MSM_STG1 schema','SEASONAL_THRESHOLD');



  EXCEPTION
    WHEN OTHERS THEN

    PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_SEASON_TH',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from ASB_STG to MSM_STG1 schema','SEASONAL_THRESHOLD');

END;

/

