--------------------------------------------------------
--  DDL for Package Body PKG_BM_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "ASB_STG"."PKG_BM_PROFILE" AS
 /*************************************************************************
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------_
     19/05/2022     1.1   Shailesh Solanki             Initial Version
     16/08/2022     1.2   Shailesh Solanki             Code changes done as part of defect fixing
     *************************************************************************/
  PROCEDURE PR_BM_PROFILE_MAIN(p_VERSION IN NUMBER) AS
  v_LOAD_SEQ_NBR NUMBER;
  BEGIN




    NULL;
  EXCEPTION

    WHEN OTHERS then
    ROLLBACK;
    PROC_PROCESS_LOG('PR_BM_PROFILE_MAIN ',v_LOAD_SEQ_NBR,'FAILURE', SQLCODE||' '||SUBSTR(sqlerrm,1,500),'BMPROFILE');  

  END PR_BM_PROFILE_MAIN;
--------------------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------
  -- PR_LOAD_ASBSTG_BM_PROFILE
  ------------------------------------------------
  PROCEDURE PR_LOAD_ASBSTG_BM_PROFILE(p_START_DATE DATE, p_END_DATE DATE, p_RANK NUMBER, p_load_seq_nbr IN number,p_VERSION IN NUMBER) AS
  v_SYSDATE DATE;

  BEGIN

    select SYSDATE into v_SYSDATE from dual ;

--    EXECUTE IMMEDIATE 'truncate table PN_OPERATION_STG';

--    LOOP
        INSERT INTO PN_OPERATION_STG2 (LOAD_SEQ_NBR,ASB_UNIT_CODE, EFFECTIVE, RANK, OP_LEVEL, FILE_DATE, ITEM_CODE,DATE_CREATED,c_PREV_MSRMT_DTTM)
        SELECT p_load_seq_nbr,ASB_UNIT_CODE, EFFECTIVE, RANK, OP_LEVEL, FILE_DATE, ITEM_CODE, v_SYSDATE,
        LAG(p1.effective) OVER(PARTITION BY p1.asb_unit_code, p1.rank  ORDER BY p1.asb_unit_code,p1.effective)    
        from PN_OPERATION p1
        where RANK = p_RANK and EFFECTIVE >= p_START_DATE AND EFFECTIVE < trunc(p_END_DATE+1);

--        UPDATE PN_OPERATION_STG2 set asb_unit_code = 'BURWB-1' where asb_unit_code like 'E_BURWB-1%' ;
--        UPDATE PN_OPERATION_STG2 set asb_unit_code = 'ARNKB-2' where asb_unit_code like 'E_ARNKB-2%' ;

        COMMIT;

--    END LOOP;

    PROC_PROCESS_LOG('PR_LOAD_ASBSTG_BM_PROFILE',p_load_seq_nbr,'SUCCESS','PR_LOAD_ASBSTG_BM_PROFILE Completed','BMPROFILE');

    EXCEPTION

        WHEN OTHERS then
        ROLLBACK;
        PROC_PROCESS_LOG('PR_LOAD_ASBSTG_BM_PROFILE ',p_LOAD_SEQ_NBR,'FAILURE', SQLCODE||' '||SUBSTR(sqlerrm,1,500),'BMPROFILE');  
        RAISE;
  END PR_LOAD_ASBSTG_BM_PROFILE;
--------------------------------------------------------------------------------------------------------------------------------------
  ------------------------------------------------
  -- PR_MSM1_BM_PROFILE
  ------------------------------------------------
  PROCEDURE PR_MSM1_BM_PROFILE(p_LOAD_SEQ_NBR IN NUMBER,p_VERSION IN NUMBER,p_RANK NUMBER,p_START_DATE DATE,p_END_DATE DATE) AS

    CURSOR cur_PN_OPER(p_MEASR_COMP_TYPE_CD VARCHAR2) IS
        select p1.ASB_UNIT_CODE, p1.EFFECTIVE, p1.C_PREV_MSRMT_DTTM, p1.RANK, p1.OP_LEVEL, p1.FILE_DATE, p1.ITEM_CODE, p1.LOAD_SEQ_NBR, p1.DATE_CREATED,
        m1.MEASR_COMP_ID as measr_comp_id 
