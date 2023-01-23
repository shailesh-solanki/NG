--------------------------------------------------------
--  DDL for Procedure PR_MSMSTG1_LOAD_CONTRACT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSMSTG1_LOAD_CONTRACT" 
/**************************************************************************************
*
* Program Name           :PR_MSMSTG1_LOAD_CONTRACT
* Author                 :IBM
* Creation Date          :30-04-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M table's 
*                         format and tranfer data from ASB_STG tables to different tables of 
*                         MSM_STG1 schema.
*                        
*
* Calling Program        :PR_ASB_LOAD_CONTRACT_MAIN
* Called Program         :
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
(pi_LOAD_SEQ_NBR IN NUMBER) as

v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);
flag number := 0;
 CURSOR c_ci_sa IS
SELECT pi_load_seq_nbr,usi.sa_id,' ' AS prop_dcl_rsn_cd,' ' AS prop_sa_id,'ANC' AS cis_division,
 CASE
 WHEN  service_code='SRBM' AND tender_number='99.99'THEN 'STORBMP'
 WHEN service_code='SRNM' AND tender_number='99.99'THEN 'STORNBMP'
 WHEN service_code='SRBM' AND comm_flex='C' AND (tender_number<>'99.99' OR tender_number IS NULL) THEN 'STORBMCC'
 WHEN service_code='SRNM' AND comm_flex='C' AND (tender_number<>'99.99' OR tender_number IS NULL)  THEN 'STORNBMC'
 WHEN service_code='SRNM' AND comm_flex='F' AND (tender_number<>'99.99' OR tender_number IS NULL)  THEN 'STORNBMF'
 END sa_type_cd,' ' AS start_opt_cd, TO_DATE(substr(fn_convert_gmt_bst1(contract_start),1,11),'DD-MON-RRRR') AS start_dt,
 /*'CASE WHEN contract_status IN ('C','T') AND contract_end IS NULL THEN '20'
  WHEN contract_status IN ('C','T') AND contract_end IS NOT NULL THEN '30'
  WHEN contract_status = 'D' THEN '40'
  END'*/'20' as sa_status_flg,
css.asb_comp_code AS acct_id,
 TO_DATE(substr(fn_convert_gmt_bst1(contract_end),1,11),'DD-MON-RRRR') AS end_dt FROM trn_con_d1_us css, connect_us_sa_id usi  
 WHERE   css.contract_seq =usi.contract_seq AND 
 contract_status IN ('C','T')
 AND css.load_seq_nbr=pi_load_seq_nbr;

 cursor c_us_sa_id is
select us_id,contract_seq
    from connect_us_sa_id a where load_seq_nbr = pi_load_seq_nbr;

cursor c_sa_id is
select us_id,a.sa_id
    from connect_us_sa_id a, msm_stg1.ci_sa b where a.sa_id = b.sa_id and b.load_seq_nbr = pi_load_seq_nbr;

cursor c_con_num is
select dui.us_id,sup.contract_number from msm_stg1.d1_us_identifier dui, srs_supplier_stg sup 
where dui.id_value = sup.contract_seq
and dui.us_id_type_flg = 'CONS'
and sup.contract_number is not null
and sup.load_seq_nbr = pi_load_seq_nbr;

cursor c_comp_code is
select dui.us_id,acs.asb_comp_code from msm_stg1.d1_us_identifier dui, asb_contract_service_stg acs 
where dui.id_value = acs.contract_seq
and dui.us_id_type_flg = 'CONS'
and acs.load_seq_nbr = pi_load_seq_nbr;

cursor c_ci_sa_sp is
select sup.asb_unit_code,csi.SA_ID,fn_convert_gmt_bst1(acs.CONTRACT_START) as contract_start,fn_convert_gmt_bst1(acs.CONTRACT_END)
--case when acs.CONTRACT_STATUS='D' then fn_convert_gmt_bst1(acs.CONTRACT_END) end 
as contract_end
    FROM CONNECT_US_SA_ID csi , ASB_CONTRACT_SERVICE_STG acs, srs_supplier_stg sup, msm_stg1.ci_sa cs
    where acs.CONTRACT_SEQ=csi.CONTRACT_SEQ  and sup.contract_seq = acs.contract_seq and cs.sa_id = csi.sa_id and 
     acs.LOAD_SEQ_NBr=PI_LOAD_SEQ_NBR;


CURSOR c_con_id IS 
select distinct contract_seq from srs_contract_factor_stg where load_seq_nbr = PI_LOAD_SEQ_NBR group by contract_seq having count(1) > 0;

