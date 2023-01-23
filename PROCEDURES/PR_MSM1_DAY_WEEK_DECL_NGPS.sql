--------------------------------------------------------
--  DDL for Procedure PR_MSM1_DAY_WEEK_DECL_NGPS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_DAY_WEEK_DECL_NGPS" (PI_LOAD_SEQ_NBR IN NUMBER) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_DAY_WEEK_DECL_NGPS
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :20-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_US_QTY(MSM_STG1).
* Calling Program        :None
* Called Program         :PR_ASB_DAY_WEEK_DECL_MAIN
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  05-10-2021     Shailesh Solanki   Changes for Day/Week Ahead Declaration
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID_CISADM VARCHAR2(12) := NULL;
v_DEF_SUP_CONTRACT_NUM NUMBER(4,2) := NULL;
v_D1_US_QTY_ID NUMBER;
v_ERROR VARCHAR2(1000);

v_DEC_BO_XML VARCHAR2(5000);
v_START_WINDOW DATE;
v_START_WINDOW_OPT DATE;
v_END_WINDOW DATE;
v_END_WINDOW_OPT DATE;

CURSOR cur_DEC IS 
select srd.CONTRACT_SEQ, srd.ASB_UNIT_CODE, srd.CONTRACT_NUMBER, srd.SERVICE_DATE, srd.SERVICE_PERIOD,srd.AVAIL_WEEK, srd.AVAIL_LEVEL, 
srd.FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, srd.REVISED_WEEK, srd.REVISED_LEVEL, srd.REJECT_FLAG, srd.BO_STATUS_CD, srd.SERVICE_CODE, srd.DAY_CODE, dsi.D1_SP_ID,
s1.asb_unit_code as "ASB_UNIT_CODE_SUB" , dsi2.D1_SP_ID as "D1_SP_ID_SUB"
from SRD_DECLARATION_STG_NGPS srd, cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK dsi, srs_supplier_stg s1 , 
cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK dsi2
where dsi.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi.ID_VALUE) = srd.ASB_UNIT_CODE
AND srd.contract_seq = s1.contract_seq
AND s1.DEFAULT_SUPPLIER = 'Y'
AND dsi2.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi2.ID_VALUE) = s1.asb_unit_code
AND srd.load_seq_nbr=pi_load_seq_nbr 
AND (srd.CONTRACT_SEQ, srd.contract_number) NOT IN (select CONTRACT_SEQ, CONTRACT_NUMBER from srs_Supplier_stg where default_supplier = 'Y')
;

CURSOR cur_DEC2 IS 
select srd.CONTRACT_SEQ, srd.ASB_UNIT_CODE, srd.CONTRACT_NUMBER, srd.SERVICE_DATE, srd.SERVICE_PERIOD, srd.AVAIL_WEEK, srd.AVAIL_LEVEL, 
srd.FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, srd.REVISED_WEEK, srd.REVISED_LEVEL, srd.REJECT_FLAG, srd.BO_STATUS_CD, srd.SERVICE_CODE, srd.DAY_CODE, dsi.D1_SP_ID,
s1.asb_unit_code as "ASB_UNIT_CODE_SUB" , dsi2.D1_SP_ID as "D1_SP_ID_SUB"
from SRD_DECLARATION_STG_NGPS srd,cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK dsi, srs_supplier_stg s1 , cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK dsi2
where dsi.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi.ID_VALUE) = srd.ASB_UNIT_CODE
AND srd.load_seq_nbr=pi_load_seq_nbr 
AND srd.service_period = 0 
AND srd.contract_seq = s1.contract_seq
AND s1.DEFAULT_SUPPLIER = 'Y'
AND dsi2.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi2.ID_VALUE) = s1.asb_unit_code
AND (srd.CONTRACT_SEQ, srd.contract_number) NOT IN (select CONTRACT_SEQ, CONTRACT_NUMBER from srs_Supplier_stg where default_supplier = 'Y')
;

