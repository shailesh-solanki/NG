--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_RURE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_RURE" (PI_LOAD_SEQ_NBR IN NUMBER) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_RURE
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-06-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_SP_QTY(MSM_STG1) from ASB_PN_RANGE_STG table.
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_RURE_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  09-06-2021     Shailesh Solanki   Changes for Operational Data (RURE)
*  04-08-2022     Shailesh Solanki    Changes for defect SPRTEAM-19111
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);

CURSOR cur_RURE_CNT IS 
select distinct ASB_UNIT_CODE from PN_RANGE_STG where ITEM_CODE = 'RURE' and load_seq_nbr = PI_LOAD_SEQ_NBR group by ASB_UNIT_CODE having count(1) > 0;

BEGIN

  FOR rec in cur_RURE_CNT
    LOOP

-- Inserting MNZT data to d1_sp_qty table
    INSERT INTO msm_stg1.d1_sp_qty (
    load_seq_nbr,
    d1_sp_qty_id,
    d1_sp_id,
    d1_sp_qty_type_cd,
    start_dttm,
    end_dttm,
    sp_qty_usg_flg,
    bus_obj_cd,
    bo_status_cd,
    status_upd_dttm,
    cre_dttm,
    version,
    d1_quantity1,
    d1_quantity2,
    d1_quantity3,
    d1_quantity4,
    d1_quantity5,
    date_created,
    bo_xml_data_area
)
    SELECT
        pi_load_seq_nbr,
        sq_ops_d1_sp_qty_id.NEXTVAL,
        asb_unit_code,
        'RURE',
        effective,
        LEAD(effective) OVER(
            PARTITION BY asb_unit_code
            ORDER BY
                asb_unit_code,effective
        ) AS end_dttm,
        'D1AC',
        'CM-ResourceParameterRange',
        ' ',
        (SYSDATE),
        (SYSDATE),
        99,
        NVL(RATE_1,0),NVL(ELBOW_2,0),NVL(RATE_2,0),NVL(ELBOW_3,0),NVL(RATE_3,0),
        SYSDATE,
        '<BO_XML_DATA_AREA><source>S</source></BO_XML_DATA_AREA>'
    FROM
       pn_range_stg
    WHERE
    ASB_UNIT_CODE = rec.ASB_UNIT_CODE
        AND item_code = 'RURE'
        AND load_seq_nbr = pi_load_seq_nbr;

   END LOOP;     

        --Inserting RURE data  to msm_stg1.d1_sp_qty_log
  INSERT INTO msm_stg1.d1_sp_qty_log (
    load_seq_nbr,
    d1_sp_qty_id,
    seqno,
    log_dttm,
    log_entry_type_flg,
    descrlong,
    bo_status_cd,
    bo_status_reason_cd,
    message_cat_nbr,
    message_nbr,
    char_type_cd,
    char_val,
    adhoc_char_val,
    char_val_fk1,
    char_val_fk2,
    char_val_fk3,
    char_val_fk4,
    char_val_fk5,
    user_id,
    version,
    date_created
)
    SELECT
        pi_load_seq_nbr,
        d1_sp_qty_id,
        1,
        sysdate,
        'F1CR',
        '',
        '',
        '',
        '11002',
        '12152',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        'MIGD',
        99,
        SYSDATE
    FROM
        msm_stg1.d1_sp_qty
    WHERE
        d1_sp_qty_type_cd = 'RURE'
        AND load_seq_nbr = pi_load_seq_nbr;

INSERT INTO msm_stg1.d1_sp_qty_log (load_seq_nbr,d1_sp_qty_id,seqno,log_dttm,log_entry_type_flg,descrlong,bo_status_cd,bo_status_reason_cd,message_cat_nbr,message_nbr,char_type_cd,
    char_val,adhoc_char_val,char_val_fk1,char_val_fk2,char_val_fk3, char_val_fk4, char_val_fk5, user_id,version,date_created)
    SELECT  pi_load_seq_nbr,d1_sp_qty_id,2,SYSDATE,'F1US','','','',0,0,'CM-LFLNM','',TO_CHAR(fn_convert_gmt_bst1(start_dttm),'RRRR-MM-DD'),'','','','','','MIGD',99,SYSDATE
    FROM msm_stg1.d1_sp_qty
    WHERE d1_sp_qty_type_cd = 'RURE' AND load_seq_nbr = pi_load_seq_nbr;




    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,120);
        ASB_STG.PROC_PROCESS_LOG('PR_MSM1_OPR_RURE',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'RURE');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

 END PR_MSM1_OPR_RURE;

/

