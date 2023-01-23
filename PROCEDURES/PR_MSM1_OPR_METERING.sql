--------------------------------------------------------
--  DDL for Procedure PR_MSM1_OPR_METERING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_OPR_METERING" (pi_load_seq_nbr IN NUMBER,
                                                  pi_effective    IN DATE)
/**************************************************************************************
*
* Program Name           :PR_MSM1_OPR_METERING
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :15-09-2021
* Description            :This is a PL/SQL procedure. This procedure process the data from
                          ASB_STG table system table(SRD_METERING) to MSM_STG1 (D!_MSRMT_METERING)
                          table.
*                          
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/

AS
  
  CURSOR cur_SRD IS
        SELECT srd1.* ,NVL(srd1.REC_LEVEL,0) as MSRMT_VAL,
        NVL(srd2.REC_LEVEL,0) as MSRMT_VAL1
        ,NVL2(srd2.EFFECTIVE,501000,201000)as MSRMT_COND_FLG
        , srd2.EFFECTIVE as SRD2_EFF
        ,mcid.measr_comp_id
        ,FN_CONVERT_GMT_BST1(srd1.msrmt_dttm) AS msrmt_local_dttm
    from MV_MTR_SRD_METERING_STG srd1 
            LEFT OUTER JOIN
     MV_MTR_SRD_METERING_STG srd2
     ON
     (
        srd1.ASB_UNIT_CODE = srd2.ASB_UNIT_CODE
        AND srd1.EFF_MTR_DELAY = srd2.EFFECTIVE
        AND srd1.CONTRACT_NUMBER = srd2.CONTRACT_NUMBER
     )
     LEFT OUTER JOIN
     MV_MEASR_COMP_ID mcid
     ON (srd1.ASB_UNIT_CODE= mcid.id_value
         AND mcid.MEASR_COMP_TYPE_CD = 'SRDMETER'
        )
     where srd1.load_seq_nbr = pi_load_seq_nbr 
     AND srd1.effective < (TRUNC(pi_effective)+1)
--     AND srd1.effective < to_date('13-OCT-2016 00:00:00','DD-MON-YYYY HH24:MI:SS')
     ;
  
  TYPE T_SRD_METERING_STG_A IS TABLE OF cur_SRD%ROWTYPE;
  tab_SRD_METER T_SRD_METERING_STG_A;
 
  
BEGIN

    COMMIT;
    MSM_STG1.PR_TRUNCATE_TABLE_MSMSTG1('D1_MSRMT_METERING');
    
    OPEN cur_SRD;

    LOOP
        FETCH cur_srd BULK COLLECT INTO tab_SRD_METER LIMIT 5000;
        EXIT WHEN tab_SRD_METER.count = 0;

        FORALL x IN tab_SRD_METER.first..tab_SRD_METER.last
          INSERT INTO msm_stg1.d1_msrmt_metering
                      (load_seq_nbr,measr_comp_id,msrmt_dttm,bo_status_cd,msrmt_cond_flg,msrmt_use_flg,
                       msrmt_local_dttm,msrmt_val,orig_init_msrmt_id,prev_msrmt_dttm,msrmt_val1,msrmt_val2,
                       msrmt_val3,msrmt_val4,msrmt_val5,msrmt_val6,msrmt_val7,msrmt_val8,
                       msrmt_val9,msrmt_val10,bus_obj_cd,cre_dttm,status_upd_dttm,
                       user_edited_flg,version,last_update_dttm,reading_val,combined_multiplier,
                       reading_cond_flg,date_created)
                       VALUES      
                       ( pi_load_seq_nbr, tab_SRD_METER(x).measr_comp_id, tab_SRD_METER(x).msrmt_dttm,
                       'OK', tab_SRD_METER(x).msrmt_cond_flg,
                       ' ', tab_SRD_METER(x).msrmt_local_dttm,
                       tab_SRD_METER(x).msrmt_val, 'SRDMETER',
                       '', tab_SRD_METER(x).msrmt_val1,
                       tab_SRD_METER(x).msrmt_cond_flg, '0',
                       '0', '0', '0', '0', '0',
                       '0', '0', 'D1-Measurement',
                       SYSDATE, SYSDATE,
                       ' ', '99', SYSDATE, '', '1', '',
                       SYSDATE );
  
    END LOOP;

    CLOSE cur_SRD;
    
    INSERT INTO MSM_STG1.D1_MSRMT_METERING_AUDIT  select * from MSM_STG1.D1_MSRMT_METERING ;

EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     PR_PROCESS_LOG('PR_MSM1_OPR_METERING',pi_load_seq_nbr,'FAILURE',SUBSTR(SQLERRM,1,400));
     DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
     
END PR_MSM1_OPR_METERING;

/

