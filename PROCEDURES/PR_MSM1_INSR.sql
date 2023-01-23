--------------------------------------------------------
--  DDL for Procedure PR_MSM1_INSR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_INSR" (PI_LOAD_SEQ_NBR IN NUMBER) AS
/**************************************************************************************
*
* Program Name           :PR_MSM1_INSR
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :20-09-2021
* Description            :This is a PL/SQL procedure. This procedure calls other procedures populate the records
                          into D1_US_QTY, D1_US_QTY_LOG, D1_DYN_OPT_EVENT D1_DYN_OPT_EVENT_LOG, D1_DYN_OPT_EVENT_LOG_PARAM(MSM_STG1).
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_INSR_MAIN
*
*
* Input files            :None
* Output files           :None
* Input Parameter        :PI_LOAD_SEQ_NBR
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/

lv_vc_current_gmt date;
lv_vc_seqno number(2,0);
v_ERROR VARCHAR2(1000);
v_END_DATE DATE;

type contract_date is record(
contract_seq srd_instruction_stg.contract_seq%type,
insr_start srd_instruction_stg.insr_start%type);

type contract_info is table of contract_date;
lv_vc_contract contract_info;

cursor cur_us_log(pi_start_dt date,pi_contract_seq varchar2) is
select distinct duq.d1_us_qty_id,sis.insr_end
    from msm_stg1.d1_us_qty_instr duq , srd_instruction_stg sis
    where duq.us_id = pi_contract_seq
    and duq.start_dttm = sis.insr_start
    and duq.start_dttm = pi_start_dt
    and sis.status = 2
    and sis.insr_end <> duq.end_dttm
    and duq.load_seq_nbr = PI_LOAD_SEQ_NBR;

BEGIN

    select fn_convert_bst_gmt(sysdate) into lv_vc_current_gmt from dual;
    dbms_output.put_line('D1_US_QTY_INSTR = '||sysdate);
    --------D1_US_QTY_INSTR--------
    INSERT INTO  MSM_STG1.D1_US_QTY_INSTR(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
    select PI_LOAD_SEQ_NBR,/*nvl((select max(duq.d1_us_qty_id)
                    from  srd_instruction_stg sis, msm_stg1.d1_us_qty_instr duq
                    where  sis.contract_seq = duq.us_id
                    and duq.start_dttm = sis.insr_start
                    and duq.end_dttm = sis.insr_end),SQ_CONTRACT_D1_US_QTY_ID.nextval)*/SQ_CONTRACT_D1_US_QTY_ID.nextval,
    sis.contract_seq,'STOR_INSTRUCTION',sis.insr_start,sis.insr_end,'D1AC','CM-STORINSTUSQNTY',' ',lv_vc_current_gmt,lv_vc_current_gmt,
    '<BO_XML_DATA_AREA><issueDateTime>'||to_char(sis.insr_issue,'YYYY-MM-DD-HH24.MI.SS')||'</issueDateTime></BO_XML_DATA_AREA>'
    ,99,sis.op_level,sis.status,0,0,0,sysdate from srd_instruction_stg sis
    where sis.status in (0,1)
    and sis.load_seq_nbr =  PI_LOAD_SEQ_NBR;

    INSERT INTO  MSM_STG1.D1_US_QTY_INSTR(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,
              BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
    select PI_LOAD_SEQ_NBR,/*nvl((select max(duq.d1_us_qty_id)
                    from  srd_instruction_stg sis, msm_stg1.d1_us_qty_instr duq
                    where  sis.contract_seq = duq.us_id
                    and duq.start_dttm = sis.insr_start
                    and duq.end_dttm = sis.insr_end),SQ_CONTRACT_D1_US_QTY_ID.nextval)*/SQ_CONTRACT_D1_US_QTY_ID.nextval,
    a.contract_seq,'STOR_INSTRUCTION',a.insr_start,a.end_dt,'D1AC','CM-STORINSTUSQNTY',' ',lv_vc_current_gmt,lv_vc_current_gmt,
    '<BO_XML_DATA_AREA><issueDateTime>'||to_char(sis.insr_issue,'YYYY-MM-DD-HH24.MI.SS')||'</issueDateTime></BO_XML_DATA_AREA>'
    ,99,sis.op_level,sis.status,0,0,0,sysdate from srd_instruction_stg sis,
    (select contract_seq,insr_start,min(insr_end) end_dt,status from srd_instruction_stg where status = 2 group by contract_seq,insr_start,status) a
    where a.contract_seq=sis.contract_seq
    and a.insr_start=sis.insr_start
    and a.end_dt = sis.insr_end
    and sis.status = 2
    and sis.load_seq_nbr =  PI_LOAD_SEQ_NBR;
    dbms_output.put_line('D1_US_QTY_LOG_INSTR = '||sysdate);

    ---------D1_US_QTY_LOG_INSTR-------------
    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_INSTR(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
            select PI_LOAD_SEQ_NBR,duq.d1_us_qty_id,1,sysdate,'F1CR','','','',11002,12151,'','','','','','','','','MIGD',99,sysdate
            from msm_stg1.d1_us_qty_instr duq
            where duq.load_seq_nbr = PI_LOAD_SEQ_NBR;

    INSERT INTO  MSM_STG1.D1_US_QTY_LOG_INSTR(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
    select PI_LOAD_SEQ_NBR,duq.d1_us_qty_id,2,sysdate,'F1US','User Details','','',0,0,'CM-LFLNM','',to_char(sis.file_date,'YYYY-MM-DD'),'','','','','','MIGD',99,sysdate
    from msm_stg1.d1_us_qty_instr duq , srd_instruction_stg sis
    where sis.contract_seq = duq.us_id
    and duq.start_dttm = sis.insr_start
    and duq.end_dttm = sis.insr_end
    and duq.load_seq_nbr = PI_LOAD_SEQ_NBR;



    select distinct contract_seq,insr_start bulk collect into lv_vc_contract
    from msm_stg1.d1_us_qty_instr duq , srd_instruction_stg sis
    where duq.us_id = sis.contract_seq
    and duq.start_dttm = sis.insr_start
    and sis.status = 2
    and duq.load_seq_nbr = PI_LOAD_SEQ_NBR;

    if lv_vc_contract.count>0 then
        for c in 1..lv_vc_contract.count
        loop
            lv_vc_seqno := 2;
            for rec in cur_us_log(lv_vc_contract(c).insr_start,lv_vc_contract(c).contract_seq)
            loop
                lv_vc_seqno := lv_vc_seqno+1;
                INSERT INTO  MSM_STG1.D1_US_QTY_LOG_INSTR(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
                        MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
                values( PI_LOAD_SEQ_NBR,rec.d1_us_qty_id,lv_vc_seqno,sysdate,'F1US','User Details','','',0,0,'CM-CEADT','',to_char(rec.insr_end,'YYYY-MM-DD-HH24.MI.SS'),'','','','','','MIGD',99,sysdate);
            end loop;
        end loop;
    end if;

 EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        PR_PROCESS_LOG('PR_MSM1_INSR'  ,pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
END PR_MSM1_INSR;

/

