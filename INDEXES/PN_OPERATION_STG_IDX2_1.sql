--------------------------------------------------------
--  DDL for Index PN_OPERATION_STG_IDX2
--------------------------------------------------------

  CREATE INDEX "ASB_STG"."PN_OPERATION_STG_IDX2" ON "ASB_STG"."PN_OPERATION_STG" ("EFFECTIVE", "RANK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
