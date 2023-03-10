--------------------------------------------------------
--  DDL for Procedure PR_ASB_CONTRACT_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_CONTRACT_LOAD" 
/**************************************************************************************
*
* Program Name           :PR_ASB_CONTRACT_LOAD
* Author                 :IBM
* Creation Date          :30-04-2021
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

BEGIN
    BEGIN
        MERGE INTO ASB_CONTRACT_SERVICE_STG A
            USING (SELECT CONTRACT_SEQ, ASB_COMP_CODE,SERVICE_CODE,CONTRACT_ID,CONTRACT_STATUS,CONTRACT_START,CONTRACT_END,TENDER_ID,GROUP_ID FROM ASB_DEV_4.ASB_CONTRACT_SERVICE WHERE ASB_COMP_CODE NOT IN('NGPS','TSTA') AND SERVICE_CODE IN ('SRBM','SRNM')) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, ASB_COMP_CODE = q.ASB_COMP_CODE,SERVICE_CODE = q.SERVICE_CODE,CONTRACT_ID = q.CONTRACT_ID,CONTRACT_STATUS = q.CONTRACT_STATUS,
            CONTRACT_START = q.CONTRACT_START,CONTRACT_END = q.CONTRACT_END,TENDER_ID = q.TENDER_ID,GROUP_ID = q.GROUP_ID, DATE_CREATED = SYSDATE
            WHERE ASB_COMP_CODE <> q.ASB_COMP_CODE OR SERVICE_CODE <> q.SERVICE_CODE OR CONTRACT_ID <> q.CONTRACT_ID OR CONTRACT_STATUS <> q.CONTRACT_STATUS OR
            CONTRACT_START <> q.CONTRACT_START OR CONTRACT_END <> q.CONTRACT_END OR TENDER_ID <> q.TENDER_ID OR GROUP_ID <> q.GROUP_ID
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, ASB_COMP_CODE,SERVICE_CODE,CONTRACT_ID,CONTRACT_STATUS,CONTRACT_START,CONTRACT_END,TENDER_ID,GROUP_ID,DATE_CREATED) 
            VALUES(pi_load_seq_nbr, q.CONTRACT_SEQ,  q.ASB_COMP_CODE,q.SERVICE_CODE,q.CONTRACT_ID,q.CONTRACT_STATUS,q.CONTRACT_START,q.CONTRACT_END,q.TENDER_ID,q.GROUP_ID, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_CONTRACT_SERVICE_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in ASB_CONTRACT_SERVICE_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;    
insert into connect_us_sa_id(load_seq_nbr, contract_seq,us_id,sa_id,date_created)
    select pi_load_seq_nbr,acs.contract_seq,sq_contract_d1_us_identifier.nextval as us_id,SQ_CONTRACT_SA_ID.nextval as sa_id,sysdate from asb_contract_service_stg acs 
    where acs.load_seq_nbr = pi_load_seq_nbr
    and acs.contract_seq not in (select contract_seq from connect_us_sa_id);

    BEGIN
        MERGE INTO SRS_CONTRACT_FORM_STG A
            USING (SELECT CONTRACT_SEQ, COMM_FLEX,NORTH_SOUTH,MAX_OCCS_WEEK,MAX_HOURS_WEEK,MAX_OCCS_CONT,MAX_HOURS_CONT,NEAREST_NODE,LOCATION,SUPPLEMENTARY,PROVIDER_TYPE FROM ASB_DEV_4.SRS_CONTRACT_FORM) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, COMM_FLEX = q.COMM_FLEX,NORTH_SOUTH = q.NORTH_SOUTH,MAX_OCCS_WEEK = q.MAX_OCCS_WEEK,MAX_HOURS_WEEK = q.MAX_HOURS_WEEK,MAX_OCCS_CONT = q.MAX_OCCS_CONT,
            MAX_HOURS_CONT = q.MAX_HOURS_CONT,NEAREST_NODE = q.NEAREST_NODE,LOCATION = q.LOCATION,SUPPLEMENTARY = q.SUPPLEMENTARY,PROVIDER_TYPE = q.PROVIDER_TYPE, DATE_CREATED = SYSDATE
            WHERE COMM_FLEX <> q.COMM_FLEX OR NORTH_SOUTH <> q.NORTH_SOUTH OR MAX_OCCS_WEEK <> q.MAX_OCCS_WEEK OR MAX_HOURS_WEEK <> q.MAX_HOURS_WEEK OR MAX_OCCS_CONT <> q.MAX_OCCS_CONT OR
            MAX_HOURS_CONT <> q.MAX_HOURS_CONT OR NEAREST_NODE <> q.NEAREST_NODE OR LOCATION <> q.LOCATION OR SUPPLEMENTARY <> q.SUPPLEMENTARY OR PROVIDER_TYPE <> q.PROVIDER_TYPE
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, COMM_FLEX,NORTH_SOUTH,MAX_OCCS_WEEK,MAX_HOURS_WEEK,MAX_OCCS_CONT,MAX_HOURS_CONT,NEAREST_NODE,LOCATION,SUPPLEMENTARY,PROVIDER_TYPE,DATE_CREATED) 
            VALUES(pi_load_seq_nbr, q.CONTRACT_SEQ, q.COMM_FLEX,q.NORTH_SOUTH,q.MAX_OCCS_WEEK,q.MAX_HOURS_WEEK,q.MAX_OCCS_CONT,q.MAX_HOURS_CONT,q.NEAREST_NODE,q.LOCATION,q.SUPPLEMENTARY,q.PROVIDER_TYPE, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRS_CONTRACT_FORM_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in SRS_CONTRACT_FORM_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;

    BEGIN
        MERGE INTO SRS_DESPATCH_STG A
            USING (SELECT CONTRACT_SEQ, EFFECTIVE, SRD_INSTALLED,SRD_SITE,SRD_LOAD,SRD_AGENT,SRD_HQ,SRD_CALLOFF,INSR_MECH,TEL_NUMBER,FAX_NUMBER FROM ASB_DEV_4.SRS_DESPATCH) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ AND q.EFFECTIVE = A.EFFECTIVE) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, SRD_INSTALLED = q.SRD_INSTALLED,SRD_SITE = q.SRD_SITE,SRD_LOAD = q.SRD_LOAD,SRD_AGENT = q.SRD_AGENT,
            SRD_HQ = q.SRD_HQ,SRD_CALLOFF = q.SRD_CALLOFF,INSR_MECH = q.INSR_MECH,TEL_NUMBER = q.TEL_NUMBER,FAX_NUMBER = q.FAX_NUMBER, DATE_CREATED = SYSDATE
            WHERE SRD_INSTALLED <> q.SRD_INSTALLED OR SRD_SITE <> q.SRD_SITE OR SRD_LOAD <> q.SRD_LOAD OR SRD_AGENT <> q.SRD_AGENT OR 
            SRD_HQ <> q.SRD_HQ OR SRD_CALLOFF <> q.SRD_CALLOFF OR INSR_MECH <> q.INSR_MECH OR TEL_NUMBER <> q.TEL_NUMBER OR FAX_NUMBER <> q.FAX_NUMBER
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, EFFECTIVE, SRD_INSTALLED,SRD_SITE,SRD_LOAD,SRD_AGENT,SRD_HQ,SRD_CALLOFF,INSR_MECH,TEL_NUMBER,FAX_NUMBER,DATE_CREATED) 
            VALUES(pi_load_seq_nbr, q.CONTRACT_SEQ, q.EFFECTIVE, q.SRD_INSTALLED,q.SRD_SITE,q.SRD_LOAD,q.SRD_AGENT,q.SRD_HQ,q.SRD_CALLOFF,q.INSR_MECH,q.TEL_NUMBER,q.FAX_NUMBER, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRS_DESPATCH_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in SRS_DESPATCH_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;

    BEGIN
        MERGE INTO SRS_SUPPLIER_STG A
            USING (SELECT CONTRACT_SEQ, ASB_UNIT_CODE, TENDER_NUMBER,CONTRACT_NUMBER,CONT_CAPACITY,OPTN_CAPACITY,MAX_UTILISATION,RESPONSE_TIME,RECOVERY_PERIOD,MNZT_LIMIT,EXP_CAPACITY,IMP_CAPACITY,CEASE_TIME,RAMPUP_RATE,RAMPDOWN_RATE,DEFAULT_SUPPLIER,INCLUDE_CONTRACT,SPINGEN_ADJUST,DUMMY_CONTRACT FROM ASB_DEV_4.SRS_SUPPLIER WHERE DUMMY_CONTRACT <> 'Y' OR DUMMY_CONTRACT IS NULL) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ and q.ASB_UNIT_CODE = A.ASB_UNIT_CODE) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, TENDER_NUMBER = q.TENDER_NUMBER,CONTRACT_NUMBER = q.CONTRACT_NUMBER,CONT_CAPACITY = q.CONT_CAPACITY,OPTN_CAPACITY = q.OPTN_CAPACITY,
            MAX_UTILISATION = q.MAX_UTILISATION,RESPONSE_TIME = q.RESPONSE_TIME,RECOVERY_PERIOD = q.RECOVERY_PERIOD,MNZT_LIMIT = q.MNZT_LIMIT,EXP_CAPACITY = q.EXP_CAPACITY,IMP_CAPACITY = q.IMP_CAPACITY,
            CEASE_TIME = q.CEASE_TIME,RAMPUP_RATE = q.RAMPUP_RATE,RAMPDOWN_RATE = q.RAMPDOWN_RATE,DEFAULT_SUPPLIER = q.DEFAULT_SUPPLIER,INCLUDE_CONTRACT = q.INCLUDE_CONTRACT,SPINGEN_ADJUST = q.SPINGEN_ADJUST,
            DUMMY_CONTRACT = q.DUMMY_CONTRACT, DATE_CREATED = SYSDATE
            WHERE TENDER_NUMBER <> q.TENDER_NUMBER OR CONTRACT_NUMBER <> q.CONTRACT_NUMBER OR CONT_CAPACITY <> q.CONT_CAPACITY OR OPTN_CAPACITY <> q.OPTN_CAPACITY OR 
            MAX_UTILISATION <> q.MAX_UTILISATION OR RESPONSE_TIME <> q.RESPONSE_TIME OR RECOVERY_PERIOD <> q.RECOVERY_PERIOD OR MNZT_LIMIT <> q.MNZT_LIMIT OR EXP_CAPACITY <> q.EXP_CAPACITY OR 
            IMP_CAPACITY <> q.IMP_CAPACITY OR CEASE_TIME <> q.CEASE_TIME OR RAMPUP_RATE <> q.RAMPUP_RATE OR RAMPDOWN_RATE <> q.RAMPDOWN_RATE OR DEFAULT_SUPPLIER <> q.DEFAULT_SUPPLIER OR 
            INCLUDE_CONTRACT <> q.INCLUDE_CONTRACT OR SPINGEN_ADJUST <> q.SPINGEN_ADJUST OR DUMMY_CONTRACT <> q.DUMMY_CONTRACT
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, ASB_UNIT_CODE, TENDER_NUMBER,CONTRACT_NUMBER,CONT_CAPACITY,OPTN_CAPACITY,MAX_UTILISATION,RESPONSE_TIME,RECOVERY_PERIOD,MNZT_LIMIT,EXP_CAPACITY,IMP_CAPACITY,CEASE_TIME,RAMPUP_RATE,RAMPDOWN_RATE,DEFAULT_SUPPLIER,INCLUDE_CONTRACT,SPINGEN_ADJUST,DUMMY_CONTRACT,DATE_CREATED) 
            VALUES(pi_load_seq_nbr,q.CONTRACT_SEQ, q.ASB_UNIT_CODE, q.TENDER_NUMBER,q.CONTRACT_NUMBER,q.CONT_CAPACITY,q.OPTN_CAPACITY,q.MAX_UTILISATION,q.RESPONSE_TIME,q.RECOVERY_PERIOD,q.MNZT_LIMIT,q.EXP_CAPACITY,q.IMP_CAPACITY,q.CEASE_TIME,q.RAMPUP_RATE,q.RAMPDOWN_RATE,q.DEFAULT_SUPPLIER,q.INCLUDE_CONTRACT,q.SPINGEN_ADJUST,q.DUMMY_CONTRACT, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRS_SUPPLIER_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in SRS_SUPPLIER_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;

     BEGIN
        MERGE INTO ASB_CONTRACT_RATE_STG A
            USING (SELECT CONTRACT_SEQ,EFFECTIVE,PAY_CODE,DAY_CODE,START_LOCAL,THRESHOLD,CONTRACT_RATE_1 FROM ASB_DEV_4.ASB_CONTRACT_RATE) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ AND q.EFFECTIVE = A.EFFECTIVE AND q.PAY_CODE = A.PAY_CODE AND q.DAY_CODE = A.DAY_CODE AND q.START_LOCAL = A.START_LOCAL AND q.THRESHOLD = A.THRESHOLD) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr,CONTRACT_RATE_1 = q.CONTRACT_RATE_1 , DATE_CREATED = SYSDATE
            WHERE CONTRACT_RATE_1 <> q.CONTRACT_RATE_1 
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ,EFFECTIVE,PAY_CODE,DAY_CODE,START_LOCAL,THRESHOLD,CONTRACT_RATE_1,DATE_CREATED) 
            VALUES(pi_load_seq_nbr,q.CONTRACT_SEQ,q.EFFECTIVE,q.PAY_CODE,q.DAY_CODE,q.START_LOCAL,q.THRESHOLD,q.CONTRACT_RATE_1, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_CONTRACT_RATE_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in ASB_CONTRACT_RATE_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;

     BEGIN
        MERGE INTO SRS_SEASONAL_STG A
            USING (SELECT CONTRACT_SEQ, SEASON_SEQ, RECON_FLAG FROM ASB_DEV_4.SRS_SEASONAL) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ and q.SEASON_SEQ = A.SEASON_SEQ) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, RECON_FLAG = q.RECON_FLAG, DATE_CREATED = SYSDATE
            WHERE RECON_FLAG <> q.RECON_FLAG
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ, SEASON_SEQ,RECON_FLAG,DATE_CREATED) 
            VALUES(pi_load_seq_nbr,q.CONTRACT_SEQ, q.SEASON_SEQ,q.RECON_FLAG, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRS_SEASONAL_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in SRS_SEASONAL_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;
/*
    BEGIN
        MERGE INTO ASB_UNIT_CONTRACT_STG A
            USING (SELECT ASB_UNIT_CODE,UNIT_TYPE FROM ASB_UNIT) q
            ON (q.ASB_UNIT_CODE = A.ASB_UNIT_CODE) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, UNIT_TYPE = q.UNIT_TYPE, DATE_CREATED = SYSDATE
            WHERE UNIT_TYPE <> q.UNIT_TYPE
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,ASB_UNIT_CODE, UNIT_TYPE,DATE_CREATED) 
            VALUES(pi_load_seq_nbr,q.ASB_UNIT_CODE, q.UNIT_TYPE, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_UNIT_CONTRACT_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in ASB_UNIT_CONTRACT_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;
    */
    BEGIN
        MERGE INTO SRS_CONTRACT_FACTOR_STG A
            USING (SELECT CONTRACT_SEQ,EFFECTIVE,STANDBY_TOLERANCE,DELIVERY_TOLERANCE,AVAIL_REDUCTION FROM ASB_DEV_4.SRS_CONTRACT_FACTOR) q
            ON (q.CONTRACT_SEQ = A.CONTRACT_SEQ AND q.EFFECTIVE = A.EFFECTIVE) 
        WHEN MATCHED THEN
            UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, STANDBY_TOLERANCE = q.STANDBY_TOLERANCE, DELIVERY_TOLERANCE=q.DELIVERY_TOLERANCE,AVAIL_REDUCTION=q.AVAIL_REDUCTION, DATE_CREATED = SYSDATE
            WHERE STANDBY_TOLERANCE <> q.STANDBY_TOLERANCE OR DELIVERY_TOLERANCE<>q.DELIVERY_TOLERANCE OR AVAIL_REDUCTION <> q.AVAIL_REDUCTION
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ,EFFECTIVE,STANDBY_TOLERANCE,DELIVERY_TOLERANCE,AVAIL_REDUCTION,DATE_CREATED) 
            VALUES(pi_load_seq_nbr,q.CONTRACT_SEQ,q.EFFECTIVE,q.STANDBY_TOLERANCE,q.DELIVERY_TOLERANCE,q.AVAIL_REDUCTION, SYSDATE);

        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRS_CONTRACT_FACTOR_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS','No insert or update done in SRS_CONTRACT_FACTOR_STG table');
    WHEN OTHERS THEN   
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'Failed',SQLERRM);    
    END;
   
     PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'SUCCESS', 'Contract data migrated successfully from ASB legacy system to ASB_STG schema');

EXCEPTION
   WHEN OTHERS then
        PR_PROCESS_LOG('PR_ASB_CONTRACT_LOAD',pi_load_seq_nbr,'FAILURE', 'Failed while migrating contract data from ASB legacy system to ASB_STG schema');
END PR_ASB_CONTRACT_LOAD;

/
