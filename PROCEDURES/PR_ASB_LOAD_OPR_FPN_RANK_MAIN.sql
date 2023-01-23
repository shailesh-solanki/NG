--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_FPN_RANK_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_FPN_RANK_MAIN" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_FPN_RANK_MAIN
* Author                 :IBM(Roshan Khandare)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(FPN) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_FPN_RANK_MAIN.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  15-09-2021     Roshan Khandare   Changes for Operational Data (FPN)
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  -- SELECT SQ_FPN_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;
  lv_vc_load_seq_nbr := PI_LOAD_SEQ_NBR;
  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OPR_FPN_RANK_MAIN',NULL,NULL,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_LOAD_OPR_FPN_RANK_MAIN',lv_vc_load_seq_nbr,'Start...', 'Operational Data(FPN) loading  process start');

--  PR_ASB_LOAD_OPR_BOA(lv_vc_load_seq_nbr,PI_EFFECTIVE,'FPN');

   PR_MSM1_OPR_FPN_RANK(lv_vc_load_seq_nbr,'FPNSTARTMIN',1);
   MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_FPN_RANK(lv_vc_load_seq_nbr,'FPNSTARTMIN');
   MSM_STG2.PR_MEASUREMENT_STAG_TRN_FPN(lv_vc_load_seq_nbr);

   PR_MSM1_OPR_FPN_RANK(lv_vc_load_seq_nbr,'FPNENDMIN',2);
   MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_FPN_RANK(lv_vc_load_seq_nbr,'FPNENDMIN');
   MSM_STG2.PR_MEASUREMENT_STAG_TRN_FPN(lv_vc_load_seq_nbr);

 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_OPR_FPN_RANK_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_FPN_RANK_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'FPN');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    ROLLBACK;
    PR_PROCESS_LOG('PR_ASB_LOAD_OPR_FPN_RANK_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END PR_ASB_LOAD_OPR_FPN_RANK_MAIN;

/
