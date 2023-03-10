--------------------------------------------------------
--  DDL for Index SRD_DECLARATION_NGPS_IDX1
--------------------------------------------------------

  CREATE INDEX "ASB_STG"."SRD_DECLARATION_NGPS_IDX1" ON "ASB_STG"."SRD_DECLARATION_STG_NGPS" ("ASB_UNIT_CODE", "CONTRACT_NUMBER", "SERVICE_DATE", "SERVICE_PERIOD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
