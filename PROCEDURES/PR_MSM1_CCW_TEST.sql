--------------------------------------------------------
--  DDL for Procedure PR_MSM1_CCW_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_CCW_TEST" (PI_LOAD_SEQ_NBR IN NUMBER)
AS 
v_ERROR varchar2(1000);
v_CNT NUMBER := 0 ;
v_DYN_OPT_EVENT_ID VARCHAR2(14) := NULL;
lv_vc_date date;
v_CONTRACT_START_WINDOW DATE;
v_CONTRACT_END_WINDOW DATE;
v_TABLE VARCHAR2(100) := NULL;

v_season_number number;

v_EX_COUNT NUMBER :=0 ;
v_COUNT NUMBER := 0;

CURSOR cur_CCW_CNT
IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, SERVICE_DATE, SERVICE_PERIOD, CONTRACT_SEQ, BO_STATUS_CD, SERVICE_CODE,DAY_CODE,sd.d1_dyn_opt_event_id
from srd_declaration_stg sd where LOAD_SEQ_NBR = 1060 AND
SERVICE_DATE >=to_date('01-APR-2020 00:00:00','DD-MON-YYYY HH24:MI:SS') AND SERVICE_DATE < trunc(to_date('01-APR-2021 00:00:00','DD-MON-YYYY HH24:MI:SS')+1);

BEGIN

        --    select fn_convert_bst_gmt(sysdate) into lv_vc_date from dual;
        v_TABLE := 'D1_DYN_OPT_EVENT' ;

        FOR rec in cur_CCW_CNT
        LOOP
                BEGIN 
                    SELECT TO_DATE(to_CHAR(rec.SERVICE_DATE,'DD-MON-YYYY ') || to_char(dw.start_local,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')
                    , TO_DATE(to_CHAR(rec.SERVICE_DATE,'DD-MON-YYYY ') || to_char(dw.end_local,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')
                    , se.season_number
                    into v_CONTRACT_START_WINDOW, v_CONTRACT_END_WINDOW
                    , v_season_number
                    FROM 
                    asb_season_stg se , asb_duty_window_stg dw
                    WHERE 
                    se.effective = (select max(effective) from asb_season_stg where service_code = rec.service_code AND trunc(effective) <= rec.SERVICE_DATE)  
--                    trunc "trunc(effective)" is added  to fetch the data without considering the timestamp of the service date done on 10-03-2022 by Anish_11184 
                    AND se.service_code = rec.service_code
                    AND se.season_seq = dw.season_seq
                    AND dw.service_period = rec.service_period
                    AND rec.day_code = dw.day_code ;
                EXCEPTION
                 WHEN OTHERS THEN
                 v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,1000);
                 DBMS_OUTPUT.PUT_LINE(v_ERROR);
                 v_EX_COUNT := v_EX_COUNT + 1;
                 
                 CONTINUE;
                END;
            v_TABLE := 'D1_DYN_OPT_EVENT 1.0' ;
            --Inserting data to D1_DYN_OPT_EVENT table
            v_COUNT := v_COUNT + 1; 
              

        END LOOP; 
        
        DBMS_OUTPUT.PUT_LINE('EXCEPTION COUNT --> ' || v_EX_COUNT) ;
        DBMS_OUTPUT.PUT_LINE('Table COUNT --> ' || v_COUNT) ;

  

    --EXCEPTIONS
    EXCEPTION
     WHEN OTHERS THEN   
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,1000);
         PROC_PROCESS_LOG('PR_MSM1_CCW - ' || v_TABLE,PI_LOAD_SEQ_NBR,'FAILURE', V_ERROR,'CCW');
         ROLLBACK;
         DBMS_OUTPUT.PUT_LINE(v_ERROR);

END PR_MSM1_CCW_TEST;

/

