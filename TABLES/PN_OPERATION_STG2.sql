--------------------------------------------------------
--  DDL for Table PN_OPERATION_STG2
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."PN_OPERATION_STG2" 
   (	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"EFFECTIVE" DATE, 
	"C_PREV_MSRMT_DTTM" DATE, 
	"RANK" NUMBER(1,0), 
	"OP_LEVEL" NUMBER(10,3), 
	"FILE_DATE" DATE, 
	"ITEM_CODE" VARCHAR2(4 BYTE), 
	"LOAD_SEQ_NBR" NUMBER, 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
