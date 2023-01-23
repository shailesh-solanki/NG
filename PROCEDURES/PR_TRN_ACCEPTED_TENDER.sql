--------------------------------------------------------
--  DDL for Procedure PR_TRN_ACCEPTED_TENDER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_TRN_ACCEPTED_TENDER" 
/**************************************************************************************
*
* Program Name           :PR_TRN_ACCEPTED_TENDER
* Author                 :IBM(Anish Kumar S)
* Creation Date          :08-02-2021
* Description            :This is a PL/SQL procedure. This procedure takes data 
*                         from STOR_ACCEPTED_TENDERS_CSV and loads data into TRN_ACCEPTED_TENDER table..
*
* Calling Program        :None
* Called Program         :ASB_LOAD_ACT_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :CSV file receive status
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 25-10-2021      Anish Kumar S     Modified for fetching CSV file Name
**************************************************************************************/
(
    PI_LOAD_SEQ_NBR IN NUMBER
)
AS

BEGIN

    INSERT INTO TRN_ACCEPTED_TENDER
        ( LOAD_SEQ_NBR, CONTRACT_NUMBER, NGESO_UNIT_ID, WINDOW_START_DATE_TIME, WINDOW_END_DATE_TIME, AVAILABILITY_PRICE, CONTRACTED_MW, CONTRACT_SEQ )
    SELECT
        CSV.LOAD_SEQ_NBR, CSV.CONTRACT_NUMBER, CSV.NGESO_UNIT_ID, CSV.WINDOW_START_DATE_TIME, CSV.WINDOW_END_DATE_TIME, CSV.AVAILABILITY_PRICE, CSV.CONTRACTED_MW, SSS.CONTRACT_SEQ
    FROM 
        STOR_ACCEPTED_TENDERS_CSV CSV, ASB_UNIT_STG AUS, SRS_SUPPLIER_STG SSS, asb_contract_service acs
    WHERE CSV.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR
        AND CSV.NGESO_UNIT_ID = AUS.GOAL_UNIT_CODE
        AND CSV.CONTRACT_NUMBER = SSS.CONTRACT_NUMBER
        AND AUS.ASB_UNIT_CODE = SSS.ASB_UNIT_CODE
        AND ACS.contract_seq = SSS.CONTRACT_SEQ
        AND CSV.WINDOW_START_DATE_TIME >= acs.contract_start
        AND CSV.WINDOW_END_DATE_TIME < acs.contract_END
        ;
    
    ASB_STG.PR_PROCESS_LOG('PR_TRN_ACCEPTED_TENDER',PI_LOAD_SEQ_NBR,'SUCCESS','Data tranformation from csv and staging tables to TRN tables is successful!!!','ACT');
  
EXCEPTION
    WHEN OTHERS then
        ROLLBACK;
        PR_PROCESS_LOG('PR_TRN_ACCEPTED_TENDER',PI_LOAD_SEQ_NBR,'FAILURE', SQLERRM,'ACT'); 
END PR_TRN_ACCEPTED_TENDER;

/