cursor c_d1_us_char_des is
select distinct cus.us_id,to_date(substr(fn_convert_gmt_bst1(des.effective),1,11),'DD-MON-RRRR') as effective,des.srd_load,des.srd_site,
des.srd_agent,des.srd_hq,des.tel_number,des.fax_number,des.srd_installed,des.srd_calloff 
from srs_despatch_stg des, connect_us_sa_id cus 
where cus.contract_seq = des.contract_seq
and des.load_seq_nbr = pi_load_seq_nbr;

cursor c_d1_us_char_sup is
select distinct cus.us_id,sup.response_time,sup.recovery_period,sup.mnzt_limit,sup.cease_time,sup.rampup_rate,sup.rampdown_rate,
to_date(substr(fn_convert_gmt_bst1(des.effective),1,11),'DD-MON-RRRR') as effective,sup.spingen_adjust,
  decode(sup.exp_capacity,sup.cont_capacity,'G',0,'D') as unit_type
from srs_supplier_stg sup, connect_us_sa_id cus ,srs_despatch_stg des
where cus.contract_seq = sup.contract_seq
and cus.contract_seq = des.contract_seq
and sup.load_seq_nbr = pi_load_seq_nbr;

cursor c_d1_us_char_acs is
select distinct cus.us_id,sup.asb_unit_code,acs.group_id,to_date(substr(fn_convert_gmt_bst1(des.effective),1,11),'DD-MON-RRRR') as effective
from asb_contract_service_stg acs, connect_us_sa_id cus, srs_despatch_stg des, SRS_SUPPLIER_STG sup
where cus.contract_seq = acs.contract_seq
and cus.contract_seq = des.contract_seq
and cus.contract_seq=sup.contract_seq
and acs.load_seq_nbr = pi_load_seq_nbr;

cursor c_d1_us_char_sea is
select distinct cus.us_id,sea.recon_flag,to_date(substr(fn_convert_gmt_bst1(des.effective),1,11),'DD-MON-RRRR') as effective
from srs_seasonal_stg sea, connect_us_sa_id cus, srs_despatch_stg des
where cus.contract_seq = sea.contract_seq
and cus.contract_seq = des.contract_seq
and sea.load_seq_nbr = pi_load_seq_nbr;

cursor c_d1_us_qty_bm(p_contract_seq number) is
select cus.US_ID,acs.CONTRACT_START,acs.CONTRACT_END,sup.CONT_CAPACITY,
(select max(acr.CONTRACT_RATE_1) from asb_contract_rate_stg acr where pay_code = 'SRBA' and contract_seq = acs.contract_seq 
and acr.load_seq_nbr = pi_load_seq_nbr and acr.contract_seq = p_contract_seq) as available,
(select max(acr.CONTRACT_RATE_1) from asb_contract_rate_stg acr where pay_code = 'SRBU' and contract_seq = acs.contract_seq 
and acr.load_seq_nbr = pi_load_seq_nbr and acr.contract_seq = p_contract_seq) as utilization,'' as premium,
sup.OPTN_CAPACITY,SYSDATE
from asb_contract_service_stg acs,  connect_us_sa_id cus,srs_supplier_stg sup
where  acs.contract_seq = cus.contract_seq
and sup.contract_seq = cus.contract_seq
and acs.service_code = 'SRBM'
and cus.contract_seq = p_contract_seq;

cursor c_d1_us_qty_nbm(p_contract_seq number) is
select cus.US_ID,acs.CONTRACT_START,acs.CONTRACT_END,sup.CONT_CAPACITY,
(select max(acr.CONTRACT_RATE_1) from asb_contract_rate_stg acr where pay_code = 'SRNA' and contract_seq = acs.contract_seq 
and acr.load_seq_nbr = pi_load_seq_nbr and acr.contract_seq = p_contract_seq) as available,
(select max(acr.CONTRACT_RATE_1) from asb_contract_rate_stg acr where pay_code = 'SRNU' and contract_seq = acs.contract_seq 
and acr.load_seq_nbr = pi_load_seq_nbr and acr.contract_seq = p_contract_seq) as utilization,
(select max(acr.CONTRACT_RATE_1) from asb_contract_rate_stg acr where pay_code = 'SRNP' and contract_seq = acs.contract_seq 
and acr.load_seq_nbr = pi_load_seq_nbr and acr.contract_seq = p_contract_seq)  as premium,
sup.OPTN_CAPACITY,SYSDATE
from asb_contract_service_stg acs,  connect_us_sa_id cus,srs_supplier_stg sup
where  acs.contract_seq = cus.contract_seq
and sup.contract_seq = cus.contract_seq
and acs.service_code = 'SRNM'
and cus.contract_seq = p_contract_seq;

