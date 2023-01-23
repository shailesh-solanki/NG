--------------------------------------------------------
--  DDL for Procedure PR_MSM1_INDEX_RATE_BKP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_INDEX_RATE_BKP" 
(
    PI_LOAD_SEQ_NBR IN NUMBER
)
/**************************************************************************************
*
* Program Name           :PR_MSM1_INDEX_RATE
* Author                 :Anish Kumar S
* Creation Date          :12-10-2021
* Description            :This is a PL/SQL procedure. This procedure will migrate data from ASB_STG Table ( ASB_INDEX_RATE_STG) to MSM_STG1
                           (D1_FACTOR_VALUE and D1_US_FACTOR_OVRD ) table
* Calling Program        :None
* Called Program         :
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  12-10-2021     Anish Kumar S   Changes for INDEX RATE Data
**************************************************************************************/
AS
v_us_id number;
v_error varchar2(1000);

lv_load_seq_nbr number;
lv_load_sequ_nbr number;

CURSOR IDX_RATE IS

     SELECT
         B.CONTRACT_SEQ,B.EFFECTIVE, B.INDEX_RATE,
             B.FACTOR_CD,
         fn_convert_gmt_bst1(LEAD(EFFECTIVE) OVER ( PARTITION BY ASB_PAYEE_CODE, ASB_UNIT_CODE, PAY_CODE, SERVICE_CODE ORDER BY EFFECTIVE, ASB_PAYEE_CODE, ASB_UNIT_CODE, PAY_CODE, SERVICE_CODE )) END_DATE
     FROM
           (
             SELECT DISTINCT C.CONTRACT_SEQ, a.*,
             CASE
                WHEN A.SERVICE_CODE='SRBM' AND A.PAY_CODE='SRBA' THEN 'SRP_STOR_AVAIL_INDEXRATE'
                WHEN A.SERVICE_CODE='SRNM' AND A.PAY_CODE='SRNA' THEN 'SRP_STOR_AVAIL_INDEXRATE'

                WHEN A.SERVICE_CODE='SRBM' AND A.PAY_CODE='SRBU' THEN 'SRP_STOR_UTIL_INDEXRATE'
                WHEN A.SERVICE_CODE='SRNM' AND A.PAY_CODE='SRNU' THEN 'SRP_STOR_UTIL_INDEXRATE'

                WHEN A.SERVICE_CODE='SRBM' AND A.PAY_CODE='SRBP' THEN 'SRP_STOR_PUTIL_INDEXRATE'
                WHEN A.SERVICE_CODE='SRNM' AND A.PAY_CODE='SRNP' THEN 'SRP_STOR_PUTIL_INDEXRATE'

            END FACTOR_CD
              FROM
             ASB_INDEX_RATE_STG A,ASB_RESOURCE_SELECTION_STG B,ASB_CONTRACT_SERVICE_STG C,SRS_SUPPLIER_STG D

             WHERE A.ASB_PAYEE_CODE=b.asb_comp_code AND
                   B.CONTRACT_SEQ=C.CONTRACT_SEQ AND
                   a.asb_unit_code=d.asb_unit_code AND
                   C.CONTRACT_SEQ=D.CONTRACT_SEQ AND
                   A.INDEX_RATE<>1 and
                   A.EFFECTIVE+interval '1' minute BETWEEN C.CONTRACT_START AND nvl(C.CONTRACT_END,sysdate) AND
                   A.PAY_CODE IN ('SRBA','SRNA','SRBU','SRNU','SRBP','SRNP')
                ) B
                where factor_cd is not null
                
           and                  LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR
                  ;

BEGIN

--D1_FACTOR_VALUE (AVAILABILITY) Migration
   INSERT INTO MSM_STG1.D1_FACTOR_VALUE_INDEX_RATE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
   SELECT DISTINCT PI_LOAD_SEQ_NBR, 'SRP_STOR_PUTIL_INDEXRATE', 'CM-NA', 'NA', TO_DATE('01-04-2000 00:00:00','DD-MM-YYYY HH24:MI:SS'), 'D1-FactorValueNumber', INDEX_RATE, ' ', ' ', '99', ' ', ' ', SYSDATE
          FROM ASB_INDEX_RATE_STG A
          WHERE A.INDEX_RATE = 1 AND
                PAY_CODE IN ('SRBP','SRNP') AND
                LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

