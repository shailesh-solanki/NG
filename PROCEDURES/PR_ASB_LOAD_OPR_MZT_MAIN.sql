--------------------------------------------------------
--  DDL for Procedure PR_ASB_LOAD_OPR_MZT_MAIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_LOAD_OPR_MZT_MAIN" (pi_load_seq_nbr NUMBER,PI_EFFECTIVE IN DATE,PI_END_DATE IN DATE)


/**************************************************************************************
*
* Program Name           :PR_ASB_LOAD_OPR_MZT_MAIN 
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :27-03-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures
*                         which are using to migrate Operational data(MZT) from ASB legacy system to C2M system.
*
* Calling Program        :None
* Called Program         :  ASB_LOAD_OPR_Main.ksh
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>

**************************************************************************************/
AS

lv_vc_load_seq_nbr  NUMBER(10);
v_ERROR varchar2(1000);
v_proc_seq_nbr number;

BEGIN

         lv_vc_load_seq_nbr := pi_load_seq_nbr;

        -- Insert a row in LOAD_DETAILS Table for new load_sequence
        INSERT INTO LOAD_DETAILS (LOAD_SEQ_NBR,LOAD_DESC,REC_PROCESSED,REC_REJECTED,DATE_CREATED) VALUES (lv_vc_load_seq_nbr,'PR_ASB_LOAD_OPR_MZT_MAIN',NULL,NULL,SYSDATE);

                  PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_MZT_MAIN',lv_vc_load_seq_nbr,'Start...', 'Operational Data(MZT)loading  process start','MZT');

--                 PR_ASB_LOAD_OPR_MZT(lv_vc_load_seq_nbr,PI_EFFECTIVE,PI_END_DATE);

                 PR_MSM1_OPR_MZT(lv_vc_load_seq_nbr);

                MSM_STG1.PR_MSM1_TO_MSM2_OPR_MZT(lv_vc_load_seq_nbr);

       SELECT MAX(PROC_SEQ_NBR) INTO V_PROC_SEQ_NBR FROM PROCESS_LOG WHERE PROC_NAME = 'PR_ASB_LOAD_OPR_MZT_MAIN' AND LOAD_SEQ_NBR = LV_VC_LOAD_SEQ_NBR;
       INSERT INTO PROCESS_LOG VALUES(v_proc_seq_nbr,'PR_ASB_LOAD_OPR_MZT_MAIN',lv_vc_load_seq_nbr,'SUCCESS', 'All the process executed successfully',SYSDATE,'MZT');

  EXCEPTION
         WHEN OTHERS then
         v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
     ROLLBACK;
       PROC_PROCESS_LOG('PR_ASB_LOAD_OPR_MZT_MAIN',lv_vc_load_seq_nbr,'FAILURE', v_ERROR,'MZT');

END PR_ASB_LOAD_OPR_MZT_MAIN;

/
