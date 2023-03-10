--------------------------------------------------------
--  DDL for Index PN_AVAILABILITY_STG_IDX2
--------------------------------------------------------

  CREATE INDEX "ASB_STG"."PN_AVAILABILITY_STG_IDX2" ON "ASB_STG"."PN_AVAILABILITY_STG" ("LOAD_SEQ_NBR") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
