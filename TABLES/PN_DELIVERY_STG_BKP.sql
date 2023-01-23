--------------------------------------------------------
--  DDL for Table PN_DELIVERY_STG_BKP
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."PN_DELIVERY_STG_BKP" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"ITEM_CODE" VARCHAR2(4 BYTE), 
	"EFFECTIVE" DATE, 
	"PERIOD" NUMBER(4,0), 
	"FILE_DATE" DATE, 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
