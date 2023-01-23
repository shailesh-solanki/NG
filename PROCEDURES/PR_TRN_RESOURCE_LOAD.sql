--------------------------------------------------------
--  DDL for Procedure PR_TRN_RESOURCE_LOAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_TRN_RESOURCE_LOAD" 
/**************************************************************************************
*
* Program Name           :PR_TRN_RESOURCE_LOAD
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-03-2021
* Description            :This is a PL/SQL procedure. This procedure takes data
*                         from ASB_UNIT_STG and RESOURCE_CSV and loads data into TRN_UNIT table.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_RESOURCE_MAIN
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
(pi_load_seq_nbr IN number)
AS

lv_vc_rec_csv_count number;
lv_vc_rec_unit_count number;
lv_vc_rec_monitor_count number;

BEGIN
    BEGIN
    
      select count(*) into lv_vc_rec_csv_count from resource_csv;
      select count(*) into lv_vc_rec_monitor_count from SRS_MONITORING_STG where load_seq_nbr = pi_load_seq_nbr;
    
    
      if(lv_vc_rec_csv_count > 0) then
    
    
        MERGE INTO TRN_MONITORING t
            USING (SELECT DISTINCT a.ASB_UNIT_CODE as UNIT_CODE,a.EFFECTIVE,a.BAD_METER_FLAG,a.METER_DELAY,a.NEGATIVE_LOAD,a.BASE_LOAD_LEAD,a.BASE_LOAD_LAG,a.BASE_LOAD_SUM,b.* FROM SRS_MONITORING_STG A
            LEFT OUTER JOIN RESOURCE_CSV B ON (A.ASB_UNIT_CODE = B.ASB_UNIT_CODE)
            WHERE (B.ERROR_CODE not in (109) or error_code is null) and (B.LOAD_SEQ_NBR = pi_load_seq_nbr OR A.LOAD_SEQ_NBR = pi_load_seq_nbr)) q
            ON(t.LOAD_SEQ_NBR=pi_load_seq_nbr)
        WHEN MATCHED THEN
        UPDATE SET BAD_METER_FLAG = q.BAD_METER_FLAG, METER_DELAY = q.METER_DELAY, NEGATIVE_LOAD = q.NEGATIVE_LOAD, BASE_LOAD_LAG = q.BASE_LOAD_LAG,
        BASE_LOAD_SUM = q.BASE_LOAD_SUM, SERVICE_PROVISION = q.SERVICE_PROVISION, MAX_MW = q.MAX_MW,
        MAX_MW_EFFDT = q.MAX_MW_EFFDT,  ERROR_CODE=q.error_code
        where load_seq_nbr = pi_load_seq_nbr and asb_unit_code = q.UNIT_CODE  and effective = q.effective
        WHEN NOT MATCHED THEN
            INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE,EFFECTIVE, BAD_METER_FLAG, METER_DELAY, NEGATIVE_LOAD, BASE_LOAD_LEAD, BASE_LOAD_LAG, BASE_LOAD_SUM, SERVICE_PROVISION, SERVICE_PROVISION_EFFDT, MAX_MW,
                    MAX_MW_EFFDT, ERROR_CODE, DATE_CREATED)
            VALUES (pi_load_seq_nbr, q.UNIT_CODE, q.EFFECTIVE, q.BAD_METER_FLAG, q.METER_DELAY, q.NEGATIVE_LOAD, q.BASE_LOAD_LEAD, q.BASE_LOAD_LAG, q.BASE_LOAD_SUM, q.SERVICE_PROVISION,
                    q.SERVICE_PROVISION_EFFDT, q.MAX_MW, q.MAX_MW_EFFDT, q.ERROR_CODE,sysdate);
      end if;
    
      if(lv_vc_rec_monitor_count > 0 and lv_vc_rec_csv_count = 0) then
        INSERT INTO TRN_MONITORING (LOAD_SEQ_NBR, ASB_UNIT_CODE,EFFECTIVE, BAD_METER_FLAG, METER_DELAY, NEGATIVE_LOAD, BASE_LOAD_LEAD, BASE_LOAD_LAG, BASE_LOAD_SUM, DATE_CREATED)
        (SELECT pi_load_seq_nbr, a.ASB_UNIT_CODE, a.EFFECTIVE, a.BAD_METER_FLAG, a.METER_DELAY, a.NEGATIVE_LOAD, a.BASE_LOAD_LEAD, a.BASE_LOAD_LAG, a.BASE_LOAD_SUM,SYSDATE from SRS_MONITORING_STG a
        where a.load_seq_nbr = pi_load_seq_nbr);
      end if;
    
    
        PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'SUCCESS','SRS_MONITORING and RESOURCE_CSV merged sucessfully!!!','RESOURCE');
    EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'SUCCESS','No new data found for sequence number '||pi_load_seq_nbr,'RESOURCE');
                RAISE;
                
            WHEN OTHERS THEN
                PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'FAILURE',SQLERRM,'RESOURCE');
                RAISE;
    END;

BEGIN


  select count(*) into lv_vc_rec_csv_count from resource_csv;
  select count(*) into lv_vc_rec_unit_count from asb_unit_stg where load_seq_nbr = pi_load_seq_nbr;


  if(lv_vc_rec_csv_count > 0) then

    MERGE INTO TRN_UNIT t
        USING (SELECT DISTINCT a.ASB_UNIT_CODE as UNIT_CODE,a.EFFECTIVE,a.GOAL_UNIT_CODE,a.BM_UNIT_CODE,a.REG_STATION_NAME,b.* 
        FROM ASB_UNIT_STG A LEFT OUTER JOIN RESOURCE_CSV B ON (A.ASB_UNIT_CODE = B.ASB_UNIT_CODE)
        WHERE (B.ERROR_CODE not in (109) or error_code is null) and (B.LOAD_SEQ_NBR = pi_load_seq_nbr OR A.LOAD_SEQ_NBR = pi_load_seq_nbr)) q
        ON(t.LOAD_SEQ_NBR=pi_load_seq_nbr)
    WHEN MATCHED THEN
    UPDATE SET EFFECTIVE = q.EFFECTIVE, GOAL_UNIT_CODE = q.GOAL_UNIT_CODE, BM_UNIT_CODE = q.BM_UNIT_CODE, REG_STATION_NAME = q.REG_STATION_NAME, RESOURCE_TYPE = q.RESOURCE_TYPE,
    RESOURCE_TYP_EFFDT = q.RESOURCE_TYP_EFFDT, SPL_RESOURCE_TYPE = q.SPL_RESOURCE_TYPE, SPL_RES_TYP_EFFDT = q.SPL_RES_TYP_EFFDT,
    BM_STATION_NAME = q.BM_STATION_NAME, BM_STAT_NAME_EFFDT = q.BM_STAT_NAME_EFFDT, METER_TYPE = q.METER_TYPE, METER_TYPE_EFFDT = q.METER_TYPE_EFFDT, NBMTOBM_MAP = q.NBMTOBM_MAP,
    NBMTOBM_MAP_EFFDT = q.NBMTOBM_MAP_EFFDT,  ERROR_CODE=q.error_code
    where load_seq_nbr = pi_load_seq_nbr and asb_unit_code = q.UNIT_CODE
    WHEN NOT MATCHED THEN
        INSERT (LOAD_SEQ_NBR, ASB_UNIT_CODE,EFFECTIVE, GOAL_UNIT_CODE, BM_UNIT_CODE, REG_STATION_NAME, RESOURCE_TYPE, RESOURCE_TYP_EFFDT, SPL_RESOURCE_TYPE, SPL_RES_TYP_EFFDT, BM_STATION_NAME, BM_STAT_NAME_EFFDT,
                METER_TYPE, METER_TYPE_EFFDT, NBMTOBM_MAP, NBMTOBM_MAP_EFFDT, ERROR_CODE, DATE_CREATED)
        VALUES (pi_load_seq_nbr, q.UNIT_CODE, q.EFFECTIVE, q.GOAL_UNIT_CODE, q.BM_UNIT_CODE, q.REG_STATION_NAME, q.RESOURCE_TYPE, q.RESOURCE_TYP_EFFDT, q.SPL_RESOURCE_TYPE, q.SPL_RES_TYP_EFFDT,
                q.BM_STATION_NAME, q.BM_STAT_NAME_EFFDT, q.METER_TYPE, q.METER_TYPE_EFFDT, q.NBMTOBM_MAP, q.NBMTOBM_MAP_EFFDT, q.error_code,sysdate);
  end if;

  if(lv_vc_rec_unit_count > 0 and lv_vc_rec_csv_count = 0) then
    INSERT INTO TRN_UNIT (LOAD_SEQ_NBR, ASB_UNIT_CODE,EFFECTIVE, GOAL_UNIT_CODE, BM_UNIT_CODE, REG_STATION_NAME, DATE_CREATED)
    (SELECT pi_load_seq_nbr, a.ASB_UNIT_CODE, a.EFFECTIVE, a.GOAL_UNIT_CODE, a.BM_UNIT_CODE, a.REG_STATION_NAME,SYSDATE from ASB_UNIT_STG a where a.load_seq_nbr = pi_load_seq_nbr);
  end if;


    PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'SUCCESS','ASB_UNIT_STG and RESOURCE_CSV merged sucessfully!!!','RESOURCE');
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'SUCCESS','No new data found for sequence number '||pi_load_seq_nbr,'RESOURCE');
    RAISE;
    
    WHEN OTHERS THEN
    PROC_PROCESS_LOG('PR_TRN_RESOURCE_LOAD',pi_load_seq_nbr,'FAILURE',SQLERRM,'RESOURCE');
    RAISE;


END;

END;

/

