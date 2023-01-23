--------------------------------------------------------
--  DDL for Procedure PR_ASB_COMP_STG_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_COMP_STG_LOAD" (pi_load_seq_nbr IN number)
/**************************************************************************************
*
* Program Name           :PR_ASB_COMP_STG_LOAD
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure takes data
*                         from ASB_COMPANY(ASB legacy system) and loads into ASB_CPNY_STG table.
* Called Program         :PR_ASB_LOAD_COMP_MAIN
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS
BEGIN

    MERGE INTO ASB_CPNY_STG A
        USING (SELECT ASB_COMP_CODE, ASB_COMP_NAME, REG_COMP_NAME FROM ASB_COMPANY) q
        ON (q.ASB_COMP_CODE = A.ASB_COMP_CODE)
    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, ASB_COMP_NAME = q.ASB_COMP_NAME, REG_COMP_NAME = q.REG_COMP_NAME, DATE_CREATED = SYSDATE
        where (nvl(A.ASB_COMP_NAME,'checknull') <> nvl(q.ASB_COMP_NAME,'checknull')) or (nvl(A.REG_COMP_NAME,'checknull') <> nvl(q.REG_COMP_NAME,'checknull'))
    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR,ASB_COMP_CODE,ASB_COMP_NAME,REG_COMP_NAME,DATE_CREATED)
        VALUES(pi_load_seq_nbr, q.ASB_COMP_CODE, q.ASB_COMP_NAME, q.REG_COMP_NAME, SYSDATE);

    PROC_PROCESS_LOG('PR_ASB_COMP_STG_LOAD',pi_load_seq_nbr,'SUCCESS','Records inserted/updated to ASB_CPNY_STG table sucessfully.','COMPANY');

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_STG_LOAD',pi_load_seq_nbr,'SUCCESS','No data inserted from ASB_COMPANY table','COMPANY');
    WHEN OTHERS THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_STG_LOAD',pi_load_seq_nbr,'FAILURE',SQLERRM,'COMPANY');

END;

/

