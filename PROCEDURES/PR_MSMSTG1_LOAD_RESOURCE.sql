--------------------------------------------------------
--  DDL for Procedure PR_MSMSTG1_LOAD_RESOURCE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSMSTG1_LOAD_RESOURCE" 
/**************************************************************************************
*
* Program Name           :PR_MSMSTG1_LOAD_RESOURCE
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-03-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M table's 
*                         format and tranfer data from TRN_UNIT, TRN_MONITORING to 6
*                         different tables of MSM_STG1 schema.
*                        
*
* Calling Program        :PR_ASB_LOAD_RESOURCE_MAIN
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
(p_LOAD_SEQ_NBR IN NUMBER) as

v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);

v_CHK NUMBER :=0;
v_PREM_ID NUMBER;
v_D1_SP_ID NUMBER;
v_CNT NUMBER;
v_NBM_STOR_MNTR VARCHAR2(10);
v_NBM_HEAD_MTR VARCHAR2(10);
v_BO_DATA_AREA MSM_STG1.D1_SP.BO_DATA_AREA%TYPE;

CURSOR cur_ASB_UNIT is 
SELECT distinct ASB_UNIT_CODE from TRN_UNIT t  where t.load_seq_nbr = p_LOAD_SEQ_NBR ;

BEGIN
    
   FOR rec in cur_ASB_UNIT
   LOOP
          v_CNT := 0;
          select count(1) into v_CNT from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = rec.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI';
          
          IF (v_CNT > 0) THEN
              select max(D1_SP_ID) into v_D1_SP_ID from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = rec.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI';
              select max(ID_VALUE) into v_PREM_ID from MSM_STG1.D1_SP_IDENTIFIER dsi where
                dsi.d1_sp_id in (select max(D1_SP_ID) from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = rec.ASB_UNIT_CODE  AND SP_ID_TYPE_FLG = 'D1MI')
                AND SP_ID_TYPE_FLG = 'D1EP';
          ELSE
              v_PREM_ID := SQ_RESO_CI_PREM_ID.nextval;
              v_D1_SP_ID := SQ_RESO_D1_SP_ID.nextval;
          END IF ;
          
          v_CNT := 0;
          select count(1) into v_CNT from SRS_MONITORING_STG where ASB_UNIT_CODE = rec.ASB_UNIT_CODE;
                
          IF (v_CNT > 0) THEN
            v_NBM_STOR_MNTR := 'true';
          ELSE
            v_NBM_STOR_MNTR := 'false';
          END IF;
          
          v_CNT := 0;
          select count(1) into v_CNT from SRS_HEADROOM_METER_STG where ASB_UNIT_CODE = rec.ASB_UNIT_CODE;      
          IF (v_CNT > 0) THEN
            v_NBM_HEAD_MTR := 'true';
          ELSE
            v_NBM_HEAD_MTR := 'false';
          END IF;
          
          v_BO_DATA_AREA := '<multiItems/><resource><nbmStorHeadroomMeter>' || v_NBM_HEAD_MTR
          || '</nbmStorHeadroomMeter><nbmStorMonitoring>' || v_NBM_STOR_MNTR || '</nbmStorMonitoring></resource>';
          
        ----------------------------------------------------------------
        ---------------- Load data in Table MSM_STG1.D1_SP -------------
        ----------------------------------------------------------------
        INSERT INTO MSM_STG1.D1_SP(LOAD_SEQ_NBR,D1_SP_ID,D1_SP_TYPE_CD,MSRMT_CYC_RTE_SEQ,TIME_ZONE_CD,D1_LS_SL_FLG,COUNTRY,ADDRESS1,ADDRESS1_UPPER,
        BUS_OBJ_CD,BO_STATUS_CD,STATUS_UPD_DTTM, CRE_DTTM,VERSION,SP_SRC_STAT_FLG,D1_GEO_LAT,D1_GEO_LONG,BO_DATA_AREA,DATE_CREATED)
                   select p_LOAD_SEQ_NBR,
                   v_D1_SP_ID ,
                  'ANC' as D1_SP_TYPE_CD, 0 as MSRMT_CYC_RTE_SEQ, 'UK' as TIME_ZONE_CD,
                  'N' as D1_LS_SL_FLG, 'UK' as COUNTRY, 
                   rec.ASB_UNIT_CODE as ADDRESS1, UPPER(rec.ASB_UNIT_CODE) as ADDRESS1_UPPER,
                   'CM-Resource' as BUS_OBJ_CD, 'ACTIVE' as BO_STATUS_CD, SYSDATE as STATUS_UPD_DTTM, SYSDATE as CRE_DTTM, 99 as VERSION,
                   'D1CN' as SP_SRC_STAT_FLG, '0' as D1_GEO_LAT, '0' as D1_GEO_LONG,
                   v_BO_DATA_AREA as BO_DATA_AREA, SYSDATE as DATE_CREATED from dual;
          
        ----------------------------------------------------------------
        ------------ Load data in Table MSM_STG1.CI_PREM ---------------
        ----------------------------------------------------------------
        INSERT INTO MSM_STG1.CI_PREM (LOAD_SEQ_NBR,PREM_ID,PREM_TYPE_CD,KEY_SW,OK_TO_ENTER_SW,ADDRESS1,MAIL_ADDR_SW,COUNTRY,VERSION,ADDRESS1_UPR,LS_SL_FLG,DATE_CREATED)
        values(p_LOAD_SEQ_NBR,v_PREM_ID ,'GEN', 'N', 'N', rec.ASB_UNIT_CODE, 'N', 'UK', 99, UPPER(rec.ASB_UNIT_CODE), 'N', SYSDATE);
                   
        ----------------------------------------------------------------
        --------- Load data in Table MSM_STG1.D1_SP_IDENTIFIER ---------
        ----------------------------------------------------------------
        INSERT INTO MSM_STG1.D1_SP_IDENTIFIER(LOAD_SEQ_NBR,D1_SP_ID,SP_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED) values(p_LOAD_SEQ_NBR, v_D1_SP_ID,'D1MI', rec.ASB_UNIT_CODE,99, SYSDATE);
                   
        INSERT INTO MSM_STG1.D1_SP_IDENTIFIER(LOAD_SEQ_NBR,D1_SP_ID,SP_ID_TYPE_FLG,ID_VALUE,VERSION,DATE_CREATED) values( p_LOAD_SEQ_NBR,v_D1_SP_ID, 'D1EP', v_PREM_ID,99,  SYSDATE);
   
   END LOOP;
   

    ----------------------------------------------------------------
    ------------ Load data in Table MSM_STG1.D1_SP_CHAR ------------
    ----------------------------------------------------------------
    
    -- GOAL_UNIT_CODE
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BMUNM' AS CHAR_TYPE_CD, (TU.EFFECTIVE) AS EFFDT, ' ' AS CHAR_VAL,TU.GOAL_UNIT_CODE AS ADHOC_CHAR_VAL,
              UPPER(TU.GOAL_UNIT_CODE) AS SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.EFFECTIVE IS NOT NULL 
              AND TU.GOAL_UNIT_CODE IS NOT NULL;

    -- BM_UNIT_CODE              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-ELBMU' AS CHAR_TYPE_CD, (TU.EFFECTIVE) AS EFFDT,' ' AS CHAR_VAL, TU.BM_UNIT_CODE AS ADHOC_CHAR_VAL,
              UPPER(TU.BM_UNIT_CODE) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.EFFECTIVE IS NOT NULL
              AND TU.BM_UNIT_CODE IS NOT NULL;
           
    -- REG_STATION_NAME              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-EBSRE' as CHAR_TYPE_CD, (tu.effective) as EFFDT,' ' AS CHAR_VAL, TU.REG_STATION_NAME as ADHOC_CHAR_VAL,
              UPPER(TU.REG_STATION_NAME) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.EFFECTIVE IS NOT NULL
              AND TU.REG_STATION_NAME IS NOT NULL;

    -- BM_STATION_NAME              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BMSTN' AS CHAR_TYPE_CD, (TU.BM_STAT_NAME_EFFDT) AS EFFDT,' ' AS CHAR_VAL, TU.BM_STATION_NAME AS ADHOC_CHAR_VAL,
              UPPER(TU.BM_STATION_NAME) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.BM_STAT_NAME_EFFDT IS NOT NULL
              AND TU.BM_STATION_NAME IS NOT NULL;     
            
    -- RESOURCE_TYPE              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-RESTY' as CHAR_TYPE_CD, (TU.RESOURCE_TYP_EFFDT) as EFFDT, TU.RESOURCE_TYPE as CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(TU.RESOURCE_TYPE) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.RESOURCE_TYP_EFFDT IS NOT NULL
              AND TU.RESOURCE_TYPE IS NOT NULL;
     
    -- SPL_RESOURCE_TYPE              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-SPRES' AS CHAR_TYPE_CD, (TU.SPL_RES_TYP_EFFDT) AS EFFDT, CASE TU.SPL_RESOURCE_TYPE 
                WHEN 'Renewable - Wind' THEN 'RENWIND'
                WHEN 'Renewable - Other' THEN 'RENOTHR'
                WHEN 'Battery' THEN 'BATTERY'
                WHEN 'Aggregator' THEN 'AGGR'
                ELSE TU.SPL_RESOURCE_TYPE
                END CHAR_VAL,' ' AS ADHOC_CHAR_VAL,
              CASE TU.SPL_RESOURCE_TYPE 
                WHEN 'Renewable - Wind' THEN 'RENWIND'
                WHEN 'Renewable - Other' THEN 'RENOTHR'
                WHEN 'Battery' THEN 'BATTERY'
                WHEN 'Aggregator' THEN 'AGGR'
                ELSE UPPER(TU.SPL_RESOURCE_TYPE)
                END SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.SPL_RES_TYP_EFFDT IS NOT NULL
              AND TU.SPL_RESOURCE_TYPE IS NOT NULL;

    -- METER_TYPE              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-METYP' AS CHAR_TYPE_CD, (TU.METER_TYPE_EFFDT) AS EFFDT, TU.METER_TYPE AS CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(TU.METER_TYPE) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.METER_TYPE_EFFDT IS NOT NULL
              AND TU.METER_TYPE IS NOT NULL;
      
    -- NBMTOBM_MAP              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BMNBM' AS CHAR_TYPE_CD, (TU.NBMTOBM_MAP_EFFDT) AS EFFDT,' ' AS CHAR_VAL, TU.NBMTOBM_MAP AS ADHOC_CHAR_VAL,
              UPPER(TU.NBMTOBM_MAP) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_UNIT TU WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TU.NBMTOBM_MAP_EFFDT IS NOT NULL
              AND TU.NBMTOBM_MAP IS NOT NULL;

    -- BAD_METER_FLAG              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BDMFG' AS CHAR_TYPE_CD, (TM.EFFECTIVE) AS EFFDT, TM.BAD_METER_FLAG AS CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(TM.BAD_METER_FLAG) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_MONITORING TM WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TM.EFFECTIVE IS NOT NULL
              AND TM.BAD_METER_FLAG IS NOT NULL;
 
    -- METER_DELAY              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-MTDEL' AS CHAR_TYPE_CD, (TM.EFFECTIVE) AS EFFDT,' ' AS CHAR_VAL, TM.METER_DELAY AS ADHOC_CHAR_VAL,
              UPPER(TM.METER_DELAY) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_MONITORING TM WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TM.EFFECTIVE IS NOT NULL
              AND TM.METER_DELAY IS NOT NULL;

    -- NEGATIVE_LOAD              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-ADDCA' AS CHAR_TYPE_CD, (TM.EFFECTIVE) AS EFFDT,' ' AS CHAR_VAL, TM.NEGATIVE_LOAD AS ADHOC_CHAR_VAL,
              UPPER(TM.NEGATIVE_LOAD) as SRCH_CHAR_VAL,
              99 AS VERSION, SYSDATE AS DATE_CREATED FROM ASB_STG.TRN_MONITORING TM WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND TM.EFFECTIVE IS NOT NULL
              AND TM.NEGATIVE_LOAD IS NOT NULL;

    -- BASE_LOAD_LEAD              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BSELD' as CHAR_TYPE_CD, (TM.EFFECTIVE) as EFFDT,' ' AS CHAR_VAL, TM.BASE_LOAD_LEAD as ADHOC_CHAR_VAL,
              UPPER(TM.BASE_LOAD_LEAD) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.TRN_MONITORING TM where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND tm.EFFECTIVE IS NOT NULL
              AND TM.BASE_LOAD_LEAD IS NOT NULL;   

    -- BASE_LOAD_LAG              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BSLAG' as CHAR_TYPE_CD, (TM.EFFECTIVE) as EFFDT,' ' AS CHAR_VAL, TM.BASE_LOAD_LAG as ADHOC_CHAR_VAL,
              UPPER(TM.BASE_LOAD_LAG) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.TRN_MONITORING TM where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND tm.EFFECTIVE IS NOT NULL
              AND TM.BASE_LOAD_LAG IS NOT NULL;   
     
    -- BASE_LOAD_SUM              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-BLDCL' as CHAR_TYPE_CD, (TM.EFFECTIVE) as EFFDT, TM.BASE_LOAD_SUM as CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(TM.BASE_LOAD_SUM) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.TRN_MONITORING TM where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND tm.EFFECTIVE IS NOT NULL
              AND TM.BASE_LOAD_SUM IS NOT NULL;   
  
    -- MAX_MW              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-MAXMW' as CHAR_TYPE_CD, (TM.MAX_MW_EFFDT) as EFFDT,' ' AS CHAR_VAL, TM.MAX_MW as ADHOC_CHAR_VAL,
              UPPER(TM.MAX_MW) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.TRN_MONITORING TM where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND tm.MAX_MW_EFFDT IS NOT NULL
              AND TM.MAX_MW IS NOT NULL;   
 
    -- SERVICE_PROVISION              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (select max(D1_SP_ID) from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = TM.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') as D1_SP_ID,
              'CM-SRPVS' as CHAR_TYPE_CD, TM.SERVICE_PROVISION_EFFDT as EFFDT, TM.SERVICE_PROVISION as CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(TM.SERVICE_PROVISION) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.TRN_MONITORING TM where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND tm.SERVICE_PROVISION_EFFDT IS NOT NULL
              AND TM.SERVICE_PROVISION IS NOT NULL;   
   
    -- AVAIL_HEADROOM              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = H.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-AVHDR' as CHAR_TYPE_CD, (H.EFFECTIVE_FROM) as EFFDT, DECODE(H.AVAIL_HEADROOM,'H','Y','M','N') as CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(DECODE(H.AVAIL_HEADROOM,'H','Y','M','N')) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.SRS_HEADROOM_METER_STG H where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND h.EFFECTIVE_FROM IS NOT NULL
              AND H.AVAIL_HEADROOM IS NOT NULL;   

    -- UTIL_HEADROOM              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              SELECT DISTINCT P_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = H.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-ULHDR' as CHAR_TYPE_CD, (H.EFFECTIVE_FROM) as EFFDT, DECODE(H.UTIL_HEADROOM,'H','Y','M','N') as CHAR_VAL,' ' as ADHOC_CHAR_VAL,
              UPPER(DECODE(H.UTIL_HEADROOM,'H','Y','M','N')) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.SRS_HEADROOM_METER_STG H where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND h.EFFECTIVE_FROM IS NOT NULL
              AND H.UTIL_HEADROOM IS NOT NULL;   
    
    -- AVAIL_METER              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (select max(D1_SP_ID) from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = H.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') as D1_SP_ID,
              'CM-AVMDT' as CHAR_TYPE_CD, H.EFFECTIVE_FROM as EFFDT,' ' AS CHAR_VAL, H.AVAIL_METER as ADHOC_CHAR_VAL,
              UPPER(H.AVAIL_METER) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.SRS_HEADROOM_METER_STG H where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND H.EFFECTIVE_FROM IS NOT NULL
              AND H.AVAIL_METER IS NOT NULL;   
     
    -- UTIL_METER              
    INSERT INTO MSM_STG1.D1_SP_CHAR(LOAD_SEQ_NBR,D1_SP_ID,CHAR_TYPE_CD,EFFDT,CHAR_VAL,ADHOC_CHAR_VAL,SRCH_CHAR_VAL,VERSION,DATE_CREATED)
              select DISTINCT p_LOAD_SEQ_NBR,
              (SELECT MAX(D1_SP_ID) FROM MSM_STG1.D1_SP_IDENTIFIER DSI WHERE DSI.ID_VALUE = H.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') AS D1_SP_ID,
              'CM-UTMDT' as CHAR_TYPE_CD, (H.EFFECTIVE_FROM) as EFFDT,' ' AS CHAR_VAL, H.UTIL_METER as ADHOC_CHAR_VAL,
              UPPER(H.UTIL_METER) as SRCH_CHAR_VAL,
              99 as VERSION, SYSDATE as DATE_CREATED from ASB_STG.SRS_HEADROOM_METER_STG H where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND h.EFFECTIVE_FROM IS NOT NULL
              AND H.UTIL_METER IS NOT NULL;   
         
    ----------------------------------------------------------------
    --------- Load data in Table MSM_STG1.D1_SP_LOG ----------------
    ----------------------------------------------------------------
    INSERT INTO MSM_STG1.D1_SP_LOG(LOAD_SEQ_NBR,D1_SP_ID,SEQNO,BO_STATUS_CD,LOG_DTTM,LOG_ENTRY_TYPE_FLG,MESSAGE_CAT_NBR,MESSAGE_NBR,USER_ID,VERSION,DATE_CREATED)
               select p_LOAD_SEQ_NBR,
              (select max(D1_SP_ID) from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') as D1_SP_ID,
               1 as SEQNO, 'ACTIVE' as BO_STATUS_CD,SYSDATE as LOG_DTTM,'F1CR' as LOG_ENTRY_TYPE_FLG,
               11002 as MESSAGE_CAT_NBR, 12151 as MESSAGE_NBR, 'MIGD' as USER_ID, 99 as VERSION,  SYSDATE as DATE_CREATED from ASB_STG.TRN_UNIT TU where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR;
    
    ----------------------------------------------------------------
    --------- Load data in Table MSM_STG1.D1_SP_LOG_PARM -----------
    ----------------------------------------------------------------
    INSERT INTO MSM_STG1.D1_SP_LOG_PARM(LOAD_SEQ_NBR,D1_SP_ID,SEQNO,PARM_SEQ,MSG_PARM_VAL,VERSION,DATE_CREATED)
               select p_LOAD_SEQ_NBR,
              (select max(D1_SP_ID) from MSM_STG1.D1_SP_IDENTIFIER dsi where dsi.ID_VALUE = TU.ASB_UNIT_CODE AND SP_ID_TYPE_FLG = 'D1MI') as D1_SP_ID,
               1 as SEQNO, 2 as PARM_SEQ,'Active' as MSG_PARM_VAL, 99 as VERSION,  SYSDATE as DATE_CREATED from ASB_STG.TRN_UNIT TU where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR;
   
   ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_RESOURCE',p_LOAD_SEQ_NBR,'SUCCESS','Data transfer successful from ASB_STG to MSM_STG1 for RESOURCE','RESOURCE');

    EXCEPTION
      WHEN OTHERS then
        ROLLBACK;
        ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_RESOURCE',p_LOAD_SEQ_NBR,'FAILURE',SUBSTR(sqlerrm,1,2000),'RESOURCE');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
        RAISE;

END PR_MSMSTG1_LOAD_RESOURCE;

/
