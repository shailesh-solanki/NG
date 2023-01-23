--------------------------------------------------------
--  DDL for Table SRS_MONITORING_STG
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SRS_MONITORING_STG" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"EFFECTIVE" DATE, 
	"BAD_METER_FLAG" CHAR(1 BYTE), 
	"METER_DELAY" NUMBER(2,0), 
	"NEGATIVE_LOAD" NUMBER(10,3), 
	"BASE_LOAD_LEAD" NUMBER(2,0), 
	"BASE_LOAD_LAG" NUMBER(2,0), 
	"BASE_LOAD_SUM" VARCHAR2(3 BYTE), 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 