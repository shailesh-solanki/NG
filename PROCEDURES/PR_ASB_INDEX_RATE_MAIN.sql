--------------------------------------------------------
--  DDL for Procedure PR_ASB_INDEX_RATE_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_INDEX_RATE_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_INDEX_RATE_MAIN
* Author                 :IBM(Anish Kumar S)
* Creation Date          :11-10-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Index Rate Data from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_INDEX_RATE_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  11-10-2021     Anish Kumar S   Changes for Index Rate
**************************************************************************************/

AS

    lv_vc_load_seq_nbr  NUMBER(10);
    v_ERROR             varchar2(1000);
    v_proc_seq_nbr      number;

BEGIN
    --Generate a new LOAD_SEQ_NBR
    SELECT SQ_INDEX_RATE_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

    --Insert a row in LOAD_DETAILS Table for new load_sequence
    INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_INDEX_RATE_MAIN',NULL,NULL,SYSDATE);

    PR_PROCESS_LOG('PR_ASB_INDEX_RATE_MAIN',lv_vc_load_seq_nbr,'Start...', 'Index Rate loading  process start');

    --PR_ASB_LOAD_INDEX_RATE(lv_vc_load_seq_nbr);
commit;
    PR_MSM1_INDEX_RATE(1040);
commit;
    --PR_MSM1_INDEX_RATE_NGPS(lv_vc_load_seq_nbr);
commit;
    MSM_STG1.PR_MSM1_TO_MSM2_INDEX_RATE(1040);
commit;
    MSM_STG2.PR_INDEX_RATE_STAG_TRN(lv_vc_load_seq_nbr);

    select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_INDEX_RATE_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;

    INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_INDEX_RATE_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'INDEXRATE');

EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ROLLBACK;
        PR_PROCESS_LOG('PR_ASB_INDEX_RATE_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END PR_ASB_INDEX_RATE_MAIN;

/

