--------------------------------------------------------
--  DDL for Procedure PR_ASB_DAY_WEEK_DECL_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_DAY_WEEK_DECL_MAIN" (PI_START_DATE IN DATE, PI_END_DATE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_DAY_WEEK_DECL_MAIN 
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :21-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Day Ahead / Week Ahead Declaration DATA from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : ASB_LOAD_DECL_Main.ksh
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS 
lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;


BEGIN

    SELECT SQ_DAYWEEK_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

    INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_DAY_WEEK_DECL_MAIN ',NULL,NULL,SYSDATE);

    PR_PROCESS_LOG('PR_ASB_DAY_WEEK_DECL_MAIN',lv_vc_load_seq_nbr,'Start...', 'DECLARATION DATA loading  process start');

    PR_ASB_LOAD_DAY_WEEK_DECL(lv_vc_load_seq_nbr,PI_START_DATE,PI_END_DATE);

    PR_MSM1_DAY_WEEK_DECL(lv_vc_load_seq_nbr);

    MSM_STG1.PR_MSM1_TO_MSM2_DAY_WEEK_DECL(lv_vc_load_seq_nbr);

    MSM_STG2.PR_DAY_WEEK_DECL_STAGING_TRN(lv_vc_load_seq_nbr);

    select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_DAY_WEEK_DECL_MAIN ' and load_seq_nbr = lv_vc_load_seq_nbr ;
     
    INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_DAY_WEEK_DECL_MAIN ',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'DAYWEEKDECLARATION');

EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
    ROLLBACK;
        PROC_PROCESS_LOG('PR_ASB_DAY_WEEK_DECL_MAIN ',lv_vc_load_seq_nbr,'FAILURE', v_ERROR,'DAYWEEKDECLARATION');
        RAISE;
END PR_ASB_DAY_WEEK_DECL_MAIN;

/

