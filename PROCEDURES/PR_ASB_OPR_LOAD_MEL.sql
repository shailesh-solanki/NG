--------------------------------------------------------
--  DDL for Procedure PR_ASB_OPR_LOAD_MEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_OPR_LOAD_MEL" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_OPR_LOAD_MEL
* Author                 :IBM(Roshan Khandare)
* Creation Date          :23-08-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table( pn_availability ) to
                          ASB_STG ( pn_availability_stg) table.
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
   -- Insert DATA from ASB Legacy database table PN_AVAILABILITY
  MERGE INTO pn_availability_stg A
        USING ( SELECT * from  pn_availability WHERE effective between pi_effective and trunc(last_day(pi_effective)+1)-1/(24*60*60)) q
        ON (q.ASB_UNIT_CODE = A.ASB_UNIT_CODE AND q.ITEM_CODE = A.ITEM_CODE AND q.EFFECTIVE = A.EFFECTIVE AND q.RANK = A.RANK)
    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, LIMIT = q.LIMIT, FILE_DATE = q.FILE_DATE
        where (nvl(A.LIMIT,'checknull') <> nvl(q.LIMIT,'checknull')) or
              (nvl(A.FILE_DATE,'checknull') <> nvl(q.FILE_DATE,'checknull'))
    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE, ITEM_CODE, EFFECTIVE, RANK, LIMIT, FILE_DATE, DATE_CREATED)
        VALUES(pi_load_seq_nbr, q.ASB_UNIT_CODE, q.ITEM_CODE, q.EFFECTIVE, q.RANK, q.LIMIT, q.FILE_DATE, SYSDATE);

     ASB_STG.PR_PROCESS_LOG('PR_ASB_OPR_LOAD_MEL',pi_load_seq_nbr,'SUCCESS', 'Operational(MEL) data migrated successfully from ASB legacy system to ASB_STG schema');

EXCEPTION
   WHEN OTHERS then
        ASB_STG.PR_PROCESS_LOG('PR_ASB_OPR_LOAD_MEL',pi_load_seq_nbr,'FAILURE', 'Failed while migrating Operational(MEL) data from ASB legacy system to ASB_STG schema');

END PR_ASB_OPR_LOAD_MEL;

/

