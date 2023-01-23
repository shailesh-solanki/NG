--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_MIL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_MIL_MAIN" (PI_LOAD_SEQ_NBR IN NUMBER, PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_MIL_MAIN
* Author                 :IBM(Roshan Khandare)
* Creation Date          :01-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(MEL) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :ASB_LOAD_OPR_MEL_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  01-09-2021     Roshan Khandare   Changes for Operational Data (MEL)
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

--    SELECT SQ_MEL_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;
    lv_vc_load_seq_nbr := PI_LOAD_SEQ_NBR;
  -- Insert a row in LOAD_DETAILS Table for new load_sequence
    INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OPR_MIL_MAIN',NULL,NULL,SYSDATE);

    PR_PROCESS_LOG('PR_ASB_LOAD_OPR_MIL_MAIN',lv_vc_load_seq_nbr,'Start...', 'Operational Data(MIL) loading  process start');

--  PR_ASB_OPR_LOAD_MEL(lv_vc_load_seq_nbr,PI_EFFECTIVE);

    -- RANK 1
    PR_MSM1_OPR_MIL(lv_vc_load_seq_nbr,'MILSTARTMIN',1);
    MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_MIL(lv_vc_load_seq_nbr,'MILSTARTMIN');
    MSM_STG2.PR_MEASUREMENT_STAG_TRN_MIL(lv_vc_load_seq_nbr);

    -- RANK 2
    PR_MSM1_OPR_MIL(lv_vc_load_seq_nbr,'MILENDMIN',2);
    MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_MIL(lv_vc_load_seq_nbr,'MILENDMIN');
    MSM_STG2.PR_MEASUREMENT_STAG_TRN_MIL(lv_vc_load_seq_nbr);

    select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_OPR_MIL_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
    INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_MIL_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'MIL');

 EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    ROLLBACK;
    PR_PROCESS_LOG('PR_ASB_LOAD_OPR_MIL_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END PR_ASB_LOAD_OPR_MIL_MAIN;

/

