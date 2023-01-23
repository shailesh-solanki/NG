--------------------------------------------------------
--  DDL for Package Body PKG_PAYMENT_DATA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "ASB_STG"."PKG_PAYMENT_DATA_MIGRATION" AS
    
    PROCEDURE PR_PAYMENT_DATA_LOAD(pi_load_seq_nbr in number,pi_start in date,pi_end in date) IS
        
        TYPE payment_tab IS TABLE OF SRS_SECTION_PAYMENT%ROWTYPE;
        l_payment_type payment_tab;
    
    BEGIN
        
        DBMS_OUTPUT.PUT_LINE('Start loading: ' ||SYSDATE);
        
        /*SELECT A.* BULK COLLECT INTO l_payment_type FROM SRS_SECTION_PAYMENT A WHERE PAY_DATE BETWEEN TRUNC(PI_START) AND TRUNC(PI_END);
        
        FORALL i IN 1..l_payment_type.COUNT
            INSERT INTO SRS_SECTION_PAYMENT_STG(LOAD_SEQ_NBR,RESOURCE_CODE,PAY_CODE,PAY_START,PAY_END,CONTRACT_SEQ,PAY_DATE,PRICE_BASE,PAY_RATE,PAY_VALUE,DURATION,CONTRACT_NUMBER,FINANCIAL_YEAR
            ,SEASON_NUMBER,DAY_CODE,SERVICE_PERIOD,AVAIL_FLAG,FM_STATUS,FF_STATUS,MAN_FAIL,AUTO_FAIL,AVAIL_LEV,NUM_BO_PAIR,BID_PRICE,OFFER_PRICE,BO_LEVEL,FPN_VOLUME,NDZ,MDP,MZT,UTIL_ISSUED,UTIL_LEVEL
            ,UTIL_PAY_RATE,MNZT,EXPECTED_VOLUME,METERED_VOLUME,BO_VOLUME,CAPBL_FAIL,UTIL_FAIL,CONTRACTED_ENERGY,EXPECTED_ENERGY,METERED_ENERGY,DELIVERED_ENERGY,CAPPED_ENERGY,RESPONSE_FAIL,
            DELIVERY_FAIL,OTHER_FAIL,RAMP_FLAG,DATE_CREATED) 
            VALUES(PI_LOAD_SEQ_NBR,l_payment_type(i).RESOURCE_CODE,l_payment_type(i).PAY_CODE,l_payment_type(i).PAY_START,l_payment_type(i).PAY_END,l_payment_type(i).CONTRACT_SEQ,
            l_payment_type(i).PAY_DATE,l_payment_type(i).PRICE_BASE,l_payment_type(i).PAY_RATE,l_payment_type(i).PAY_VALUE,l_payment_type(i).DURATION,l_payment_type(i).CONTRACT_NUMBER,
            l_payment_type(i).FINANCIAL_YEAR,l_payment_type(i).SEASON_NUMBER,l_payment_type(i).DAY_CODE,l_payment_type(i).SERVICE_PERIOD,l_payment_type(i).AVAIL_FLAG,l_payment_type(i).FM_STATUS,
            l_payment_type(i).FF_STATUS,l_payment_type(i).MAN_FAIL,l_payment_type(i).AUTO_FAIL,l_payment_type(i).AVAIL_LEV,l_payment_type(i).NUM_BO_PAIR,l_payment_type(i).BID_PRICE,
            l_payment_type(i).OFFER_PRICE,l_payment_type(i).BO_LEVEL,l_payment_type(i).FPN_VOLUME,l_payment_type(i).NDZ,l_payment_type(i).MDP,l_payment_type(i).MZT,l_payment_type(i).UTIL_ISSUED,
            l_payment_type(i).UTIL_LEVEL,l_payment_type(i).UTIL_PAY_RATE,l_payment_type(i).MNZT,l_payment_type(i).EXPECTED_VOLUME,l_payment_type(i).METERED_VOLUME,l_payment_type(i).BO_VOLUME,
            l_payment_type(i).CAPBL_FAIL,l_payment_type(i).UTIL_FAIL,l_payment_type(i).CONTRACTED_ENERGY,l_payment_type(i).EXPECTED_ENERGY,l_payment_type(i).METERED_ENERGY,
            l_payment_type(i).DELIVERED_ENERGY,l_payment_type(i).CAPPED_ENERGY,l_payment_type(i).RESPONSE_FAIL,l_payment_type(i).DELIVERY_FAIL,l_payment_type(i).OTHER_FAIL,l_payment_type(i).RAMP_FLAG,
            SYSDATE);*/
            DBMS_OUTPUT.PUT_LINE('Start Section payment loading: ' ||SYSDATE);
            INSERT INTO SRS_SECTION_PAYMENT_STG 
            SELECT PI_LOAD_SEQ_NBR,A.*,SYSDATE FROM SRS_SECTION_PAYMENT A WHERE TRUNC(PAY_START) BETWEEN TRUNC(PI_START) AND TRUNC(PI_END);
            
            DBMS_OUTPUT.PUT_LINE('Start Failure pall loading: ' ||SYSDATE);
            INSERT INTO SRS_FAILURE_PALL_STG 
            SELECT PI_LOAD_SEQ_NBR,A.*,SYSDATE FROM SRS_FAILURE_PALL A WHERE TRUNC(FAIL_START) BETWEEN TRUNC(PI_START) AND TRUNC(PI_END);
            
            DBMS_OUTPUT.PUT_LINE('Start Utilisation loading: ' ||SYSDATE);
            INSERT INTO SRS_UTILISATION_STG 
            SELECT PI_LOAD_SEQ_NBR,A.*,SYSDATE FROM SRS_UTILISATION A WHERE TRUNC(UTIL_START) BETWEEN TRUNC(PI_START) AND TRUNC(PI_END);

        DBMS_OUTPUT.PUT_LINE('End loading: ' ||SYSDATE);
   
    END PR_PAYMENT_DATA_LOAD;
    
    --Code without NGPS
    PROCEDURE PR_PAYMENT_DATA_TRANSFER(pi_load_seq_nbr in number,pi_version in number) IS
    BEGIN
        
        DBMS_OUTPUT.PUT_LINE('Start loading: ' ||SYSDATE);
        
        insert into srs_section_payment 
        select c.asb_comp_code,a.* from srs_section_payment_stg a, 
        asb_contract_service_stg c
        where a.contract_seq=c.contract_seq
        and a.load_seq_nbr = pi_load_seq_nbr;
        
        
        
        DBMS_OUTPUT.PUT_LINE('End loading: ' ||SYSDATE);
        
    END PR_PAYMENT_DATA_TRANSFER;

END PKG_PAYMENT_DATA_MIGRATION;

/

