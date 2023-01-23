--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_RDRI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_RDRI" (PI_LOAD_SEQ_NBR IN NUMBER)
AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_RDRI
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-06-2021
* Description            :This is a PL/SQL procedure. This procedure migrate data for item code RDRI
                          to D1_SP_QTY(MSM_STG1) from PN_RANGE_STG(ASB_STG) table.
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_RDRI_MAIN.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  04-08-2022     Shailesh Solanki    Changes for defect SPRTEAM-19111
**************************************************************************************/

v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);

CURSOR cur_RDRI_CNT2 IS 
select distinct ASB_UNIT_CODE from PN_RANGE_STG where ITEM_CODE = 'RDRI' and load_seq_nbr = PI_LOAD_SEQ_NBR group by ASB_UNIT_CODE having count(1) > 0;

BEGIN

    -- Inserting records in D1_SP_QTY table.
    FOR rec in cur_RDRI_CNT2
    LOOP

       -- Inserting records in D1_SP_QTY (MSM_STG1)
        INSERT INTO MSM_STG1.D1_SP_QTY(LOAD_SEQ_NBR ,D1_SP_QTY_ID,D1_SP_ID,D1_SP_QTY_TYPE_CD,START_DTTM ,END_DTTM,SP_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD ,STATUS_UPD_DTTM ,CRE_DTTM ,BO_XML_DATA_AREA ,
        VERSION ,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
        SELECT PI_LOAD_SEQ_NBR,SQ_OPS_D1_SP_QTY_ID.NEXTVAL,ASB_UNIT_CODE,'RDRI',EFFECTIVE,LEAD(EFFECTIVE) OVER(PARTITION BY ASB_UNIT_CODE ORDER BY ASB_UNIT_CODE,EFFECTIVE)AS END_DTTM
        ,'D1AC','CM-ResourceParameterRange',' ',(SYSDATE),(SYSDATE),
        '<BO_XML_DATA_AREA><source>S</source></BO_XML_DATA_AREA>',99,NVL(RATE_1,0),NVL(ELBOW_2,0),NVL(RATE_2,0),NVL(ELBOW_3,0),NVL(RATE_3,0),SYSDATE 
        FROM PN_RANGE_STG PN1 
        where ASB_UNIT_CODE = rec.ASB_UNIT_CODE
        and ITEM_CODE = 'RDRI' 
        and load_seq_nbr = PI_LOAD_SEQ_NBR  ;
    END LOOP; 
         --Inserting data  to msm_stg1.d1_sp_qty_log
        INSERT INTO MSM_STG1.D1_SP_QTY_LOG(LOAD_SEQ_NBR, D1_SP_QTY_ID, SEQNO, LOG_DTTM, LOG_ENTRY_TYPE_FLG, DESCRLONG, BO_STATUS_CD, BO_STATUS_REASON_CD, MESSAGE_CAT_NBR, MESSAGE_NBR, CHAR_TYPE_CD,
        CHAR_VAL, ADHOC_CHAR_VAL, CHAR_VAL_FK1, CHAR_VAL_FK2, CHAR_VAL_FK3, CHAR_VAL_FK4, CHAR_VAL_FK5, USER_ID, VERSION, DATE_CREATED)
        SELECT PI_LOAD_SEQ_NBR,D1_SP_QTY_ID,1,sysdate,'F1CR',NULL,NULL,NULL,11002,12152,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'MIGD',99,SYSDATE 
        FROM MSM_STG1.D1_SP_QTY  
        where D1_SP_QTY_TYPE_CD = 'RDRI' 
        and load_seq_nbr = PI_LOAD_SEQ_NBR  ;
        
        INSERT INTO msm_stg1.d1_sp_qty_log (load_seq_nbr,d1_sp_qty_id,seqno,log_dttm,log_entry_type_flg,descrlong,bo_status_cd,bo_status_reason_cd,message_cat_nbr,message_nbr,char_type_cd,
    char_val,adhoc_char_val,char_val_fk1,char_val_fk2,char_val_fk3, char_val_fk4, char_val_fk5, user_id,version,date_created)
    SELECT  pi_load_seq_nbr,d1_sp_qty_id,2,SYSDATE,'F1US','','','',0,0,'CM-LFLNM','',TO_CHAR(fn_convert_gmt_bst1(start_dttm),'RRRR-MM-DD'),'','','','','','MIGD',99,SYSDATE
    FROM msm_stg1.d1_sp_qty
    WHERE d1_sp_qty_type_cd = 'RDRI' AND load_seq_nbr = pi_load_seq_nbr;

EXCEPTION
WHEN OTHERS THEN
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    PROC_PROCESS_LOG('PR_MSM1_OPR_RDRI',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'RDRI');
    DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_OPR_RDRI;

/

