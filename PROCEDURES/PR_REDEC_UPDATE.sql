--------------------------------------------------------
--  DDL for Procedure PR_REDEC_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_REDEC_UPDATE" (PI_LOAD_SEQ_NBR IN NUMBER) AS 

v_LOAD_SEQ_NBR NUMBER;
v_CNT NUMBER;
v_US_ID NUMBER;
v_DYN_OPT_ID NUMBER;
v_D1_US_QTY_ID NUMBER;
v_DYN_OPT_EVENT_ID NUMBER;
v_ERROR VARCHAR2(1000);
v_cont_seq NUMBER;
val VARCHAR2(1000);
v_REDEC_BO_XML VARCHAR2(5000);
v_AVAIL_LEVEL NUMBER(10,3); 
v_FILE_DATE DATE;
v_START_WINDOW DATE;
v_START_WINDOW_OPT DATE;
v_END_WINDOW DATE;
v_END_WINDOW_OPT DATE;

CURSOR cur_REDEC IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, REDEC_START, REDEC_END, CONTRACT_SEQ, max(REDEC_ISSUE) as latest_issue_date,
CASE WHEN (redec_end - redec_start) >= 0.94 THEN
'AVAILABILITY_REDECLARATION_O'
ELSE
'AVAILABILITY_REDECLARATION_C'
END as D1_US_QTY_TYPE_CD
from srd_redeclaration_stg srd
where srd.load_seq_nbr=pi_load_seq_nbr
AND (redec_end - redec_start) < 0.94
group by ASB_UNIT_CODE, CONTRACT_NUMBER, CONTRACT_SEQ, REDEC_START, REDEC_END;

CURSOR cur_REDEC_BO_XML(p_asb_unit_code VARCHAR2, p_CONTRACT_NUMBER NUMBER, p_redec_start DATE, p_redec_end DATE, p_latest_issue_date DATE) IS 
select ASB_UNIT_CODE, CONTRACT_NUMBER, REDEC_START, REDEC_END, REDEC_ISSUE, AVAIL_LEVEL, FILE_DATE, CONTRACT_SEQ
from srd_redeclaration_stg srd
where srd.load_seq_nbr = pi_load_seq_nbr
AND asb_unit_code = p_asb_unit_code
AND CONTRACT_NUMBER = p_CONTRACT_NUMBER
AND redec_start = p_redec_start
AND redec_end = p_redec_end
;

BEGIN
    FOR rec in cur_REDEC
    LOOP

        select max(AVAIL_LEVEL), max(FILE_DATE) into v_AVAIL_LEVEL,v_FILE_DATE
        from srd_redeclaration_stg srd
        where asb_unit_code = rec.asb_unit_code
        AND CONTRACT_NUMBER = rec.CONTRACT_NUMBER
        AND redec_start = rec.redec_start
        AND redec_end = rec.redec_end
        AND REDEC_ISSUE = rec.latest_issue_date;

        v_REDEC_BO_XML := '<BO_XML_DATA_AREA><reDec>';

        FOR rec_BO in cur_REDEC_BO_XML(rec.asb_unit_code,rec.CONTRACT_NUMBER, rec.redec_start, rec.redec_end,rec.latest_issue_date)
        LOOP

            v_REDEC_BO_XML := v_REDEC_BO_XML || '<reDecList>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<issueDateTime>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || to_char(rec_BO.REDEC_ISSUE,'YYYY-MM-DD-') || to_char(rec_BO.REDEC_ISSUE,'HH24.MI.SS');
            v_REDEC_BO_XML := v_REDEC_BO_XML || '</issueDateTime>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<mw>' || rec_BO.AVAIL_LEVEL || '.00</mw>';
            v_REDEC_BO_XML := v_REDEC_BO_XML || '<fileName>'||to_char(rec_bo.FILE_DATE,'YYYY-MM-DD')||'</fileName></reDecList>';           
        END LOOP;
        v_REDEC_BO_XML := v_REDEC_BO_XML || '</reDec></BO_XML_DATA_AREA>';

--     
insert into redec_update@stg_msm_link_nft (contract_seq,redec_start,redec_end,redec_issue,bo_xml)
values(rec.CONTRACT_SEQ,rec.redec_start,rec.redec_end,rec.latest_issue_date,v_REDEC_BO_XML);
commit;
insert into redec_update@stg_msm_link_uat (contract_seq,redec_start,redec_end,redec_issue,bo_xml)
values(rec.CONTRACT_SEQ,rec.redec_start,rec.redec_end,rec.latest_issue_date,v_REDEC_BO_XML);
commit;
    END LOOP;  

EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PR_PROCESS_LOG('PR_MSM1_REDECLARATION',PI_LOAD_SEQ_NBR,'FAILURE',v_ERROR);

 END PR_REDEC_UPDATE;

/