cursor c_count_contract_rate is
select distinct contract_seq from asb_contract_rate_stg where load_seq_nbr = pi_load_seq_nbr;
BEGIN

dbms_output.put_line('CI_SA start'||sysdate);
    -----------------------------------------------------------
    ------------ Load data in Table MSM_STG1.CI_SA ------------
    -----------------------------------------------------------

      FOR rec IN c_ci_sa
    LOOP

        INSERT  INTO msm_stg1.ci_sa    ( load_seq_nbr, sa_id,prop_dcl_rsn_cd,prop_sa_id,cis_division,sa_type_cd,start_opt_cd,
        start_dt,sa_status_flg,acct_id,end_dt,old_acct_id,cust_read_flg,allow_est_sw,sic_cd,char_prem_id,tot_to_bill_amt,currency_cd,
        VERSION,sa_rel_id,strt_rsn_flg, stop_rsn_flg, strt_reqed_by,stop_reqed_by,high_bill_amt,int_calc_dt,ciac_review_dt,
        bus_activity_desc,ib_sa_cutoff_tm,ib_base_tm_day_flg,enrl_id,special_usage_flg,prop_sa_stat_flg,nbr_pymnt_periods,
        nb_rule_cd, expire_dt,renewal_dt,nb_apay_flg,sa_data_area, date_created)
    VALUES  ( pi_load_seq_nbr, rec.sa_id,' ' ,' ','ANC',rec.sa_type_cd,' ',rec.start_dt,rec.sa_status_flg,rec.acct_id,rec.end_dt,
    ' ','N','Y',' ',' ',0,'GBP',99,' ',' ',' ',' ',' ',0,'','',' ','',' ',' ',' ',' ',0,' ','','',' ','',sysdate);


    END LOOP;

delete from connect_us_sa_id where sa_id not in (select sa_id from msm_stg1.ci_sa where load_seq_nbr = pi_load_seq_nbr);

  ----------------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_IDENTIFIER ------------
    ----------------------------------------------------------------------

dbms_output.put_line('D1_US_IDENTIFIER start'||sysdate);



    for rec in c_us_sa_id
    loop
        insert into msm_stg1.D1_US_IDENTIFIER(LOAD_SEQ_NBR,US_ID,US_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED)
        values (pi_load_seq_nbr,rec.us_id,'CONS',rec.contract_seq,99,sysdate);
     end loop;

     for rec in c_sa_id
     loop
        insert into msm_stg1.D1_US_IDENTIFIER(LOAD_SEQ_NBR,US_ID,US_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED)
        values (pi_load_seq_nbr,rec.us_id,'D2EI',rec.sa_id,99,sysdate);
    end loop;

    for rec in c_con_num
    loop
        insert into msm_stg1.D1_US_IDENTIFIER(LOAD_SEQ_NBR,US_ID,US_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED)
        values (pi_load_seq_nbr,rec.us_id,'CONB',rec.contract_number,99,sysdate);
    end loop;

    for rec in c_comp_code
    loop
        insert into msm_stg1.D1_US_IDENTIFIER(LOAD_SEQ_NBR,US_ID,US_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED)
        values (pi_load_seq_nbr,rec.us_id,'D2EA',rec.asb_comp_code,99,sysdate);
    end loop;

    dbms_output.put_line('D1_US_IDENTIFIER end'||sysdate);




    --------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.CI_SA_SP ------------
    --------------------------------------------------------------

    dbms_output.put_line('CI_SA_SP start'||sysdate);

   for rec in c_ci_sa_sp
   loop 
        insert into msm_stg1.ci_sa_sp(load_seq_nbr,SP_ID,SA_SP_ID,SA_ID ,START_DTTM,START_MR_ID,STOP_DTTM,USAGE_FLG,STOP_MR_ID,VERSION,USE_PCT,DATE_CREATED)
        values (pi_load_seq_nbr,rec.asb_unit_code,SQ_CONTRACT_CI_SA_SP.nextval,rec.sa_id,rec.contract_start,' ',rec.CONTRACT_END ,'+',' ',99,100,SYSDATE);
