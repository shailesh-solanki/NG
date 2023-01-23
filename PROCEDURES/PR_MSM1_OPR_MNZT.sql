--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_MNZT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_MNZT" (PI_LOAD_SEQ_NBR IN NUMBER) AS 
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_MNZT
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-05-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_SP_QTY(MSM_STG1) from ASB_PN_DELIVERY_STG table.
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_NDZ_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  26-05-2021     Shailesh Solanki   Changes for Operational Data (MNZT)
*  04-08-2022     Shailesh Solanki    Changes for defect SPRTEAM-19111
**************************************************************************************/
v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);

CURSOR cur_MNZT_CNT IS 
select distinct ASB_UNIT_CODE from PN_DELIVERY_STG where ITEM_CODE = 'MNZT' and load_seq_nbr = PI_LOAD_SEQ_NBR group by ASB_UNIT_CODE having count(1) > 0;

BEGIN

  FOR rec in cur_MNZT_CNT
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
    bo_xml_data_area,
    version,
    D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,
        D1_QUANTITY4,D1_QUANTITY5,
    date_created
)
    SELECT
        pi_load_seq_nbr,
        sq_ops_d1_sp_qty_id.NEXTVAL,
        asb_unit_code,
        'MNZT',
       effective,
        LEAD(effective) OVER(
            PARTITION BY asb_unit_code
            ORDER BY
                asb_unit_code,effective
        ) AS end_dttm,
        'D1AC',
        'CM-ResourceParameter',
        ' ',
        (SYSDATE),
        (SYSDATE),
        --'<BO_XML_DATA_AREA><fileName>' || TO_CHAR(file_date,'RRRR-MM-DD')|| '</fileName><source>S</source></BO_XML_DATA_AREA>',
        '<BO_XML_DATA_AREA><source>S</source></BO_XML_DATA_AREA>',
        99,
        NVL(period,0),0,0,0,0,
        SYSDATE
    FROM
        pn_delivery_stg
    WHERE
    ASB_UNIT_CODE = rec.ASB_UNIT_CODE
        AND item_code = 'MNZT'
        AND load_seq_nbr = pi_load_seq_nbr;

   END LOOP;     

        --Inserting MNZT data  to msm_stg1.d1_sp_qty_log
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
        d1_sp_qty_type_cd = 'MNZT'
        AND load_seq_nbr = pi_load_seq_nbr;


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
        2,
        SYSDATE,
        'F1US',
        '',
        '',
        '',
        0,
        0,
        'CM-LFLNM',
        '',
         TO_CHAR(fn_convert_gmt_bst1(start_dttm),'RRRR-MM-DD'),
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
        d1_sp_qty_type_cd = 'MNZT'
        AND load_seq_nbr = pi_load_seq_nbr;


    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,120);
        ASB_STG.PROC_PROCESS_LOG('PR_MSM1_OPS_MNZT',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'MNZT');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

 END PR_MSM1_OPR_MNZT;

/

