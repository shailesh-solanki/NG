--------------------------------------------------------
--  DDL for Function SEQ_NEXTVAL_ON_DEMAND
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."SEQ_NEXTVAL_ON_DEMAND" (p_seq_name  IN  VARCHAR2)
  RETURN NUMBER
IS
  v_seq_val  NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'select ' || p_seq_name || '.nextval from dual'
     INTO v_seq_val;

  RETURN v_seq_val;
END seq_nextval_on_demand;

/
