--------------------------------------------------------
--  DDL for Procedure PR_MSM1_ACCEPTED_TENDERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_ACCEPTED_TENDERS" 
(
    PI_LOAD_SEQ_NBR IN NUMBER
    ,PI_CSV_FILE_NAME_DT IN VARCHAR2 -- Added by Anish Kumar S on 25-10-2021
) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_ACCEPTED_TENDERS
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :05-08-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_US_QTY(MSM_STG1).
* Calling Program        :None
* Called Program         :PR_ASB_LOAD__MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  05-08-2021     Shailesh Solanki   Changes for Accepted_tenders
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID NUMBER;
v_DYN_OPT_ID NUMBER;
v_D1_US_QTY_ID NUMBER;
v_DYN_OPT_EVENT_ID NUMBER;
v_ERROR VARCHAR2(1000);
v_cont_seq NUMBER;

CURSOR cur_Accept_tenders IS 
select CONTRACT_NUMBER, NGESO_UNIT_ID, WINDOW_START_DATE_TIME, WINDOW_END_DATE_TIME, AVAILABILITY_PRICE, CONTRACTED_MW, tat.CONTRACT_SEQ, cus.us_id, 'CM-ACTTNDUSQNTY' as bus_obj_cd
from TRN_ACCEPTED_TENDER tat, connect_us_sa_id cus
where tat.contract_seq=cus.contract_seq AND tat.load_seq_nbr=pi_load_seq_nbr
union
select CONTRACT_NUMBER, NGESO_UNIT_ID, WINDOW_START_DATE_TIME, WINDOW_END_DATE_TIME, AVAILABILITY_PRICE, CONTRACTED_MW, tat.CONTRACT_SEQ, cus.us_id, 'CM-ACTTNDUSQNTY' as bus_obj_cd
from TRN_ACCEPTED_TENDER tat, connect_us_sa_id_ngps cus
where tat.contract_seq=cus.contract_seq AND tat.load_seq_nbr=pi_load_seq_nbr
;
/*
select sss.contract_seq, cus.us_id, sat.window_start_date_time, sat.window_end_date_time,sat.contracted_mw,sat.availability_price,sat.CONTRACT_NUMBER,
--sat.CRM_UNIQUE_ID,
'CM-ACTTNDUSQNTY' as bus_obj_cd
from stor_accepted_tenders_csv sat, srs_supplier_stg sss,connect_us_sa_id cus
where sat.contract_number=sss.contRact_number and
sat.ngeso_unit_id= sss.asb_unit_code and
sss.contract_seq=cus.contract_seq AND
sat.load_seq_nbr=pi_load_seq_nbr;
*/

CURSOR cur_Act_cnt IS
select CONTRACT_SEQ, CONTRACT_NUMBER, NGESO_UNIT_ID, WINDOW_START_DATE_TIME, WINDOW_END_DATE_TIME, AVAILABILITY_PRICE, CONTRACTED_MW--, LOAD_SEQ_NBR
from TRN_ACCEPTED_TENDER tat
where LOAD_SEQ_NBR = pi_load_seq_nbr;
/*
select sus.contract_seq,str.contract_number,str.ngeso_unit_id,str.window_start_date_time,str.window_end_date_time,str.contracted_mw,
str.availability_price
from stor_accepted_tenders_csv str, srs_supplier_stg sus 
where str.contract_number=sus.contract_number AND
str.ngeso_unit_id=sus.asb_unit_code AND
str.load_seq_nbr=pi_load_seq_nbr;
*/
-- Patch Added by Anish Kumar S on 23-11-2021
/*CURSOR c3 
    is
        select sd.SERVICE_PERIOD,sd.d1_dyn_opt_event_id,se.season_number
        from srd_declaration_stg sd,asb_season_stg se , asb_duty_window_stg dw 
        where
            se.effective = (select max(effective) from asb_season_stg se where service_code = sd.service_code AND effective <= sd.SERVICE_DATE)
            AND se.service_code = sd.service_code
            AND se.season_seq = dw.season_seq
            AND dw.service_period = sd.service_period
            AND sd.day_code = dw.day_code;*/
-- Patch End by Anish KumarS on 23-11-2021  