--        LAG(p1.effective) OVER(PARTITION BY p1.asb_unit_code  ORDER BY p1.asb_unit_code,p1.effective) AS c_PREV_MSRMT_DTTM
        from pn_operation_stg2 p1 LEFT JOIN MV_MEASR_COMP_ID m1
        ON (trim(m1.ID_VALUE) = trim(p1.ASB_UNIT_CODE) AND MEASR_COMP_TYPE_CD = p_MEASR_COMP_TYPE_CD)
        where EFFECTIVE >= p_START_DATE AND EFFECTIVE < trunc(p_END_DATE + 1)
        AND p1.RANK = p_RANK and LOAD_SEQ_NBR = p_LOAD_SEQ_NBR
        ;

  TYPE T_PN_OPER_STG_A IS TABLE OF cur_PN_OPER%ROWTYPE;
  tab_PN_OPER T_PN_OPER_STG_A;

  v_orig_init_msrmt_id VARCHAR2(20) := NULL;

  BEGIN

    IF (p_RANK = 1) THEN
        v_orig_init_msrmt_id := 'BMSTARTMIN';
    ELSIF (p_RANK = 2) THEN
        v_orig_init_msrmt_id := 'BMENDMIN';
    END IF;

    MSM_STG1.PR_TRUNCATE_TABLE_MSMSTG1('D1_MSRMT_BM_PROFILE_TEMP');

    OPEN cur_PN_OPER(v_orig_init_msrmt_id);

    LOOP
        FETCH cur_PN_OPER BULK COLLECT INTO tab_PN_OPER LIMIT 5000;
        EXIT WHEN tab_PN_OPER.count = 0;

        FORALL x IN tab_PN_OPER.first..tab_PN_OPER.last
          INSERT INTO msm_stg1.d1_msrmt_bm_profile_TEMP
                      (load_seq_nbr,measr_comp_id,msrmt_dttm,bo_status_cd,msrmt_cond_flg,msrmt_use_flg,
                       msrmt_local_dttm,msrmt_val,orig_init_msrmt_id,prev_msrmt_dttm,msrmt_val1,msrmt_val2,
                       msrmt_val3,msrmt_val4,msrmt_val5,msrmt_val6,msrmt_val7,msrmt_val8,
                       msrmt_val9,msrmt_val10,bus_obj_cd,cre_dttm,status_upd_dttm,
                       user_edited_flg,version,last_update_dttm,reading_val,combined_multiplier,
                       reading_cond_flg,date_created)
                       VALUES      
                       ( p_load_seq_nbr, tab_PN_OPER(x).measr_comp_id, tab_PN_OPER(x).EFFECTIVE,
                       'OK', 501000,
                       ' ', FN_CONVERT_GMT_BST1(tab_PN_OPER(x).EFFECTIVE),
                       tab_PN_OPER(x).OP_LEVEL, v_orig_init_msrmt_id,
                       tab_PN_OPER(x).c_PREV_MSRMT_DTTM
                       , '0',
                       '0', '0',
                       '0', '0', '0', '0', '0',
                       '0', '0', 'D1-Measurement',
                       SYSDATE, SYSDATE,
                       ' ', p_VERSION, SYSDATE, tab_PN_OPER(x).OP_LEVEL, '1', '',
                       SYSDATE );

    END LOOP;

    CLOSE cur_PN_OPER;

    INSERT INTO MSM_STG1.d1_msrmt_bm_profile  select * from MSM_STG1.d1_msrmt_bm_profile_TEMP ;
    COMMIT;

    PROC_PROCESS_LOG('PR_MSM1_BM_PROFILE',p_load_seq_nbr,'SUCCESS','PR_MSM1_BM_PROFILE Completed','BMPROFILE');

 EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     PROC_PROCESS_LOG('PR_MSM1_BM_PROFILE',p_load_seq_nbr,'FAILURE',SUBSTR(SQLERRM,1,400),'BMPROFILE');
     DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
     RAISE;
  END PR_MSM1_BM_PROFILE;