end loop;


    dbms_output.put_line('CI_SA_SP end'||sysdate);
    -------------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.CI_SA_SP_CHAR ------------
    -------------------------------------------------------------------
    dbms_output.put_line('CI_SA_SP_CHAR start'||sysdate);
    INSERT INTO  MSM_STG1.CI_SA_SP_CHAR(LOAD_SEQ_NBR,SA_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,VERSION,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,DATE_CREATED)
   select pi_load_seq_nbr,SA_SP_ID,'CM-DFSUP',to_date(substr(START_DTTM,1,11),'DD-MON-RRRR'),'Y','99',' ',' ',' ',' ',' ',' ',SYSDATE from msm_stg1.ci_sa_sp where load_seq_nbr = pi_load_seq_nbr; 
  dbms_output.put_line('CI_SA_SP_CHAR end'||sysdate);

    -----------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US ------------
    -----------------------------------------------------------
    dbms_output.put_line('D1_US start'||sysdate);
    INSERT INTO MSM_STG1.D1_US(LOAD_SEQ_NBR,US_ID,BUS_OBJ_CD,BO_STATUS_CD,BO_STATUS_REASON_CD,US_TYPE_CD,D1_SPR_CD,USG_APPR_REQ_FLG,START_DTTM,END_DTTM,CRE_DTTM,
                            STATUS_UPD_DTTM,VERSION,US_STAT_COND_FLG,TIME_ZONE_CD,BO_DATA_AREA,D1_BILL_CYC_CD,US_MP_ID,MOST_RECENT_TRANS_DTTM,
                            DIVISION_CD,ACCESS_GRP_CD,DATE_CREATED)                                    
 SELECT pi_load_seq_nbr,USI.US_ID,'CM-CONTRACT',
 /*case when TRN_CON_D1_US.CONTRACT_STATUS in ('C','T') 
 then 'ACTIVE' 
 when TRN_CON_D1_US.CONTRACT_STATUS = 'D' 
 then 'INACTIVE'  end*/ 'ACTIVE' as BO_STATUS_CD,' ',
 CASE
 WHEN  TRN_CON_D1_US.SERVICE_CODE='SRBM' and TENDER_NUMBER='99.99'THEN 'STOR_BM_PREQUAL'
 WHEN TRN_CON_D1_US.SERVICE_CODE='SRNM' and TRN_CON_D1_US.TENDER_NUMBER='99.99' THEN 'STOR_NBM_PREQUAL'
 WHEN TRN_CON_D1_US.SERVICE_CODE='SRBM' and TRN_CON_D1_US.COMM_FLEX='C' AND TRN_CON_D1_US.TENDER_NUMBER<>'99.99' THEN 'STOR_BM_CONTRACT_COMMITTED'
 WHEN TRN_CON_D1_US.SERVICE_CODE='SRNM' and TRN_CON_D1_US.COMM_FLEX='C' AND TRN_CON_D1_US.TENDER_NUMBER<>'99.99' THEN 'STOR_NBM_CONTRACT_COMMITTED'
 WHEN TRN_CON_D1_US.SERVICE_CODE='SRNM' and TRN_CON_D1_US.COMM_FLEX='F' AND TRN_CON_D1_US.TENDER_NUMBER<>'99.99' THEN 'STOR_NBM_FLEXIBLE'
 END
 ,'OUC2M','D1NR',fn_convert_gmt_bst1(TRN_CON_D1_US.CONTRACT_START),
fn_convert_gmt_bst1(TRN_CON_D1_US.CONTRACT_END) ,
 fn_convert_gmt_bst1(SYSDATE),fn_convert_gmt_bst1(SYSDATE),99,'D1AC','UK',
 '<tenderNumber>'||TRN_CON_D1_US.tender_number||'</tenderNumber><flexiComIndicator>'||TRN_CON_D1_US.COMM_FLEX||'</flexiComIndicator><maxOccPerWeek>'||TRN_CON_D1_US.MAX_OCCS_WEEK
 ||'</maxOccPerWeek><maxHrsPerWeek>'||TRN_CON_D1_US.MAX_HOURS_WEEK||'</maxHrsPerWeek><maxOccPerYear>'||TRN_CON_D1_US.MAX_OCCS_CONT||'</maxOccPerYear><maxHrsPerYear>'||
 TRN_CON_D1_US.MAX_HOURS_CONT||'</maxHrsPerYear><maxUtilPeriod>'||TRN_CON_D1_US.MAX_UTILISATION||'</maxUtilPeriod><nearestNode>'||TRN_CON_D1_US.NEAREST_NODE||'</nearestNode><location>'||
 TRN_CON_D1_US.LOCATION||'</location><northOrSouth>'||TRN_CON_D1_US.NORTH_SOUTH||'</northOrSouth><includeInContractDataExtract>'||TRN_CON_D1_US.INCLUDE_CONTRACT||
 '</includeInContractDataExtract><instructionMechanism>'||TRN_CON_D1_US.INSR_MECH||'</instructionMechanism>',
 '','','','','',sysdate 
  FROM trn_con_d1_us , connect_us_sa_id usi  WHERE   trn_con_d1_us.contract_seq =usi.contract_seq AND  contract_status IN ('C','T') AND trn_con_d1_us.load_seq_nbr=PI_LOAD_SEQ_NBR;