BEGIN

    FOR rec in cur_Accept_tenders
    LOOP
              -- Inserting data to MSM_STG1.D1_US_QTY_ACT table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_ACT(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
              values(pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,rec.contract_seq,'ACCEPTED_TENDER',rec.window_start_date_time,rec.window_end_date_time,'D1AC','CM-ACTTNDUSQNTY',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),
--              '<BO_XML_DATA_AREA><crmUnique>'||rec.CRM_UNIQUE_ID||'</crmUnique></BO_XML_DATA_AREA>'
              '<BO_XML_DATA_AREA><crmUnique>'||rec.contract_number||'</crmUnique></BO_XML_DATA_AREA>'
              ,99,rec.contracted_mw,rec.availability_price,0,0,0,sysdate);
    END LOOP;     

    --Inserting data  to MSM_STG1.d1_us_qty_log_ACT
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_ACT(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    SELECT PI_LOAD_SEQ_NBR,D1_US_QTY_ID,1,sysdate,'F1CR',' ',' ',' ','11002','12152',' ',' ',' ',' ',' ',' ',
    ' ',' ','MIGD','99',SYSDATE FROM msm_stg1.D1_US_QTY_ACT WHERE load_seq_nbr = pi_load_seq_nbr;
    --for sequence number 2 
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_ACT(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    SELECT PI_LOAD_SEQ_NBR,D1_US_QTY_ID,2,sysdate,'F1US','User Details',' ',' ','0','0','CM-LFLNM',' ',PI_CSV_FILE_NAME_DT--'STOR_ACCEPTED_TENDER_20210118'
    ,' ',' ',' ',' ',' ','MIGD','99',SYSDATE FROM msm_stg1.D1_US_QTY_ACT WHERE load_seq_nbr = pi_load_seq_nbr;
    
   FOR rec in cur_Act_cnt
    LOOP
        --Inserting data to MSM_STG1.D1_DYN_OPT_EVENT_ACT table
            INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_ACT(LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, BUS_OBJ_CD, BO_STATUS_CD, BO_STATUS_REASON_CD,DYN_OPT_ID,
            START_DTTM, END_DTTM, STATUS_UPD_DTTM, CRE_DTTM, VERSION, BO_DATA_AREA, QUANTITY, DATE_CREATED)
            VALUES(pi_load_seq_nbr,SQ_CCW_DYN_OPT_EVENT_ID.nextval,'CM-DynamicOptionEvent','FROZEN',' ',rec.contract_seq,
             rec.window_start_date_time,rec.window_end_date_time,fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),
             99,NULL,0,SYSDATE);
    END LOOP; 

    --Inserting data  to MSM_STG1.D1_DYN_OPT_EVENT_LOG_ACT
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, LOG_ENTRY_TYPE_FLG, LOG_DTTM, DESCRLONG, BO_STATUS_CD, MESSAGE_CAT_NBR, MESSAGE_NBR, 
    CHAR_TYPE_CD, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4, CHAR_VAL_FK5, USER_ID, VERSION, BO_STATUS_REASON_CD, DATE_CREATED
    )
    SELECT  pi_load_seq_nbr,DYN_OPT_EVENT_ID,1,'F1CR',fn_convert_bst_gmt(sysdate),' ','FROZEN',
        '11002','12151',' ',' ',' ',' ',' ',' ',' ',' ','MIGD',99,' ',SYSDATE
    FROM MSM_STG1.D1_DYN_OPT_EVENT_ACT
    WHERE load_seq_nbr = pi_load_seq_nbr;

    --Inserting data  to MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM_ACT
    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_LOG_PARM_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, SEQNO, PARM_SEQ, MSG_PARM_TYP_FLG, MSG_PARM_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,1, 2,' ','Frozen',99,SYSDATE FROM MSM_STG1.D1_DYN_OPT_EVENT_ACT
    WHERE load_seq_nbr = pi_load_seq_nbr;

    INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
    CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
    SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,'CM-DOECV', 1,' ','CM_AVAIL_DEC_CONTRACT', ' ', ' ', ' ', ' ',
    ' ', ' ', 99, SYSDATE  FROM msm_stg1.D1_DYN_OPT_EVENT_ACT
    WHERE load_seq_nbr = pi_load_seq_nbr; 
    
    -- Patch Added by Anish Kumar S on 23-11-2021
  /*  for i in c3
    loop
        INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
        CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
        SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,'CM-WINID', 2,' ',I.SERVICE_PERIOD, ' ', ' ', ' ', ' ',
        ' ', ' ', 99, SYSDATE  FROM msm_stg1.D1_DYN_OPT_EVENT_ACT DOE
        WHERE load_seq_nbr = pi_load_seq_nbr AND DOE.DYN_OPT_EVENT_ID = I.d1_dyn_opt_event_id;
        
        INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
        CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
        SELECT pi_load_seq_nbr, DYN_OPT_EVENT_ID,' ', 3,' ',I.season_number, ' ', ' ', ' ', ' ',
        ' ', ' ', 99, SYSDATE  FROM msm_stg1.D1_DYN_OPT_EVENT_ACT DOE
        WHERE load_seq_nbr = pi_load_seq_nbr AND DOE.DYN_OPT_EVENT_ID = I.d1_dyn_opt_event_id;
    end loop;*/
    -- Patch End by Anish KumarS on 23-11-2021
    
    -- Patch Added by Anish Kumar S on 27-01-2022                    
        for x in (                     
            SELECT SEASON_NUMBER, SERVICE_PERIOD, DYN_OPT_EVENT_ID FROM
                (
                SELECT 
                    x.LOAD_SEQ_NBR, WINDOW_START_DATE_TIME, WINDOW_END_DATE_TIME, X.CONTRACT_SEQ, X.SEASON_SEQ, X.SERVICE_CODE, SEASON_NUMBER, Y.SERVICE_PERIOD
                --    , START_LOCAL, END_LOCAL
                --    , FN_CONVERT_BST_GMT(TO_DATE(TO_CHAR(WINDOW_START_DATE_TIME,'DD-MON-YYYY ') || TO_CHAR(START_LOCAL,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')) M
                --    , FN_CONVERT_BST_GMT(TO_DATE(TO_CHAR(WINDOW_END_DATE_TIME,'DD-MON-YYYY ') || TO_CHAR(END_LOCAL,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')) N
                --    , 441 D1_DYN_OPT_EVENT_ID
                FROM 
                    (
                    SELECT --*
                        CSV.LOAD_SEQ_NBR, CSV.WINDOW_START_DATE_TIME, CSV.WINDOW_END_DATE_TIME, CSV.CONTRACT_SEQ, ASS.SEASON_SEQ, ASS.SERVICE_CODE, ASS.SEASON_NUMBER
                    FROM 
                        TRN_ACCEPTED_TENDER CSV --stor_accepted_tenders_csv csv, asb_unit_stg aus, srs_supplier_stg sss
                        , (select * from ASB_CONTRACT_SERVICE_STG UNION select * from asb_contract_service_ngps) ACS
                        ,(SELECT SEASON_SEQ, SERVICE_CODE, EFFECTIVE, SEASON_NUMBER, 
                            LEAD(EFFECTIVE, 1,(EFFECTIVE+INTERVAL '1' SECOND)) OVER (PARTITION BY SERVICE_CODE ORDER BY EFFECTIVE)-INTERVAL '1' SECOND LEAD_EFFECTIVE 
                          FROM ASB_SEASON_STG) ASS
                    WHERE CSV.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR --and csv.ngeso_unit_id = aus.goal_unit_code and csv.contract_number = sss.CONTRACT_NUMBER and aus.asb_unit_code = sss.asb_unit_code
                        AND CSV.CONTRACT_SEQ = ACS.CONTRACT_SEQ
                        AND ACS.SERVICE_CODE = ASS.SERVICE_CODE
                        AND CSV.WINDOW_START_DATE_TIME BETWEEN ASS.EFFECTIVE AND ASS.LEAD_EFFECTIVE 
                    ) X,
                    ASB_DUTY_WINDOW_STG Y
                --    , MSM_STG1.D1_DYN_OPT_EVENT_ACT z
                WHERE X.SEASON_SEQ = Y.SEASON_SEQ 
                AND FN_CONVERT_BST_GMT(TO_DATE(TO_CHAR(X.WINDOW_START_DATE_TIME,'DD-MON-YYYY ') || TO_CHAR(Y.START_LOCAL,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS')) = X.WINDOW_START_DATE_TIME
                AND FN_CONVERT_BST_GMT(TO_DATE(TO_CHAR(X.WINDOW_END_DATE_TIME,'DD-MON-YYYY ') || TO_CHAR(Y.END_LOCAL,'HH24:MI:SS'),'DD-MON-YYYY HH24:MI:SS'))  = X.WINDOW_END_DATE_TIME
                AND FN_LOCAL_DAYCODE(TRUNC(WINDOW_START_DATE_TIME)) = Y.DAY_CODE ) X
                , MSM_STG1.D1_DYN_OPT_EVENT_ACT z
            where Z.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR
            and x.LOAD_SEQ_NBR = Z.LOAD_SEQ_NBR
            and x.CONTRACT_SEQ = z.DYN_OPT_ID
            and x.WINDOW_START_DATE_TIME = z.START_DTTM
            and x.WINDOW_END_DATE_TIME = z.END_DTTM
        )
    loop
    
--        if substr(to_char(x.WINDOW_START_DATE_TIME,'dd-mon-yy hh24:mi:ss'),-8) = x.START_LOCAL_TS and substr(to_char(x.WINDOW_END_DATE_TIME,'dd-mon-yy hh24:mi:ss'),-8)  = x.END_LOCAL_TS then 
            INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR_ACT 
                (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
            CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
            VALUES 
                ( pi_load_seq_nbr, x.DYN_OPT_EVENT_ID,'CM-WINID', 2,' ',x.SERVICE_PERIOD, ' ', ' ', ' ', ' ',
            ' ', ' ', 99, SYSDATE  );
        
            INSERT INTO MSM_STG1.D1_DYN_OPT_EVENT_CHAR_ACT (LOAD_SEQ_NBR, DYN_OPT_EVENT_ID, CHAR_TYPE_CD, SEQ_NUM, CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4,
            CHAR_VAL_FK5, SRCH_CHAR_VAL, VERSION, DATE_CREATED)
            VALUES 
                ( pi_load_seq_nbr, x.DYN_OPT_EVENT_ID,'CM-SEAID', 3,' ',x.SEASON_NUMBER, ' ', ' ', ' ', ' ',
            ' ', ' ', 99, SYSDATE );        
--        end if;
    end loop;
    -- Patch End by Anish KumarS on 27-01-2022
  
EXCEPTION
      WHEN OTHERS THEN
      
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,500);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_ACCEPTED_TENDERS',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'ACT');
        --DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

 END PR_MSM1_ACCEPTED_TENDERS;

/

