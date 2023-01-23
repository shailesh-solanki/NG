--------------------------------------------------------
--  DDL for Procedure PR_MSM1_REDECLARATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_REDECLARATION" (PI_LOAD_SEQ_NBR IN NUMBER) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_REDECLARATION
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :20-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_US_QTY(MSM_STG1).
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Vers>    <Modifier Name>    <Description>
*  05-08-2021     1.1         Shailesh Solanki   Changes for Accepted_tenders
*  01-09-2022     1.2         Shailesh Solanki     Changes in BO_XML_DATA_AREA - added FILE_NAME
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID NUMBER;
v_DYN_OPT_ID NUMBER;
v_D1_US_QTY_ID NUMBER;
v_DYN_OPT_EVENT_ID NUMBER;
v_ERROR VARCHAR2(1000);
v_cont_seq NUMBER;

v_REDEC_BO_XML VARCHAR2(5000);
v_AVAIL_LEVEL NUMBER(10,3); 
v_FILE_DATE DATE;
v_START_WINDOW DATE;
v_START_WINDOW_OPT DATE;
v_END_WINDOW DATE;
v_END_WINDOW_OPT DATE;

CURSOR cur_REDEC IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, REDEC_START, REDEC_END, CONTRACT_SEQ, max(REDEC_ISSUE) as latest_issue_date, 
CASE WHEN (redec_end - redec_start) >= 0.94 THEN
'AVAILABILITY_REDECLARATION_O'
ELSE
'AVAILABILITY_REDECLARATION_C'
END as D1_US_QTY_TYPE_CD
from srd_redeclaration_stg srd
where srd.load_seq_nbr=pi_load_seq_nbr
AND (redec_end - redec_start) < 0.94
group by ASB_UNIT_CODE, CONTRACT_NUMBER, CONTRACT_SEQ, REDEC_START, REDEC_END;

CURSOR cur_REDEC_BO_XML(p_asb_unit_code VARCHAR2, p_CONTRACT_NUMBER NUMBER, p_redec_start DATE, p_redec_end DATE, p_latest_issue_date DATE) IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, REDEC_START, REDEC_END, REDEC_ISSUE, AVAIL_LEVEL, FILE_DATE, CONTRACT_SEQ
from srd_redeclaration_stg srd
where srd.load_seq_nbr = pi_load_seq_nbr
AND asb_unit_code = p_asb_unit_code
AND CONTRACT_NUMBER = p_CONTRACT_NUMBER
AND redec_start = p_redec_start
AND redec_end = p_redec_end
;

BEGIN


    -------------------
    -- REDECLARATION --
    -------------------
    FOR rec in cur_REDEC
    LOOP
--        v_CNT := 0;
--       select NVL(max(D1_US_QTY_ID),0),count(1) into v_D1_US_QTY_ID, v_CNT
--        from MSM_STG1.d1_us_qty duq where duq.US_ID = rec.CONTRACT_SEQ AND duq.START_DTTM = rec.REDEC_START and duq.END_DTTM=rec.REDEC_END 
--        and duq.bus_obj_cd='CM-AvailabilityRedeclaration';
--      

        select max(AVAIL_LEVEL), max(FILE_DATE) into v_AVAIL_LEVEL,v_FILE_DATE
        from srd_redeclaration_stg srd
        where asb_unit_code = rec.asb_unit_code
        AND CONTRACT_NUMBER = rec.CONTRACT_NUMBER
        AND redec_start = rec.redec_start
        AND redec_end = rec.redec_end
        AND REDEC_ISSUE = rec.latest_issue_date;

        v_REDEC_BO_XML := '<BO_XML_DATA_AREA><reDec>';

        FOR rec_BO in cur_REDEC_BO_XML(rec.asb_unit_code,rec.CONTRACT_NUMBER, rec.redec_start, rec.redec_end,rec.latest_issue_date)
        LOOP

            v_REDEC_BO_XML := v_REDEC_BO_XML || '<reDecList>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<issueDateTime>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || to_char(rec_BO.REDEC_ISSUE,'YYYY-MM-DD-') || to_char(rec_BO.REDEC_ISSUE,'HH24.MI.SS');
            v_REDEC_BO_XML := v_REDEC_BO_XML || '</issueDateTime>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<mw>' || rec_BO.AVAIL_LEVEL || '</mw>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<parentServiceTask></parentServiceTask><fileName>'||to_char(rec_bo.FILE_DATE,'YYYY-MM-DD')||'</fileName></reDecList>';           
        END LOOP;
        v_REDEC_BO_XML := v_REDEC_BO_XML || '</reDec></BO_XML_DATA_AREA>';

--        IF (v_CNT > 0) THEN
--              -- Inserting data to MSM_STG1.D1_US_QTY table (Exist Record)
--              INSERT INTO  MSM_STG1.D1_US_QTY_REDECL(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
--              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
--              values(pi_load_seq_nbr,v_D1_US_QTY_ID,rec.CONTRACT_SEQ,rec.D1_US_QTY_TYPE_CD,rec.REDEC_START,rec.REDEC_END,'D1AC','CM-AvailabilityRedeclaration',' ',
--              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_REDEC_BO_XML,99,NVL(v_AVAIL_LEVEL,0),0,0,0,0,sysdate,v_REDEC_BO_XML);
--        ELSE
              v_D1_US_QTY_ID := SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL;
              -- Inserting data to MSM_STG1.D1_US_QTY table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_REDECL(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED,BO_XML_DATA_AREA_CHAR)
              values(pi_load_seq_nbr,v_D1_US_QTY_ID,rec.CONTRACT_SEQ,rec.D1_US_QTY_TYPE_CD,rec.REDEC_START,rec.REDEC_END,'D1AC','CM-AvailabilityRedeclaration',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),v_REDEC_BO_XML,99,NVL(v_AVAIL_LEVEL,0),0,0,0,0,sysdate,v_REDEC_BO_XML);
--        END IF;  

            --Inserting data  to MSM_STG1.d1_us_qty_log
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_REDECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values( PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,1,sysdate,'F1CR','','','','11002','12152','','','','','','',
    '','','MIGD','99',SYSDATE);

    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_REDECL(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    values (PI_LOAD_SEQ_NBR,v_D1_US_QTY_ID,2,sysdate,'F1US','User Details',NULL,'',0,0,'CM-LFLNM','',to_char(v_FILE_DATE,'YYYY-MM-DD'),'','','',
    '','','MIGD','99',SYSDATE );

    END LOOP;  

EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_REDECLARATION',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR);

 END PR_MSM1_REDECLARATION;

/
