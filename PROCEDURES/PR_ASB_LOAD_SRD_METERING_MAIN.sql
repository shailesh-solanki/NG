--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_SRD_METERING_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_SRD_METERING_MAIN" (lv_vc_load_seq_nbr IN number,PI_EFFECTIVE IN DATE)
 /**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_SRD_METERING_MAIN
* Author                 :Shailesh Solanki
* Creation Date          :01-09-21
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(SRD METERING) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_SRD_METERING_MAIN .ksh
*
**************************************************************************************/
AS

--lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_SRD_METERING_MAIN',NULL,NULL,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING_MAIN',lv_vc_load_seq_nbr,'Start...', 'operational data(SRD METERING) loading  process start');

  PR_MSM1_OPR_METERING (lv_vc_load_seq_nbr,PI_EFFECTIVE);
    
  MSM_STG1.PR_MSM1_TO_MSM2_SRD_METERING(lv_vc_load_seq_nbr);

  MSM_STG2.PR_SRD_METERING_STAGING_TRN(lv_vc_load_seq_nbr);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_SRD_METERING_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_SRD_METERING_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'METERING');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
    ROLLBACK;
    PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);
    RAISE;

END PR_ASB_LOAD_SRD_METERING_MAIN;

/

