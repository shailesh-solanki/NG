--------------------------------------------------------
--  DDL for Table MV_MEASR_COMP_ID_BK226
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."MV_MEASR_COMP_ID_BK226" 
   (	"ID_VALUE" VARCHAR2(120 BYTE), 
	"D1_SP_ID" CHAR(12 BYTE), 
	"SP_ID_TYPE_FLG" CHAR(4 BYTE), 
	"DEVICE_CONFIG_ID" CHAR(12 BYTE), 
	"MEASR_COMP_TYPE_CD" VARCHAR2(30 BYTE), 
	"MEASR_COMP_ID" CHAR(12 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
 