CURSOR cur_DEC_OPT(p_asb_unit_code VARCHAR2, p_CONTRACT_NUMBER NUMBER, p_SERVICE_DATE DATE) IS 
select srd.CONTRACT_SEQ, srd.ASB_UNIT_CODE, srd.CONTRACT_NUMBER, srd.SERVICE_DATE, srd.SERVICE_PERIOD, srd.AVAIL_WEEK, srd.AVAIL_LEVEL, 
srd.FILE_DATE, DECODE(FILE_TYPE,'MAN','M','S') as FILE_TYPE, srd.REVISED_WEEK, srd.REVISED_LEVEL, srd.REJECT_FLAG, srd.BO_STATUS_CD, srd.SERVICE_CODE, srd.DAY_CODE, dsi.D1_SP_ID,
s1.asb_unit_code as "ASB_UNIT_CODE_SUB" , dsi2.D1_SP_ID as "D1_SP_ID_SUB"
from SRD_DECLARATION_STG_NGPS srd,cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK  dsi, srs_supplier_stg s1 , cisadm.D1_SP_IDENTIFIER@STG_MSM_LINK dsi2
where dsi.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi.ID_VALUE) = srd.ASB_UNIT_CODE
AND srd.load_seq_nbr = pi_load_seq_nbr
AND srd.asb_unit_code = p_asb_unit_code
AND srd.CONTRACT_NUMBER = p_CONTRACT_NUMBER
AND srd.SERVICE_DATE = p_SERVICE_DATE
AND srd.service_period > 0 
AND srd.contract_seq = s1.contract_seq
AND s1.DEFAULT_SUPPLIER = 'Y'
AND dsi2.SP_ID_TYPE_FLG = 'D1MI' AND
trim(dsi2.ID_VALUE) = s1.asb_unit_code
AND (srd.CONTRACT_SEQ, srd.contract_number) NOT IN (select CONTRACT_SEQ, CONTRACT_NUMBER from srs_Supplier_stg where default_supplier = 'Y')
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
                    se.effective = (select max(effective) from asb_season_stg where service_code = rec.service_code AND trunc(effective) <= rec.SERVICE_DATE)
                    AND se.service_code = rec.service_code
                    AND se.season_seq = dw.season_seq
                    AND dw.service_period = rec.service_period
                    AND rec.day_code = dw.day_code ;
                EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                 CONTINUE;
                END;

                v_DEC_BO_XML := '<BO_XML_DATA_AREA><subResource>';
                v_DEC_BO_XML :=  v_DEC_BO_XML || rec.D1_SP_ID  || '</subResource></BO_XML_DATA_AREA>';

              v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;
              
              v_DEF_SUP_CONTRACT_NUM := NULL ;
              select CONTRACT_NUMBER into v_DEF_SUP_CONTRACT_NUM from srs_supplier_stg where contract_seq = rec.CONTRACT_SEQ and DEFAULT_SUPPLIER = 'Y';
            
              v_US_ID_CISADM := NULL ;
              select A1.US_ID into v_US_ID_CISADM from 
              cisadm.d1_US_Identifier@STG_MSM_LINK A1 , cisadm.d1_US_Identifier@STG_MSM_LINK A2
              where trim(A1.ID_VALUE) = to_char(rec.CONTRACT_SEQ) and trim(A2.ID_VALUE) = to_char(v_DEF_SUP_CONTRACT_NUM) AND A1.US_ID = A2.US_ID ;
                
              -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,v_US_ID_CISADM,'MANAGE_SUB',fn_convert_bst_gmt(v_START_WINDOW),fn_convert_bst_gmt(v_END_WINDOW),'D1AC','CM-ManageSubstitution',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,0,0,0,0,0,sysdate,v_DEC_BO_XML);
