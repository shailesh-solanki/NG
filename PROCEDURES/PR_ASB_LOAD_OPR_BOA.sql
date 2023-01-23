--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_BOA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_BOA" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE,p_ITEM_CODE IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_BOA
* Author                 :IBM(ANISH KUMAR S)
* Creation Date          :23-08-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table ( PN_POSITION ) to
                          ASB_STG (PN_POSITION_STG) table.
*
*
* Calling Program        :None
* Called Program         :
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

    MERGE INTO PN_POSITION_STG S2
    USING (
        SELECT ASB_UNIT_CODE, BO_ACCEPTANCE, EFFECTIVE, RANK, OP_LEVEL, FILE_DATE, ITEM_CODE
        FROM PN_POSITION S1
        WHERE ITEM_CODE = p_ITEM_CODE AND EFFECTIVE between pi_effective and trunc(last_day(pi_effective)+1)-1/(24*60*60) ) S1
        ON (S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.EFFECTIVE=S1.EFFECTIVE AND S2.BO_ACCEPTANCE=S1.BO_ACCEPTANCE AND S2.RANK=S1.RANK AND S2.ITEM_CODE=S1.ITEM_CODE)
    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, OP_LEVEL=S1.OP_LEVEL, FILE_DATE=S1.FILE_DATE
        WHERE OP_LEVEL<>S1.OP_LEVEL OR FILE_DATE<>S1.FILE_DATE 
    WHEN NOT MATCHED THEN
        INSERT ( LOAD_SEQ_NBR,ASB_UNIT_CODE, BO_ACCEPTANCE, EFFECTIVE, RANK, OP_LEVEL, FILE_DATE, ITEM_CODE, DATE_CREATED )
        VALUES ( pi_load_seq_nbr,S1.ASB_UNIT_CODE,S1.BO_ACCEPTANCE,S1.EFFECTIVE, S1.RANK, S1.OP_LEVEL, S1.FILE_DATE, S1.ITEM_CODE, SYSDATE );

   PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BOA',pi_load_seq_nbr,'SUCCESS','All the new records pushed to PN_POSITION_STG table sucessfully!!!');
   --Exceptions
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BOA',pi_load_seq_nbr,'SUCCESS','No insert or update done in  PN_POSITION_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BOA',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');

END PR_ASB_LOAD_OPR_BOA;

/

