--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_WBP_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_WBP_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_WBP_MAIN
* Author                 :IBM(Roshan Khandare/Shailesh Solanki)
* Creation Date          :20-10-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Windows Bid Price data from ASB legacy system to C2M system.
*
* Calling Program        :PR_ASB_LOAD_WBP_MAIN.ksh
* Called Program         :
* Input files            :None
* Output files           :None
* Input Parameter        :CSV file receive status
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  20-10-2021     Roshan Khandare   V1.0
**************************************************************************************/
(P_CSV_FILE_NAME IN VARCHAR2,pi_csv_file_status IN NUMBER)
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  SELECT SQ_WBP_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  -- Update the latest load_seq_num in WBP_CSV table
  IF (pi_csv_file_status = 1) THEN
    UPDATE WINDOW_BID_PRICE_csv SET load_seq_nbr = lv_vc_load_seq_nbr;
  END IF;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_WBP_MAIN',NULL,NULL,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_LOAD_WBP_MAIN',lv_vc_load_seq_nbr,'Start...', 'WBP loading  process start');
  
  -- Remove duplicate records from CSV
    DELETE from window_bid_price_csv where rowid IN 
    (  select  min(rowid) from window_bid_price_csv group by SERVICE_TYPE, CONTRACT_NUMBER, CONTRACT_ID, START_DATE_TIME, END_DATE_TIME,UTILISATION_PRICE,MW having count(1) > 1) ;
  
  -- Remove Duplicate records with MW <= 0
    DELETE from window_bid_price_csv where (SERVICE_TYPE, CONTRACT_NUMBER, CONTRACT_ID, START_DATE_TIME, END_DATE_TIME) IN (
    select  SERVICE_TYPE, CONTRACT_NUMBER, CONTRACT_ID, START_DATE_TIME, END_DATE_TIME
    from window_bid_price_csv group by SERVICE_TYPE, CONTRACT_NUMBER, CONTRACT_ID, START_DATE_TIME, END_DATE_TIME having count(1) > 1) AND MW <=0 ;


  PR_MSM1_WBP(lv_vc_load_seq_nbr,substr(P_CSV_FILE_NAME, 1,25));

  MSM_STG1.PR_MSM1_TO_MSM2_WBP(lv_vc_load_seq_nbr);

  MSM_STG2.PR_WBP_STAG_TRN(lv_vc_load_seq_nbr);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_WBP_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;

 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_WBP_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'WINDOW_BID_PRICE');

  EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ROLLBACK;
        PR_PROCESS_LOG('PR_ASB_LOAD_WBP_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END;

/

