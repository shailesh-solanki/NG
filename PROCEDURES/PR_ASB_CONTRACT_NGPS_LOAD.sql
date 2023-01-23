--------------------------------------------------------
--  DDL for Procedure PR_ASB_CONTRACT_NGPS_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_CONTRACT_NGPS_LOAD" 
/**************************************************************************************
*
* Program Name           :PR_ASB_CONTRACT_NGPS_LOAD
* Author                 : VASANTH IBM
* Creation Date          :19-04-2022
* Description            :This is a PL/SQL procedure. This procedure takes 
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_CONTRACT_MAIN
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
(pi_load_seq_nbr IN NUMBER)
as
v_ERROR VARCHAR2(1000);

CURSOR cur_contract_ngps IS
select distinct asb_unit_code,ass.contract_seq from srs_supplier_stg ass , asb_contract_service_ngps acs where ass.contract_seq=acs.contract_seq;


BEGIN



    BEGIN
        MERGE INTO ASB_CONTRACT_SERVICE_NGPS A
            USING (SELECT CONTRACT_SEQ, ASB_COMP_CODE,SERVICE_CODE,CONTRACT_ID,CONTRACT_STATUS,CONTRACT_START,CONTRACT_END,TENDER_ID,GROUP_ID FROM ASB_DEV_4.ASB_CONTRACT_SERVICE WHERE ASB_COMP_CODE= 'NGPS' AND SERVICE_CODE IN ('SRBM','SRNM')) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, ASB_COMP_CODE = q.ASB_COMP_CODE,SERVICE_CODE = q.SERVICE_CODE,CONTRACT_ID = q.CONTRACT_ID,CONTRACT_STATUS = q.CONTRACT_STATUS,
            CONTRACT_START = q.CONTRACT_START,CONTRACT_END = q.CONTRACT_END,TENDER_ID = q.TENDER_ID,GROUP_ID = q.GROUP_ID, DATE_CREATED = SYSDATE
            WHERE ASB_COMP_CODE <> q.ASB_COMP_CODE OR SERVICE_CODE <> q.SERVICE_CODE OR CONTRACT_ID <> q.CONTRACT_ID OR CONTRACT_STATUS <> q.CONTRACT_STATUS OR
            CONTRACT_START <> q.CONTRACT_START OR CONTRACT_END <> q.CONTRACT_END OR TENDER_ID <> q.TENDER_ID OR GROUP_ID <> q.GROUP_ID
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, ASB_COMP_CODE,SERVICE_CODE,CONTRACT_ID,CONTRACT_STATUS,CONTRACT_START,CONTRACT_END,TENDER_ID,GROUP_ID,DATE_CREATED) 
            VALUES(pi_load_seq_nbr, q.CONTRACT_SEQ,  q.ASB_COMP_CODE,q.SERVICE_CODE,q.CONTRACT_ID,q.CONTRACT_STATUS,q.CONTRACT_START,q.CONTRACT_END,q.TENDER_ID,q.GROUP_ID, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_CONTRACT_SERVICE_NGPS table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in ASB_CONTRACT_SERVICE_NGPS table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_load_seq_nbr,'FAILURE',SQLERRM);    
    END;    

  BEGIN

    FOR rec in cur_contract_ngps

    LOOP
    INSERT INTO CONNECT_US_SA_ID_NGPS(
    load_seq_nbr,
    contract_seq,
    asb_unit_code,
    us_id,
    sa_id,
    date_created
)
    SELECT
        pi_load_seq_nbr,
        acs.contract_seq,
        sss.asb_unit_code,
        sq_contract_d1_us_identifier.NEXTVAL AS us_id,
        sq_contract_sa_id.NEXTVAL AS sa_id,
        SYSDATE
    FROM

        asb_contract_service_ngps acs, srs_supplier_stg sss
    WHERE
       acs.contract_seq=sss.contract_seq and sss.asb_unit_code= rec.asb_unit_code and acs.contract_seq=rec.contract_seq and
        acs.load_seq_nbr = pi_load_seq_nbr;  

        END LOOP;

         ASB_STG.PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_LOAD_SEQ_NBR,'SUCCESS','All the new records pushed to CONNECT_US_SA_ID_NGPS table sucessfully!!');

    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ASB_STG.PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
        end;

   begin
insert into TRN_CON_D1_US_NGPS (LOAD_SEQ_NBR,CONTRACT_SEQ,ASB_UNIT_CODE,ASB_COMP_CODE,SERVICE_CODE,TENDER_NUMBER,COMM_FLEX,CONTRACT_START,CONTRACT_END,CONTRACT_STATUS,TENDER_ID,MAX_OCCS_WEEK,MAX_HOURS_WEEK,
        MAX_OCCS_CONT,MAX_HOURS_CONT,MAX_UTILISATION,NEAREST_NODE,LOCATION,NORTH_SOUTH,INCLUDE_CONTRACT,INSR_MECH,DATE_CREATED)
SELECT  acs.load_seq_nbr,acs.contract_seq,sup.asb_unit_code,acs.asb_comp_code,acs.SERVICE_CODE,sup.TENDER_NUMBER,scf.COMM_FLEX,acs.CONTRACT_START,acs.CONTRACT_END,acs.contract_status,acs.tender_id,scf.max_occs_week,
scf.max_hours_week,scf.max_occs_cont,scf.max_hours_cont,sup.MAX_UTILISATION,scf.nearest_node,scf.location,scf.north_south,sup.include_contract,srd.insr_mech,sysdate
FROM (Select * from ASB_CONTRACT_SERVICE_NGPS where load_seq_nbr =pi_load_seq_nbr) acs,
(Select * from SRS_SUPPLIER_STG ) sup,
(Select * from SRS_CONTRACT_FORM_STG )  scf, 
(Select * from srs_despatch_stg) srd
where acs.contract_seq = sup.contract_seq
and acs.contract_seq = srd.contract_seq
and acs.contract_seq = scf.contract_seq;

   ASB_STG.PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_LOAD_SEQ_NBR,'SUCCESS','Data tranformation from staging tables to TRN tables is successful!!!');

    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ASB_STG.PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
end; 

     PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_load_seq_nbr,'SUCCESS', 'Contract data migrated successfully from ASB legacy system to ASB_STG schema');

EXCEPTION
   WHEN OTHERS then
        PR_PROCESS_LOG('PR_ASB_CONTRACT_NGPS_LOAD',pi_load_seq_nbr,'FAILURE', 'Failed while migrating contract data from ASB legacy system to ASB_STG schema');
END PR_ASB_CONTRACT_NGPS_LOAD;

/

