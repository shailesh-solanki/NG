--------------------------------------------------------
--  DDL for Procedure PR_MSM1_INDEX_RATE_NGPS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_INDEX_RATE_NGPS" 
(
    PI_LOAD_SEQ_NBR IN NUMBER
)
/**************************************************************************************
*
* Program Name           :PR_MSM1_INDEX_RATE
* Author                 :Anish Kumar S
* Creation Date          :12-10-2021
* Description            :This is a PL/SQL procedure. This procedure will migrate data 
*                         from ASB_STG Table ( ASB_INDEX_RATE_STG) to MSM_STG1
*                           (D1_FACTOR_VALUE and D1_US_FACTOR_OVRD ) table
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*  12-10-2021     Anish Kumar S   Changes for INDEX RATE Data
**************************************************************************************/
AS
v_us_id number;
v_error varchar2(1000);

lv_load_seq_nbr number;
lv_load_sequ_nbr number;

CURSOR IDX_RATE IS
    select * from (
select distinct c.load_seq_nbr,a.contract_seq,a.contract_start as effective,c.index_rate,a.contract_end as END_DATE,
CASE
                WHEN c.SERVICE_CODE='SRBM' AND c.PAY_CODE='SRBA' THEN 'SRP_STOR_AVAIL_INDEXRATE'
                WHEN c.SERVICE_CODE='SRNM' AND c.PAY_CODE='SRNA' THEN 'SRP_STOR_AVAIL_INDEXRATE'
                WHEN c.SERVICE_CODE='SRBM' AND c.PAY_CODE='SRBU' THEN 'SRP_STOR_UTIL_INDEXRATE'
                WHEN c.SERVICE_CODE='SRNM' AND c.PAY_CODE='SRNU' THEN 'SRP_STOR_UTIL_INDEXRATE'
                WHEN c.SERVICE_CODE='SRBM' AND c.PAY_CODE='SRBP' THEN 'SRP_STOR_PUTIL_INDEXRATE'
                WHEN c.SERVICE_CODE='SRNM' AND c.PAY_CODE='SRNP' THEN 'SRP_STOR_PUTIL_INDEXRATE'
            END FACTOR_CD
from asb_contract_service_ngps a,srs_supplier_stg b,connect_us_sa_id_ngps e,
(select load_seq_nbr,effective,asb_unit_code,pay_code,service_code,index_rate,
lead(effective) over (partition by asb_unit_code,service_code,pay_code order by effective,asb_unit_code,service_code,pay_code desc) 
as end_effective from asb_index_rate_stg) c,asb_index_rate_stg d
where a.contract_start >= c.effective and contract_start < nvl(c.end_effective,sysdate)
and c.effective = d.effective
and c.asb_unit_code = d.asb_unit_code
and c.pay_code = d.pay_code
and c.asb_unit_code = b.asb_unit_code
and b.contract_seq = a.contract_seq
and b.contract_seq = e.contract_seq
and c.INDEX_RATE<>1 
and c.PAY_CODE IN ('SRBA','SRNA','SRBU','SRNU','SRBP','SRNP'))
where factor_cd is not null

           and                  LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;


BEGIN

--   D1_US_FACTOR_OVRD  Table Migration
   FOR AVAIL IN IDX_RATE
    LOOP
    select us_id into v_us_id from CONNECT_US_SA_ID_NGPS where contract_seq=AVAIL.contract_seq;

     INSERT INTO MSM_STG1.D1_US_FACTOR_OVRD_INDEX_RATE(LOAD_SEQ_NBR, US_ID, FACTOR_CD, START_DTTM, END_DTTM, VALUE, VERSION, DATE_CREATED)
     VALUES(pi_load_seq_nbr, v_US_ID, AVAIL.FACTOR_CD, fn_convert_gmt_bst1(AVAIL.EFFECTIVE), AVAIL.END_DATE,AVAIL.INDEX_RATE, '99', SYSDATE);


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
            SRS_CONTRACT_FACTOR_STG SCF, CONNECT_US_SA_ID_NGPS CUS
        WHERE
            CUS.CONTRACT_SEQ = SCF.CONTRACT_SEQ AND SCF.CONTRACT_SEQ = REC.CONTRACT_SEQ AND SCF.LOAD_SEQ_NBR = lv_load_sequ_nbr  ;
    END LOOP;
    -- Added for Reduction Percentage 

EXCEPTION
      WHEN OTHERS THEN
        V_ERROR:=SQLCODE||' '||SUBSTR(SQLERRM,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_INDEX_RATE',PI_LOAD_SEQ_NBR,'FAILURE',V_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_INDEX_RATE_NGPS;

/

