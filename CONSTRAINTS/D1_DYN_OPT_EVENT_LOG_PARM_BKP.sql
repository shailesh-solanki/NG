--------------------------------------------------------
--  Constraints for Table D1_DYN_OPT_EVENT_LOG_PARM_BKP
--------------------------------------------------------

  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("VERSION" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("MSG_PARM_VAL" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("MSG_PARM_TYP_FLG" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("PARM_SEQ" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("SEQNO" NOT NULL ENABLE);
  ALTER TABLE "ASB_STG"."D1_DYN_OPT_EVENT_LOG_PARM_BKP" MODIFY ("DYN_OPT_EVENT_ID" NOT NULL ENABLE);
