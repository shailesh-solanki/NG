--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_DSW_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_DSW_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_DSW_MAIN 
* Author                 :IBM(Roshan Khandare)
* Creation Date          :28-06-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate DSW DATA from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_DSW_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS 
lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

    SELECT SQ_DSW_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

    INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_DSW_MAIN ',NULL,NULL,SYSDATE);

    PROC_PROCESS_LOG('PR_ASB_LOAD_DSW_MAIN',lv_vc_load_seq_nbr,'Start...', 'DSW DATA loading  process start','DSW');

    PR_ASB_LOAD_DEF_SRVC_WINDOW(lv_vc_load_seq_nbr);

    PR_MSM1_DEF_SRVC_WINDOW(lv_vc_load_seq_nbr );

    MSM_STG1.PR_MSM1_TO_MSM2_DEF_SRV_WINDOW(lv_vc_load_seq_nbr );

--    MSM_STG2.PR_DEF_SRVC_WINDOW_STAG_TRN(lv_vc_load_seq_nbr);

     select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_DSW_MAIN ' and load_seq_nbr = lv_vc_load_seq_nbr ;
     INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_DSW_MAIN ',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'DSW');

EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
    ROLLBACK;
        PROC_PROCESS_LOG('PR_ASB_LOAD_DSW_MAIN ',lv_vc_load_seq_nbr,'FAILURE', v_ERROR,'DSW');


END PR_ASB_LOAD_DSW_MAIN;

/

