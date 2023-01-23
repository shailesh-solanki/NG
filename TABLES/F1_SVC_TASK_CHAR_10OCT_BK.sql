--------------------------------------------------------
--  DDL for Table F1_SVC_TASK_CHAR_10OCT_BK
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."F1_SVC_TASK_CHAR_10OCT_BK" 
   (	"F1_SVC_TASK_ID" CHAR(14 BYTE), 
	"CHAR_TYPE_CD" CHAR(8 BYTE), 
	"SEQ_NUM" NUMBER(3,0), 
	"CHAR_VAL" CHAR(16 BYTE), 
	"ADHOC_CHAR_VAL" VARCHAR2(254 BYTE), 
	"CHAR_VAL_FK1" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK2" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK3" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK4" VARCHAR2(50 BYTE), 
	"CHAR_VAL_FK5" VARCHAR2(50 BYTE), 
	"SRCH_CHAR_VAL" VARCHAR2(50 BYTE), 
	"VERSION" NUMBER(5,0)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
