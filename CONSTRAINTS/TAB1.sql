--------------------------------------------------------
--  Constraints for Table TAB1
--------------------------------------------------------

  ALTER TABLE "ASB_STG"."TAB1" ADD PRIMARY KEY ("C1")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS"  ENABLE;
  ALTER TABLE "ASB_STG"."TAB1" MODIFY ("C2" NOT NULL ENABLE);
