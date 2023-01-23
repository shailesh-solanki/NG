--------------------------------------------------------
--  DDL for Procedure PR_SEASONAL_THRESHOLD_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_SEASONAL_THRESHOLD_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_SEASONAL_THRESHOLD_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Seasonal threshold data to C2M system.
*
* Calling Program        :None
* Called Program         :ASB_LOAD_SEASONAL_THRESHOLD_Main.ksh
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
as
v_date  DATE;
v_LOAD_SEQ_NBR NUMBER;
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  -- Generate a new LOAD_SEQ_NBR
    SELECT SQ_SEASON_TH_LOAD_SEQNO.nextval into v_LOAD_SEQ_NBR from dual;

    -- Insert a row in LOAD_DETAILS Table for new load_sequence
    INSERT into LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) values (v_LOAD_SEQ_NBR,'PR_SEASONAL_THRESHOLD_MAIN',NULL,NULL,SYSDATE);


    PROC_PROCESS_LOG('PR_SEASONAL_THRESHOLD_MAIN',v_LOAD_SEQ_NBR,'Start...', 'Seasonal threshold loading process start','SEASONAL_THRESHOLD');
    -- Calling the Procedure PR_ASB_SEASONAL_TH_STG_LOAD to load data into SRS_SEASONAL_THRESHOLD_STG, SRS_METER_TOLERANCE_STG,SRS_ACPT_PENALTY_STG tables
    PR_ASB_SEASONAL_TH_STG_LOAD(v_LOAD_SEQ_NBR);

    -- Calling the Procedure PR_MSMSTG1_LOAD_SEASON_TH to load data into D1_FACTOR_VALUE table
    PR_MSMSTG1_LOAD_SEASON_TH(v_LOAD_SEQ_NBR);

     -- Calling PROCEDURE PR_SEASON_TH_DATA_TRANS to load data in MSM_STG2 Tables
    MSM_STG1.PR_SEASON_TH_DATA_TRANS(v_LOAD_SEQ_NBR);

--    MSM_STG2.PR_MSM2_SEASONAL_TRANS(v_LOAD_SEQ_NBR);

   select proc_seq_nbr into v_proc_seq_nbr from process_log where proc_name = 'PR_SEASONAL_THRESHOLD_MAIN' and load_seq_nbr = v_LOAD_SEQ_NBR;

  INSERT INTO PROCESS_LOG
    VALUES(v_proc_seq_nbr,'PR_SEASONAL_THRESHOLD_MAIN',v_LOAD_SEQ_NBR,'SUCCESS', 'All the process executed successfully',SYSDATE,'SEASONAL_THRESHOLD');


  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,120);
    ROLLBACK;
    PROC_PROCESS_LOG('PR_SEASONAL_THRESHOLD_MAIN',v_LOAD_SEQ_NBR,'FAILURE', v_ERROR,'SEASONAL_THRESHOLD');


END PR_SEASONAL_THRESHOLD_MAIN ;

/
