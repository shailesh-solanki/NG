--------------------------------------------------------
--  DDL for Table OWNER_CSV_CUT3
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."OWNER_CSV_CUT3" 
   (	"RESOURCE_CODE" VARCHAR2(10 BYTE), 
	"TYPE" VARCHAR2(20 BYTE), 
	"COMPANY_CODE" VARCHAR2(10 BYTE), 
	"OWNED_EFF_START_DT" DATE, 
	"OWNED_EFF_END_DT" DATE, 
	"PAYMENT_EFF_START_DT" DATE, 
	"PAYMENT_EFF_END_DT" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
  