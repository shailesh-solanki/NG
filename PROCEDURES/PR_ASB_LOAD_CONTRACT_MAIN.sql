--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_CONTRACT_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_CONTRACT_MAIN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_CONTRACT_MAIN
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :30-04-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate CONTRACT data from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :ASB_LOAD_CONTRACT_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>      <Description>
* 30-04-2021      Shailesh Solanki     Changes for CONTRACT Main PROC
**************************************************************************************/

AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  SELECT SQ_CONTRACT_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence of CONTRACT
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_CONTRACT_MAIN',NULL,NULL,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_LOAD_CONTRACT_MAIN',lv_vc_load_seq_nbr,'Start...', 'Contract loading  process start');
dbms_output.put_line('Start load contract '||sysdate);

  PR_ASB_CONTRACT_LOAD(lv_vc_load_seq_nbr);
  commit;
--dbms_output.put_line('Start transaction loading for contract '||sysdate);
  pr_trn_contract_load(lv_vc_load_seq_nbr);
commit;
 dbms_output.put_line('Start MSM_STG1 loading '||sysdate);

  PR_MSMSTG1_LOAD_CONTRACT(lv_vc_load_seq_nbr);
  commit;
  dbms_output.put_line('Start MSM_STG1 to MSM_STG2 loading '||sysdate);

  MSM_STG1.PR_CONTRACT_DATA_TRANS(lv_vc_load_seq_nbr);
  commit;
  dbms_output.put_line('end MSM_STG1 to MSM_STG2 loading '||sysdate);



  --NGPS starts here
  SELECT SQ_CONTRACT_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  dbms_output.put_line('Start load contract NGPS '||sysdate);
  PR_ASB_CONTRACT_NGPS_LOAD(lv_vc_load_seq_nbr);
  commit;
  dbms_output.put_line('Start MSM_STG1 loading  for NGPS'||sysdate);
  PR_MSMSTG1_LOAD_CONTRACT_NGPS(lv_vc_load_seq_nbr);
commit;
  dbms_output.put_line('Start MSM_STG1 to MSM_STG2 loading '||sysdate);

  MSM_STG1.PR_CONTRACT_NGPS_DATA_TRANS(lv_vc_load_seq_nbr);
  commit;
  dbms_output.put_line('end MSM_STG1 to MSM_STG2 loading '||sysdate);

  MSM_STG2.PR_CONTRACT_STAGING_TRANS(lv_vc_load_seq_nbr);


 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_CONTRACT_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_CONTRACT_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'CONTRACT');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    ROLLBACK;
    PR_PROCESS_LOG('PR_ASB_LOAD_CONTRACT_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);

END PR_ASB_LOAD_CONTRACT_MAIN;

/

