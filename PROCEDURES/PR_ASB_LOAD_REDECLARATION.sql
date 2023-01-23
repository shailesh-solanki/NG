--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_REDECLARATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_REDECLARATION" (PI_LOAD_SEQ_NBR NUMBER,PI_START_DATE IN DATE, PI_END_DATE IN DATE) 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_REDECLARATION
* Author                 :IBM(SHAILESH SOLANKI)
* Creation Date          :17-09-2021
* Description            :This is a PL/SQL procedure. This procedure loads data from legacy table(SRD_REDECLARATION) and loads 
                          into ASB_STG table(SRD_REDECLARATION_STG)
*                         
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_REDECLARATION_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 17-09-2021      Shailesh Solanki   V1.0
**************************************************************************************/AS 
v_ERROR VARCHAR2(400);
BEGIN

 --Loads data into SRD_REDECLARATION_STG Table in ASB_STG schema
    MERGE INTO SRD_REDECLARATION_STG S2
    USING (select srd.ASB_UNIT_CODE, srd.CONTRACT_NUMBER , srd.REDEC_START, srd.REDEC_END, srd.REDEC_ISSUE, srd.AVAIL_LEVEL, srd.FILE_DATE  ,
            sup.contract_seq,
            cs.service_code
            from srd_redeclaration srd , srs_supplier_STG sup , asb_contract_service_STG cs 
            where 
            sup.asb_unit_code = srd.asb_unit_code
            AND sup.contract_number = srd.contract_number 
            AND cs.contract_seq = sup.contract_seq
            AND sup.CONTRACT_SEQ IN (select CONTRACT_SEQ from CONNECT_US_SA_ID) 
            AND srd.REDEC_ISSUE >= PI_START_DATE AND srd.REDEC_ISSUE < trunc(PI_END_DATE+1)) S1
           ON(S1.ASB_UNIT_CODE=S2.ASB_UNIT_CODE AND S1.CONTRACT_NUMBER=S2.CONTRACT_NUMBER AND S1.REDEC_START=S2.REDEC_START 
           AND S1.REDEC_END=S2.REDEC_END AND S1.REDEC_ISSUE=S2.REDEC_ISSUE )
    WHEN MATCHED THEN 
    UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, AVAIL_LEVEL=S1.AVAIL_LEVEL, FILE_DATE=S1.FILE_DATE    
                WHERE  (nvl(s2.AVAIL_LEVEL,'checknull') <> nvl(s1.AVAIL_LEVEL,'checknull'))
                OR (nvl(s2.FILE_DATE,'checknull') <> nvl(s1.FILE_DATE,'checknull')) 
    WHEN NOT MATCHED THEN
    INSERT( LOAD_SEQ_NBR, ASB_UNIT_CODE, CONTRACT_NUMBER , REDEC_START, REDEC_END, REDEC_ISSUE, AVAIL_LEVEL, FILE_DATE,CONTRACT_SEQ,DATE_CREATED )
    VALUES(PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE, S1.CONTRACT_NUMBER , S1.REDEC_START, S1.REDEC_END, S1.REDEC_ISSUE, S1.AVAIL_LEVEL, S1.FILE_DATE, S1.CONTRACT_SEQ
    ,SYSDATE);

--Exceptions
     PROC_PROCESS_LOG('PR_ASB_LOAD_REDECLARATION',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRD_REDECLARATION_STG table sucessfully!!!','REDECLARATION');
    EXCEPTION WHEN NO_DATA_FOUND THEN
         v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
         DBMS_OUTPUT.PUT_LINE('ERROR : ' || v_ERROR);
        PROC_PROCESS_LOG('PR_ASB_LOAD_REDECLARATION',pi_load_seq_nbr,'SUCCESS','No insert or update done in  SRD_REDECLARATION_STG table','REDECLARATION');
    WHEN OTHERS THEN   
         v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
         DBMS_OUTPUT.PUT_LINE('ERROR : ' || v_ERROR);
         PROC_PROCESS_LOG('PR_ASB_LOAD_REDECLARATION',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema','REDECLARATION');


END PR_ASB_LOAD_REDECLARATION;

/

