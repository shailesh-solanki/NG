--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OWNER_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OWNER_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OWNER_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-04-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures 
*                         which are using to migrate owner data from ASB legacy system to C2M system.
*
* Called Program         :ASB_LOAD_OWNER_Main.ksh
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(pi_csv_file_status IN number)
as

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN
  SELECT SQ_OWNER_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  -- Update the latest load_seq_num in OWNER_CSV table
  IF (pi_csv_file_status = 1) THEN
    UPDATE OWNER_CSV SET load_seq_nbr = lv_vc_load_seq_nbr;
    COMMIT;
  END IF;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OWNER_MAIN',NULL,NULL,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_LOAD_OWNER_MAIN',lv_vc_load_seq_nbr,'Start...', 'OWNER loading process start','OWNER');

  -- Call Proc PR_ASB_RESOURCE_ERR_CHK for error code check
  PR_ASB_OWNER_ERR_CHK(lv_vc_load_seq_nbr);

  -- Generate a file for rejected records
--  PR_ASB_GEN_REJECT_FILE(lv_vc_load_seq_nbr,'99,109,111','OWNER','OWNER_CSV');

  PR_TRN_OWNER_LOAD(lv_vc_load_seq_nbr);

  PR_MSMSTG1_LOAD_OWNER(lv_vc_load_seq_nbr);

  MSM_STG1.PR_OWNER_DATA_TRANS(lv_vc_load_seq_nbr);

  MSM_STG2.PR_MSM2_OWNER_TRANS(lv_vc_load_seq_nbr);

  select proc_seq_nbr into v_proc_seq_nbr from process_log where proc_name ='PR_ASB_LOAD_OWNER_MAIN' AND  load_seq_nbr = lv_vc_load_seq_nbr;

   INSERT INTO PROCESS_LOG 
    VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OWNER_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'OWNER');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
    ROLLBACK;
    PROC_PROCESS_LOG('PR_ASB_LOAD_OWNER_MAIN',pi_csv_file_status,'FAILURE', v_ERROR,'OWNER');
    RAISE;
END;

/
