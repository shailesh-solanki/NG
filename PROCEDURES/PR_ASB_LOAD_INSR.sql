--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_INSR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_INSR" (PI_LOAD_SEQ_NBR IN NUMBER, PI_EFFECTIVE IN DATE,PI_EFFECTIVE_END IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_INSR
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :17-09-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table ( SRD_INSTRUCTION ) to
                          ASB_STG (SRD_INSTRUCTION_STG) table.
*
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_INSR_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS
BEGIN

    MERGE INTO SRD_INSTRUCTION_STG S2
    USING (
        SELECT sri.ASB_UNIT_CODE, sri.CONTRACT_NUMBER, sri.INSR_START, sri.INSR_END, sri.INSR_ISSUE, sri.OP_LEVEL, sri.STATUS, sri.FILE_DATE, sup.contract_seq
        FROM SRD_INSTRUCTION sri, SRS_SUPPLIER sup
        where sri.asb_unit_code = sup.asb_unit_code
        and sri.contract_number = sup.contract_number
        and sri.insr_issue between pi_effective and PI_EFFECTIVE_END) S1
        ON (S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.CONTRACT_NUMBER=S1.CONTRACT_NUMBER AND S2.INSR_START=S1.INSR_START AND S2.CONTRACT_SEQ=S1.CONTRACT_SEQ)
    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, INSR_END=S1.INSR_END, INSR_ISSUE=S1.INSR_ISSUE, OP_LEVEL=S1.OP_LEVEL, STATUS=S1.STATUS, FILE_DATE=S1.FILE_DATE
        WHERE OP_LEVEL<>S1.OP_LEVEL OR FILE_DATE<>S1.FILE_DATE OR INSR_END<>S1.INSR_END OR INSR_ISSUE<>S1.INSR_ISSUE OR STATUS<>S1.STATUS
    WHEN NOT MATCHED THEN
        INSERT ( LOAD_SEQ_NBR,ASB_UNIT_CODE, CONTRACT_NUMBER, INSR_START, INSR_END, INSR_ISSUE, OP_LEVEL, STATUS, FILE_DATE, CONTRACT_SEQ, DATE_CREATED )
        VALUES ( PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE, S1.CONTRACT_NUMBER, S1.INSR_START, S1.INSR_END, S1.INSR_ISSUE, S1.OP_LEVEL, S1.STATUS, S1.FILE_DATE, S1.CONTRACT_SEQ, SYSDATE );

   PR_PROCESS_LOG('PR_ASB_LOAD_INSR',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRD_INSTRUCTION_STG table sucessfully!!!');
   --Exceptions
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_INSR',pi_load_seq_nbr,'SUCCESS','No insert or update done in  SRD_INSTRUCTION_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_INSR',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');

END PR_ASB_LOAD_INSR;

/

