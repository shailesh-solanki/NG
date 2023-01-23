--------------------------------------------------------
--  DDL for Function FN_GET_MEASR_COMP_ID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."FN_GET_MEASR_COMP_ID" ( p_asb_unit_code VARCHAR2, p_measr_comp_type_cd VARCHAR2 ) 
RETURN VARCHAR2 IS
v_measr_comp_id VARCHAR2(12 BYTE);
BEGIN

    SELECT  dmc.measr_comp_id into v_measr_comp_id
       FROM 
     cisadm.d1_sp_identifier@stg_msm_link dsi,
     cisadm.d1_install_evt@stg_msm_link die,
     cisadm.d1_measr_comp@stg_msm_link dmc
     WHERE 
      dsi.d1_sp_id = die.d1_sp_id
     AND die.device_config_id = dmc.device_config_id
     AND dsi.sp_id_type_flg = 'D1MI'
     AND dsi.id_value = p_asb_unit_code
     AND MEASR_COMP_TYPE_CD = p_measr_comp_type_cd ;

 RETURN v_measr_comp_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
--        raise_application_error(sqlerrm,sqlcode , TRUE);

END fn_get_MEASR_COMP_ID;

/
