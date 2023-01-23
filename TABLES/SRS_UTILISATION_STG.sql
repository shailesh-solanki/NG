--------------------------------------------------------
--  DDL for Table SRS_UTILISATION_STG
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SRS_UTILISATION_STG" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"UTIL_START" DATE, 
	"UTIL_END" DATE, 
	"UTIL_ISSUED" DATE, 
	"CONTRACT_SEQ" NUMBER(22,0), 
	"EXPECTED_ENERGY" NUMBER(10,3), 
	"METERED_ENERGY" NUMBER(10,3), 
	"REVISED_ENERGY" NUMBER(10,3), 
	"CAPPED_ENERGY" NUMBER(10,3), 
	"ACCEPT_STATUS" NUMBER(1,0), 
	"CEASE_STATUS" NUMBER(1,0), 
	"RESPONSE_STATUS" NUMBER(1,0), 
	"DELIVERY_STATUS" NUMBER(1,0), 
	"RAMP_FLAG" CHAR(1 BYTE), 
	"RESPONSE_PERCENT" NUMBER(10,3), 
	"DELIVERY_PERCENT" NUMBER(10,3), 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
  