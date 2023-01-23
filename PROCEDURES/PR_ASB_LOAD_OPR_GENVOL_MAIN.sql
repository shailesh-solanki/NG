--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_GENVOL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_GENVOL_MAIN" (v_LOAD_SEQ NUMBER, v_MEASR_COMP_TYPE_CD VARCHAR2,p_DATE DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_GENVOL_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :25-08-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(SPBMU - Expected Volume) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_OPR_SPBMU_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  26-05-2021     Shailesh Solanki   Changes for Operational Data (SPBMU - Expected Volume)
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;
v_PARTITION_NAME VARCHAR2(20);

BEGIN

    -- Load Seq No. for EXPVOL Data load
  -- SELECT SQ_EXPVOL_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;
  lv_vc_load_seq_nbr := v_LOAD_SEQ ;

  -- Partition name string creation
--  v_PARTITION_NAME := 'SP_BMU_STG' || to_char(p_DATE,'_MON_YYYY');

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OPR_GENVOL_MAIN',NULL,NULL,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_GENVOL_MAIN - ' || v_MEASR_COMP_TYPE_CD,lv_vc_load_seq_nbr,'Start...', 'Operational Data(Expected Volume) loading  process start',v_MEASR_COMP_TYPE_CD);

  PR_MSM1_OPR_GEN_VOLUME(lv_vc_load_seq_nbr,v_MEASR_COMP_TYPE_CD);

  MSM_STG1.PR_MSM1_TO_MSM2_MEASUREMENT(lv_vc_load_seq_nbr, v_MEASR_COMP_TYPE_CD);

  -- CISADM
  MSM_STG2.PR_MEASUREMENT_STAG_TRN (lv_vc_load_seq_nbr, v_MEASR_COMP_TYPE_CD);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_OPR_GENVOL_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;

 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_GENVOL_MAIN - ' || v_MEASR_COMP_TYPE_CD,lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,v_MEASR_COMP_TYPE_CD);

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    ROLLBACK;
    PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_GENVOL_MAIN - ' || v_MEASR_COMP_TYPE_CD,lv_vc_load_seq_nbr,'FAILURE', v_ERROR,v_MEASR_COMP_TYPE_CD);

END PR_ASB_LOAD_OPR_GENVOL_MAIN;

/

