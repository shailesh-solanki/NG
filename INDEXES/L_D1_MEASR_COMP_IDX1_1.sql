--------------------------------------------------------
--  DDL for Index L_D1_MEASR_COMP_IDX1
--------------------------------------------------------

  CREATE INDEX "ASB_STG"."L_D1_MEASR_COMP_IDX1" ON "ASB_STG"."L_D1_MEASR_COMP" ("DEVICE_CONFIG_ID", "MEASR_COMP_TYPE_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;