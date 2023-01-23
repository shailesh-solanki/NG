--------------------------------------------------------
--  DDL for Materialized View MV_MEASR_COMP_ID
--------------------------------------------------------

  CREATE MATERIALIZED VIEW "ASB_STG"."MV_MEASR_COMP_ID" ("ID_VALUE", "D1_SP_ID", "SP_ID_TYPE_FLG", "DEVICE_CONFIG_ID", "MEASR_COMP_TYPE_CD", "MEASR_COMP_ID")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS select dsi.id_value,dsi.d1_sp_id, dsi.sp_id_type_flg, die.device_config_id, dmc.measr_comp_type_cd, dmc.measr_comp_id 
    from  cisadm.d1_sp_identifier@stg_msm_link dsi,
    cisadm.d1_install_evt@stg_msm_link die,
    cisadm.d1_measr_comp@stg_msm_link dmc 
    where dsi.d1_sp_id = die.d1_sp_id
    AND dsi.sp_id_type_flg = 'D1MI'
    AND die.device_config_id = dmc.device_config_id;

   COMMENT ON MATERIALIZED VIEW "ASB_STG"."MV_MEASR_COMP_ID"  IS 'snapshot table for snapshot ASB_STG.MV_MEASR_COMP_ID';
  