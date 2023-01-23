--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_SRD_METERING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_SRD_METERING" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE)

/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_SRD_METERING
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table(SRD_METERING) to
                          ASB_STG (SRD_METERING_STG) table.
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
dbms_output.put_line('pi_effective:'|| pi_effective||' - PI_LOAD_SEQ_NBR - '||PI_LOAD_SEQ_NBR );

--  DELETE from SRD_METERING_STG;
  EXECUTE IMMEDIATE 'truncate table SRD_METERING_STG';
  
  /*
  MERGE INTO SRD_METERING_STG S2
  USING (
  SELECT SRD.ASB_UNIT_CODE,SRD.CONTRACT_NUMBER,SRD.EFFECTIVE,SRD.REC_LEVEL,SRD.FILE_DATE FROM SRD_METERING
         SRD,SRS_SUPPLIER_STG S2 ,asb_contract_service_stg s3
  WHERE         SRD.ASB_UNIT_CODE=S2.ASB_UNIT_CODE and 
                SRD.CONTRACT_NUMBER=S2.CONTRACT_NUMBER and 
                s2.contract_seq=s3.contract_seq and 
                SRD.effective >= s3.contract_start and SRD.effective<s3.contract_end AND
                SRD.EFFECTIVE >= pi_effective and  SRD.EFFECTIVE < (trunc(pi_effective)+1)+INTERVAL '2' MINUTE 
  
--  WHERE EFFECTIVE between pi_effective and  ((END_effective)+1)- interval '1' second--trunc(last_day(pi_effective)+1)-1/(24*60*60)
    --WHERE contract_number=(SELECT MAX(CONTRACT_NUMBER) FROM SRD_METERING  WHERE EFFECTIVE=srt.effective AND ASB_UNIT_CODE=srt.asb_unit_code) and 
        ) S1
  ON(S2.EFFECTIVE=S1.EFFECTIVE AND S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.CONTRACT_NUMBER=S1.CONTRACT_NUMBER)
  WHEN MATCHED
  THEN
            UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,REC_LEVEL=S1.REC_LEVEL,FILE_DATE=S1.FILE_DATE
  WHEN NOT MATCHED THEN
              INSERT(LOAD_SEQ_NBR,ASB_UNIT_CODE,CONTRACT_NUMBER,EFFECTIVE,REC_LEVEL,FILE_DATE,MSRMT_DTTM,DATE_CREATED)
              VALUES(PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE,S1.CONTRACT_NUMBER,S1.EFFECTIVE,S1.REC_LEVEL,S1.FILE_DATE,
              s1.EFFECTIVE+INTERVAL '1' MINUTE ,SYSDATE); 
              */
              
    INSERT INTO SRD_METERING_STG(LOAD_SEQ_NBR,ASB_UNIT_CODE,CONTRACT_NUMBER,EFFECTIVE,REC_LEVEL,FILE_DATE,MSRMT_DTTM,DATE_CREATED) 
    SELECT PI_LOAD_SEQ_NBR,SRD.ASB_UNIT_CODE,SRD.CONTRACT_NUMBER,SRD.EFFECTIVE,SRD.REC_LEVEL,SRD.FILE_DATE,
           SRD.EFFECTIVE+INTERVAL '1' MINUTE ,SYSDATE
           FROM SRD_METERING SRD,SRS_SUPPLIER_STG S2 ,asb_contract_service_stg s3
  WHERE         SRD.ASB_UNIT_CODE=S2.ASB_UNIT_CODE and 
                SRD.CONTRACT_NUMBER=S2.CONTRACT_NUMBER and 
                s2.contract_seq=s3.contract_seq and 
                SRD.effective >= s3.contract_start and SRD.effective<s3.contract_end AND
                SRD.EFFECTIVE >= pi_effective and  SRD.EFFECTIVE < (trunc(pi_effective)+1)+INTERVAL '2' MINUTE ; 


    PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRD_METERING_STG table sucessfully!!!');

EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',pi_load_seq_nbr,'SUCCESS','No insert or update done in  SRD_METERING_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');

END PR_ASB_LOAD_SRD_METERING;


--create or replace PROCEDURE PR_ASB_LOAD_SRD_METERING (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE)

/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_SRD_METERING
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table(SRD_METERING) to
                          ASB_STG (SRD_METERING_STG) table.
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
/*AS

BEGIN

delete from SRD_METERING_STG;
  MERGE INTO SRD_METERING_STG S2
  USING (SELECT ASB_UNIT_CODE,CONTRACT_NUMBER,EFFECTIVE,REC_LEVEL,FILE_DATE FROM SRD_METERING
--  WHERE EFFECTIVE between pi_effective and  ((END_effective)+1)- interval '1' second--trunc(last_day(pi_effective)+1)-1/(24*60*60)
    WHERE EFFECTIVE >= pi_effective and  EFFECTIVE < trunc(pi_effective)+1
  ) S1
  ON(S2.EFFECTIVE=S1.EFFECTIVE AND S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.CONTRACT_NUMBER=S1.CONTRACT_NUMBER)
  WHEN MATCHED THEN
  UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,REC_LEVEL=S1.REC_LEVEL,FILE_DATE=S1.FILE_DATE

    WHERE (NVL(S2.REC_LEVEL,'checknull')<>NVL(S1.REC_LEVEL,'checknull')) or
           (NVL(S2.FILE_DATE,'checknull')<>NVL(S1.FILE_DATE,'checknull'))
  WHEN NOT MATCHED THEN
  INSERT(LOAD_SEQ_NBR,ASB_UNIT_CODE,CONTRACT_NUMBER,EFFECTIVE,REC_LEVEL,FILE_DATE,MSRMT_DTTM,DATE_CREATED)
  VALUES(PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE,S1.CONTRACT_NUMBER,S1.EFFECTIVE,S1.REC_LEVEL,S1.FILE_DATE,
  s1.EFFECTIVE+INTERVAL '1' MINUTE ,SYSDATE);


    PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SRD_METERING_STG table sucessfully!!!');
   --Exceptions
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',pi_load_seq_nbr,'SUCCESS','No insert or update done in  SRD_METERING_STG table');
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_SRD_METERING',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy to ASB_STG schema');

END PR_ASB_LOAD_SRD_METERING;*/

/

