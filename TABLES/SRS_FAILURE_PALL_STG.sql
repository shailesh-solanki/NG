--------------------------------------------------------
--  DDL for Table SRS_FAILURE_PALL_STG
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SRS_FAILURE_PALL_STG" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"CONTRACT_SEQ" NUMBER(22,0), 
	"FAIL_CODE" VARCHAR2(4 BYTE), 
	"FAIL_ENTRY" CHAR(1 BYTE), 
	"FAIL_SUPP" NUMBER(1,0), 
	"FAIL_START" DATE, 
	"FAIL_END" DATE, 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 