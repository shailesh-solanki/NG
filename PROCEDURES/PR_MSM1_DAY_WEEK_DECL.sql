--------------------------------------------------------
--  DDL for Procedure PR_MSM1_DAY_WEEK_DECL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_DAY_WEEK_DECL" (PI_LOAD_SEQ_NBR IN NUMBER) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_DAY_WEEK_DECL
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :20-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_US_QTY(MSM_STG1).
* Calling Program        :None
* Called Program         :PR_ASB_DAY_WEEK_DECL_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  05-10-2021     Shailesh Solanki   Changes for Day/Week Ahead Declaration
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID NUMBER;
v_DYN_OPT_ID NUMBER;
v_D1_US_QTY_ID NUMBER;
v_DYN_OPT_EVENT_ID NUMBER;
v_ERROR VARCHAR2(1000);
v_cont_seq NUMBER;

v_DEC_BO_XML VARCHAR2(5000);
v_AVAIL_LEVEL NUMBER(10,3); 
v_FILE_DATE DATE;
v_START_WINDOW DATE;
v_START_WINDOW_OPT DATE;
v_END_WINDOW DATE;
v_END_WINDOW_OPT DATE;

CURSOR cur_DEC IS 
select CONTRACT_SEQ, ASB_UNIT_CODE, CONTRACT_NUMBER, SERVICE_DATE, SERVICE_PERIOD, AVAIL_WEEK, AVAIL_LEVEL, 
FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, REVISED_WEEK, REVISED_LEVEL, REJECT_FLAG, BO_STATUS_CD, SERVICE_CODE, DAY_CODE
from SRD_DECLARATION_STG_DW srd
where srd.load_seq_nbr=pi_load_seq_nbr 
;

CURSOR cur_DEC2 IS 
select CONTRACT_SEQ, ASB_UNIT_CODE, CONTRACT_NUMBER, SERVICE_DATE, SERVICE_PERIOD, AVAIL_WEEK, AVAIL_LEVEL, 
FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, REVISED_WEEK, REVISED_LEVEL, REJECT_FLAG, BO_STATUS_CD, SERVICE_CODE, DAY_CODE
from SRD_DECLARATION_STG_DW srd
where srd.load_seq_nbr=pi_load_seq_nbr 
AND service_period = 0 
;

CURSOR cur_DEC_OPT(p_asb_unit_code VARCHAR2, p_CONTRACT_NUMBER NUMBER, p_SERVICE_DATE DATE) IS 
select CONTRACT_SEQ, ASB_UNIT_CODE, CONTRACT_NUMBER, SERVICE_DATE, SERVICE_PERIOD, AVAIL_WEEK, AVAIL_LEVEL, 
FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, REVISED_WEEK, REVISED_LEVEL, REJECT_FLAG, BO_STATUS_CD, SERVICE_CODE, DAY_CODE
from SRD_DECLARATION_STG_DW srd
where srd.load_seq_nbr = pi_load_seq_nbr
AND asb_unit_code = p_asb_unit_code
AND CONTRACT_NUMBER = p_CONTRACT_NUMBER
AND SERVICE_DATE = p_SERVICE_DATE
AND service_period > 0 
;

