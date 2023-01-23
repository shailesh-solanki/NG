--------------------------------------------------------
--  DDL for Procedure PR_ASB_RESOURCE_ERR_CHK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_RESOURCE_ERR_CHK" (pi_load_seq_nbr IN NUMBER)
/**************************************************************************************
*
* Program Name           :PR_ASB_RESOURCE_ERR_CHK
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-03-2021
* Description            :This is a PL/SQL procedure. This procedure filters data in RESOURCE_CSV
*                         table and marked each rows with appropriate error codes.
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS

lv_vc_rec_processed number(5) := 0;
lv_vc_rec_rejected number(5) := 0;



BEGIN

    -- CHECK for asb_unit_code not present in ASB_UNIT Table
    UPDATE RESOURCE_CSV
    set error_code = 109
    where asb_unit_code in
        (
        select asb_unit_code from RESOURCE_CSV
            MINUS
        select asb_unit_code from ASB_UNIT_STG
        );

    select count(1) into lv_vc_rec_rejected from RESOURCE_CSV where error_code in (109);
    select count(1) into lv_vc_rec_processed from RESOURCE_CSV where error_code not in (109) or error_code is null;

    UPDATE LOAD_DETAILS set REC_PROCESSED = lv_vc_rec_processed, REC_REJECTED = lv_vc_rec_rejected where load_seq_nbr = pi_load_seq_nbr
    AND load_desc = 'PR_ASB_LOAD_RESOURCE_MAIN';

   PROC_PROCESS_LOG('PR_ASB_RESOURCE_ERR_CHK',pi_load_seq_nbr,'SUCCESS','All the invalid records identified sucessfully.','RESOURCE');

EXCEPTION

    WHEN NO_DATA_FOUND THEN
    PROC_PROCESS_LOG('PR_ASB_RESOURCE_ERR_CHK',pi_load_seq_nbr,'SUCCESS',SQLERRM,'RESOURCE');
    RAISE;

    WHEN OTHERS THEN
    PROC_PROCESS_LOG('PR_ASB_RESOURCE_ERR_CHK',pi_load_seq_nbr,'FAILURE',SQLERRM,'RESOURCE');
    RAISE;

END PR_ASB_RESOURCE_ERR_CHK;

/

