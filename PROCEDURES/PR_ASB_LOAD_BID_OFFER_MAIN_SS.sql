--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_BID_OFFER_MAIN_SS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_BID_OFFER_MAIN_SS" (PI_EFFECTIVE IN DATE)
/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_BID_OFFER_MAIN
* Author                 :Shailesh Solanki
* Creation Date          :01-09-21
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(BID OFFER) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         : PR_ASB_LOAD_BID_OFFER_MAIN.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  27-05-2021     Shailesh Solanki   Changes for Operational Data (MNZT)
**************************************************************************************/
AS

lv_vc_load_seq_nbr NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

  --MSM_STG2.PR_TRUNCATE_TABLE_MSMSTG2('D1_SP_QTY_BID_OFFER');
  --MSM_STG2.PR_TRUNCATE_TABLE_MSMSTG2('D1_SP_QTY_BID_OFFER_LOG');

  SELECT SQ_BID_OFFER_LOAD_SEQNO.nextval into lv_vc_load_seq_nbr from dual;

  -- Insert a row in LOAD_DETAILS Table for new load_sequence
  INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_BID_OFFER_MAIN',NULL,NULL,SYSDATE);

  PR_PROCESS_LOG('PR_ASB_LOAD_BID_OFFER_MAIN',lv_vc_load_seq_nbr,'Start...', 'operational data(BID OFFER) loading  process start');

  PR_ASB_LOAD_OPR_BID_OFFER (lv_vc_load_seq_nbr,PI_EFFECTIVE );

 /* PR_MSM1_OPR_BID_OFFER_SS (lv_vc_load_seq_nbr,1,'SPBIDOFFPAIR1');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  /*PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,2,'SPBIDOFFPAIR2');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,3,'SPBIDOFFPAIR3');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,4,'SPBIDOFFPAIR4');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);*/

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  --PR_MSM1_OPR_BID_OFFER_SS (lv_vc_load_seq_nbr,5,'SPBIDOFFPAIR5');
  --MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER_SS (lv_vc_load_seq_nbr,-1,'SPBIDOFFPAIR-1');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

 /* PR_MSM1_OPR_BID_OFFER_SS (lv_vc_load_seq_nbr,-2,'SPBIDOFFPAIR-2');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,-3,'SPBIDOFFPAIR-3');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,-4,'SPBIDOFFPAIR-4');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);

  -- MSM_STG2.PR_BID_OFFER_STAGING_TRN;

  PR_MSM1_OPR_BID_OFFER (lv_vc_load_seq_nbr,-5,'SPBIDOFFPAIR-5');
  MSM_STG1.PR_MSM1_TO_MSM2_OPR_BID_OFF(lv_vc_load_seq_nbr);*/
  COMMIT;
  MSM_STG2.PR_BID_OFFER_STAGING_TRN(lv_vc_load_seq_nbr);



 select max(proc_seq_nbr) into v_proc_seq_nbr from process_log where proc_name = 'PR_ASB_LOAD_BID_OFFER_MAIN' and load_seq_nbr = lv_vc_load_seq_nbr;
 INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_BID_OFFER_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'BID_OFFER');

  EXCEPTION
    WHEN OTHERS then
    v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
    ROLLBACK;
    PR_PROCESS_LOG('PR_ASB_LOAD_BID_OFFER_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR);


END PR_ASB_LOAD_BID_OFFER_MAIN_SS;

/

