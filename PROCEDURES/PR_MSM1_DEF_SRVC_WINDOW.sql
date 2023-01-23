--------------------------------------------------------
--  DDL for Procedure PR_MSM1_DEF_SRVC_WINDOW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_DEF_SRVC_WINDOW" (PI_LOAD_SEQ_NBR IN NUMBER) 
AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_DEF_SRVC_WINDOW
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-05-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into F1_EXT_LOOKUP_VAL & F1_EXT_LOOKUP_VAL_L(MSM_STG1) from ASB_SEASON_STG & ASB_DUTY_WINDOW_STG table.
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_DSW_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  26-05-2021     Shailesh Solanki   Changes for Operational Data (NDZ)
**************************************************************************************/

v_ERROR VARCHAR2(1000);
v_BO_DATA_AREA VARCHAR2(5000);
v_SEASON_SEQ ASB_DUTY_WINDOW_STG.SEASON_SEQ%TYPE;
v_financial_year VARCHAR2(4000);
v_DESCR VARCHAR2(100);
v_curr_financial_year NUMBER := 0;
v_MAX_SEASON_NUMBER NUMBER := 0;
v_MAX_WD_SP NUMBER;
v_MAX_NWD_SP NUMBER;
v_COUNT NUMBER;

CURSOR cur_ASB_SEASON IS 
select SEASON_SEQ, SERVICE_CODE, EFFECTIVE,LEAD(EFFECTIVE) OVER(ORDER BY EFFECTIVE) END_DATE , FINANCIAL_YEAR, SEASON_NUMBER, SUPPLEMENTARY
from ASB_SEASON_STG where SERVICE_CODE = 'SRBM' and load_seq_nbr = PI_LOAD_SEQ_NBR 
AND NVL(supplementary,'checknull') <> 'Y'
AND SEASON_SEQ IN (select distinct SEASON_SEQ from asb_duty_window_stg) order by financial_year,SEASON_NUMBER;

CURSOR cur_ASB_DUTY_WINDOW IS 
select SEASON_SEQ, DAY_CODE, START_LOCAL, END_LOCAL, SERVICE_PERIOD
from ASB_DUTY_WINDOW_STG where load_seq_nbr = PI_LOAD_SEQ_NBR AND SEASON_SEQ = v_SEASON_SEQ 
order by DAY_CODE, SERVICE_PERIOD;

