--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_MNZT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_MNZT" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE,PI_END_DATE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_OPR_LOAD_MNZT
* Author                 :(Shailesh Solanki)
* Creation Date          :26-05-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(MNZT) from ASB legacy system to  asb_stg schema
*
* Calling Program        :None
* Called Program         : AR_ASB_LOAD_OPR_MNZT_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 25-05-2021    Shailesh Solanki       Initial version
**************************************************************************************/
AS
BEGIN
  MERGE INTO PN_DELIVERY_STG S2
  USING(
--  SELECT * FROM PN_delivery WHERE (ASB_UNIT_CODE, EFFECTIVE, ITEM_CODE)IN (select asb_unit_code, max(effective) AS EFFECTIVE,ITEM_CODE from PN_delivery
--WHERE ITEM_CODE='MNZT'
-- group by asb_unit_code,ITEM_CODE having max(effective)< PI_EFFECTIVE)
-- UNION
 SELECT ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,PERIOD , VOLUME,FILE_DATE FROM PN_DELIVERY
 WHERE ITEM_CODE='MNZT' AND TRUNC(EFFECTIVE)>= PI_EFFECTIVE AND TRUNC(EFFECTIVE)< TRUNC(PI_END_DATE) + 1) S1
 ON(S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.EFFECTIVE=S1.EFFECTIVE AND S2.ITEM_CODE=S1.ITEM_CODE)
  WHEN MATCHED THEN
   UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, PERIOD = S1.PERIOD, FILE_DATE = S1.FILE_DATE
 WHEN NOT MATCHED THEN
 INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,PERIOD ,FILE_DATE,DATE_CREATED)
 VALUES( PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE,S1.ITEM_CODE,S1.EFFECTIVE,S1.PERIOD ,S1.FILE_DATE,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_MNZT',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_PN_DELIVERY_STG table sucessfully!!!','MNZT');

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_MNZT',pi_load_seq_nbr,'SUCCESS','No insert or update done in  ASB_PN_DELIVERY_STG table','MNZT');
    WHEN OTHERS THEN
    ROLLBACK;
         PR_PROCESS_LOG('PR_ASB_LOAD_OPR_MNZT',PI_LOAD_SEQ_NBR,'FAILURE', SUBSTR(sqlerrm,1,3000));
END PR_ASB_LOAD_OPR_MNZT;

/

