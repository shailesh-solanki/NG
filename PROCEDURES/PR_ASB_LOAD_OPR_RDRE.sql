--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_RDRE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_RDRE" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE in DATE,PI_END_DATE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_OPR_LOAD_RDRE
* Author                 :(Roshan Khandare)
* Creation Date          :09-06-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(RDRE) from ASB legacy system to  asb_stg schema
*
* Calling Program        :None
* Called Program         : AR_ASB_LOAD_OPR_RDRE_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 09-06-2021   Roshan Khandare       Initial version
**************************************************************************************/
AS
BEGIN
 MERGE INTO PN_RANGE_STG V
USING (
--SELECT * FROM PN_RANGE WHERE (ASB_UNIT_CODE, EFFECTIVE, ITEM_CODE)IN (select asb_unit_code, max(effective) AS EFFECTIVE,ITEM_CODE from PN_RANGE WHERE ITEM_CODE='RDRE'
-- group by asb_unit_code,ITEM_CODE having max(effective)< PI_EFFECTIVE)
-- UNION
 SELECT ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,RATE_1,ELBOW_2,RATE_2,ELBOW_3,RATE_3,FILE_DATE FROM PN_RANGE
WHERE ITEM_CODE='RDRE' AND TRUNC(EFFECTIVE)>= PI_EFFECTIVE AND TRUNC(EFFECTIVE) < TRUNC(PI_END_DATE) + 1)S
ON (V.ASB_UNIT_CODE=S.ASB_UNIT_CODE AND V.ITEM_CODE=S.ITEM_CODE AND V.EFFECTIVE=S.EFFECTIVE)
WHEN MATCHED THEN
UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, RATE_1=S.RATE_1, ELBOW_2=S.ELBOW_2,RATE_2=S.RATE_2, ELBOW_3=S.ELBOW_3, RATE_3=S.RATE_3,FILE_DATE=S.FILE_DATE
--WHERE (NVL(V.RATE_1,'Checknull')<> NVL(S.RATE_1,'Checknull')) OR  (NVL(V.ELBOW_2,'Checknull')<> NVL(S.ELBOW_2,'Checknull')) OR
--      (NVL(V.RATE_2,'Checknull')<> NVL(S.RATE_2,'Checknull')) OR  (NVL(V.ELBOW_3,'Checknull')<> NVL(S.ELBOW_3,'Checknull')) OR
--      (NVL(V.RATE_3,'Checknull')<> NVL(S.RATE_3,'Checknull')) OR  (NVL(V.FILE_DATE,'Checknull')<> NVL(S.FILE_DATE,'Checknull'))
WHEN NOT MATCHED THEN
INSERT (LOAD_SEQ_NBR,ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,RATE_1,ELBOW_2,RATE_2,ELBOW_3,RATE_3,FILE_DATE,DATE_CREATED)
VALUES(PI_LOAD_SEQ_NBR,S.ASB_UNIT_CODE,S.ITEM_CODE,S.EFFECTIVE,S.RATE_1,S.ELBOW_2,S.RATE_2,S.ELBOW_3,S.RATE_3,S.FILE_DATE,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_OPR_LOAD_RDRE',pi_load_seq_nbr,'SUCCESS','All the new records pushed to PN_RANGE_STG table sucessfully!!!');
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_OPR_LOAD_RDRE',pi_load_seq_nbr,'SUCCESS','No insert or update done in  PN_RANGE_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_OPR_LOAD_RDRE',PI_LOAD_SEQ_NBR,'FAILURE', SUBSTR(sqlerrm,1,3000));
END PR_ASB_LOAD_OPR_RDRE;

/