--D1_FACTOR_VALUE (UTILIZATION) Migration
    INSERT INTO MSM_STG1.D1_FACTOR_VALUE_INDEX_RATE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
    SELECT DISTINCT PI_LOAD_SEQ_NBR, 'SRP_STOR_AVAIL_INDEXRATE', 'CM-NA', 'NA', TO_DATE('01-04-2000 00:00:00','DD-MM-YYYY HH24:MI:SS'), 'D1-FactorValueNumber', INDEX_RATE, ' ', ' ', '99', ' ', ' ', SYSDATE
        FROM ASB_INDEX_RATE_STG A
       WHERE A.INDEX_RATE = 1
            AND PAY_CODE IN ('SRBA','SRNA')
            AND  LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR  ;
--D1_FACTOR_VALUE (P UTILIZATION) Migration
    INSERT INTO MSM_STG1.D1_FACTOR_VALUE_INDEX_RATE(LOAD_SEQ_NBR,FACTOR_CD,FACTOR_CHAR_TYPE_CD,FACTOR_CHAR_VAL,EFF_DTTM,BUS_OBJ_CD,NUM_VAL,VEE_GRP_CD,MEASR_COMP_ID,VERSION,D1_ID_TYPE_FLG,ID_VALUE,DATE_CREATED)
    SELECT DISTINCT PI_LOAD_SEQ_NBR, 'SRP_STOR_UTIL_INDEXRATE','CM-NA', 'NA', TO_DATE('01-04-2000 00:00:00','DD-MM-YYYY HH24:MI:SS'), 'D1-FactorValueNumber', INDEX_RATE, ' ', ' ', '99', ' ', ' ', SYSDATE
       FROM ASB_INDEX_RATE_STG A
       WHERE A.INDEX_RATE = 1
            AND PAY_CODE IN ('SRBU','SRNU')
            AND  LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

--   D1_US_FACTOR_OVRD (AVAILABILITY) Table Migration
   FOR AVAIL IN IDX_RATE
    LOOP
    select us_id into v_us_id from connect_us_sa_id where contract_seq=AVAIL.contract_seq;

     INSERT INTO MSM_STG1.D1_US_FACTOR_OVRD_INDEX_RATE(LOAD_SEQ_NBR, US_ID, FACTOR_CD, START_DTTM, END_DTTM, VALUE, VERSION, DATE_CREATED)
     VALUES(PI_LOAD_SEQ_NBR, v_US_ID, AVAIL.FACTOR_CD, fn_convert_gmt_bst1(AVAIL.EFFECTIVE), AVAIL.END_DATE,AVAIL.INDEX_RATE, '99', SYSDATE);


      END LOOP;


    -- Added for Reduction Percentage

    SELECT DISTINCT  LOAD_SEQ_NBR INTO LV_LOAD_SEQ_NBR FROM SRS_CONTRACT_FACTOR_STG WHERE ROWNUM<=1;

    IF PI_LOAD_SEQ_NBR = LV_LOAD_SEQ_NBR   THEN
        LV_LOAD_SEQU_NBR := PI_LOAD_SEQ_NBR;
    ELSE
        LV_LOAD_SEQU_NBR := LV_LOAD_SEQ_NBR;
    END IF;

    FOR REC IN ( select distinct contract_seq from srs_contract_factor_stg where load_seq_nbr = lv_load_sequ_nbr )
    LOOP
        INSERT INTO MSM_STG1.D1_US_FACTOR_OVRD_INDEX_RATE
            (
                LOAD_SEQ_NBR, US_ID, FACTOR_CD, START_DTTM,
                END_DTTM,
                VALUE,VERSION,DATE_CREATED
            )
        SELECT
            PI_LOAD_SEQ_NBR, CUS.US_ID, 'SRP_STOR_AVAIL_REDUCTIONPER', FN_CONVERT_GMT_BST1(SCF.EFFECTIVE),
            LEAD(FN_CONVERT_GMT_BST1(SCF.EFFECTIVE)) OVER(PARTITION BY SCF.CONTRACT_SEQ ORDER BY SCF.CONTRACT_SEQ,SCF.EFFECTIVE)AS END_DTTM,
            AVAIL_REDUCTION, 99, SYSDATE
        FROM
            SRS_CONTRACT_FACTOR_STG SCF, CONNECT_US_SA_ID CUS
        WHERE
            CUS.CONTRACT_SEQ = SCF.CONTRACT_SEQ AND SCF.CONTRACT_SEQ = REC.CONTRACT_SEQ AND SCF.LOAD_SEQ_NBR = lv_load_sequ_nbr  ;
    END LOOP;
    -- Added for Reduction Percentage

EXCEPTION
      WHEN OTHERS THEN
        V_ERROR:=SQLCODE||' '||SUBSTR(SQLERRM,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_INDEX_RATE',PI_LOAD_SEQ_NBR,'FAILURE',V_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_INDEX_RATE_BKP;

/

