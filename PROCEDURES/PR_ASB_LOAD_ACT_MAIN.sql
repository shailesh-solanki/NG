--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_ACT_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_ACT_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_ACT_MAIN
* Author                 :IBM(Shailesh Solanki/Roshan Khandare)
* Creation Date          :06-08-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate accepted tenders data from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :ASB_LOAD_ACT_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :CSV file receive status
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 25-10-2021      Anish Kumar S     Modified for fetching CSV file Name
**************************************************************************************/
(
pi_csv_file_status IN NUMBER
,PI_CSV_FILE_NAME_DT in varchar2 -- Added by Anish Kumar S on 25-10-2021
)
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

v_CSV_FILE_NAME_DT varchar2(100);    -- Added by Anish Kumar S on 25-10-2021

csv_cnt number;

BEGIN
  
  SELECT SQ_ACT_TENDER_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;
--lv_vc_load_seq_nbr:=499;
    select count(*) into csv_cnt from stor_accepted_tenders_csv;
  
   -- Update the latest load_seq_num in ACT_CSV table
  IF (pi_csv_file_status = 1) THEN
    UPDATE stor_accepted_tenders_csv SET load_seq_nbr = lv_vc_load_seq_nbr;
  END IF;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_ACT_MAIN',csv_cnt,NULL,SYSDATE); -- csv_cnt added by Anish 

  PR_PROCESS_LOG('PR_ASB_LOAD_ACT_MAIN',lv_vc_load_seq_nbr,'Start...', 'ACT loading  process start');
  
  PR_TRN_ACCEPTED_TENDER(lv_vc_load_seq_nbr);

  PR_MSM1_ACCEPTED_TENDERS(lv_vc_load_seq_nbr, substr(PI_CSV_FILE_NAME_DT, 1,29));

  MSM_STG1.PR_MSM1_TO_MSM2_ACPTD_TENDERS(lv_vc_load_seq_nbr);

  MSM_STG2.PR_ACCPT_TENDER_STAG_TRN(lv_vc_load_seq_nbr);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_ACT_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_ACT_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE, 'ACT');
 
EXCEPTION
    WHEN OTHERS then
        ROLLBACK;
        PR_PROCESS_LOG('PR_ASB_LOAD_ACT_MAIN',lv_vc_load_seq_nbr,'FAILURE', SQLERRM,'ACT');
END;

/

