--------------------------------------------------------
--  DDL for Procedure PR_PUBLIC_HOD_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_PUBLIC_HOD_MAIN" 

/**************************************************************************************
*
* Program Name           :PR_PUBLIC_HOD_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :22-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate holiday  data fromASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :ASB_LOAD_PH_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
as
v_date  DATE;
v_LOAD_SEQ_NBR NUMBER;
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  -- Generate a new LOAD_SEQ_NBR
    SELECT SEQ_NEXTVAL_ON_LOAD_NUM.nextval into v_LOAD_SEQ_NBR from dual;

    -- Insert a row in LOAD_DETAILS Table for new load_sequence
    INSERT into LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) values (v_LOAD_SEQ_NBR,'PR_PUBLIC_HOD_MAIN',NULL,NULL,SYSDATE);
    PR_PROCESS_LOG('PR_PUBLIC_HOD_MAIN',v_LOAD_SEQ_NBR,'Start...', 'public holiday loading process start');

    -- Calling the Procedure PR_PUBLIC_HOD to load data into ASB_PH_STG table
    PR_PUBLIC_HOD(v_LOAD_SEQ_NBR);

    -- Calling the Procedure PR_MSM1_PUB_HOLIDAY to load data into CI_CAL_HOL and CI_CAL_HOL_L tables
    PR_MSM1_PUB_HOLIDAY(v_LOAD_SEQ_NBR);


     -- Calling PROCEDURE PR_MSM1_PUB_HOLIDAY to load data in MSM_STG2 Tables
    MSM_STG1.pr_msm2_PUB_HOLIDAY(v_load_seq_nbr);

  --calling procedure for load data from MSM_STG1 to msm_staging
  MSM_STG2.PR_MSM2_PUBLIC_TRANS(v_load_seq_nbr);
  select proc_seq_nbr into v_proc_seq_nbr from process_log where proc_name = 'PR_PUBLIC_HOD_MAIN' and load_seq_nbr = v_LOAD_SEQ_NBR;

  INSERT INTO PROCESS_LOG
    VALUES(v_proc_seq_nbr,'PR_PUBLIC_HOD_MAIN',v_LOAD_SEQ_NBR,'SUCCESS', 'All the process executed successfully',SYSDATE,'PUBLIC_HOLIDAY');
    
  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,120);
    ROLLBACK;
    PR_PROCESS_LOG('PR_PUBLIC_HOD_MAIN',v_LOAD_SEQ_NBR,'FAILURE', v_ERROR);


END PR_PUBLIC_HOD_MAIN ;

/

