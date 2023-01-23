--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_BID_OFFER_SS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_BID_OFFER_SS" (PI_LOAD_SEQ_NBR IN NUMBER, pi_bo_pair IN number, pi_sp_qty_type_cd IN varchar2)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_BID_OFFER
* Author                 :IBM((Shailesh Solanki )
* Creation Date          :31-08-2021
* Description            :This is a PL/SQL procedure. This procedure transfer data
*                         from SP_BID_OFFER_STG(ASB_STG) table to D1_SP_QTY(MSM_STG1) tables.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_BID_OFFER_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :pi_load_seq_nbr,pi_bo_pair,pi_sp_qty_type_cd
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
**************************************************************************************/
AS
v_ERROR VARCHAR2(1000);
CURSOR CUR_BID_OFFER IS
            SELECT  dsi.D1_SP_ID,pi_sp_qty_type_cd as D1_SP_QTY_TYPE_CD,sbo.start_dttm,sbo.end_dttm ,NVL(sbo.BID_PRICE,0) AS D1_QUANTITY1,NVL(sbo.OFFER_PRICE,0) AS D1_QUANTITY2,
          NVL(sbo.BO_LEVEL,0) AS D1_QUANTITY3,NVL(sbo.BID_VOLUME,0) AS D1_QUANTITY4,NVL(sbo.OFFER_VOLUME,0) AS D1_QUANTITY5
   FROM SP_BID_OFFER_STG sbo,cisadm.d1_sp_identifier@stg_msm_link dsi
   WHERE sbo.LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR
   and dsi.sp_id_type_flg = 'D1MI'
   and dsi.id_value = sbo.ASB_UNIT_CODE
   and sbo.bo_pair = pi_bo_pair;
        

TYPE typ_BID_OFFER is TABLE OF CUR_BID_OFFER%ROWTYPE;
tab_BID_OFFER typ_BID_OFFER;

CURSOR cur_D1_SP_QTY IS 
    SELECT D1_SP_QTY_ID
    FROM MSM_STG1.D1_SP_QTY_BID_OFFER_TEMP
    WHERE  LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR
        and D1_SP_QTY_TYPE_CD = pi_sp_qty_type_cd;

TYPE typ_D1_SP_QTY is TABLE OF cur_D1_SP_QTY%ROWTYPE;
tab_D1_SP_QTY typ_D1_SP_QTY;

BEGIN

    COMMIT;
    MSM_STG1.PR_TRUNCATE_TABLE_MSMSTG1('D1_SP_QTY_BID_OFFER_TEMP');
    MSM_STG1.PR_TRUNCATE_TABLE_MSMSTG1('D1_SP_QTY_BID_OFFER_LOG_TEMP');

    OPEN cur_BID_OFFER ;
    LOOP
        FETCH CUR_BID_OFFER BULK COLLECT INTO tab_BID_OFFER LIMIT 5000;
        EXIT WHEN tab_BID_OFFER.count = 0;

        FORALL x IN tab_BID_OFFER.first..tab_BID_OFFER.last
          INSERT INTO MSM_STG1.D1_SP_QTY_BID_OFFER_TEMP(LOAD_SEQ_NBR,D1_SP_QTY_ID,D1_SP_ID,D1_SP_QTY_TYPE_CD,START_DTTM,END_DTTM,SP_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM
                                        ,CRE_DTTM,BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
            VALUES(PI_LOAD_SEQ_NBR,SQ_OPS_D1_SP_QTY_ID.NEXTVAL,tab_BID_OFFER(x).D1_SP_ID,tab_BID_OFFER(x).D1_SP_QTY_TYPE_CD,tab_BID_OFFER(x).START_DTTM ,tab_BID_OFFER(x).end_dttm,
            'D1AC','CM-SpBidOfferPair',' ',SYSDATE,SYSDATE,
                   '',99,tab_BID_OFFER(x).D1_QUANTITY1,tab_BID_OFFER(x).D1_QUANTITY2,tab_BID_OFFER(x).D1_QUANTITY3,tab_BID_OFFER(x).D1_QUANTITY4,tab_BID_OFFER(x).D1_QUANTITY5,SYSDATE);
     END LOOP;

     CLOSE cur_BID_OFFER ;

     INSERT INTO MSM_STG1.D1_SP_QTY_BID_OFFER  select * from MSM_STG1.D1_SP_QTY_BID_OFFER_TEMP ;

     /*      
    OPEN cur_D1_SP_QTY ;
    LOOP
        FETCH cur_D1_SP_QTY BULK COLLECT INTO tab_D1_SP_QTY LIMIT 5000;
        EXIT WHEN tab_D1_SP_QTY.count = 0;

        FORALL x IN tab_D1_SP_QTY.first..tab_D1_SP_QTY.last
        INSERT INTO MSM_STG1.D1_SP_QTY_BID_OFFER_LOG(LOAD_SEQ_NBR,D1_SP_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,MESSAGE_CAT_NBR
                ,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
        VALUES( PI_LOAD_SEQ_NBR,tab_D1_SP_QTY(x).D1_SP_QTY_ID,'1',SYSDATE,'F1CR','','','','11002','12152','','','','','','','','','MIGD',99,SYSDATE );

    END LOOP;

    CLOSE cur_D1_SP_QTY ;
    */


        INSERT INTO MSM_STG1.D1_SP_QTY_BID_OFFER_LOG_TEMP(LOAD_SEQ_NBR,D1_SP_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,MESSAGE_CAT_NBR
                ,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
        SELECT PI_LOAD_SEQ_NBR,D1_SP_QTY_ID,'1',SYSDATE,'F1CR','','','','11002','12152','','','','','','','','','MIGD',99,SYSDATE FROM MSM_STG1.D1_SP_QTY_BID_OFFER_TEMP
        ;


    INSERT INTO MSM_STG1.D1_SP_QTY_BID_OFFER_LOG select * from MSM_STG1.D1_SP_QTY_BID_OFFER_LOG_TEMP ;

EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,500);
        PR_PROCESS_LOG('PR_MSM1_OPR_BID_OFFER',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_OPR_BID_OFFER_SS;

/

