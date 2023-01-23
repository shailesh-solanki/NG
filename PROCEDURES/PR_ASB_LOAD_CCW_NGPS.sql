--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_CCW_NGPS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_CCW_NGPS" (PI_LOAD_SEQ_NBR NUMBER,PI_CUT_OFF_DATE IN DATE,PI_END_DATE IN DATE) 
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_CCW
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-07-2021
* Description            :This is a PL/SQL procedure. This procedure cops data from legacy table(SRD_DECLARATION) and loads 
                          into ASB_STG table(SRD_DECLARATION_CCW_NGPS)
*                         
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_CCW_MAIN
*
* Date        Vers    Developer                   Description
* ----        ----   ---------                    -----------
19/07/2022     1.1   Shailesh Solanki             Initial Version

**************************************************************************************/AS 
v_ERROR VARCHAR2(400);
BEGIN

 --Loads data into SRD_DECLARATION_CCW_NGPS Table in ASB_STG schema
    MERGE INTO SRD_DECLARATION_CCW_NGPS S2
    USING (select sd.ASB_UNIT_CODE, sd.CONTRACT_NUMBER, sd.SERVICE_DATE, sd.SERVICE_PERIOD, 
            sup.contract_seq, DECODE(sd.REJECT_FLAG,'R','REJECTED','FROZEN') as BO_STATUS_CD
            , cs.service_code,FN_Local_DayCode(sd.service_date) as DAY_CODE,
            AVAIL_WEEK,AVAIL_LEVEL,FILE_DATE,FILE_TYPE,REVISED_WEEK,REVISED_LEVEL,REJECT_FLAG
            from srd_declaration sd , srs_supplier_STG sup , asb_contract_service_ngps cs 
            where 
            sup.asb_unit_code = sd.asb_unit_code
            AND sup.contract_number = sd.contract_number 
            AND cs.contract_seq = sup.contract_seq
            AND sup.CONTRACT_SEQ IN (select CONTRACT_SEQ from connect_us_sa_id_ngps)
            AND sd.SERVICE_DATE  >= trunc(cs.CONTRACT_START)  and sd.SERVICE_DATE < trunc(cs.CONTRACT_END)               -- CONTRACT duration Validaton
            AND sup.contract_seq  IN (select CONTRACT_SEQ from srs_supplier_stg a where TENDER_NUMBER <> 99.99) -- NON-PREQUAL contracts only
            AND SERVICE_DATE >=PI_CUT_OFF_DATE AND SERVICE_DATE < TRUNC(PI_END_DATE)+1 AND SERVICE_PERIOD > 0) S1
           ON(S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.CONTRACT_NUMBER=S1.CONTRACT_NUMBER AND S2.SERVICE_DATE=S1.SERVICE_DATE AND S2.SERVICE_PERIOD=S1.SERVICE_PERIOD )
    WHEN MATCHED THEN 
    UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,AVAIL_WEEK=S1.AVAIL_WEEK,AVAIL_LEVEL=S1.AVAIL_LEVEL, FILE_DATE=S1.FILE_DATE,FILE_TYPE=S1.FILE_TYPE,REVISED_WEEK=S1.REVISED_WEEK,
    REVISED_LEVEL=S1.REVISED_LEVEL,REJECT_FLAG=S1.REJECT_FLAG, 
    BO_STATUS_CD = s1.BO_STATUS_CD,
    service_code = s1.service_code,
    DAY_CODE = s1.DAY_CODE,
    contract_seq = s1.contract_seq    
                WHERE  
                       (nvl(s2.FILE_TYPE,'checknull') <> nvl(s1.FILE_TYPE,'checknull')) OR
                       (nvl(s2.REJECT_FLAG,'checknull') <> nvl(s1.REJECT_FLAG,'checknull')) OR
                       (nvl(s2.BO_STATUS_CD,'checknull') <> nvl(s1.BO_STATUS_CD,'checknull')) OR
                       (nvl(s2.service_code,'checknull') <> nvl(s1.service_code,'checknull')) OR
                       (nvl(s2.DAY_CODE,'checknull') <> nvl(s1.DAY_CODE,'checknull')) 


    WHEN NOT MATCHED THEN
    INSERT( LOAD_SEQ_NBR,D1_DYN_OPT_EVENT_ID,CONTRACT_SEQ, ASB_UNIT_CODE,CONTRACT_NUMBER,SERVICE_DATE,SERVICE_PERIOD,AVAIL_WEEK,AVAIL_LEVEL,
    FILE_DATE,FILE_TYPE,REVISED_WEEK,REVISED_LEVEL,REJECT_FLAG,BO_STATUS_CD,SERVICE_CODE,DAY_CODE,DATE_CREATED )
    VALUES(PI_LOAD_SEQ_NBR,SQ_CCW_DYN_OPT_EVENT_ID.nextval,s1.contract_seq ,S1.ASB_UNIT_CODE,S1.CONTRACT_NUMBER,S1.SERVICE_DATE,S1.SERVICE_PERIOD,S1.AVAIL_WEEK,S1.AVAIL_LEVEL,
    S1.FILE_DATE,S1.FILE_TYPE,S1.REVISED_WEEK,S1.REVISED_LEVEL,S1.REJECT_FLAG,
    s1.BO_STATUS_CD
    ,s1.SERVICE_CODE
    ,s1.day_code
    ,SYSDATE);

     PROC_PROCESS_LOG('PR_ASB_LOAD_CCW',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRD_DECLARATION_CCW_NGPS table sucessfully.','CCW');

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
         v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
         DBMS_OUTPUT.PUT_LINE('ERROR : ' || v_ERROR);
        PROC_PROCESS_LOG('PR_ASB_LOAD_CCW',pi_load_seq_nbr,'SUCCESS','No insert or update done in  SRD_DECLARATION_CCW_NGPS table','CCW');
    WHEN OTHERS THEN   
         v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
         DBMS_OUTPUT.PUT_LINE('ERROR : ' || v_ERROR);
         PROC_PROCESS_LOG('PR_ASB_LOAD_CCW',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema','CCW');


END PR_ASB_LOAD_CCW_NGPS;

/

