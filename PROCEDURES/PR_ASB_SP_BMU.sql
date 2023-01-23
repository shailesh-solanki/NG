--------------------------------------------------------
--  DDL for Procedure PR_ASB_SP_BMU
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_SP_BMU" 
(
    PI_LOAD_SEQ_NBR IN NUMBER,
    PI_EFFECTIVE IN DATE
)
/**************************************************************************************
*
* Program Name           :PR_ASB_SP_BMU
* Author                 :IBM(Anish Kumar S)
* Creation Date          :23-08-2021
* Description            :This is a PL/SQL procedure. This procedure loads data from SP_BMU table of ASB legacy system 
*                         and loads into SP_BMU_STG table.
*
* Calling Program        :None
* Called Program         : PR_ASB_SP_BMU_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :load sequence number
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
* 
**************************************************************************************/
AS 

--variable bst_time varchar2(30);


BEGIN
    MERGE INTO SP_BMU_STG S2
    USING ( SELECT SB.*,fn_get_gmt(SB.SETT_DATE,SB.SETT_PER) as gmt_time FROM SP_BMU SB WHERE SETT_DATE between pi_effective and trunc(last_day(pi_effective)+1)-1/(24*60*60)) S1 
    ON(S2.SETT_DATE = S1.SETT_DATE AND S2.ASB_UNIT_CODE = S1.ASB_UNIT_CODE AND S2.SETT_PER = S1.SETT_PER)
    WHEN MATCHED THEN 
        UPDATE 
            SET LOAD_SEQ_NBR=PI_LOAD_SEQ_NBR, S2.FPN_VOLUME = S1.FPN_VOLUME, S2.BO_VOLUME = S1.BO_VOLUME, S2.EXPECTED_VOLUME = S1.EXPECTED_VOLUME, 
                S2.METERED_VOLUME = S1.METERED_VOLUME, S2.IMBALANCE_VOLUME = S1.IMBALANCE_VOLUME, S2.TLM_SCALAR = S1.TLM_SCALAR, S2.ND_CHARGE = S1.ND_CHARGE
            WHERE S2.FPN_VOLUME <> S1.FPN_VOLUME OR S2.BO_VOLUME <> S1.BO_VOLUME OR S2.EXPECTED_VOLUME <> S1.EXPECTED_VOLUME OR 
                S2.METERED_VOLUME <> S1.METERED_VOLUME OR S2.IMBALANCE_VOLUME <> S1.IMBALANCE_VOLUME OR S2.TLM_SCALAR <> S1.TLM_SCALAR OR S2.ND_CHARGE <> S1.ND_CHARGE
    WHEN NOT MATCHED THEN
        INSERT ( LOAD_SEQ_NBR, ASB_UNIT_CODE, SETT_DATE, SETT_PER, FPN_VOLUME, BO_VOLUME, EXPECTED_VOLUME, 
            METERED_VOLUME, IMBALANCE_VOLUME, TLM_SCALAR, ND_CHARGE,SETT_GMT_TIME,SETT_BST_TIME, DATE_CREATED )
        VALUES ( PI_LOAD_SEQ_NBR, S1.ASB_UNIT_CODE, S1.SETT_DATE, S1.SETT_PER, S1.FPN_VOLUME, S1.BO_VOLUME, S1.EXPECTED_VOLUME, 
            S1.METERED_VOLUME, S1.IMBALANCE_VOLUME, S1.TLM_SCALAR, S1.ND_CHARGE,S1.gmt_time,fn_convert_gmt_bst1(S1.gmt_time), SYSDATE );

    ASB_STG.PROC_PROCESS_LOG('PR_ASB_SP_BMU ',pi_load_seq_nbr,'SUCCESS','Data Migrated sucessfully from legacy (SP_BMU) to ASB_STG (SP_BMU_STG) schema!!!','VOLUME');

EXCEPTION 

    WHEN OTHERS THEN   
        ASB_STG.PROC_PROCESS_LOG('PR_ASB_SP_BMU ',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating data from legacy (SP_BMU) to ASB_STG (SP_BMU_STG) schema','VOLUME');

END PR_ASB_SP_BMU;

/