dbms_output.put_line('D1_US end'||sysdate);
    ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_CHAR ------------
    ----------------------------------------------------------------
   dbms_output.put_line('D1_US_char start'||sysdate);
    for rec in c_d1_us_char_des
    loop
        flag:=0;
        if (rec.SRD_LOAD is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRDLO',rec.effective,' ',nvl(rec.SRD_LOAD,' '),' ',' ',' ',' ',' ',upper(nvl(rec.SRD_LOAD,' ')),99,sysdate);
        end if;

        if (rec.SRD_SITE is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRSTE',rec.effective,' ',nvl(rec.SRD_SITE,' '),' ',' ',' ',' ',' ',upper(nvl(rec.SRD_SITE,' ')),99,sysdate);
        flag:=flag+1;
        end if;

        if (rec.SRD_AGENT is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRAGN',rec.effective,' ',nvl(rec.SRD_AGENT,' '),' ',' ',' ',' ',' ',upper(nvl(rec.SRD_AGENT,' ')),99,sysdate);        
        flag:=flag+1;
        end if;

        if (rec.SRD_HQ is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRDHQ',rec.effective,' ',nvl(rec.SRD_HQ,' '),' ',' ',' ',' ',' ',upper(nvl(rec.SRD_HQ,' ')),99,sysdate);
        flag:=flag+1;
        end if;

        if (rec.TEL_NUMBER is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-DESTL',rec.effective,' ',nvl(rec.TEL_NUMBER,' '),' ',' ',' ',' ',' ',' ',99,sysdate);
        end if;

        if (rec.FAX_NUMBER is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-DESFX',rec.effective,' ',nvl(rec.FAX_NUMBER,' '),' ',' ',' ',' ',' ',upper(nvl(rec.FAX_NUMBER,' ')),99,sysdate);
        end if;

        if (rec.SRD_INSTALLED is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRDIN',rec.effective,nvl(rec.SRD_INSTALLED,' '),' ',' ',' ',' ',' ',' ',upper(nvl(rec.SRD_INSTALLED,' ')),99,sysdate);
        end if;

        /*if(rec.srd_calloff != ' ' and flag =3 )then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRCAL',rec.effective,' ',coalesce(rec.srd_calloff,rec.srd_site,rec.srd_agent,rec.srd_hq,' '),' ',' ',' ',' ',' ',upper(coalesce(rec.srd_calloff,rec.srd_site,rec.srd_agent,rec.srd_hq,' ')),99,sysdate);
        end if;*/
        if (rec.SRD_CALLOFF != ' ') then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SRCAL',rec.effective,decode(rec.srd_calloff,rec.srd_site,'SITE',rec.srd_agent,'AGENT',rec.srd_hq,'HQ'),' ',' ',' ',' ',' ',' ',upper(decode(rec.srd_calloff,rec.srd_site,'SITE',rec.srd_agent,'AGENT',rec.srd_hq,'HQ')),99,sysdate);
        end if;
    end loop;

    for rec in c_d1_us_char_sup
    loop
        if (rec.RESPONSE_TIME is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-RPTIM',rec.effective,' ',nvl(rec.RESPONSE_TIME,0),' ',' ',' ',' ',' ',upper(nvl(rec.RESPONSE_TIME,0)),99,sysdate);
        end if;

        if (rec.RECOVERY_PERIOD is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-RCPRD',rec.effective,' ',nvl(rec.RECOVERY_PERIOD,0),' ',' ',' ',' ',' ',upper(nvl(rec.RECOVERY_PERIOD,0)),99,sysdate);
        end if;

        if (rec.MNZT_LIMIT is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-MNZT',rec.effective,' ',nvl(rec.MNZT_LIMIT,0),' ',' ',' ',' ',' ',upper(nvl(rec.MNZT_LIMIT,0)),99,sysdate);
        end if;

        if (rec.CEASE_TIME is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-CSTIM',rec.effective,' ',nvl(rec.CEASE_TIME,0),' ',' ',' ',' ',' ',upper(nvl(rec.CEASE_TIME,0)),99,sysdate);
        end if;

        if (rec.RAMPUP_RATE is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-RUR',rec.effective,' ',nvl(rec.RAMPUP_RATE,0),' ',' ',' ',' ',' ',upper(nvl(rec.RAMPUP_RATE,0)),99,sysdate);
        end if;

        if (rec.RAMPDOWN_RATE is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-RDR',rec.effective,' ',nvl(rec.RAMPDOWN_RATE,0),' ',' ',' ',' ',' ',upper(nvl(rec.RAMPDOWN_RATE,0)),99,sysdate);
        end if;

        if (rec.SPINGEN_ADJUST is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-SGADJ',rec.effective,' ',nvl(rec.SPINGEN_ADJUST,0),' ',' ',' ',' ',' ',upper(nvl(rec.SPINGEN_ADJUST,0)),99,sysdate);
        end if;

        if (rec.UNIT_TYPE is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-UNIT',rec.effective,nvl(rec.UNIT_TYPE,' '),' ',' ',' ',' ',' ',' ',upper(nvl(rec.UNIT_TYPE,' ')),99,sysdate);
        end if;
    end loop;

    for rec in c_d1_us_char_acs
    loop
        if (rec.GROUP_ID is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-GRPID',rec.effective,' ',nvl(rec.GROUP_ID,' '),' ',' ',' ',' ',' ',upper(nvl(rec.GROUP_ID,' ')),99,sysdate);
        end if;

        if (rec.asb_unit_code is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-CONID',rec.effective,' ',nvl(rec.asb_unit_code,' '),' ',' ',' ',' ',' ',upper(nvl(rec.asb_unit_code,' ')),99,sysdate);
        end if;
    end loop;        

   /* for rec in c_d1_us_char_sea
    loop
        if (rec.RECON_FLAG is not null) then
        insert into msm_stg1.d1_us_char (LOAD_SEQ_NBR,US_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
        values(pi_load_seq_nbr,rec.us_id,'CM-RECFL',rec.effective,nvl(rec.RECON_FLAG,' '),' ',' ',' ',' ',' ',' ',upper(nvl(rec.RECON_FLAG,' ')),99,sysdate);
        end if;
    end loop;       */ 
    ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_SP --------------
    ----------------------------------------------------------------
    dbms_output.put_line('D1_US_SP start'||sysdate);
    insert into MSM_STG1.D1_US_SP
    select pi_load_seq_nbr,dui.us_id,sup.asb_unit_code,fn_convert_gmt_bst1(acs.contract_start),--decode(acs.contract_status,'D',fn_convert_gmt_bst1(acs.contract_end),''),
    fn_convert_gmt_bst1(acs.contract_end),'D1AD',100,99,null,null,null,sysdate 
    from MSM_STg1.D1_US_IDENTIFIER dui, ASB_CONTRACT_SERVICE_STG acs , srs_supplier_stg sup
    where acs.contract_seq=sup.contract_seq 
    and dui.id_value = acs.contract_seq 
    and dui.us_id_type_flg = 'CONS'
    and dui.load_seq_nbr = pi_load_seq_nbr;
    dbms_output.put_line('D1_US_SP end'||sysdate);
    ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_SP_CHAR --------------
    ----------------------------------------------------------------
    dbms_output.put_line('D1_US_sp_char start'||sysdate);
     INSERT INTO MSM_STG1.D1_US_SP_CHAR
 SELECT  PI_LOAD_SEQ_NBR,DUS.US_ID,DUS.D1_SP_ID,fn_convert_gmt_bst1(DUS.START_DTTM),to_date(substr(fn_convert_gmt_bst1(DUS.START_DTTM),1,11),'DD-MON-RRRR') AS EFFDT,'CM-DFSUP',nvl(sup.default_supplier,'Y'),' ',' ',' ',' ',' ',' ',upper(nvl(sup.default_supplier,'Y')),'99',SYSDATE 
 FROM MSM_STG1.D1_US_SP DUS, connect_us_sa_id cus ,srs_supplier_stg sup
 where dus.us_id = cus.us_id
 and cus.contract_seq = sup.contract_seq and DUS.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;
 dbms_output.put_line('D1_US_sp_char end'||sysdate);
 ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_FACTOR_OVRD --------
    ----------------------------------------------------------------
    dbms_output.put_line('D1_US_factor_ovrd start'||sysdate);

    FOR rec in c_con_id
    LOOP


        INSERT INTO MSM_STG1.D1_US_FACTOR_OVRD(LOAD_SEQ_NBR,US_ID,FACTOR_CD,START_DTTM,END_DTTM,VALUE,VERSION,DATE_CREATED)
       SELECT pi_load_seq_nbr,cus.us_id,'CM_STDBY_TOLERANCE',fn_convert_gmt_bst1(scf.EFFECTIVE),
        LEAD(fn_convert_gmt_bst1(scf.EFFECTIVE)) OVER(PARTITION BY scf.contract_seq ORDER BY scf.contract_seq,scf.EFFECTIVE)AS END_DTTM,STANDBY_TOLERANCE
        ,99,SYSDATE 
        FROM srs_contract_factor_stg scf, connect_us_sa_id cus where cus.contract_seq = scf.contract_seq and scf.contract_seq = rec.contract_seq
       and scf.load_seq_nbr = pi_load_seq_nbr  ;

    END LOOP;
    /*
FOR rec in c_con_id
    LOOP


        INSERT INTO MSM_STG1.D1_US_FACTOR_OVRD(LOAD_SEQ_NBR,US_ID,FACTOR_CD,START_DTTM,END_DTTM,VALUE,VERSION,DATE_CREATED)
       SELECT pi_load_seq_nbr,cus.us_id,'CM_DELIVERY_TOLERANCE',fn_convert_gmt_bst1(scf.EFFECTIVE),
        LEAD(fn_convert_gmt_bst1(scf.EFFECTIVE)) OVER(PARTITION BY scf.contract_seq ORDER BY scf.contract_seq,scf.EFFECTIVE)AS END_DTTM,delivery_tolerance
        ,99,SYSDATE 
        FROM srs_contract_factor_stg scf, connect_us_sa_id cus where cus.contract_seq = scf.contract_seq and scf.contract_seq = rec.contract_seq
       and scf.load_seq_nbr = pi_load_seq_nbr  ;

    END LOOP;
*/
 ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_QTY --------------
    ----------------------------------------------------------------
   dbms_output.put_line('D1_US_qty start'||sysdate);
for i in c_count_contract_rate
loop
 for rec in c_d1_us_qty_bm(i.contract_seq)
 loop
    INSERT INTO  MSM_STG1.D1_US_QTY(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,BO_XML_DATA_AREA,VERSION,
    D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
    values(pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,rec.us_id,'PREQUAL_CONTRACT',rec.contract_start,rec.contract_end,'D1AC','D1-UsageSubscriptionQuantity',' ',sysdate,sysdate,'','99',
    rec.cont_capacity,rec.available,rec.utilization,rec.premium,rec.OPTN_CAPACITY,sysdate);
 end loop;
 for rec in c_d1_us_qty_nbm(i.contract_seq)
 loop
    INSERT INTO  MSM_STG1.D1_US_QTY(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,BO_XML_DATA_AREA,VERSION,
    D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,D1_QUANTITY5,DATE_CREATED)
    values(pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,rec.us_id,'PREQUAL_CONTRACT',rec.contract_start,rec.contract_end,'D1AC','D1-UsageSubscriptionQuantity',' ',sysdate,sysdate,'','99',
    rec.cont_capacity,rec.available,rec.utilization,rec.premium,rec.OPTN_CAPACITY,sysdate);
 end loop;
end loop;
/*
INSERT INTO  MSM_STG1.D1_US_QTY(LOAD_SEQ_NBR,D1_US_QTY_ID,US_ID,D1_US_QTY_TYPE_CD,START_DTTM,END_DTTM,US_QTY_USG_FLG,BUS_OBJ_CD,
  BO_STATUS_CD,STATUS_UPD_DTTM,CRE_DTTM,BO_XML_DATA_AREA,VERSION,D1_QUANTITY1,D1_QUANTITY2,D1_QUANTITY3,D1_QUANTITY4,
  D1_QUANTITY5,DATE_CREATED)
  select pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,cus.US_ID,'PREQUAL_CONTRACT',acs.CONTRACT_START,acs.CONTRACT_END,'D1AC',
'D1-UsageSubscriptionQuantity','',sysdate,sysdate,'','99',sup.CONT_CAPACITY,
(select acr.CONTRACT_RATE_1 from asb_contract_rate_stg acr where pay_code = 'SRNA' and contract_seq = acs.contract_seq and acr.load_seq_nbr = pi_load_seq_nbr),
(select acr.CONTRACT_RATE_1 from asb_contract_rate_stg acr where pay_code = 'SRNU' and contract_seq = acs.contract_seq and acr.load_seq_nbr = pi_load_seq_nbr),
(select acr.CONTRACT_RATE_1 from asb_contract_rate_stg acr where pay_code = 'SRNP' and contract_seq = acs.contract_seq and acr.load_seq_nbr = pi_load_seq_nbr),sup.OPTN_CAPACITY,SYSDATE
from asb_contract_service_stg acs,  connect_us_sa_id cus,srs_supplier_stg sup
where  acs.contract_seq = cus.contract_seq
and sup.contract_seq = cus.contract_seq
and acs.service_code = 'SRNM';*/
/*
SELECT pi_load_seq_nbr,SQ_CONTRACT_D1_US_QTY_ID.NEXTVAL,E.US_ID,
  'PREQUAL_CONTRACT',A.CONTRACT_START,A.CONTRACT_END,'D1AC','D1-UsageSubscriptionQuantity','',sysdate,sysdate,'','99',
  B.CONT_CAPACITY,C.CONTRACT_RATE_1,C.CONTRACT_RATE_1,C.CONTRACT_RATE_1,B.OPTN_CAPACITY,SYSDATE
  FROM asb_contract_service_stg A,srs_supplier_stg B,asb_contract_rate_stg C,connect_us_sa_id E
  WHERE A.CONTRACT_SEQ=B.CONTRACT_SEQ AND B.CONTRACT_SEQ=C.CONTRACT_SEQ AND 
  C.CONTRACT_SEQ=E.contract_seq;*/
dbms_output.put_line('D1_US_qty end'||sysdate);
----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_QTY_LOG --------------
    ----------------------------------------------------------------
    dbms_output.put_line('D1_US_qty_log start'||sysdate);
INSERT INTO  MSM_STG1.D1_US_QTY_LOG(LOAD_SEQ_NBR,D1_US_QTY_ID,SEQNO,LOG_DTTM,LOG_ENTRY_TYPE_FLG,DESCRLONG,BO_STATUS_CD,BO_STATUS_REASON_CD,
  MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,DATE_CREATED)
  SELECT PI_LOAD_SEQ_NBR,D1_US_QTY_ID,1,fn_convert_gmt_bst1(SYSDATE),'F1CR','','','','11002','12152','','','','','','',
  '','','MIGD','99',SYSDATE FROM msm_stg1.D1_US_QTY;
  dbms_output.put_line('D1_US_qty_log end'||sysdate);
       ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_LOG --------------
    ----------------------------------------------------------------
      dbms_output.put_line('D1_US_log start'||sysdate);
      insert into MSM_STG1.D1_US_LOG
             select distinct PI_LOAD_SEQ_NBR as LOAD_SEQ_NBR,US_ID,1,fn_convert_gmt_bst1(SYSDATE),'F1CR',' ','ACTIVE',' ','11002','12151',' ',' ',' ', ' ',' ',' ',' ',' ','MIGD',99,SYSDATE 
             from connect_us_sa_id cus,asb_contract_service_stg acs where cus.contract_seq = acs.contract_seq and acs.contract_status not in ('D') and acs.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

     /*insert into MSM_STG1.D1_US_LOG
             select distinct PI_LOAD_SEQ_NBR as LOAD_SEQ_NBR,US_ID,2,fn_convert_gmt_bst1(SYSDATE),'F1ST',' ','INACTIVE',' ','11002','12150',' ',' ',' ', ' ',' ',' ',' ',' ','MIGD',99,SYSDATE 
             from connect_us_sa_id cus,asb_contract_service_stg acs where cus.contract_seq = acs.contract_seq and acs.contract_status in ('D') and acs.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;*/
    dbms_output.put_line('D1_US_log end'||sysdate);
    ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_US_LOG_PARM --------
    ----------------------------------------------------------------
    dbms_output.put_line('D1_US_log_parm start'||sysdate);
    insert into MSM_STG1.D1_US_LOG_PARM
    select distinct pi_load_seq_nbr,US_ID,1,2,'Active',' ',99,sysdate from connect_us_sa_id cus,asb_contract_service_stg acs 
    where cus.contract_seq = acs.contract_seq and acs.contract_status not in ('D') and acs.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;

   /* insert into MSM_STG1.D1_US_LOG_PARM
    select distinct pi_load_seq_nbr,US_ID,2,3,'Inactive',' ',99,sysdate from connect_us_sa_id cus,asb_contract_service_stg acs 
    where cus.contract_seq = acs.contract_seq and acs.contract_status in ('D') and acs.LOAD_SEQ_NBR = PI_LOAD_SEQ_NBR;*/

    dbms_output.put_line('D1_US_log_parm end'||sysdate);


    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,200);
        ASB_STG.PR_PROCESS_LOG('PR_MSMSTG1_LOAD_CONTRACT',pi_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSMSTG1_LOAD_CONTRACT;

/

