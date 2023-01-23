--------------------------------------------------------
--  DDL for Table ASB_DUTY_WINDOW_STG
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."ASB_DUTY_WINDOW_STG" 
   (	"LOAD_SEQ_NBR" VARCHAR2(10 BYTE), 
	"SEASON_SEQ" NUMBER(5,0), 
	"DAY_CODE" VARCHAR2(4 BYTE), 
	"START_LOCAL" DATE, 
	"END_LOCAL" DATE, 
	"SERVICE_PERIOD" NUMBER(1,0), 
	"CONTRACT_SEQ" NUMBER(22,0), 
	"WEEK_DAY_CODE" NUMBER(1,0), 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
  