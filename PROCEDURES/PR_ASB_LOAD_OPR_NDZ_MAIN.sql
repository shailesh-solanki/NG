--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_NDZ_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_NDZ_MAIN" (pi_load_seq_nbr NUMBER, pi_effective date,pi_end_date date)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_NDZ_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :25-05-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(NDZ) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_OPR_NDZ_Main.ksh
*
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  26-05-2021     Shailesh Solanki   Changes for Operational Data (NDZ)
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  lv_vc_load_seq_nbr := pi_load_seq_nbr;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OPR_NDZ_MAIN',NULL,NULL,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_NDZ_MAIN',lv_vc_load_seq_nbr,'Start...', 'Operational Data(NDZ) loading  process start','NDZ');

--  PR_ASB_LOAD_OPR_NDZ(pi_load_seq_nbr,pi_effective,pi_end_date);

  PR_MSM1_OPR_NDZ(pi_load_seq_nbr);

  MSM_STG1.PR_MSM1_TO_MSM2_OPR_NDZ(pi_load_seq_nbr);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_OPR_NDZ_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_NDZ_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'NDZ');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
    ROLLBACK;
    PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_NDZ_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR,'NDZ');
    RAISE;
END PR_ASB_LOAD_OPR_NDZ_MAIN;

/
