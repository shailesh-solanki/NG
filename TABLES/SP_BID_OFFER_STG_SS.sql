--------------------------------------------------------
--  DDL for Table SP_BID_OFFER_STG_SS
--------------------------------------------------------

  CREATE TABLE "ASB_STG"."SP_BID_OFFER_STG_SS" 
   (	"LOAD_SEQ_NBR" NUMBER(10,0), 
	"ASB_UNIT_CODE" VARCHAR2(10 BYTE), 
	"SETT_DATE" DATE, 
	"SETT_PER" NUMBER(2,0), 
	"BO_PAIR" NUMBER(2,0), 
	"BID_PRICE" NUMBER(10,5), 
	"OFFER_PRICE" NUMBER(10,5), 
	"BO_LEVEL" NUMBER(10,3), 
	"BID_VOLUME" NUMBER(10,3), 
	"OFFER_VOLUME" NUMBER(10,3), 
	"START_DTTM" DATE, 
	"END_DTTM" DATE, 
	"DATE_CREATED" DATE
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
 