--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_MZT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_MZT" (PI_LOAD_SEQ_NBR IN NUMBER,pi_effective in date,PI_END_DATE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_OPS_LOAD_MZT
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :26-05-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(MZT) from ASB legacy system to  asb_stg schema
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_MZT_MAIN
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
  MERGE INTO PN_DELIVERY_STG S2
  USING(
--  SELECT * FROM PN_delivery WHERE (ASB_UNIT_CODE, EFFECTIVE, ITEM_CODE)IN (select asb_unit_code, max(effective) AS EFFECTIVE,ITEM_CODE from PN_delivery
--WHERE ITEM_CODE='MZT'
-- group by asb_unit_code,ITEM_CODE having max(effective)< PI_EFFECTIVE)
-- UNION
 SELECT ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,PERIOD , VOLUME,FILE_DATE FROM PN_DELIVERY
 WHERE ITEM_CODE='MZT' AND TRUNC(EFFECTIVE)>= PI_EFFECTIVE AND TRUNC(EFFECTIVE) < TRUNC(PI_END_DATE) + 1)S1
  ON(S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.EFFECTIVE=S1.EFFECTIVE AND S2.ITEM_CODE=S1.ITEM_CODE)
  WHEN MATCHED THEN
  
  UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, PERIOD =S1.PERIOD ,FILE_DATE=S1.FILE_DATE ,DATE_CREATED=SYSDATE
  
 WHEN NOT MATCHED THEN
 INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,PERIOD ,FILE_DATE,DATE_CREATED)
 VALUES( PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE,S1.ITEM_CODE,S1.EFFECTIVE,S1.PERIOD ,S1.FILE_DATE,SYSDATE);

  PROC_PROCESS_LOG('PR_ASB_OPS_LOAD_MZT',pi_load_seq_nbr,'SUCCESS','All the new records pushed to ASB_PN_DELIVERY_STG table sucessfully!!!','MZT');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_ASB_OPS_LOAD_MZT',pi_load_seq_nbr,'SUCCESS',SUBSTR(sqlerrm,1,3000),'MZT');
    WHEN OTHERS THEN
         PROC_PROCESS_LOG('PR_ASB_OPS_LOAD_MZT',PI_LOAD_SEQ_NBR,'FAILURE', SUBSTR(sqlerrm,1,3000),'MZT');
END PR_ASB_LOAD_OPR_MZT;

/