BEGIN


    v_BO_DATA_AREA := v_BO_DATA_AREA || '<seasonWindow>';

    FOR rec in cur_ASB_SEASON
    LOOP

        select MAX(SEASON_NUMBER) into v_MAX_SEASON_NUMBER
        from ASB_SEASON_STG where SERVICE_CODE = 'SRBM' AND NVL(supplementary,'checknull') <> 'Y' and load_seq_nbr = PI_LOAD_SEQ_NBR AND FINANCIAL_YEAR = rec.financial_year ;

        v_SEASON_SEQ := rec.SEASON_SEQ;

        select count(1) into v_COUNT from asb_duty_window_stg
        where SEASON_SEQ = rec.SEASON_SEQ AND DAY_CODE = 'WD' ;

        IF (v_COUNT >0) THEN
        select NVL(max(SERVICE_PERIOD),0) into v_MAX_WD_SP from asb_duty_window_stg
        where SEASON_SEQ = rec.SEASON_SEQ AND DAY_CODE = 'WD' group by SEASON_SEQ,DAY_CODE ;
        END IF;

        select count(1) into v_COUNT from asb_duty_window_stg
        where SEASON_SEQ = rec.SEASON_SEQ AND DAY_CODE = 'NWD' ;

        IF (v_COUNT >0) THEN
        select NVL(max(SERVICE_PERIOD),0) into v_MAX_NWD_SP from asb_duty_window_stg
        where SEASON_SEQ = rec.SEASON_SEQ AND DAY_CODE = 'NWD' group by SEASON_SEQ,DAY_CODE ;
        END IF ;

        v_BO_DATA_AREA := v_BO_DATA_AREA || '<seasonList><season>' || rec.SEASON_NUMBER || '</season>';
        v_BO_DATA_AREA := v_BO_DATA_AREA || '<startDate>' || to_char(rec.EFFECTIVE,'YYYY-MM-DD-HH24.MI.SS') ||'</startDate>';

        IF (rec.END_DATE IS NULL) THEN
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<endDate>' || to_char(rec.EFFECTIVE,'YYYY') || '-04-01-05.00.00' ||'</endDate>';
        ELSE 
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<endDate>' || to_char(rec.END_DATE,'YYYY-MM-DD-HH24.MI.SS') ||'</endDate>';
        END IF;


        FOR rec2 in cur_ASB_DUTY_WINDOW
        LOOP

            IF (rec2.SERVICE_PERIOD = 1) THEN
                v_BO_DATA_AREA := v_BO_DATA_AREA || '<dayType>' ;
                v_BO_DATA_AREA := v_BO_DATA_AREA || '<day>' || rec2.DAY_CODE || '</day>' ;
                v_BO_DATA_AREA := v_BO_DATA_AREA || '<timeGroup>';
            END IF;

            v_BO_DATA_AREA := v_BO_DATA_AREA || '<time>';
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<windowId>' || rec2.SERVICE_PERIOD || '</windowId>';
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<startTime>' || to_char(rec2.START_LOCAL,'HH24.MI.SS') ||'</startTime>';
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<endTime>' || to_char(rec2.END_LOCAL,'HH24.MI.SS') ||'</endTime>';
            v_BO_DATA_AREA := v_BO_DATA_AREA || '</time>';            

            IF (rec2.SERVICE_PERIOD = v_MAX_WD_SP AND rec2.DAY_CODE = 'WD') THEN
                v_BO_DATA_AREA := v_BO_DATA_AREA || '</timeGroup>';
                v_BO_DATA_AREA := v_BO_DATA_AREA || '</dayType>' ;
            END IF;

            IF (rec2.SERVICE_PERIOD = v_MAX_NWD_SP AND rec2.DAY_CODE = 'NWD') THEN
                v_BO_DATA_AREA := v_BO_DATA_AREA || '</timeGroup>';
                v_BO_DATA_AREA := v_BO_DATA_AREA || '</dayType>' ;
            END IF;            

        END LOOP;
                v_BO_DATA_AREA := v_BO_DATA_AREA || '</seasonList>';

        --   Inserting records in F1_EXT_LOOKUP_VAL (MSM_STG1)
        IF(v_curr_financial_year <> rec.financial_year) THEN

            v_DESCR := 'Year ' || to_char(rec.EFFECTIVE,'YYYY') || ' STOR Seasons - ' || RTRIM(to_char(rec.EFFECTIVE,'DD Month')) || 
            to_char(rec.EFFECTIVE,' YYYY') || ' to ' || '1 April' || to_char(rec.EFFECTIVE+365,' YYYY');

            INSERT INTO MSM_STG1.F1_EXT_LOOKUP_VAL_L(LOAD_SEQ_NBR, BUS_OBJ_CD, F1_EXT_LOOKUP_VALUE, LANGUAGE_CD, DESCR, DESCR_OVRD, DESCRLONG, OWNER_FLG, VERSION, DATE_CREATED) values
            (PI_LOAD_SEQ_NBR,'CM-ServiceWindow',rec.financial_year,'ENG',v_DESCR,' ',' ','CM',99,SYSDATE);

            v_curr_financial_year := rec.financial_year;

        END IF;

        --   Inserting records in F1_EXT_LOOKUP_VAL_L (MSM_STG1)
        IF(rec.SEASON_NUMBER = v_MAX_SEASON_NUMBER) THEN

            v_MAX_SEASON_NUMBER := 0 ;
            v_BO_DATA_AREA := v_BO_DATA_AREA || '</seasonWindow>';

            INSERT INTO MSM_STG1.F1_EXT_LOOKUP_VAL(LOAD_SEQ_NBR, BUS_OBJ_CD, F1_EXT_LOOKUP_VALUE, F1_EXT_LOOKUP_USAGE_FLG, BO_DATA_AREA, OWNER_FLG, VERSION, BASE_BO_DATA_AREA, DATE_CREATED) values 
            (PI_LOAD_SEQ_NBR,'CM-ServiceWindow',rec.financial_year,'F1AC',v_BO_DATA_AREA,'CM',99,' ',SYSDATE );

            v_BO_DATA_AREA := NULL;
            v_BO_DATA_AREA := v_BO_DATA_AREA || '<seasonWindow>';

        END IF ;


    END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        PROC_PROCESS_LOG('PR_MSM1_DEF_SRVC_WINDOW',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'DSW');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_DEF_SRVC_WINDOW;

/

