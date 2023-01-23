--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_COMP_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_COMP_MAIN" 
/**************************************************************************************
* Program Name           :PR_ASB_LOAD_COMP_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate company data fromASB legacy system to C2M system.
* VERSION                :1.0
* Called Program         :ASB_LOAD_COMPANY_Main.ksh
* Input Parameter        :CSV file receive status
* Output Parameter       :None
* <DD-MM-YYYY>   <Modifier Name>    <Description>
**************************************************************************************/
(p_CSV_FILE_STATUS IN NUMBER) AS
    v_date  DATE;
    v_LOAD_SEQ_NBR NUMBER;
    v_ERROR varchar2(1000);
    v_proc_seq_nbr number;

BEGIN


  -- Generate a new LOAD_SEQ_NBR
    SELECT SQ_COMP_LOAD_SEQNO.nextval into v_LOAD_SEQ_NBR from dual;

    -- Update the latest load_seq_num in COMPANY_CSV table
    IF (p_CSV_FILE_STATUS = 1) THEN
        UPDATE company_csv SET load_seq_nbr = v_LOAD_SEQ_NBR ;
    END IF;
commit;
    -- Insert a row in LOAD_DETAILS Table for new load_sequence
    INSERT into LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) values (v_LOAD_SEQ_NBR,'PR_ASB_LOAD_COMP_MAIN',NULL,NULL,SYSDATE);

    PROC_PROCESS_LOG('PR_ASB_LOAD_COMP_MAIN',v_LOAD_SEQ_NBR,'Start...', 'COMPANY loading process start','COMPANY');
    -- Calling the Procedure PR_ASB_LOAD_COMP_STG to load data into ASB_COMP_STG table
    PR_ASB_COMP_STG_LOAD(v_LOAD_SEQ_NBR);
commit;
    -- Calling the procedure PR_ASB_COMP_TRN_DATA to validate data
    PR_ASB_COMP_TRN_DATA(v_LOAD_SEQ_NBR);
commit;
    -- Calling
--    PR_ASB_GEN_REJECT_FILE(v_LOAD_SEQ_NBR,'99,100,101,102,103,104,105,106,107','COMPANY','COMPANY_CSV');

    -- Calling the procedure PR_ASB_COMP_LOAD_TRN to load data in table TRN_COMPANY
    PR_ASB_COMP_LOAD_TRN(v_LOAD_SEQ_NBR);

commit;
    -- Calling PROCEDURE PR_MSMSTG1_LOAD_CMPNY to load data in MSM_STG1 Tables
    PR_MSMSTG1_LOAD_COMPANY(v_LOAD_SEQ_NBR);
commit;
    MSM_STG1.PR_COMP_DATA_TRANS(v_LOAD_SEQ_NBR);
commit;
    MSM_STG2.PR_COMP_STAGING_TRN(v_LOAD_SEQ_NBR);

    select proc_seq_nbr into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_COMP_MAIN' and load_seq_nbr = v_LOAD_SEQ_NBR;

  INSERT INTO PROCESS_LOG(PROC_SEQ_NBR, PROC_NAME, LOAD_SEQ_NBR, STATUS, STATUS_DESCRIPTION, DATE_CREATED, ENTITY_NAME) 
  VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_COMP_MAIN',v_LOAD_SEQ_NBR,'SUCCESS', 'All the process executed successfully',SYSDATE,'COMPANY');

EXCEPTION
    WHEN OTHERS then
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ROLLBACK;
        PROC_PROCESS_LOG('PR_ASB_LOAD_COMP_MAIN',v_LOAD_SEQ_NBR,'FAILURE', v_ERROR,'COMPANY');
        RAISE;

END PR_ASB_LOAD_COMP_MAIN;

/