BEGIN


    ------------------------------------------
    -- DECLARATION -- Day Ahead / Week Ahead
    ------------------------------------------
    FOR rec in cur_DEC
    LOOP

                BEGIN 
                    SELECT to_date(to_CHAR(rec.SERVICE_DATE,'DD-MON-YY ') || to_char(dw.start_local,'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
                    , to_DATE(to_CHAR(rec.SERVICE_DATE,'DD-MON-YY ') || to_char(dw.end_local,'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
                    into v_START_WINDOW, v_END_WINDOW
                    FROM 
                    asb_season_stg se , asb_duty_window_stg dw
                    WHERE 
                    se.effective = (select max(effective) from asb_season_stg where service_code = rec.service_code 
                    AND trunc(effective) <= rec.SERVICE_DATE)
                    AND se.service_code = rec.service_code
                    AND se.season_seq = dw.season_seq
                    AND dw.service_period = rec.service_period
                    AND rec.day_code = dw.day_code ;
                EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 CONTINUE;
                END;

                v_DEC_BO_XML := '<BO_XML_DATA_AREA><fileType>';
                v_DEC_BO_XML := v_DEC_BO_XML || rec.FILE_TYPE  || '</fileType></BO_XML_DATA_AREA>';

              v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;
            
              -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,rec.CONTRACT_SEQ,'WEEKAHEAD_DAYAHEAD_DECLARATION',fn_convert_bst_gmt(v_START_WINDOW),fn_convert_bst_gmt(v_END_WINDOW),'D1AC','CM-WeekandDayAheadDeclaration',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,NVL(rec.AVAIL_LEVEL,0),NVL(rec.AVAIL_WEEK,0),NVL(rec.REVISED_LEVEL,0),NVL(rec.REVISED_WEEK,0),0,sysdate,v_DEC_BO_XML);
--        END IF;  

    --Inserting data  to MSM_STG1.d1_us_qty_log_DECL
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR','','','','11002','12152','','','','','','',
    '','','MIGD','99',SYSDATE );

    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',NULL,'',0,0,'CM-LFLNM','',to_char(rec.FILE_DATE,'YYYY-MM-DD'),'','','',
    '','','MIGD','99',SYSDATE);

    END LOOP; 


    -- Optional window data DAY/WEEK Ahead Decalaration
    FOR rec in cur_DEC2
    LOOP

                FOR rec_OPT in cur_DEC_OPT(rec.ASB_UNIT_CODE, rec.CONTRACT_NUMBER, rec.SERVICE_DATE)
                LOOP
                    BEGIN 
                        v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;
                        v_START_WINDOW_OPT := v_END_WINDOW;

                        SELECT to_DATE(to_CHAR(rec_OPT.SERVICE_DATE,'DD-MON-YY ') || to_char(dw.start_local,'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
                        , to_DATE(to_CHAR(rec_OPT.SERVICE_DATE,'DD-MON-YY ') || to_char(dw.end_local,'HH24:MI:SS'),'DD-MON-YY HH24:MI:SS')
                        into v_START_WINDOW, v_END_WINDOW
                        FROM 
                        asb_season_stg se , asb_duty_window_stg dw
                        WHERE 
                        se.effective = (select max(effective) from asb_season_stg where service_code = rec_OPT.service_code AND trunc(effective) <= rec_OPT.SERVICE_DATE)
                        AND se.service_code = rec_OPT.service_code
                        AND se.season_seq = dw.season_seq
                        AND dw.service_period = rec_OPT.service_period
                        AND rec_OPT.day_code = dw.day_code ;

                        IF (rec_OPT.service_PERIOD = 1) THEN
                            v_START_WINDOW_OPT := rec_OPT.SERVICE_DATE+5/24;
                        END IF;

                        v_END_WINDOW_OPT := v_START_WINDOW;

                    EXCEPTION

                     WHEN NO_DATA_FOUND THEN
--                     DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
                     CONTINUE;
                    END;

              v_DEC_BO_XML := '<BO_XML_DATA_AREA><fileType>';
              v_DEC_BO_XML := v_DEC_BO_XML || rec.FILE_TYPE  || '</fileType></BO_XML_DATA_AREA>';   

              -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,rec.CONTRACT_SEQ,'WEEKAHEAD_DAYAHEAD_DECLARATION',fn_convert_bst_gmt(v_START_WINDOW_OPT),fn_convert_bst_gmt(v_END_WINDOW_OPT),'D1AC','CM-WeekandDayAheadDeclaration',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,NVL(rec.AVAIL_LEVEL,0),NVL(rec.AVAIL_WEEK,0),NVL(rec.REVISED_LEVEL,0),NVL(rec.REVISED_WEEK,0),0,sysdate,v_DEC_BO_XML);

                --Inserting data  to MSM_STG1.d1_us_qty_log_DECL
                INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
                values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR','','','','11002','12152','','','','','','',
                '','','MIGD','99',SYSDATE );

                INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
                values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',NULL,'',0,0,'CM-LFLNM','',to_char(rec.FILE_DATE,'YYYY-MM-DD'),'','','',
                '','','MIGD','99',SYSDATE);

                END LOOP;

                v_START_WINDOW_OPT := v_END_WINDOW;
                v_END_WINDOW_OPT := rec.SERVICE_DATE + 1 + 5/24 ;

                v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;

                -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,rec.CONTRACT_SEQ,'WEEKAHEAD_DAYAHEAD_DECLARATION',fn_convert_bst_gmt(v_START_WINDOW_OPT),fn_convert_bst_gmt(v_END_WINDOW_OPT),'D1AC','CM-WeekandDayAheadDeclaration',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,NVL(rec.AVAIL_LEVEL,0),NVL(rec.AVAIL_WEEK,0),NVL(rec.REVISED_LEVEL,0),NVL(rec.REVISED_WEEK,0),0,sysdate,v_DEC_BO_XML);

            --Inserting data  to MSM_STG1.d1_us_qty_log_DECL
            INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
            MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
            values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR','','','','11002','12152','','','','','','',
            '','','MIGD','99',SYSDATE );

            INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
            MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
            values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',NULL,'',0,0,'CM-LFLNM','',to_char(rec.FILE_DATE,'YYYY-MM-DD'),'','','',
            '','','MIGD','99',SYSDATE);
       END LOOP;  
       
       ASB_STG.PROC_PROCESS_LOG('PR_MSM1_DAY_WEEK_DECL',PI_LOAD_SEQ_NBR,'SUCCESS', 'Operational data(Day/Week Ahead Declaration) migrated successfully from MSM_STG1 to MSM_STG2 schema','DAYWEEKDECLARATION');

EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PROC_PROCESS_LOG('PR_MSM1_DAY_WEEK_DECL',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'DAYWEEKDECLARATION');

 END PR_MSM1_DAY_WEEK_DECL;

/