--------------------------------------------------------------------------------------------------------------------------------------
  -------------------------------------------
  -- PR_MSM2_BM_PROFILE
  -------------------------------------------
  PROCEDURE PR_MSM2_BM_PROFILE(p_LOAD_SEQ_NBR IN NUMBER,p_VERSION IN NUMBER) AS
  BEGIN

    -- Clean the MSM_STG2 Table d1_msrmt_bm_profile
    MSM_STG2.PR_TRUNCATE_TABLE_MSMSTG2('d1_msrmt_bm_profile');

    INSERT INTO MSM_STG2.d1_msrmt_bm_profile  
    select MEASR_COMP_ID, MSRMT_DTTM, BO_STATUS_CD, MSRMT_COND_FLG, MSRMT_USE_FLG, MSRMT_LOCAL_DTTM, MSRMT_VAL, ' ', PREV_MSRMT_DTTM,
    MSRMT_VAL1, MSRMT_VAL2, MSRMT_VAL3, MSRMT_VAL4, MSRMT_VAL5, MSRMT_VAL6, MSRMT_VAL7, MSRMT_VAL8, MSRMT_VAL9, MSRMT_VAL10, BUS_OBJ_CD, CRE_DTTM, STATUS_UPD_DTTM,
    USER_EDITED_FLG, VERSION, LAST_UPDATE_DTTM, READING_VAL, COMBINED_MULTIPLIER, READING_COND_FLG 
    from MSM_STG1.d1_msrmt_bm_profile_TEMP ;

    PROC_PROCESS_LOG('PR_MSM2_BM_PROFILE',p_load_seq_nbr,'SUCCESS','PR_MSM2_BM_PROFILE Completed','BMPROFILE');

    COMMIT;

 EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     PROC_PROCESS_LOG('PR_MSM2_BM_PROFILE',p_load_seq_nbr,'FAILURE',SUBSTR(SQLERRM,1,400),'BMPROFILE');
     DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
     RAISE;
  END PR_MSM2_BM_PROFILE;
--------------------------------------------------------------------------------------------------------------------------------------  
  -------------------------------------------
  -- PR_CISADM_BM_PROFILE
  -------------------------------------------
  PROCEDURE PR_CISADM_BM_PROFILE(p_LOAD_SEQ_NBR IN NUMBER,p_VERSION IN NUMBER) AS
  BEGIN
    
    DELETE from MSM_STG2.d1_msrmt_bm_profile where MEASR_COMP_ID IS NULL;
    COMMIT;
    
    INSERT INTO CISADM.d1_msrmt@STG_MSM_LINK 
    select MEASR_COMP_ID, MSRMT_DTTM, BO_STATUS_CD, MSRMT_COND_FLG, MSRMT_USE_FLG, MSRMT_LOCAL_DTTM, MSRMT_VAL, ORIG_INIT_MSRMT_ID, PREV_MSRMT_DTTM,
    MSRMT_VAL1, MSRMT_VAL2, MSRMT_VAL3, MSRMT_VAL4, MSRMT_VAL5, MSRMT_VAL6, MSRMT_VAL7, MSRMT_VAL8, MSRMT_VAL9, MSRMT_VAL10, BUS_OBJ_CD, CRE_DTTM, STATUS_UPD_DTTM,
    USER_EDITED_FLG, VERSION, LAST_UPDATE_DTTM, READING_VAL, COMBINED_MULTIPLIER, READING_COND_FLG 
    from MSM_STG2.d1_msrmt_bm_profile ;

 EXCEPTION
     WHEN OTHERS THEN
     ROLLBACK;
     PROC_PROCESS_LOG('PR_CISADM_BM_PROFILE',p_load_seq_nbr,'FAILURE',SUBSTR(SQLERRM,1,400),'BMPROFILE');
     DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
    RAISE;
  END PR_CISADM_BM_PROFILE;

END PKG_BM_PROFILE;

/

