--------------------------------------------------------
--  DDL for Procedure PR_PROCESS_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_PROCESS_LOG" 
/**************************************************************************************
*
* Program Name           :PR_PROCESS_LOG
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure inserts status
*                         of every procedure in PROCESS_LOG table.
*
**************************************************************************************/
(pi_proc_name IN VARCHAR2,pi_load_seq_nbr IN NUMBER,pi_status IN VARCHAR2,pi_error IN VARCHAR2, PI_ENTITY_NAME IN VARCHAR2 DEFAULT NULL)
--PI_ENTITY_NAME Added By Anish Kumar S
AS
BEGIN

    INSERT INTO PROCESS_LOG (PROC_SEQ_NBR, PROC_NAME, LOAD_SEQ_NBR, STATUS, STATUS_DESCRIPTION, DATE_CREATED, ENTITY_NAME)
    VALUES(SQ_PROC_SEQ_NBR.nextval,pi_proc_name,pi_load_seq_nbr,pi_status,pi_error,SYSDATE, PI_ENTITY_NAME);

EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error while inserting process status in PROCESS_LOG table : '||SQLERRM);
END;

/
