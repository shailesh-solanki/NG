--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_RURI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_RURI" (PI_LOAD_SEQ_NBR IN NUMBER)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_RURI 
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-JUN-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records (RURI)
                          into MSM_STG1 tables from PN_RANGE_STG table.
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_RURI_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 09-JUN-2021   Shailesh Solanki Changes for Operational Data (RURI)
*  04-08-2022     Shailesh Solanki    Changes for defect SPRTEAM-19111
**************************************************************************************/
AS 
 v_ERROR varchar2(1000);
BEGIN
 --Inserting data into D1_SP_QTY Table 
  INSERT INTO MSM_STG1.D1_SP_QTY(LOAD_SEQ_NBR,D1_SP_QTY_ID ,D1_SP_ID ,D1_SP_QTY_TYPE_CD ,START_DTTM ,END_DTTM ,SP_QTY_USG_FLG  ,BUS_OBJ_CD,BO_STATUS_CD  ,
              STATUS_UPD_DTTM  ,CRE_DTTM ,VERSION ,D1_QUANTITY1  ,D1_QUANTITY2 ,D1_QUANTITY3 ,D1_QUANTITY4  ,D1_QUANTITY5  ,DATE_CREATED ,BO_XML_DATA_AREA )
      SELECT  PI_LOAD_SEQ_NBR,sq_ops_d1_sp_qty_id.NEXTVAL,ASB_UNIT_CODE,'RURI',EFFECTIVE,LEAD(EFFECTIVE) OVER(PARTITION BY ASB_UNIT_CODE ORDER BY ASB_UNIT_CODE,
              EFFECTIVE)AS END_DTTM,'D1AC' ,'CM-ResourceParameterRange',' ',(SYSDATE),(SYSDATE),99,
              NVL(RATE_1,0),NVL(ELBOW_2,0),NVL(RATE_2,0),NVL(ELBOW_3,0),NVL(RATE_3,0) ,SYSDATE,'<BO_XML_DATA_AREA><source>S</source></BO_XML_DATA_AREA>'
      FROM PN_RANGE_STG WHERE ITEM_CODE='RURI' AND LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR;

 --Inserting data into D1_SP_QTY_LOG Table 
   INSERT INTO MSM_STG1.D1_SP_QTY_LOG (LOAD_SEQ_NBR ,D1_SP_QTY_ID ,SEQNO ,LOG_DTTM ,LOG_ENTRY_TYPE_FLG ,DESCRLONG ,BO_STATUS_CD ,BO_STATUS_REASON_CD,MESSAGE_CAT_NBR,
               MESSAGE_NBR,CHAR_TYPE_CD ,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1 ,CHAR_VAL_FK2 ,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5 ,USER_ID,VERSION,date_created)       
       SELECT  PI_LOAD_SEQ_NBR,D1_SP_QTY_ID,1,SYSDATE,'F1CR','','','','11002','12152','','','','','','','','','MIGD',99 ,SYSDATE
        FROM MSM_STG1.D1_SP_QTY WHERE D1_SP_QTY_TYPE_CD='RURI' AND LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR;
        

INSERT INTO msm_stg1.d1_sp_qty_log (load_seq_nbr,d1_sp_qty_id,seqno,log_dttm,log_entry_type_flg,descrlong,bo_status_cd,bo_status_reason_cd,message_cat_nbr,message_nbr,char_type_cd,
    char_val,adhoc_char_val,char_val_fk1,char_val_fk2,char_val_fk3, char_val_fk4, char_val_fk5, user_id,version,date_created)
    SELECT  pi_load_seq_nbr,d1_sp_qty_id,2,SYSDATE,'F1US','','','',0,0,'CM-LFLNM','',TO_CHAR(fn_convert_gmt_bst1(start_dttm),'RRRR-MM-DD'),'','','','','','MIGD',99,SYSDATE
    FROM msm_stg1.d1_sp_qty
    WHERE d1_sp_qty_type_cd = 'RURI' AND load_seq_nbr = pi_load_seq_nbr;        

--EXCEPTIONS
EXCEPTION
     WHEN OTHERS THEN   
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,1000);
        PROC_PROCESS_LOG('PR_MSM1_OPR_RURI ',PI_LOAD_SEQ_NBR,'FAILURE', v_ERROR,'RURI');
END PR_MSM1_OPR_RURI;

/

