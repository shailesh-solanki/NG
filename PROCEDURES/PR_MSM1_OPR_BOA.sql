--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_BOA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_BOA" (PI_LOAD_SEQ_NBR IN NUMBER,p_MEASR_COMP_TYPE_CD IN VARCHAR2,p_RANK IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_BOA
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_MSRMT_BOA(MSM_STG1) from pn_position_stg table.
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  15-09-2021     Shailesh Solanki   Changes for BOA Data 
**************************************************************************************/
AS
 v_op_level NUMBER;
 v_BO_ACCEPTANCE NUMBER;
 v_CNT NUMBER;
 v_ERROR VARCHAR2(500);

type t_pn_position_stg is table of pn_position_stg.asb_unit_code%type;
lv_vc_unit_code t_pn_position_stg;

v_EFFECTIVE DATE ;

CURSOR cur_BOA (v_asb_unit_code VARCHAR2)
IS

SELECT
     dmc.measr_comp_id,
     a.asb_unit_code,
     a.item_code,
     a.effective,
     LAG(A.effective) OVER(PARTITION BY a.asb_unit_code  ORDER BY a.asb_unit_code,a.effective) AS PREV_MSRMT_DTTM,
     a.rank,
     a.boacpt,
     pps.op_level
 FROM
     pn_position_stg pps,
--        l_d1_sp_identifier dsi,
--        l_d1_install_evt die,
--        l_d1_measr_comp dmc,
     cisadm.d1_sp_identifier@stg_msm_link dsi,
     cisadm.d1_install_evt@stg_msm_link die,
     cisadm.d1_measr_comp@stg_msm_link dmc,
     (select   pps.asb_unit_code,     pps.item_code,     pps.effective,     pps.rank,     MAX(bo_acceptance) boacpt
     FROM     pn_position_stg pps     GROUP BY     pps.asb_unit_code,     pps.item_code,     pps.rank,     pps.effective) a
 WHERE a.asb_unit_code = pps.asb_unit_code
 and a.effective=pps.effective
 and a.item_code = pps.item_code
 and a.rank=pps.rank
 and a.boacpt=pps.bo_acceptance
     and pps.asb_unit_code = dsi.id_value
     AND dsi.d1_sp_id = die.d1_sp_id
     AND die.device_config_id = dmc.device_config_id
     AND dsi.sp_id_type_flg = 'D1MI'
     AND dmc.measr_comp_type_cd = p_MEASR_COMP_TYPE_CD
     AND pps.item_code = 'BOAL'
     AND pps.rank = p_rank
     AND pps.load_seq_nbr =PI_LOAD_SEQ_NBR
      AND pps.ASB_UNIT_CODE = v_asb_unit_code;


BEGIN

    select distinct asb_unit_code bulk collect into lv_vc_unit_code from pn_position_stg where LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR and item_code = 'BOAL'
    ;

    for i in 1..lv_vc_unit_code.count
    loop
     FOR REC IN cur_BOA (lv_vc_unit_code(i))
     LOOP    

        IF (REC.PREV_MSRMT_DTTM IS NULL) THEN
            select max(effective) into v_effective from pn_position_stg where ASB_UNIT_CODE =  lv_vc_unit_code(i) and RANK = p_RANK
            AND ITEM_CODE = 'BOAL' AND effective < REC.effective;
        END IF ;

      INSERT INTO MSM_STG1.D1_MSRMT_BOA
            (LOAD_SEQ_NBR,MEASR_COMP_ID,MSRMT_DTTM,BO_STATUS_CD,MSRMT_COND_FLG,MSRMT_USE_FLG,MSRMT_LOCAL_DTTM,MSRMT_VAL,ORIG_INIT_MSRMT_ID,PREV_MSRMT_DTTM,
             MSRMT_VAL1,MSRMT_VAL2,MSRMT_VAL3,MSRMT_VAL4,MSRMT_VAL5,MSRMT_VAL6,MSRMT_VAL7,MSRMT_VAL8,MSRMT_VAL9,MSRMT_VAL10,BUS_OBJ_CD,CRE_DTTM,STATUS_UPD_DTTM,
             USER_EDITED_FLG,VERSION,LAST_UPDATE_DTTM,READING_VAL,COMBINED_MULTIPLIER,READING_COND_FLG,date_created )

        VALUES
            ( PI_LOAD_SEQ_NBR,REC.measr_comp_id,REC.effective,'OK','501000',' ',fn_convert_gmt_bst1(REC.effective),rec.op_level,p_MEASR_COMP_TYPE_CD,NVL(REC.PREV_MSRMT_DTTM,v_effective)
            ,'0','0','0','0','0','0','0','0','0','0',
                'D1-Measurement',SYSDATE,SYSDATE,' ','99',SYSDATE,REC.op_level,'1',NULL,sysdate  );

     END LOOP;
     END LOOP;


 EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        PR_PROCESS_LOG('PR_MSM1_OPR_BOA - ' || p_MEASR_COMP_TYPE_CD ,pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
END PR_MSM1_OPR_BOA;

/

