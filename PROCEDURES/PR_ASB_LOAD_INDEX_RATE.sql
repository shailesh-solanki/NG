--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_INDEX_RATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_INDEX_RATE" (PI_LOAD_SEQ_NBR IN NUMBER)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_INDEX_RATE
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-OCT-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table(ASB_INDEX_RATE) to
                          ASB_STG (ASB_INDEX_RATE_STG) table.
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
 MERGE INTO ASB_INDEX_RATE_STG S2
 USING (SELECT * FROM ASB_DEV_4.ASB_INDEX_RATE WHERE SERVICE_CODE IN ('SRBM','SRNM')) S1
 ON(S2.ASB_PAYEE_CODE=S1.ASB_PAYEE_CODE AND S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.EFFECTIVE=S1.EFFECTIVE AND S2.INDEX_CODE=S1.INDEX_CODE AND
    S2.PAY_CODE=S1.PAY_CODE AND S2.SERVICE_CODE=S1.SERVICE_CODE)

 WHEN MATCHED THEN
 UPDATE SET S2.INDEX_RATE=S1.INDEX_RATE,S2.FINANCIAL_YEAR=S1.FINANCIAL_YEAR
 WHERE (NVL(S2.INDEX_RATE,0)<>NVL(S1.INDEX_RATE,0)) or
           (NVL(S2.FINANCIAL_YEAR,0)<>NVL(S1.FINANCIAL_YEAR,0))

 WHEN NOT MATCHED THEN
 INSERT (LOAD_SEQ_NBR,ASB_PAYEE_CODE ,SERVICE_CODE,EFFECTIVE ,INDEX_CODE,INDEX_RATE,FINANCIAL_YEAR,ASB_UNIT_CODE,PAY_CODE,DATE_CREATED)
 VALUES(PI_LOAD_SEQ_NBR,S1.ASB_PAYEE_CODE,S1.SERVICE_CODE,S1.EFFECTIVE,S1.INDEX_CODE,S1.INDEX_RATE,S1.FINANCIAL_YEAR,S1.ASB_UNIT_CODE,S1.PAY_CODE,SYSDATE);


            /* MERGE INTO ASB_RESOURCE_SELECTION_STG S2
 USING (SELECT * FROM ASB_RESOURCE_SELECTION ) S1
 ON(S2.CONTRACT_SEQ=S1.CONTRACT_SEQ)

 WHEN MATCHED THEN
 UPDATE SET S2.ASB_COMP_CODE=S1.ASB_COMP_CODE,S2.ASB_STAT_CODE=S1.ASB_STAT_CODE,S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE,S2.UNIT_TYPE=S1.UNIT_TYPE
 WHERE (NVL(S2.ASB_COMP_CODE,'checknull')<>NVL(S1.ASB_COMP_CODE,'checknull')) or
           (NVL(S2.ASB_STAT_CODE,'checknull')<>NVL(S1.ASB_STAT_CODE,'checknull')) OR
           (NVL(S2.ASB_UNIT_CODE,'checknull')<>NVL(S1.ASB_UNIT_CODE,'checknull')) or
           (NVL(S2.UNIT_TYPE,'checknull')<>NVL(S1.UNIT_TYPE,'checknull'))

 WHEN NOT MATCHED THEN
 INSERT (LOAD_SEQ_NBR,CONTRACT_SEQ,ASB_COMP_CODE ,ASB_STAT_CODE,ASB_UNIT_CODE ,UNIT_TYPE,DATE_CREATED)
 VALUES(PI_LOAD_SEQ_NBR,S1.CONTRACT_SEQ,S1.ASB_COMP_CODE ,S1.ASB_STAT_CODE,S1.ASB_UNIT_CODE ,S1.UNIT_TYPE,SYSDATE);*/

  PR_PROCESS_LOG('PR_ASB_LOAD_INDEX_RATE',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_INDEX_RATE_STG table sucessfully!!!');
   --Exceptions
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_INDEX_RATE',pi_load_seq_nbr,'SUCCESS','No insert or update done in  ASB_INDEX_RATE_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_INDEX_RATE',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');



END PR_ASB_LOAD_INDEX_RATE;

/
