--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_RESOURCE_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_RESOURCE_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_RESOURCE_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate RESOURCE data from ASB legacy system to C2M system.
* Called Program         :ASB_LOAD_RESOURCE_Main.ksh
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(pi_csv_file_status IN NUMBER)
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  SELECT SQ_RESOURCE_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  -- Update the latest load_seq_num in RESOURCE_CSV table
  IF (pi_csv_file_status = 1) THEN
    UPDATE resource_csv SET load_seq_nbr = lv_vc_load_seq_nbr;
  END IF;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_RESOURCE_MAIN',NULL,NULL,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_LOAD_RESOURCE_MAIN',lv_vc_load_seq_nbr,'Start...', 'Resource loading  process start','RESOURCE');

  PR_ASB_RESOURCE_LOAD(lv_vc_load_seq_nbr);
  COMMIT;
  
  -- Call Proc PR_ASB_RESOURCE_ERR_CHK for error code check
  PR_ASB_RESOURCE_ERR_CHK(lv_vc_load_seq_nbr);

  -- Generate a file for rejected records
  --PR_ASB_GEN_REJECT_FILE(lv_vc_load_seq_nbr,'109','RESOURCE','RESOURCE_CSV');

  PR_TRN_RESOURCE_LOAD(lv_vc_load_seq_nbr);

  PR_MSMSTG1_LOAD_RESOURCE(lv_vc_load_seq_nbr);
    COMMIT;

  MSM_STG1.PR_RESOURCE_DATA_TRANS(lv_vc_load_seq_nbr);
    COMMIT;

--  MSM_STG2.PR_RESOURCE_STAGING_TRN(lv_vc_load_seq_nbr);
    COMMIT;
 
 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_RESOURCE_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 
 --PROCESS_LOG table entry
  INSERT INTO PROCESS_LOG(PROC_SEQ_NBR, PROC_NAME, LOAD_SEQ_NBR, STATUS, STATUS_DESCRIPTION, DATE_CREATED, ENTITY_NAME) 
  VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_RESOURCE_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'RESOURCE');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,500);
    ROLLBACK;
    PROC_PROCESS_LOG('PR_ASB_LOAD_RESOURCE_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR,'RESOURCE');
    RAISE;
END;

/

