--------------------------------------------------------
--  DDL for Table FILETEST
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."FILETEST" 
   (	"F1_SVC_TASK_ID" CHAR(14 BYTE), 
	"CHAR_TYPE_CD" CHAR(8 BYTE), 
	"SEQ_NUM" CHAR(1 BYTE), 
	"CHAR_VAL" CHAR(1 BYTE), 
	"ADHOC_CHAR_VAL" VARCHAR2(100 BYTE), 
	"NEWFILE" VARCHAR2(100 BYTE), 
	"VERSION" NUMBER
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;