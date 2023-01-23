--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_MIL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_MIL" (PI_LOAD_SEQ_NBR IN NUMBER,p_MEASR_COMP_TYPE_CD IN VARCHAR2,p_RANK IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_MIL
* Author                 :IBM(Roshan Khandare)
* Creation Date          :26-08-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_MSRMT(MSM_STG1) from pn_availability_stg table.
* Calling Program        :None
* Called Program         :
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  26-08-2021     Roshan Khandare   Changes for MIL Data 
**************************************************************************************/
AS

type t_pn_availability_stg is table of pn_availability_stg.asb_unit_code%type;
lv_vc_unit_code t_pn_availability_stg;

v_EFFECTIVE DATE ;

CURSOR cur_MIL (v_asb_unit_code VARCHAR2)
IS 
    select 
        dmc.measr_comp_id measr_comp_id, 
       pas.asb_unit_code,pas.item_code,pas.limit,pas.effective,
       LAG(EFFECTIVE) OVER ( PARTITION BY asb_unit_code ORDER BY EFFECTIVE, LIMIT ) PREV_MSRMT_DTTM

    from 
        pn_availability_stg pas,
     cisadm.d1_sp_identifier@stg_msm_link dsi,
     cisadm.d1_install_evt@stg_msm_link die,
     cisadm.d1_measr_comp@stg_msm_link dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = p_MEASR_COMP_TYPE_CD  
        and pas.item_code = 'MIL'
        and pas.rank = p_RANK 
        AND pas.ASB_UNIT_CODE = v_asb_unit_code
        AND pas.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

BEGIN
    select distinct asb_unit_code bulk collect into lv_vc_unit_code from pn_availability_stg where LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR and item_code = 'MIL' and rank = p_RANK ;

    for i in 1..lv_vc_unit_code.count
    loop
      FOR REC IN cur_MIL (lv_vc_unit_code(i))
      LOOP    
        IF (REC.PREV_MSRMT_DTTM IS NULL) THEN
            select max(effective) into v_effective from pn_availability_stg where ASB_UNIT_CODE =  lv_vc_unit_code(i) and RANK = p_RANK
            AND ITEM_CODE = 'MIL' AND effective < REC.effective;
        END IF ;

        INSERT INTO MSM_STG1.D1_MSRMT_MIL
            (LOAD_SEQ_NBR,MEASR_COMP_ID,MSRMT_DTTM,BO_STATUS_CD,MSRMT_COND_FLG,MSRMT_USE_FLG,MSRMT_LOCAL_DTTM,MSRMT_VAL,ORIG_INIT_MSRMT_ID,PREV_MSRMT_DTTM,
             MSRMT_VAL1,MSRMT_VAL2,MSRMT_VAL3,MSRMT_VAL4,MSRMT_VAL5,MSRMT_VAL6,MSRMT_VAL7,MSRMT_VAL8,MSRMT_VAL9,MSRMT_VAL10,BUS_OBJ_CD,CRE_DTTM,STATUS_UPD_DTTM,
             USER_EDITED_FLG,VERSION,LAST_UPDATE_DTTM,READING_VAL,COMBINED_MULTIPLIER,READING_COND_FLG,date_created )
        VALUES
            ( PI_LOAD_SEQ_NBR,REC.measr_comp_id,REC.effective,'OK','501000',' ',fn_convert_gmt_bst1(REC.effective),REC.LIMIT,
            p_MEASR_COMP_TYPE_CD,NVL(REC.PREV_MSRMT_DTTM,v_effective),'0','0','0','0','0','0','0','0','0','0',
                'D1-Measurement',SYSDATE,SYSDATE,' ','99',SYSDATE,REC.LIMIT,'1',NULL,sysdate  );
        END LOOP;
  END LOOP;

END PR_MSM1_OPR_MIL;

/
