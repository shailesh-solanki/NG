--------------------------------------------------------
--  DDL for Procedure PR_MSM1_CCW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_CCW" (PI_LOAD_SEQ_NBR IN NUMBER)
/**************************************************************************************
*
* Program Name           :PR_MSM1_CCW
* Author                 :IBM(Shailesh Solanki/Shailesh Solanki)
* Creation Date          :15-07-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate CCW data from ASB_STG TO MSM_STG1
*
* Calling Program        :None
* Called Program         : PR_ASB_LOAD_CCW_MAIN 
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* Date        Vers    Developer                   Description
* ----        ----   ---------                    -----------
19/07/2022     1.1   Shailesh Solanki             Initial Version

**************************************************************************************/
AS 
v_ERROR varchar2(1000);
v_CNT NUMBER := 0 ;
v_DYN_OPT_EVENT_ID VARCHAR2(14) := NULL;
lv_vc_date date;
v_CONTRACT_START_WINDOW DATE;
v_CONTRACT_END_WINDOW DATE;
v_TABLE VARCHAR2(100) := NULL;

v_season_number number;

CURSOR cur_CCW_CNT
IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, SERVICE_DATE, SERVICE_PERIOD, CONTRACT_SEQ, BO_STATUS_CD, SERVICE_CODE,DAY_CODE,sd.d1_dyn_opt_event_id
from srd_declaration_stg sd where LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

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
                 WHEN NO_DATA_FOUND THEN
                 CONTINUE;
                END;
            v_TABLE := 'D1_DYN_OPT_EVENT 1.0' ;
            --Inserting data to D1_DYN_OPT_EVENT table
                INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT(
                LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, BUS_OBJ_CD, BO_STATUS_CD, BO_STATUS_REASON_CD,DYN_OPT_ID,
                START_DTTM, END_DTTM, STATUS_UPD_DTTM, CRE_DTTM, VERSION, BO_DATA_AREA, QUANTITY, DATE_CREATED)
                VALUES
                (pi_load_seq_nbr,rec.d1_dyn_opt_event_id,'CM-DynamicOptionEvent',rec.BO_STATUS_CD,' ',rec.contract_seq,
                 fn_convert_bst_gmt(v_CONTRACT_START_WINDOW),fn_convert_bst_gmt(v_CONTRACT_END_WINDOW),
                 fn_convert_bst_gmt(SYSDATE),fn_convert_bst_gmt(SYSDATE),
                 99,NULL,0,SYSDATE);
                 
                    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, 
                    ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
                    CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
                    values ( pi_load_seq_nbr, rec.d1_dyn_opt_event_id ,'CM-SEAID', 3,' ', v_season_number, ' ', ' ', ' ', ' ',
                    ' ', ' ', 99, SYSDATE );

        END LOOP; 

    v_TABLE := 'D1_DYN_OPT_EVENT_LOG' ;
    --Inserting data  to msm_stg1.D1_DYN_OPT_EVENT_LOG
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, LOG_ENTRY_TYPE_FLG, LOG_DTTM, DESCRLONG, BO_STATUS_CD, MESSAGE_CAT_NBR, MESSAGE_NBR, 
    CHAR_TYPE_CD, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4, CHAR_VAL_FK5, USER_ID, VERSION, BO_STATUS_REASON_CD, DATE_CREATED
    )
    SELECT  pi_load_seq_nbr,DYN_OPT_EVENT_ID,1,'F1CR',SYSDATE,' ','FROZEN',
        '11002','12151',' ',' ',' ',' ',' ',' ',' ',' ','MIGD',99,' ',SYSDATE
    FROM MSM_STG1.D1_DYN_OPT_EVENT
    WHERE load_seq_nbr = pi_load_seq_nbr AND BO_STATUS_CD = 'FROZEN';

    v_TABLE := 'D1_DYN_OPT_EVENT_LOG_PARM' ;
    --Inserting data  to MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, PARM_SEQ, MSG_PARM_TYP_FLG, MSG_PARM_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,1, 2, ' ','Frozen',99,SYSDATE FROM MSM_STG1.D1_DYN_OPT_EVENT
    WHERE load_seq_nbr = pi_load_seq_nbr AND BO_STATUS_CD = 'FROZEN';

    v_TABLE := 'D1_DYN_OPT_EVENT_CHAR' ;
    --Inserting data  to msm_stg1.D1_DYN_OPT_EVENT_CHAR
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
    CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, s1.D1_DYN_OPT_EVENT_ID,'CM-WINID', 2,' ', s1.SERVICE_PERIOD, ' ', ' ', ' ', ' ',
    ' ', ' ', 99, SYSDATE  FROM ASB_STG.srd_declaration_stg s1, MSM_STG1.D1_DYN_OPT_EVENT d1
    WHERE s1.load_seq_nbr = pi_load_seq_nbr AND s1.load_seq_nbr = d1.load_seq_nbr
    AND s1.D1_DYN_OPT_EVENT_ID = d1.DYN_OPT_EVENT_ID ;
    
    v_TABLE := 'D1_DYN_OPT_EVENT_CHAR' ;
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
    CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,'CM-DOECV', 1,' ','CM_AVAIL_DEC_CONTRACT', ' ', ' ', ' ', ' ',
    ' ', ' ', 99, SYSDATE  FROM msm_stg1.D1_DYN_OPT_EVENT
    WHERE load_seq_nbr = pi_load_seq_nbr; 
    
    v_TABLE := 'D1_DYN_OPT_EVENT_LOG REJECTED WINDOWS' ;
    -- For REJECTED WINDOWS only
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, LOG_ENTRY_TYPE_FLG, LOG_DTTM, DESCRLONG, BO_STATUS_CD, MESSAGE_CAT_NBR, MESSAGE_NBR, 
    CHAR_TYPE_CD, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4, CHAR_VAL_FK5, USER_ID, VERSION, BO_STATUS_REASON_CD, DATE_CREATED
    )
    SELECT  pi_load_seq_nbr,DYN_OPT_EVENT_ID,2,'F1ST',SYSDATE,' ','REJECTED',
        '11002','12150',' ',' ',' ',' ',' ',' ',' ',' ','MIGD',99,' ',SYSDATE
    FROM MSM_STG1.D1_DYN_OPT_EVENT WHERE BO_STATUS_CD = 'REJECTED'
    AND load_seq_nbr = pi_load_seq_nbr;
    
    v_TABLE := 'D1_DYN_OPT_EVENT_LOG_PARM REJECTED' ;
    --Inserting data  to MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, PARM_SEQ, MSG_PARM_TYP_FLG, MSG_PARM_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,2, 3, ' ','REJECTED',99,SYSDATE FROM MSM_STG1.D1_DYN_OPT_EVENT
    WHERE load_seq_nbr = pi_load_seq_nbr AND BO_STATUS_CD = 'REJECTED';

    PROC_PROCESS_LOG('PR_MSM1_CCW',pi_load_seq_nbr,'SUCCESS','All the new records pushed to MSM_STG1 tables sucessfully.','CCW');
    
    --EXCEPTIONS
    EXCEPTION
     WHEN OTHERS THEN   
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,1000);
         PROC_PROCESS_LOG('PR_MSM1_CCW - ' || v_TABLE,PI_LOAD_SEQ_NBR,'FAILURE', V_ERROR,'CCW');
         ROLLBACK;
         DBMS_OUTPUT.PUT_LINE(v_ERROR);
         
END PR_MSM1_CCW;

/

