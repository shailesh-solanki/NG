--------------------------------------------------------
--  DDL for Table SRD_DECLARATION_STG_BK0607
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SRD_DECLARATION_STG_BK0607" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"CONTRACT_SEQ" NUMBER(22,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"CONTRACT_NUMBER" NUMBER(4,2), 
	"SERVICE_DATE" DATE, 
	"SERVICE_PERIOD" NUMBER(1,0), 
	"AVAIL_WEEK" NUMBER(10,3), 
	"AVAIL_LEVEL" NUMBER(10,3), 
	"FILE_DATE" DATE, 
	"FILE_TYPE" VARCHAR2(3 BYTE), 
	"REVISED_WEEK" NUMBER(10,3), 
	"REVISED_LEVEL" NUMBER(10,3), 
	"REJECT_FLAG" CHAR(1 BYTE), 
	"BO_STATUS_CD" VARCHAR2(8 BYTE), 
	"SERVICE_CODE" VARCHAR2(4 BYTE), 
	"DAY_CODE" VARCHAR2(4000 BYTE), 
	"D1_DYN_OPT_EVENT_ID" NUMBER(*,0), 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 