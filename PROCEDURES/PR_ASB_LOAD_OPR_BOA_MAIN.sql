--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_BOA_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_BOA_MAIN" (PI_LOAD_SEQ_NBR IN NUMBER , PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_BOA_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate BOA Rank from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : PR_ASB_LOAD_OPR_BOA_MAIN.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  16-09-2021    Shailesh Solanki       Changes for BOA Rank
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

    lv_vc_load_seq_nbr := PI_LOAD_SEQ_NBR;

    --Insert a row in LOAD_DETAILS Table for new load_sequence
   INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED)
    VALUES (lv_vc_load_seq_nbr,'PR_ASB_BOA_RANK_MAIN',NULL,NULL,SYSDATE);

   PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BOA_MAIN',lv_vc_load_seq_nbr,'Start...', 'BOA Rank loading  process start');

    dbms_output.put_line('PR_ASB_LOAD_OPR_BOA_MAIN Start time '||sysdate);

    --PR_ASB_LOAD_OPR_BOA(lv_vc_load_seq_nbr,pi_effective,'BOAL');

    PR_MSM1_OPR_BOA(lv_vc_load_seq_nbr,'BOASTARTMIN',1);
    MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_BOA(lv_vc_load_seq_nbr,'BOASTARTMIN');
    MSM_STG2.PR_MEASUREMENT_STAG_TRN_BOA(lv_vc_load_seq_nbr);

    PR_MSM1_OPR_BOA(lv_vc_load_seq_nbr,'BOAENDMIN',2);
    MSM_STG1.PR_MSM1_TO_MSM2_MSRMT_BOA(lv_vc_load_seq_nbr,'BOAENDMIN');
    MSM_STG2.PR_MEASUREMENT_STAG_TRN_BOA(lv_vc_load_seq_nbr);

    select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_OPR_BOA_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;

    INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_BOA_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'BOA');

    dbms_output.put_line('PR_ASB_LOAD_OPR_BOA_MAIN End time '||sysdate);

EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ROLLBACK;
        PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BOA_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END PR_ASB_LOAD_OPR_BOA_MAIN;

/
