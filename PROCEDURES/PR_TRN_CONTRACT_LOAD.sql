--------------------------------------------------------
--  DDL for Procedure PR_TRN_CONTRACT_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_TRN_CONTRACT_LOAD" (pi_load_seq_nbr in number)
/**************************************************************************************
*
* Program Name           :PR_TRN_CONTRACT_LOAD
* Author                 :IBM
* Creation Date          :07-05-2021
* Description            :This is a PL/SQL procedure. This procedure joins staging tables into tranformation tables 
*                         which use to split data into C2M table format.
*                         MSM_STG1 schema.
*                        
*
* Calling Program        :PR_ASB_LOAD_CONTRACT_MAIN
* Called Program         :
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
as
v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);
begin
insert into TRN_CON_D1_US (LOAD_SEQ_NBR,CONTRACT_SEQ,ASB_COMP_CODE,SERVICE_CODE,TENDER_NUMBER,COMM_FLEX,CONTRACT_START,CONTRACT_END,CONTRACT_STATUS,TENDER_ID,MAX_OCCS_WEEK,MAX_HOURS_WEEK,
        MAX_OCCS_CONT,MAX_HOURS_CONT,MAX_UTILISATION,NEAREST_NODE,LOCATION,NORTH_SOUTH,INCLUDE_CONTRACT,INSR_MECH,DATE_CREATED)
SELECT  acs.load_seq_nbr,acs.contract_seq,acs.asb_comp_code,acs.SERVICE_CODE,sup.TENDER_NUMBER,scf.COMM_FLEX,acs.CONTRACT_START,acs.CONTRACT_END,acs.contract_status,acs.tender_id,scf.max_occs_week,
scf.max_hours_week,scf.max_occs_cont,scf.max_hours_cont,sup.MAX_UTILISATION,scf.nearest_node,scf.location,scf.north_south,sup.include_contract,srd.insr_mech,sysdate
FROM (Select * from ASB_CONTRACT_SERVICE_STG where load_seq_nbr =pi_load_seq_nbr) acs,
(Select * from SRS_SUPPLIER_STG where load_seq_nbr =pi_load_seq_nbr) sup,
(Select * from SRS_CONTRACT_FORM_STG where load_seq_nbr =pi_load_seq_nbr)  scf, 
(Select * from srs_despatch_stg where load_seq_nbr =pi_load_seq_nbr) srd
where acs.contract_seq = sup.contract_seq
and acs.contract_seq = srd.contract_seq
and acs.contract_seq = scf.contract_seq;

   ASB_STG.PR_PROCESS_LOG('PR_TRN_CONTRACT_LOAD',pi_LOAD_SEQ_NBR,'SUCCESS','Data tranformation from staging tables to TRN tables is successful!!!');

    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ASB_STG.PR_PROCESS_LOG('PR_TRN_CONTRACT_LOAD',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
end;

/

