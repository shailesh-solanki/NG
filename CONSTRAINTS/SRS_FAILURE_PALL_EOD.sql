--------------------------------------------------------
--  Constraints for Table SRS_FAILURE_PALL_EOD
--------------------------------------------------------

  ALTER TABLE "ASB_STG"."SRS_FAILURE_PALL_EOD" MODIFY ("FAIL_SUPP" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."SRS_FAILURE_PALL_EOD" MODIFY ("FAIL_ENTRY" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."SRS_FAILURE_PALL_EOD" MODIFY ("FAIL_CODE" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."SRS_FAILURE_PALL_EOD" MODIFY ("CONTRACT_SEQ" NOT NULL ENABLE);
