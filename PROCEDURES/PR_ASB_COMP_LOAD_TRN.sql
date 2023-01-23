--------------------------------------------------------
--  DDL for Procedure PR_ASB_COMP_LOAD_TRN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_COMP_LOAD_TRN" 
/**************************************************************************************
*
* Program Name           :PR_ASB_COMP_LOAD_TRN2
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :08-03-2021
* Description            :This is a PL/SQL procedure. This procedure takes data
*                         from ASB_CPNY_STG and COMPANY_CSV and loads data into TRN_COMPANY table.
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(pi_load_seq_nbr IN number)
AS

lv_vc_rec_csv_count number;
lv_vc_rec_comp_count number;

BEGIN


  select count(*) into lv_vc_rec_csv_count from company_csv;
  select count(*) into lv_vc_rec_comp_count from asb_cpny_stg where load_seq_nbr = pi_load_seq_nbr;



  if(lv_vc_rec_csv_count > 0) then
  dbms_output.put_line(lv_vc_rec_csv_count);

    MERGE INTO TRN_COMPANY t
        USING (SELECT a.asb_comp_code AS COMP_CODE,a.asb_comp_name,a.reg_comp_name,b.* FROM ASB_CPNY_STG A LEFT OUTER JOIN COMPANY_CSV B ON (A.ASB_COMP_CODE = B.ASB_COMP_CODE)
        WHERE (B.ERROR_CODE not in (99,107) or error_code is null) and (B.LOAD_SEQ_NBR = pi_load_seq_nbr OR A.LOAD_SEQ_NBR = pi_load_seq_nbr)) q
        ON(t.LOAD_SEQ_NBR=pi_load_seq_nbr)
    WHEN MATCHED THEN
    UPDATE SET VENDOR_CODE = q.VENDOR_CODE, VENDOR_CODE_EFFECTIVEDT = q.VENDOR_CODE_EFFECTIVEDT, VAT_PERC = q.VAT_PERC, VAT_PERC_EFFECTIVEDT = q.VAT_PERC_EFFECTIVEDT, VAT_CODE = q.VAT_CODE,
    VAT_CODE_EFFECTIVEDT = q.VAT_CODE_EFFECTIVEDT, INV_RECPT = q.INV_RECPT, INV_ADD1 = q.INV_ADD1,
    INV_ADD2 = q.INV_ADD2, INV_ADD3 = q.INV_ADD3, INV_ADD4 = q.INV_ADD4, INV_ADD5 = q.INV_ADD5, POSTCODE = q.POSTCODE,
    EMAIL_RECPT_NAME = q.EMAIL_RECPT_NAME, EMAIL_RECPT = q.EMAIL_RECPT, ERROR_CODE=q.error_code
    where load_seq_nbr = pi_load_seq_nbr and asb_comp_code = q.asb_comp_code

    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR, ASB_COMP_CODE,ASB_COMP_NAME, REG_COMP_NAME, VENDOR_CODE, VENDOR_CODE_EFFECTIVEDT, VAT_PERC, VAT_PERC_EFFECTIVEDT, VAT_CODE, VAT_CODE_EFFECTIVEDT, INV_RECPT, INV_ADD1,
                INV_ADD2, INV_ADD3, INV_ADD4, INV_ADD5, POSTCODE, EMAIL_RECPT_NAME, EMAIL_RECPT, ERROR_CODE, DATE_CREATED)
        VALUES (pi_load_seq_nbr, q.COMP_CODE, q.ASB_COMP_NAME, q.REG_COMP_NAME, q.VENDOR_CODE, q.VENDOR_CODE_EFFECTIVEDT, q.VAT_PERC, q.VAT_PERC_EFFECTIVEDT, q.VAT_CODE, q.VAT_CODE_EFFECTIVEDT,
                q.INV_RECPT, q.INV_ADD1, q.INV_ADD2, q.INV_ADD3, q.INV_ADD4, q.INV_ADD5, q.POSTCODE, q.EMAIL_RECPT_NAME, q.EMAIL_RECPT, q.error_code,sysdate);
  end if;

  if(lv_vc_rec_comp_count > 0 and lv_vc_rec_csv_count = 0) then
    INSERT INTO TRN_COMPANY (LOAD_SEQ_NBR, ASB_COMP_CODE,ASB_COMP_NAME, REG_COMP_NAME, DATE_CREATED)
    (SELECT pi_load_seq_nbr, A.ASB_COMP_CODE, a.asb_comp_name,a.reg_comp_name,SYSDATE from ASB_CPNY_STG a where a.load_seq_nbr = pi_load_seq_nbr);
  end if;

    PROC_PROCESS_LOG('PR_ASB_COMP_LOAD_TRN',pi_load_seq_nbr,'SUCCESS','ASB_CPNY_STG and COMPANY_CSV merged sucessfully.','COMPANY');

EXCEPTION 

    WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_LOAD_TRN',pi_load_seq_nbr,'FAILURE','No new data found for sequence number '||pi_load_seq_nbr,'COMPANY');
    WHEN OTHERS THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_LOAD_TRN',pi_load_seq_nbr,'FAILURE',SQLERRM,'COMPANY');

END;

/

