--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_NTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_NTO" 
/**************************************************************************************
*
* Program Name           :PR_ASB_OPR_LOAD_NTO
* Author                 :IBM(Roshan Khandare)
* Creation Date          :27-05-2021
* Description            :This is a PL/SQL procedure. This procedure takes data from PN_NOTICE
*                         data from ASB legacy system
*                         and loads into PN_NOTICE_STG table.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_OPR_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :load sequence number
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  27-05-2021    Roshan Khandare
**************************************************************************************/
(PI_LOAD_SEQ_NBR IN NUMBER,
 PI_EFFECTIVE IN DATE,PI_END_DATE IN DATE)
AS
BEGIN
  -- Insert DATA from ASB Legacy database table PN_NOTICE
  MERGE INTO PN_NOTICE_STG A
         USING (
--         select * FROM PN_NOTICE WHERE (ASB_UNIT_CODE, EFFECTIVE,ITEM_CODE)IN (select asb_unit_code, max(effective) AS EFFECTIVE,ITEM_CODE from PN_NOTICE WHERE ITEM_CODE='NTO'
-- group by asb_unit_code,ITEM_CODE having max(effective)< PI_EFFECTIVE)
-- UNION
 SELECT ASB_UNIT_CODE, ITEM_CODE, EFFECTIVE, PERIOD, FILE_DATE from PN_NOTICE where ITEM_CODE = 'NTO' AND TRUNC(EFFECTIVE)>=PI_EFFECTIVE AND TRUNC(EFFECTIVE) < TRUNC(PI_END_DATE) + 1) q
 ON (q.ASB_UNIT_CODE = A.ASB_UNIT_CODE AND q.ITEM_CODE = A.ITEM_CODE AND q.EFFECTIVE = A.EFFECTIVE)


    WHEN MATCHED THEN
        UPDATE SET LOAD_SEQ_NBR = pi_load_seq_nbr, PERIOD = q.PERIOD, FILE_DATE = q.FILE_DATE
       -- where (nvl(A.PERIOD,'checknull') <> nvl(q.PERIOD,'checknull')) or (nvl(A.FILE_DATE,'checknull') <> nvl(q.FILE_DATE,'checknull'))
    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE, ITEM_CODE, EFFECTIVE, PERIOD, FILE_DATE, DATE_CREATED)
        VALUES(pi_load_seq_nbr, q.ASB_UNIT_CODE, q.ITEM_CODE, q.EFFECTIVE, q.PERIOD, q.FILE_DATE, SYSDATE);

     ASB_STG.PROC_PROCESS_LOG('PR_ASB_OPR_NTO_LOAD',pi_load_seq_nbr,'SUCCESS', 'Operational(NTO) data migrated successfully from ASB legacy system to ASB_STG schema','NTO');

EXCEPTION
   WHEN OTHERS then
        ASB_STG.PROC_PROCESS_LOG('PR_ASB_OPR_NTO_LOAD',pi_load_seq_nbr,'FAILURE', SUBSTR(sqlerrm,1,3000),'NTO');

END PR_ASB_LOAD_OPR_NTO;

/
