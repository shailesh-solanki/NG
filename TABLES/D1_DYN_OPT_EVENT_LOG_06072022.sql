--------------------------------------------------------
--  DDL for Table D1_DYN_OPT_EVENT_LOG_06072022
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_06072022" 
   (	"DYN_OPT_EVENT_ID" CHAR(14 BYTE), 
	"SEQNO" NUMBER(5,0), 
	"LOG_ENTRY_TYPE_FLG" CHAR(4 BYTE), 
	"LOG_DTTM" DATE, 
	"DESCRLONG" VARCHAR2(4000 BYTE), 
	"BO_STATUS_CD" CHAR(12 BYTE), 
	"MESSAGE_CAT_NBR" NUMBER(5,0), 
	"MESSAGE_NBR" NUMBER(5,0), 
	"CHAR_TYPE_CD" CHAR(8 BYTE), 
	"CHAR_VAL" CHAR(16 BYTE), 
	"ADHOC_CHAR_VAL" VARCHAR2(254 BYTE), 
	"CHAR_VAL_FK1" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK2" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK3" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK4" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK5" VARCHAR2(50 BYTE), 
	"USER_ID" CHAR(8 BYTE), 
	"VERSION" NUMBER(5,0), 
	"BO_STATUS_REASON_CD" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 