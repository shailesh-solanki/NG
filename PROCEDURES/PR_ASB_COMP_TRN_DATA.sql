--------------------------------------------------------
--  DDL for Procedure PR_ASB_COMP_TRN_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_COMP_TRN_DATA" (pi_load_seq_nbr IN NUMBER)
/**************************************************************************************
*
* Program Name           :PR_ASB_COMP_TRN_DATA
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-03-2021
* Description            :This is a PL/SQL procedure. This procedure filters data in COMPANY_CSV
*                         table and marked each rows with appropriate error codes.
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
AS

lv_vc_comp_code company_csv.asb_comp_code%type;
lv_vc_vendor_code_eff company_csv.vendor_code_effectivedt%type;
lv_vc_vat_code_eff company_csv.vat_code_effectivedt%type;
lv_vc_vat_perc_eff company_csv.vat_perc_effectivedt%type;
lv_vc_err_code company_csv.error_code%type;
lv_vc_rec_processed number(5) := 0;
lv_vc_rec_rejected number(5) := 0;
v_string varchar2(4000);
lc_vc_call_proc varchar2(4000);

cursor c_vendor_code_err is
        select asb_comp_code,vendor_code_effectivedt,error_code
        from company_csv
        where error_code is null
        group by asb_comp_code,vendor_code_effectivedt,error_code
        having count(*) > 1
        minus
        from company_csv
        select asb_comp_code,vendor_code_effectivedt,error_code
        where error_code is null
        group by asb_comp_code,vendor_code,vendor_code_effectivedt,error_code
        having count(*) > 1;

cursor c_vat_code_err is
        select asb_comp_code,vat_code_effectivedt,error_code
        from company_csv
        where error_code is null or error_code = 100
        group by asb_comp_code,vat_code_effectivedt,error_code
        having count(*) > 1
        minus
        select asb_comp_code,vat_code_effectivedt,error_code
        from company_csv
        where error_code is null or error_code = 100
        group by asb_comp_code,vat_code,vat_code_effectivedt,error_code
        having count(*) > 1;

cursor c_vat_perc_err is
        select asb_comp_code,vat_perc_effectivedt,error_code
        from company_csv
        where error_code is null or error_code in (100,101,103)
        group by asb_comp_code,vat_perc_effectivedt,error_code
        having count(*) > 1
        minus
        select asb_comp_code,vat_perc_effectivedt,error_code
        from company_csv
        where error_code is null or error_code in (100,101,103)
        group by asb_comp_code,vat_perc,vat_perc_effectivedt,error_code
        having count(*) > 1;

BEGIN

  update company_csv
    set error_code = 108
    where
(asb_comp_code,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT) in (
  select asb_comp_code,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT
            from company_csv
            where error_code is null
            group by ASB_COMP_CODE,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT
            having count(*) > 1);

    update company_csv
    set error_code = 99
    where asb_comp_code in
        (select asb_comp_code from company_csv
            minus
        select asb_comp_code from asb_cpny_stg
        );

    open c_vendor_code_err;
    loop
        fetch c_vendor_code_err into lv_vc_comp_code,lv_vc_vendor_code_eff,lv_vc_err_code;
        exit when c_vendor_code_err%notfound;
            if(lv_vc_err_code is null) then
                update company_csv set error_code = 100
                where asb_comp_code = lv_vc_comp_code
                and vendor_code_effectivedt = lv_vc_vendor_code_eff
                and error_code is null;
            end if;
    end loop;
    close c_vendor_code_err;

    open c_vat_code_err;
    loop
        fetch c_vat_code_err into lv_vc_comp_code,lv_vc_vat_code_eff,lv_vc_err_code;
        exit when c_vat_code_err%notfound;
            if(lv_vc_err_code is null) then
                update company_csv set error_code = 101
                where asb_comp_code = lv_vc_comp_code
                and vat_code_effectivedt = lv_vc_vat_code_eff
                and error_code is null;
            else
                update company_csv set error_code = 103
                where asb_comp_code = lv_vc_comp_code
                and vat_code_effectivedt = lv_vc_vat_code_eff
                and error_code = 100;
            end if;
    end loop;
    close c_vat_code_err;

    open c_vat_perc_err;
    loop
        fetch c_vat_perc_err into lv_vc_comp_code,lv_vc_vat_perc_eff,lv_vc_err_code;
        exit when c_vat_perc_err%notfound;
            if(lv_vc_err_code is null) then
                update company_csv set error_code = 102
                where asb_comp_code = lv_vc_comp_code
                and vat_perc_effectivedt = lv_vc_vat_perc_eff
                and error_code is null;
            elsif(lv_vc_err_code = 100) then
                update company_csv set error_code = 104
                where asb_comp_code = lv_vc_comp_code
                and vat_perc_effectivedt = lv_vc_vat_perc_eff
                and error_code = 100;
            elsif(lv_vc_err_code = 101) then
                update company_csv set error_code = 105
                where asb_comp_code = lv_vc_comp_code
                and vat_perc_effectivedt = lv_vc_vat_perc_eff
                and error_code = 101;
            else
                update company_csv set error_code = 106
                where asb_comp_code = lv_vc_comp_code
                and vat_perc_effectivedt = lv_vc_vat_perc_eff
                and error_code = 103;
            end if;
    end loop;
    close c_vat_perc_err;

    update company_csv
    set error_code = 108
    where
(asb_comp_code,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT) in (
  select asb_comp_code,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT
            from company_csv
            where error_code is null
            group by ASB_COMP_CODE,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT,VAT_PERC,VAT_PERC_EFFECTIVEDT,VAT_CODE,VAT_CODE_EFFECTIVEDT,INV_RECPT,INV_ADD1,INV_ADD2,INV_ADD3,INV_ADD4,INV_ADD5,POSTCODE,EMAIL_RECPT_NAME,EMAIL_RECPT
            having count(*) > 1);

      update company_csv
    set error_code = 107
    where asb_comp_code in
        (select asb_comp_code from
            (select asb_comp_code, count(*)
            from company_csv
            where error_code is null
            group by asb_comp_code, vendor_code, vendor_code_effectivedt, vat_perc, vat_perc_effectivedt, vat_code, vat_code_effectivedt
            having count(*) > 1)
        );



    select count(1) into lv_vc_rec_rejected from company_csv where error_code in (99,107);
    select count(1) into lv_vc_rec_processed from company_csv where error_code not in (99,107) or error_code is null;
    update load_details set REC_PROCESSED = lv_vc_rec_processed, REC_REJECTED = lv_vc_rec_rejected where load_seq_nbr = pi_load_seq_nbr
    AND load_desc = 'PR_ASB_LOAD_COMP_MAIN';

   PROC_PROCESS_LOG('PR_ASB_COMP_TRN_DATA',pi_load_seq_nbr,'SUCCESS','All the invalid records identified sucessfully.','COMPANY');

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_TRN_DATA',pi_load_seq_nbr,'SUCCESS','No data found to validate','COMPANY');
    WHEN OTHERS THEN
        PROC_PROCESS_LOG('PR_ASB_COMP_TRN_DATA',pi_load_seq_nbr,'FAILURE',SQLERRM,'COMPANY');

END;

/