--        END IF;  

    --Inserting data  to MSM_STG1.D1_US_QTY_LOG_DECL_NGPS
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR',' ',' ',' ','11002','12152',' ',' ',' ',' ',' ',' ',
    ' ',' ','MIGD','99',SYSDATE );

    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',' ',' ',NULL,NULL,'CM-LFLNM',' ',to_char(rec.FILE_DATE,'YYYY-MM-DD'),' ',' ',' ',
    ' ',' ','MIGD','99',SYSDATE);

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

              v_DEC_BO_XML := '<BO_XML_DATA_AREA><subResource>';
              v_DEC_BO_XML := v_DEC_BO_XML || rec.D1_SP_ID  || '</subResource></BO_XML_DATA_AREA>';   
              
              v_DEF_SUP_CONTRACT_NUM := NULL ;
              select CONTRACT_NUMBER into v_DEF_SUP_CONTRACT_NUM from srs_supplier_stg where contract_seq = rec.CONTRACT_SEQ and DEFAULT_SUPPLIER = 'Y';
            
              v_US_ID_CISADM := NULL ;
              select A1.US_ID into v_US_ID_CISADM from 
              cisadm.d1_US_Identifier@STG_MSM_LINK A1 , cisadm.d1_US_Identifier@STG_MSM_LINK A2
              where trim(A1.ID_VALUE) = to_char(rec.CONTRACT_SEQ) and trim(A2.ID_VALUE) = to_char(v_DEF_SUP_CONTRACT_NUM) AND A1.US_ID = A2.US_ID ;

              -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,v_US_ID_CISADM,'MANAGE_SUB',fn_convert_bst_gmt(v_START_WINDOW_OPT),fn_convert_bst_gmt(v_END_WINDOW_OPT),'D1AC','CM-ManageSubstitution',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,0,0,0,0,0,sysdate,v_DEC_BO_XML);

                --Inserting data  to MSM_STG1.D1_US_QTY_LOG_DECL_NGPS
                INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
                values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR',' ',' ',' ','11002','12152',' ',' ',' ',' ',' ',' ',
                ' ',' ','MIGD','99',SYSDATE );

                INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
                values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',' ',' ',NULL,NULL,'CM-LFLNM',' ',to_char(rec.FILE_DATE,'YYYY-MM-DD'),' ',' ',' ',
                ' ',' ','MIGD','99',SYSDATE);

                END LOOP;

                v_START_WINDOW_OPT := v_END_WINDOW;
                v_END_WINDOW_OPT := rec.SERVICE_DATE + 1 + 5/24 ;

                v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;
                


                -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,v_US_ID_CISADM,'MANAGE_SUB',fn_convert_bst_gmt(v_START_WINDOW_OPT),fn_convert_bst_gmt(v_END_WINDOW_OPT),'D1AC','CM-ManageSubstitution',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_DEC_BO_XML,99,0,0,0,0,0,sysdate,v_DEC_BO_XML);

            --Inserting data  to MSM_STG1.D1_US_QTY_LOG_DECL_NGPS
            INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
            MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
            values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR',' ',' ',' ','11002','12152',' ',' ',' ',' ',' ',' ',
            ' ',' ','MIGD','99',SYSDATE );

            INSERT INTO  MSM_STG1.D1_US_QTY_LOG_DECL_NGPS(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
            MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
            values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',' ',' ',NULL,NULL,'CM-LFLNM','',to_char(rec.FILE_DATE,'YYYY-MM-DD'),' ',' ',' ',
            ' ',' ','MIGD','99',SYSDATE);

       END LOOP;  


       ASB_STG.PR_PROCESS_LOG('PR_MSM1_DAY_WEEK_DECL_NGPS',PI_LOAD_SEQ_NBR,'SUCCESS', 'Operational data(Day/Week Ahead Declaration NGPS) migrated successfully from MSM_STG1 to MSM_STG2 schema');

EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_DAY_WEEK_DECL_NGPS',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR);

 END PR_MSM1_DAY_WEEK_DECL_NGPS;

/

