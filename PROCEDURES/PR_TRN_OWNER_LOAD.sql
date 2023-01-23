--------------------------------------------------------
--  DDL for Procedure PR_TRN_OWNER_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_TRN_OWNER_LOAD" 
/**************************************************************************************
*
* Program Name           :pr_trn_owner_load
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-04-2021
* Description            :This is a PL/SQL procedure. This procedure takes data 
*                         from OWNER_CSV and loads data into TRN_OWNER table.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OWNER_MAIN
*                         
*
* Input files            :None
* Output files           :None
* Input Parameter        :load sequence number
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(pi_load_seq_nbr IN number)
as
BEGIN
    
    INSERT INTO TRN_OWNER 
    SELECT pi_load_seq_nbr, Q.D1_SP_ID, A.RESOURCE_CODE,A.TYPE,A.COMPANY_CODE,A.OWNED_EFF_START_DT,A.OWNED_EFF_END_DT,A.PAYMENT_EFF_START_DT,A.PAYMENT_EFF_END_DT,A.ERROR_CODE,SYSDATE 
    FROM OWNER_CSV A,
    (SELECT B.D1_SP_ID,A.RESOURCE_CODE FROM ASB_STG.OWNER_CSV A, MSM_STG1.D1_SP_IDENTIFIER B WHERE B.ID_VALUE = A.RESOURCE_CODE
    AND B.SP_ID_TYPE_FLG = 'D1MI' AND (ERROR_CODE NOT IN (99,109,111) or ERROR_CODE is NULL)
    ) Q
    WHERE A.RESOURCE_CODE = Q.RESOURCE_CODE AND
    LOAD_SEQ_NBR = pi_load_seq_nbr AND
    (ERROR_CODE NOT IN (99,109,111) OR ERROR_CODE is NULL);

 PROC_PROCESS_LOG('PR_TRN_OWNER_LOAD',pi_load_seq_nbr,'SUCCESS','Data transfer from OWNER_CSV to TRN_ONWER is successful!!!','OWNER');

EXCEPTION 

    WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_TRN_OWNER_LOAD',pi_load_seq_nbr,'SUCCESS','No new data found for sequence number '||pi_load_seq_nbr,'OWNER');
        RAISE;
    WHEN OTHERS THEN   
        PROC_PROCESS_LOG('PR_TRN_OWNER_LOAD',pi_load_seq_nbr,'FAILURE',SQLERRM,'OWNER');  
        RAISE;
  
END;

/
