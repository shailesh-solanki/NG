--------------------------------------------------------
--  DDL for Procedure PR_MSMSTG1_LOAD_OWNER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSMSTG1_LOAD_OWNER" 
/**************************************************************************************
*
* Program Name           :PR_MSMSTG1_LOAD_OWNER
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-03-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M table's
*                         format and tranfer data from ASB_STG to MSM_STG1 Tables for OWNER entity(ASB)
*
*
* Calling Program        :PR_ASB_LOAD_OWNER_MAIN
* Called Program         :
*
*
* Input files            :None
* Output Tables          : D1_SP_MKT_PARTICIPANT    D1_MKT_FALLBACK_SPR
*                          D1_MKT_ALID_SPR
* Input Parameter        :Load sequence number
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(p_LOAD_SEQ_NBR IN NUMBER) as

v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);

v_CHK NUMBER :=0;
v_PREM_ID NUMBER;
v_D1_SP_ID NUMBER;
v_CNT NUMBER;

CURSOR CUR_OWNER IS
SELECT distinct t.* from TRN_OWNER t  where t.load_seq_nbr = p_LOAD_SEQ_NBR ;

CURSOR CUR_OWNER_COMP_CODE IS
SELECT T.COMPANY_CODE, MIN(T.OWNED_EFF_START_DT) as OLDEST_EFF_STDT from TRN_OWNER t  where t.load_seq_nbr = p_LOAD_SEQ_NBR group by T.COMPANY_CODE;

BEGIN

   FOR rec in cur_OWNER
   LOOP
          v_CNT := 0;
          select count(1) into v_CNT from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = rec.RESOURCE_CODE AND SP_ID_TYPE_FLG = 'D1MI';

          IF (v_CNT > 0) THEN
              select max(D1_SP_ID) into v_D1_SP_ID from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = rec.RESOURCE_CODE AND SP_ID_TYPE_FLG = 'D1MI';

              ------------ Load data in Table MSM_STG1.D1_SP_MKT_PARTICIPANT ---------------
              IF (REC.OWNED_EFF_START_DT IS NOT NULL) THEN
                INSERT INTO MSM_STG1.D1_SP_MKT_PARTICIPANT VALUES(P_LOAD_SEQ_NBR,v_D1_SP_ID ,'OWNR', REC.COMPANY_CODE, REC.OWNED_EFF_START_DT, REC.OWNED_EFF_END_DT,99, SYSDATE);
              END IF;

              IF (REC.PAYMENT_EFF_START_DT IS NOT NULL) THEN
                INSERT INTO MSM_STG1.D1_SP_MKT_PARTICIPANT VALUES(P_LOAD_SEQ_NBR,v_D1_SP_ID ,REC.TYPE, REC.COMPANY_CODE, REC.PAYMENT_EFF_START_DT, REC.PAYMENT_EFF_END_DT,99, SYSDATE);
              END IF;
          END IF;
   END LOOP;

   FOR REC IN CUR_OWNER_COMP_CODE
   LOOP
      INSERT INTO MSM_STG1.D1_MKT_VALID_SPR VALUES(P_LOAD_SEQ_NBR,'ANCILLARY' ,'OWNR', REC.COMPANY_CODE,99, REC.OLDEST_EFF_STDT,NULL, SYSDATE);
      INSERT INTO MSM_STG1.D1_MKT_FALLBACK_SPR VALUES(P_LOAD_SEQ_NBR,'ANCILLARY' ,'OWNR', REC.COMPANY_CODE,99, REC.OLDEST_EFF_STDT,NULL, SYSDATE);
   END LOOP;

   ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_OWNER',p_LOAD_SEQ_NBR,'SUCCESS','Data transfer successful from ASB_STG to MSM_STG1 for OWNER','OWNER');

    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_OWNER',p_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'OWNER');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
        RAISE;

END PR_MSMSTG1_LOAD_OWNER;

/

