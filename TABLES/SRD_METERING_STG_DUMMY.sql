--------------------------------------------------------
--  DDL for Table SRD_METERING_STG_DUMMY
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SRD_METERING_STG_DUMMY" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"CONTRACT_NUMBER" NUMBER(4,2), 
	"EFFECTIVE" DATE, 
	"REC_LEVEL" NUMBER(10,6), 
	"FILE_DATE" DATE, 
	"MSRMT_DTTM" DATE, 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 