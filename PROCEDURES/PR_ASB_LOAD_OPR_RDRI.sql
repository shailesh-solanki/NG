--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_RDRI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_RDRI" (PI_LOAD_SEQ_NBR NUMBER,pi_EFFECTIVE DATE,PI_END_DATE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_RDRI
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-06-2021
* Description            :This is a PL/SQL procedure. This procedure loads operation data for item code RDRI
*
* Calling Program        :None
* Called Program         : PR_ASB_LOAD_OPR_RDRI_MAIN
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
    MERGE INTO PN_RANGE_STG S2
    USING (
--    SELECT * FROM PN_RANGE WHERE (ASB_UNIT_CODE, EFFECTIVE, ITEM_CODE)IN (select asb_unit_code, max(effective) AS EFFECTIVE,ITEM_CODE from PN_RANGE WHERE ITEM_CODE='RDRI'
-- group by asb_unit_code,ITEM_CODE having max(effective)< PI_EFFECTIVE)
-- UNION
 SELECT ASB_UNIT_CODE,ITEM_CODE,EFFECTIVE,RATE_1,ELBOW_2,RATE_2,ELBOW_3,RATE_3,FILE_DATE FROM PN_RANGE
WHERE ITEM_CODE='RDRI' AND TRUNC(EFFECTIVE)>= PI_EFFECTIVE AND TRUNC(EFFECTIVE) < TRUNC(PI_END_DATE) + 1)S1
    ON(S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.EFFECTIVE=S1.EFFECTIVE AND S2.ITEM_CODE=S1.ITEM_CODE)
    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, RATE_1=S1.RATE_1,ELBOW_2=S1.ELBOW_2,RATE_2 =S1.RATE_2 ,ELBOW_3 =S1.ELBOW_3,RATE_3  =S1.RATE_3  ,FILE_DATE=S1.FILE_DATE
     --   WHERE RATE_1<>s1.RATE_1 OR ELBOW_2<>S1.ELBOW_2 OR RATE_2<>S1.RATE_2 OR ELBOW_3 <>S1.ELBOW_3  OR RATE_3  <>S1.RATE_3  OR FILE_DATE<>S1.FILE_DATE
    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR,ASB_UNIT_CODE ,ITEM_CODE ,EFFECTIVE ,RATE_1,ELBOW_2 ,RATE_2 ,ELBOW_3 ,RATE_3 ,FILE_DATE,DATE_CREATED)
        VALUES(PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE ,S1.ITEM_CODE ,S1.EFFECTIVE ,S1.RATE_1,S1.ELBOW_2 ,S1.RATE_2 ,S1.ELBOW_3 ,S1.RATE_3 ,S1.FILE_DATE,SYSDATE);

    PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_RDRI ',pi_load_seq_nbr,'SUCCESS','All the new records for RDRI item code pushed to PN_RANGE_STG table sucessfully!!!','RDRI');
EXCEPTION 
WHEN NO_DATA_FOUND THEN
    PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_RDRI ',pi_load_seq_nbr,'SUCCESS',SUBSTR(sqlerrm,1,3000),'RDRI');
WHEN OTHERS THEN
    PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_RDRI ',PI_LOAD_SEQ_NBR,'FAILURE', SUBSTR(sqlerrm,1,3000),'RDRI');
END PR_ASB_LOAD_OPR_RDRI;

/

