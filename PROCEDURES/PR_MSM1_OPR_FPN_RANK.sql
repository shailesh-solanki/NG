--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_FPN_RANK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_FPN_RANK" (PI_LOAD_SEQ_NBR IN NUMBER,p_MEASR_COMP_TYPE_CD IN VARCHAR2,p_RANK IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_FPN
* Author                 :IBM(Roshan Khandare)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records 
                          into D1_MSRMT(MSM_STG1) from pn_position_stg table.
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
v_ERROR VARCHAR2(1000);
v_END_DATE DATE;

v_EFFECTIVE DATE ;

type t_pn_position_stg is table of pn_position_stg.asb_unit_code%type;
lv_vc_unit_code t_pn_position_stg;

CURSOR cur_FPN (v_asb_unit_code VARCHAR2)
IS 
    select 
        dmc.measr_comp_id measr_comp_id, 
       pas.asb_unit_code,pas.item_code,pas.op_level,pas.effective
       , LAG(EFFECTIVE) OVER ( PARTITION BY asb_unit_code ORDER BY EFFECTIVE, OP_LEVEL ) PREV_MSRMT_DTTM -- Added by Anish Kumar S on 02-11-2021
    from 
        pn_position_stg pas,
--         l_d1_sp_identifier dsi,
--        l_d1_install_evt die,
--        l_d1_measr_comp dmc
        cisadm.d1_sp_identifier@stg_msm_link dsi,
        cisadm.d1_install_evt@stg_msm_link die,
        cisadm.d1_measr_comp@stg_msm_link dmc

    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = p_MEASR_COMP_TYPE_CD  
        and pas.item_code = 'FPN'
        and pas.rank = p_RANK 
        AND pas.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR
        AND pas.ASB_UNIT_CODE = v_asb_unit_code
        ;

BEGIN
    
    select distinct asb_unit_code bulk collect into lv_vc_unit_code from pn_position_stg where LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR and item_code = 'FPN'
    ;
    
    for i in 1..lv_vc_unit_code.count
    loop
    FOR rec in cur_FPN(lv_vc_unit_code(i))
    LOOP
      
        IF (REC.PREV_MSRMT_DTTM IS NULL) THEN
            select max(effective) into v_effective from pn_position_stg where ASB_UNIT_CODE =  lv_vc_unit_code(i) and RANK = p_RANK
            AND ITEM_CODE = 'FPN' AND effective < REC.effective;
        END IF ;
        
        INSERT INTO MSM_STG1.D1_MSRMT_FPN
            (LOAD_SEQ_NBR,MEASR_COMP_ID,MSRMT_DTTM,BO_STATUS_CD,MSRMT_COND_FLG,MSRMT_USE_FLG,MSRMT_LOCAL_DTTM,MSRMT_VAL,ORIG_INIT_MSRMT_ID,PREV_MSRMT_DTTM,
             MSRMT_VAL1,MSRMT_VAL2,MSRMT_VAL3,MSRMT_VAL4,MSRMT_VAL5,MSRMT_VAL6,MSRMT_VAL7,MSRMT_VAL8,MSRMT_VAL9,MSRMT_VAL10,BUS_OBJ_CD,CRE_DTTM,STATUS_UPD_DTTM,
             USER_EDITED_FLG,VERSION,LAST_UPDATE_DTTM,READING_VAL,COMBINED_MULTIPLIER,READING_COND_FLG,date_created )

        VALUES
            ( PI_LOAD_SEQ_NBR,REC.measr_comp_id,REC.effective,'OK','501000',' ',fn_convert_gmt_bst1(REC.effective),REC.OP_LEVEL,p_MEASR_COMP_TYPE_CD--,NULL
                ,NVL(REC.PREV_MSRMT_DTTM,v_effective)    -- Added by Anish Kumar S on 02-11-2021
                ,'0','0','0','0','0','0','0','0','0','0',
                'D1-Measurement',SYSDATE,SYSDATE,' ','99',SYSDATE --,NULL
                ,REC.OP_LEVEL   -- Added by Anish Kumar S on 02-11-2021
                ,'1',NULL,sysdate  );

  END LOOP;
  END LOOP;
 EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        PR_PROCESS_LOG('PR_MSM1_OPR_FPN_RANK - ' || p_MEASR_COMP_TYPE_CD ,pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_OPR_FPN_RANK;

/

