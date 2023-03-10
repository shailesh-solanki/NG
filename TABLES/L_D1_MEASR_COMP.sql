--------------------------------------------------------
--  DDL for Table L_D1_MEASR_COMP
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."L_D1_MEASR_COMP" 
   (	"MEASR_COMP_ID" CHAR(12 BYTE), 
	"DEVICE_CONFIG_ID" CHAR(12 BYTE), 
	"MEASR_COMP_TYPE_CD" VARCHAR2(30 BYTE), 
	"BUS_OBJ_CD" CHAR(30 BYTE), 
	"BO_STATUS_CD" CHAR(12 BYTE), 
	"MEASR_COMP_USAGE_FLG" CHAR(4 BYTE), 
	"D1_NBR_OF_DGTS_LFT" NUMBER(5,0), 
	"D1_NBR_OF_DGTS_RGT" NUMBER(5,0), 
	"MEASR_COMP_MULTIPLIER" NUMBER(12,6), 
	"TIME_ZONE_CD" CHAR(10 BYTE), 
	"LATEST_MSRMT_DTTM" DATE, 
	"D1_READ_SEQ" NUMBER(5,0), 
	"USER_ID" CHAR(12 BYTE), 
	"CRE_DTTM" DATE, 
	"STATUS_UPD_DTTM" DATE, 
	"BO_STATUS_REASON_CD" VARCHAR2(30 BYTE), 
	"VERSION" NUMBER(5,0), 
	"D1_FULL_SCALE" NUMBER(18,7), 
	"BO_DATA_AREA" CLOB, 
	"MOST_RECENT_MSRMT_DTTM" DATE, 
	"MOST_RECENT_NON_EST_MSRMT_DTTM" DATE, 
	"ADJ_LATEST_MSRMT_DTTM" DATE, 
	"MOST_RECENT_MSRMT_READING_VAL" NUMBER(16,6), 
	"MOST_RECENT_MSRMT_READING_COND" CHAR(6 BYTE), 
	"ATTR_VAL_ID" CHAR(12 BYTE), 
	"ACCESS_GRP_CD" CHAR(12 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" 
 LOB ("BO_DATA_AREA") STORE AS BASICFILE (
  TABLESPACE "USERS" ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE LOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)) ;
 