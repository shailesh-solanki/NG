--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_BID_OFFER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_BID_OFFER" (PI_LOAD_SEQ_NBR IN NUMBER,PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_BID_OFFER
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :23-08-2021
* Description            :This is a PL/SQL procedure. This procedure loads the data from legacy system table(SP_BID_OFFER) to
                          ASB_STG (SP_BID_OFFER_STG) table.
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
  /*
  MERGE INTO SP_BID_OFFER_STG S2
  USING (SELECT ASB_UNIT_CODE,SETT_DATE,SETT_PER,BO_PAIR,BID_PRICE,OFFER_PRICE,BO_LEVEL,BID_VOLUME,OFFER_VOLUME,fn_get_gmt( SETT_DATE, SETT_PER ) as end_dttm FROM SP_BID_OFFER
  WHERE SETT_DATE >= pi_effective and SETT_DATE <= trunc(last_day(pi_effective)+1)-1/(24*60*60) ) S1
  ON(S2.SETT_DATE=S1.SETT_DATE AND S2.ASB_UNIT_CODE=S1.ASB_UNIT_CODE AND S2.SETT_PER=S1.SETT_PER AND S2.BO_PAIR=S1.BO_PAIR)
  WHEN MATCHED THEN
  UPDATE SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR,BID_PRICE=S1.BID_PRICE,OFFER_PRICE=S1.OFFER_PRICE,BO_LEVEL=S1.BO_LEVEL,BID_VOLUME=S1.BID_VOLUME,
             OFFER_VOLUME=S1.OFFER_VOLUME ,START_DTTM=s1.end_dttm-interval '30' minute,END_DTTM=s1.end_dttm
    WHERE (NVL(S2.BID_PRICE,'checknull')<>NVL(S1.BID_PRICE,'checknull')) or
           (NVL(S2.OFFER_PRICE,'checknull')<>NVL(S1.OFFER_PRICE,'checknull')) or
           (NVL(S2.BO_LEVEL,'checknull')<>NVL(S1.BO_LEVEL,'checknull')) or
           (NVL(S2.BID_VOLUME,'checknull')<>NVL(S1.BID_VOLUME,'checknull')) or
           (NVL(S2.OFFER_VOLUME,'checknull')<>NVL(S1.OFFER_VOLUME,'checknull'))
  WHEN NOT MATCHED THEN
  INSERT(LOAD_SEQ_NBR,ASB_UNIT_CODE,SETT_DATE,SETT_PER,BO_PAIR,BID_PRICE,OFFER_PRICE,BO_LEVEL,BID_VOLUME,OFFER_VOLUME,START_DTTM,END_DTTM,DATE_CREATED)
  VALUES(PI_LOAD_SEQ_NBR,S1.ASB_UNIT_CODE,S1.SETT_DATE,S1.SETT_PER,S1.BO_PAIR,S1.BID_PRICE,S1.OFFER_PRICE,S1.BO_LEVEL,S1.BID_VOLUME,S1.OFFER_VOLUME,s1.end_dttm-interval '30' minute,
   s1.end_dttm,SYSDATE);
   */
   
   delete from SP_BID_OFFER_STG;
   commit;
   --EXECUTE IMMEDIATE 'truncate table SP_BID_OFFER_STG';
   INSERT into SP_BID_OFFER_STG (LOAD_SEQ_NBR,ASB_UNIT_CODE,SETT_DATE,SETT_PER,BO_PAIR,BID_PRICE,OFFER_PRICE,BO_LEVEL,BID_VOLUME,OFFER_VOLUME,
      START_DTTM,END_DTTM,DATE_CREATED)
      SELECT PI_LOAD_SEQ_NBR,ASB_UNIT_CODE,SETT_DATE,SETT_PER,BO_PAIR,BID_PRICE,OFFER_PRICE,BO_LEVEL,BID_VOLUME,OFFER_VOLUME,
      fn_get_gmt( SETT_DATE, SETT_PER ) -interval '30' minute,
      fn_get_gmt( SETT_DATE, SETT_PER ) as END_DTTM,
      sysdate as DATE_CREATED
      FROM SP_BID_OFFER
      WHERE SETT_DATE >= pi_effective and SETT_DATE <=  trunc(last_day(pi_effective)+1)-1/(24*60*60);
  
    

   PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BID_OFFER',pi_load_seq_nbr,'SUCCESS','All the new records pushed to SP_BID_OFFER_STG table sucessfully!!!');
   --Exceptions
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BID_OFFER',pi_load_seq_nbr,'SUCCESS',SQLERRM);
    WHEN OTHERS THEN
         PR_PROCESS_LOG('PR_ASB_LOAD_OPR_BID_OFFER',PI_LOAD_SEQ_NBR,'FAILURE', SQLERRM);
END PR_ASB_LOAD_OPR_BID_OFFER;

/

