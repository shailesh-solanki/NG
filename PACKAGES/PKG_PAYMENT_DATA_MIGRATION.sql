--------------------------------------------------------
--  DDL for Package PKG_PAYMENT_DATA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "ASB_STG"."PKG_PAYMENT_DATA_MIGRATION" 
AS
    
    PROCEDURE PR_PAYMENT_DATA_LOAD(pi_load_seq_nbr in number,pi_start in date,pi_end in date);
    PROCEDURE PR_PAYMENT_DATA_TRANSFER(pi_load_seq_nbr in number,pi_version in number);

END PKG_PAYMENT_DATA_MIGRATION;

/

