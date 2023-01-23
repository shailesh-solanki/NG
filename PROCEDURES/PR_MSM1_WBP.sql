--------------------------------------------------------
--  DDL for Procedure PR_MSM1_WBP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_WBP" (PI_LOAD_SEQ_NBR IN NUMBER,P_CSV_FILE_NAME IN VARCHAR2) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_WBP
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :19-10-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_US_QTY,D1_US_QTY_LOG(MSM_STG1).
* Calling Program        :PR_ASB_LOAD_WBP_MAIN
* Called Program         :
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  19-10-2021        Changes for Accepted_tenders
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID NUMBER;
v_DYN_OPT_ID NUMBER;
v_D1_US_QTY_ID NUMBER;
v_DYN_OPT_EVENT_ID NUMBER;
v_ERROR VARCHAR2(1000);
v_cont_seq NUMBER;

CURSOR cur_WBP IS 
select sss.contract_seq, cus.us_id, wbp.start_date_time, wbp.end_date_time,wbp.UTILISATION_PRICE,wbp.MW,
      'CM-WindowBidPriceQuantity' as bus_obj_cd
      from WINDOW_BID_PRICE_CSV wbp, srs_supplier_stg sss,connect_us_sa_id cus
where wbp.contract_number=sss.contract_number and
        wbp.CONTRACT_ID= sss.asb_unit_code and
        sss.contract_seq=cus.contract_seq AND
        wbp.load_seq_nbr=pi_load_seq_nbr;

BEGIN

    FOR rec in cur_WBP
    LOOP
              -- Inserting data to MSM_STG1.D1_US_QTY_WBP table (New Record)
              INSERT INTO  MSM_STG1.D1_US_QTY_WBP(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
                  values(pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,rec.contract_seq,'WINDOW_BID_PRICE',rec.start_date_time,rec.end_date_time,'D1AC','CM-WindowBidPriceQuantity',' ',
              fn_convert_bst_gmt(sysdate),fn_convert_bst_gmt(sysdate),'',99,rec.MW,rec.UTILISATION_PRICE,0,0,0,sysdate);

    END LOOP;     

    -- Inserting data  to MSM_STG1.d1_us_qty_log_WBP (Sequence No = 1)
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_WBP(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    SELECT PI_LOAD_SEQ_NBR,D1_US_QTY_ID,1,sysdate,'F1CR','','','','11002','12152','','','','','','',
    '','','MIGD',99,SYSDATE FROM msm_stg1.D1_US_QTY_WBP WHERE load_seq_nbr = pi_load_seq_nbr;


    -- Inserting data  to MSM_STG1.d1_us_qty_log_WBP (Sequence No = 2)
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_WBP(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
    MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    SELECT PI_LOAD_SEQ_NBR,D1_US_QTY_ID,2,sysdate,'F1US','User Details','','','0','0','CM-LFLNM','',P_CSV_FILE_NAME,'','','',
    '','','MIGD',99,SYSDATE FROM msm_stg1.D1_US_QTY_WBP WHERE load_seq_nbr = pi_load_seq_nbr;

    ASB_STG.PR_PROCESS_LOG('PR_MSM1_WBP',PI_LOAD_SEQ_NBR,'SUCCESS','Data transfer successful from ASB_STG to MSM_STG1 for WINDOWS BID PRICE');

 EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_WBP',PI_LOAD_SEQ_NBR,'FAILURE',SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

 END PR_MSM1_WBP;

/

