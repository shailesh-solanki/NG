--------------------------------------------------------
--  DDL for Procedure PR_ASB_OWNER_ERR_CHK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_OWNER_ERR_CHK" 
/**************************************************************************************
*
* Program Name           :PR_ASB_OWNER_ERR_CHK
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-04-2021
* Description            :This is a PL/SQL procedure. This procedure filters data in OWNER_CSV
*                         table and marked each rows with appropriate error codes.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OWNER_MAIN
*                         
*
* Input files            :None
* Output files           :None
* Input Parameter        :Load sequence number
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 16-02-2022	  Anish Kumar S	     SRPTEAM-9860 ( QES-Defect-Data Migration: Getting Missing Records for D1_SP_MKT_PARTICIPANT table )
**************************************************************************************/
(pi_load_seq_nbr IN NUMBER)
AS
lv_vc_rec_processed number(5) := 0;
lv_vc_rec_rejected number(5) := 0;
BEGIN

 UPDATE OWNER_CSV 
    SET ERROR_CODE=109
    where RESOURCE_CODE not in
        ( SELECT ASB_UNIT_CODE FROM ASB_UNIT_STG  );  

 UPDATE OWNER_CSV 
    set ERROR_CODE=99
    where company_code not in
        (
       select asb_comp_code from ASB_CPNY_STG
        )
        and error_code is null;   

    UPDATE OWNER_CSV 
    set ERROR_CODE=110
    where company_code not in
        (
       select asb_comp_code from ASB_CPNY_STG
        )
        and error_code = 109;  

    -- Set error_code for records where same resource_code is mapped to different company_code
    /*
    UPDATE owner_csv set ERROR_CODE = 111
    where (resource_code, COMPANY_CODE) IN 
    (select distinct o1.resource_code, o1.COMPANY_CODE from owner_csv o1 , owner_csv o2 
    where o1.resource_code = o2.resource_code
    and o1.COMPANY_CODE <> o2.COMPANY_CODE );
    */
    UPDATE owner_csv s3
    SET
        s3.error_code = 111
    WHERE
        s3.resource_code in ( SELECT distinct s1.resource_code 
                 FROM owner_csv s1, owner_csv s2
                 WHERE
                        s1.resource_code = s2.resource_code
                    AND s1.type = s2.type
                    AND s1.company_code <> s2.company_code
                    AND TO_DATE(s2.owned_eff_start_dt) BETWEEN TO_DATE(s1.owned_eff_start_dt) AND nvl( (TO_DATE(s1.owned_eff_end_dt) - INTERVAL '1' SECOND),SYSDATE )
                );
    
    select count(1) into lv_vc_rec_rejected from OWNER_CSV where error_code in (99,109,110);
    select count(1) into lv_vc_rec_processed from OWNER_CSV where error_code not in (99,109,110) or error_code is null;
      
    UPDATE LOAD_DETAILS set REC_PROCESSED = lv_vc_rec_processed, REC_REJECTED = lv_vc_rec_rejected where load_seq_nbr = pi_load_seq_nbr
    AND load_desc = 'PR_ASB_OWNER_ERR_CHK';

     PROC_PROCESS_LOG('PR_ASB_OWNER_ERR_CHK',pi_load_seq_nbr,'SUCCESS','All the invalid records identified sucessfully!!!','OWNER');

EXCEPTION 

    WHEN NO_DATA_FOUND THEN
    PROC_PROCESS_LOG('PR_ASB_OWNER_ERR_CHK',pi_load_seq_nbr,'SUCCESS','No data found to validate','OWNER');

    WHEN OTHERS THEN   
    PROC_PROCESS_LOG('PR_ASB_OWNER_ERR_CHK',pi_load_seq_nbr,'FAILURE',SQLERRM,'OWNER');  

    RAISE;
END PR_ASB_OWNER_ERR_CHK;

/

