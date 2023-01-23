--------------------------------------------------------
--  DDL for Procedure PR_MSMSTG1_LOAD_COMPANY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSMSTG1_LOAD_COMPANY" 
/**************************************************************************************
*
* Program Name           :PR_MSMSTG1_LOAD_COMPANY
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :09-03-2021
* Description            :This is a PL/SQL procedure. This procedure splits data into C2M table's
*                         format and tranfer data from TRN_COMPANY to 7 different tables of MSM_STG1 schema.
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*09-FEB-2022             Sirisha                    Code modified on (CI_PER_NAME) based on defect SRPTEAM-9809
**************************************************************************************/
(p_LOAD_SEQ_NBR IN NUMBER) as
v_date  DATE;
v_LOAD_SEQ_NBR NUMBER;
v_ERROR VARCHAR2(1000);
v_cnt NUMBER :=0;
v_cnt2 NUMBER;

v_PER_ID MSM_STG1.CI_PER_ID.PER_ID%TYPE;
v_CONTACT_VALUE MSM_STG1.C1_PER_CONTDET.CONTACT_VALUE%TYPE;
v_CONTACT_NAME MSM_STG1.C1_PER_CONTDET.CONTACT_NAME%TYPE;

CURSOR cur_CI_PER_NAME_CHAR is SELECT distinct t.*,c.per_id
    from TRN_COMPANY t, MSM_STG1.CI_PER_ID c
    where t.asb_comp_code = c.per_id_nbr AND t.load_seq_nbr = p_LOAD_SEQ_NBR
    AND t.rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code);

CURSOR cur_CI_PER_CHAR_VATPERC is SELECT distinct t.*,c.per_id
    FROM TRN_COMPANY T, MSM_STG1.CI_PER_ID C
    where t.asb_comp_code = c.per_id_nbr AND t.load_seq_nbr = p_LOAD_SEQ_NBR AND T.VAT_PERC_EFFECTIVEDT IS NOT NULL
    AND t.rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code,VAT_PERC,VAT_PERC_EFFECTIVEDT)
    AND (t.ERROR_CODE NOT IN (106,102,104,105) OR t.ERROR_CODE IS NULL);

CURSOR cur_CI_PER_CHAR_VATCODE is SELECT distinct t.*,c.per_id
    FROM TRN_COMPANY T, MSM_STG1.CI_PER_ID C
    where t.asb_comp_code = c.per_id_nbr AND t.load_seq_nbr = p_LOAD_SEQ_NBR AND T.VAT_CODE_EFFECTIVEDT IS NOT NULL
    AND t.rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code,VAT_CODE,VAT_CODE_EFFECTIVEDT)
    AND (t.ERROR_CODE NOT IN (106,101,103,105) OR t.ERROR_CODE IS NULL);

CURSOR cur_CI_PER_CHAR_VENDORCODE is SELECT distinct t.*,c.per_id
    FROM TRN_COMPANY T, MSM_STG1.CI_PER_ID C
    where t.asb_comp_code = c.per_id_nbr AND t.load_seq_nbr = p_LOAD_SEQ_NBR AND T.VENDOR_CODE_EFFECTIVEDT IS NOT NULL
    AND t.rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code,VENDOR_CODE,VENDOR_CODE_EFFECTIVEDT)
    AND (t.ERROR_CODE NOT IN (106,100,103,104) OR t.ERROR_CODE IS NULL);

CURSOR C1_CONTDET is
select LOAD_SEQ_NBR,ERROR_CODE,EMAIL_RECPT , EMAIL_RECPT_NAME , ASB_COMP_CODE
        from ASB_STG.TRN_COMPANY tc1
        WHERE LOAD_SEQ_NBR = p_LOAD_SEQ_NBR and EMAIL_RECPT is not null
        AND rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code); -- AND ASB_COMP_CODE = 'KEYS';

TYPE t_EMAIL_RECPT IS TABLE OF TRN_COMPANY.EMAIL_RECPT%TYPE;
v_EMAIL t_EMAIL_RECPT ;

TYPE t_EMAIL_RECPT_NAME IS TABLE OF TRN_COMPANY.EMAIL_RECPT_NAME%TYPE;
v_RECPT_NAME t_EMAIL_RECPT_NAME ;

BEGIN
    DBMS_OUTPUT.put_line('TEST 1.0');
    ---------------------------------------------------------
    --------- Load data in Table MSM_STG1.CI_PER_ID ---------
    ---------------------------------------------------------
    INSERT INTO MSM_STG1.CI_PER_ID (LOAD_SEQ_NBR,PER_ID,ID_TYPE_CD,PER_ID_NBR,PRIM_SW,VERSION,ENCR_PER_ID_NBR,HASH_PER_ID_NBR,DATE_CREATED)
               select p_LOAD_SEQ_NBR,
              NVL((select max(PER_ID) from MSM_STG1.CI_PER_ID where PER_ID_NBR = TC.ASB_COMP_CODE),(SEQ_NEXTVAL_ON_DEMAND('SQ_COMP_PERID_GEN'))) AS PER_ID,
               'CM_CMP' as ID_TYPE_CD,ASB_COMP_CODE,
               'Y' as PRIM_SW, '99' as VERSION, NULL, NULL, SYSDATE from ASB_STG.TRN_COMPANY TC WHERE TC.LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where
               LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code);

    DBMS_OUTPUT.put_line('TEST 1.1');
    ---------------------------------------------------------
    --------- Load data in Table MSM_STG1.CI_PER ------------
    ---------------------------------------------------------
    INSERT INTO MSM_STG1.CI_PER(LOAD_SEQ_NBR,PER_ID,LANGUAGE_CD,PER_OR_BUS_FLG,LS_SL_FLG,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,CITY,POSTAL,COUNTRY,VERSION,PER_DATA_AREA,DATE_CREATED)
               select p_LOAD_SEQ_NBR,
              NVL((select max(PER_ID) from MSM_STG1.CI_PER_ID where PER_ID_NBR = TC.ASB_COMP_CODE),'') AS PER_ID,
              'ENG','B', 'N' , NVL(INV_ADD1,' ') as ADDRESS1, NVL(INV_ADD2,' ') as ADDRESS2, NVL(INV_ADD3,' ') as ADDRESS3,NVL(INV_ADD4,' ') as ADDRESS4,NVL(INV_ADD5,' ') as CITY,
              NVL(POSTCODE,' ') as POSTAL,'UK','99',
              '<company><creationDateTime>' || TO_CHAR(SYSDATE,'YYYY-MM-DD-HH.MM.SS') ||'</creationDateTime><lastUpdatedDate>' || TO_CHAR(SYSDATE,'YYYY-MM-DD-HH.MM.SS') ||'
              </lastUpdatedDate><createdBY>MIGD</createdBY><updatedBY>MIGD</updatedBY></company>',
              SYSDATE
               from ASB_STG.TRN_COMPANY TC WHERE TC.LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code);

    DBMS_OUTPUT.put_line('TEST 1.2');
    ---------------------------------------------------------
    ------ Load data in Table MSM_STG1.CI_PER_CONTDET -------
    ---------------------------------------------------------
   FOR rec in C1_CONTDET
   LOOP
        -- EMAIL
        SELECT REGEXP_SUBSTR(rec.EMAIL_RECPT,'[^;]+', 1, LEVEL) COL1 bulk collect into v_EMAIL FROM DUAL CONNECT BY LEVEL <= REGEXP_COUNT(rec.EMAIL_RECPT, ';') + 1;
        -- Name
        SELECT REGEXP_SUBSTR(rec.EMAIL_RECPT_NAME,'[^;]+', 1, LEVEL) COL1 bulk collect into v_RECPT_NAME FROM DUAL CONNECT BY LEVEL <= REGEXP_COUNT(rec.EMAIL_RECPT_NAME, ';') + 1;

        SELECT PER_ID into v_PER_ID from MSM_STG1.CI_PER_ID where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND per_id_nbr = rec.ASB_COMP_CODE ;

        FOR cnt in 1..v_EMAIL.count
        LOOP
            IF (TRIM(v_EMAIL(cnt)) IS NOT NULL) THEN
              v_CONTACT_VALUE := TRIM(v_EMAIL(cnt));

              IF(v_RECPT_NAME.count < cnt AND v_RECPT_NAME.count <>0) THEN
                  v_CONTACT_NAME := NULL; -- v_RECPT_NAME(1);
              ELSIF(v_RECPT_NAME.count =0) THEN
                  v_CONTACT_NAME := NULL;
              ELSE
                v_CONTACT_NAME := v_RECPT_NAME(cnt);
              END IF ;
                DBMS_OUTPUT.put_line('CONTACT_NAME -> ' || v_CONTACT_NAME);
                DBMS_OUTPUT.put_line('COUNT -> ' || v_EMAIL.count);
                DBMS_OUTPUT.put_line('CONTACT_VALUE -> ' || v_CONTACT_VALUE);
                
              INSERT INTO msm_stg1.C1_PER_CONTDET(LOAD_SEQ_NBR, C1_CONTACT_ID, PER_ID, COMM_RTE_TYPE_CD, CONTACT_VALUE, CND_PRIMARY_FLG, DND_START_TM, DND_END_TM, CND_ACTINACT_FLG, VERSION, CONTACT_NAME, DATE_CREATED)
              values (p_LOAD_SEQ_NBR,SQ_COMP_CONTCTID.nextval,v_PER_ID,'SECONDARYEMAIL', NVL(v_CONTACT_VALUE,' '),'C1NO',NULL,NULL,'C1AC','99', NVL(v_CONTACT_NAME,' ')
              ,SYSDATE)  ;

            END IF;
         END LOOP;


   END LOOP;
    DBMS_OUTPUT.put_line('TEST 1.3');
    --------------------------------------------------------
    ------ Load data in Table MSM_STG1.CI_PER_NAME ---------
    --------------------------------------------------------
   FOR rec in cur_CI_PER_NAME_CHAR
   LOOP
--        SELECT PER_ID into v_PER_ID from MSM_STG1.CI_PER_ID where LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND per_id_nbr = rec.ASB_COMP_CODE ;

     /*   IF (rec.ASB_COMP_NAME IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_NAME (LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 1, NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE), 'PRIM', 99,'Y', UPPER(NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)) ,SYSDATE);
        END IF ;

        IF (rec.REG_COMP_NAME IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_NAME (LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 2, NVL(rec.REG_COMP_NAME,' '), 'LCDS', 99,'N', UPPER(NVL(rec.REG_COMP_NAME,' ')), SYSDATE);
        END IF ;

        IF (rec.INV_RECPT IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_NAME (LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 3, NVL(rec.INV_RECPT,' '), 'IREC', 99,'N', UPPER(NVL(rec.INV_RECPT,' ')), SYSDATE);
        END IF ;

   END LOOP; */

        IF (rec.ASB_COMP_NAME IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 1, NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE), 'PRIM', 99,'Y', UPPER(NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)) ,SYSDATE);
        END IF ;

      INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 2,coalesce(rec.REG_COMP_NAME,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE),
        'LCDS', 99,'N', upper(coalesce(rec.REG_COMP_NAME,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)),
         SYSDATE);

      INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (p_LOAD_SEQ_NBR, rec.PER_ID, 3,coalesce(rec.INV_RECPT,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE),
       'IREC', 99,'N', UPPER(coalesce(rec.INV_RECPT,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)), SYSDATE);

      END LOOP; 
      DBMS_OUTPUT.put_line('TEST 1.4');
    --------------------------------------------------------
    ------ Load data in Table MSM_STG1.CI_PER_CHAR ---------
    --------------------------------------------------------

   FOR rec in cur_CI_PER_CHAR_VATCODE
   LOOP

--        IF (rec.VAT_CODE IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_CHAR (LOAD_SEQ_NBR, PER_ID, CHAR_TYPE_CD, EFFDT, ADHOC_CHAR_VAL, VERSION, SRCH_CHAR_VAL,DATE_CREATED)
               values (p_LOAD_SEQ_NBR,rec.PER_ID,'CM-VATCD', TRUNC(rec.VAT_CODE_EFFECTIVEDT), NVL(rec.VAT_CODE,'NONE'), '99', NVL(upper(rec.VAT_CODE),'NONE'),SYSDATE);
--        END IF ;
    END LOOP;
    DBMS_OUTPUT.put_line('TEST 1.5');
    FOR rec in cur_CI_PER_CHAR_VATPERC
    LOOP
--        IF (rec.VAT_PERC IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_CHAR (LOAD_SEQ_NBR, PER_ID, CHAR_TYPE_CD, EFFDT, ADHOC_CHAR_VAL, VERSION, SRCH_CHAR_VAL,DATE_CREATED)
               values (p_LOAD_SEQ_NBR,rec.PER_ID,'CM-VATPC', TRUNC(rec.VAT_PERC_EFFECTIVEDT), NVL(rec.VAT_PERC,0), '99', NVL(upper(rec.VAT_PERC),0),SYSDATE);
--        END IF ;
    END LOOP;
    DBMS_OUTPUT.put_line('TEST 1.6');
    FOR rec in cur_CI_PER_CHAR_VENDORCODE
    LOOP
--        IF (rec.VENDOR_CODE IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_CHAR (LOAD_SEQ_NBR, PER_ID, CHAR_TYPE_CD, EFFDT, ADHOC_CHAR_VAL, VERSION, SRCH_CHAR_VAL,DATE_CREATED)
               values (p_LOAD_SEQ_NBR,rec.PER_ID,'CM-VECD', TRUNC(rec.VENDOR_CODE_EFFECTIVEDT), NVL(rec.VENDOR_CODE,'NONE'), '99', NVL(upper(rec.VENDOR_CODE),'NONE'),SYSDATE);
--        END IF ;
    END LOOP;

   DBMS_OUTPUT.put_line('TEST 1.7'); 
      -- Load data in Table MSM_STG1.D1_SPR --
      INSERT INTO MSM_STG1.D1_SPR (LOAD_SEQ_NBR,D1_SPR_CD,SPR_EXT_REF_ID,BUS_OBJ_CD,CRE_DTTM,VERSION,NT_XID_CD,BO_DATA_AREA,SPR_TYPE_FLG,DATE_CREATED)
               select p_LOAD_SEQ_NBR as LOAD_SEQ_NBR,
               ASB_COMP_CODE AS D1_SPR_CD,
                NVL((select max(PER_ID) from MSM_STG1.CI_PER_ID where PER_ID_NBR = TC.ASB_COMP_CODE),' ') AS SPR_EXT_REF_ID,
               'D1-MarketParticipant' as BUS_OBJ_CD, NVL((select max(DATE_CREATED) from MSM_STG1.CI_PER_ID where PER_ID_NBR = TC.ASB_COMP_CODE),SYSDATE) as CRE_DTTM,
               '99' as VERSION, NULL as NT_XID_CD, NULL as BO_DATA_AREA, 'D1MP' as SPR_TYPE_FLG, SYSDATE as DATE_CREATED
               from ASB_STG.TRN_COMPANY TC WHERE TC.LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where
               LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code);
    DBMS_OUTPUT.put_line('TEST 1.8');
       -- Load data in Table MSM_STG1.D1_SPR_L --
       INSERT INTO MSM_STG1.D1_SPR_L (LOAD_SEQ_NBR,D1_SPR_CD,LANGUAGE_CD,DESCR100,VERSION,DATE_CREATED)
               select p_LOAD_SEQ_NBR as LOAD_SEQ_NBR,
               ASB_COMP_CODE AS D1_SPR_CD, 'ENG' as LANGUAGE_CD,
              NVL(ASB_COMP_NAME,ASB_COMP_CODE) AS DESCR100,
              '99' as VERSION,SYSDATE as DATE_CREATED
               from ASB_STG.TRN_COMPANY TC WHERE TC.LOAD_SEQ_NBR = p_LOAD_SEQ_NBR AND rowid in (SELECT MAX(rowid) FROM ASB_STG.TRN_COMPANY where
               LOAD_SEQ_NBR = p_LOAD_SEQ_NBR GROUP BY asb_comp_code);
    DBMS_OUTPUT.put_line('TEST 1.9');
    -- Load data in Table MSM_STG1.CI_ACCT_PER --
        INSERT INTO MSM_STG1.CI_ACCT_PER(LOAD_SEQ_NBR,ACCT_ID,ACCT_REL_TYPE_CD,BILL_ADDR_SRCE_FLG,PER_ID,MAIN_CUST_SW,FIN_RESP_SW,THRD_PTY_SW,RECEIVE_COPY_SW,BILL_RTE_TYPE_CD,BILL_FORMAT_FLG,NBR_BILL_COPIES,VERSION,CUST_PO_ID,NOTIFY_SW,NAME_PFX_SFX,PFX_SFX_FLG,QTE_RTE_TYPE_CD,RECV_QTE_SW,WEB_ACCESS_FLG,ALW_PREF_FLG,CSS_ACCESS_ROLE_FLG,DATE_CREATED)
              SELECT P_LOAD_SEQ_NBR AS LOAD_SEQ_NBR, 
              NVL((select max(ACCT_ID) from MSM_STG1.CI_ACCT_PER where PER_ID = (select max(PER_ID) from MSM_STG1.CI_PER_ID where PER_ID_NBR = TC.ASB_COMP_CODE )),SQ_COMP_ACCTID_SEQNO.NEXTVAL) AS ACCTID,
             'MAIN' AS ACCT_REL_TYPE_CD ,'PER' AS BILL_ADDR_SRCE_FLG, NVL((SELECT MAX(PER_ID) FROM MSM_STG1.CI_PER_ID WHERE PER_ID_NBR = TC.ASB_COMP_CODE),'') AS PER_ID,'Y' AS MAIN_CUST_SW ,'Y' AS FIN_RESP_SW,'N' AS THRD_PTY_SW,'N' AS RECEIVE_COPY_SW,
             ' ' AS BILL_RTE_TYPE_CD, ' ' AS BILL_FORMAT_FLG, 0 AS NBR_BILL_COPIES,'99'AS VERSION, ' ' AS CUST_PO_ID,'N' AS NOTIFY_SW,
             ' ' AS NAME_PFX_SFX, ' ' AS QTE_RTE_TYPE_CD, ' ' AS PFX_SFX_FLG,'N' AS RECV_QTE_SW,' ' AS WEB_ACCESS_FLG, 'C1NO' AS ALW_PREF_FLG, ' ' AS CSS_ACCESS_ROLE_FLG, SYSDATE FROM ASB_STG.TRN_COMPANY TC WHERE TC.LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND
             ROWID IN (SELECT MAX(ROWID) FROM ASB_STG.TRN_COMPANY WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR GROUP BY ASB_COMP_CODE);
    DBMS_OUTPUT.put_line('TEST 1.10');
        -- Load data in Table MSM_STG1.CI_ACCT --
        INSERT INTO MSM_STG1.CI_ACCT(LOAD_SEQ_NBR,ACCT_ID,BILL_CYC_CD,SETUP_DT,CURRENCY_CD,ACCT_MGMT_GRP_CD,ALERT_INFO,BILL_AFTER_DT,PROTECT_CYC_SW,CIS_DIVISION,MAILING_PREM_ID,PROTECT_PREM_SW,COLL_CL_CD,CR_REVIEW_DT,POSTPONE_CR_RVW_DT,INT_CR_REVIEW_SW,CUST_CL_CD,BILL_PRT_INTERCEPT,NO_DEP_RVW_SW,BUD_PLAN_CD,VERSION,PROTECT_DIV_SW,ACCESS_GRP_CD,ACCT_DATA_AREA,DATE_CREATED)            
             SELECT P_LOAD_SEQ_NBR AS LOAD_SEQ_NBR,CAP.ACCT_ID,' ' AS BILL_CYC_CD,SYSDATE AS SETUP_DT,'GBP' AS CURRENCY_CD,' ' AS ACCT_MGMT_GRP_CD,' ' AS ALERT_INFO, '' AS BILL_AFTER_DT,'N' AS PROTECT_CYC_SW,
             'ANC' AS CIS_DIVISION,' ' AS MAILING_PREM_ID,'N' AS PROTECT_PREM_SW,' ' AS COLL_CL_CD,'' AS CR_REVIEW_DT, '' AS POSTPONE_CR_RVW_DT, 'N' AS INT_CR_REVIEW_SW,'C' AS CUST_CL_CD,
             ' ' AS BILL_PRT_INTERCEPT,'N' AS NO_DEP_RVW_SW,' ' AS BUD_PLAN_CD, '99' AS VERSION, 'N' AS PROTECT_DIV_SW, '***'  AS ACCESS_GRP_CD, ' ' AS ACCT_DATA_AREA, SYSDATE FROM MSM_STG1.CI_ACCT_PER CAP
             WHERE CAP.LOAD_SEQ_NBR = P_LOAD_SEQ_NBR AND
             ROWID IN (SELECT MAX(ROWID) FROM  MSM_STG1.CI_ACCT_PER WHERE LOAD_SEQ_NBR = P_LOAD_SEQ_NBR GROUP BY ACCT_ID);

   ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_COMPANY',p_LOAD_SEQ_NBR,'SUCCESS','Data transfer successful from ASB_STG to MSM_STG1','COMPANY');

    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,400);
        ASB_STG.PROC_PROCESS_LOG('PR_MSMSTG1_LOAD_COMPANY',p_LOAD_SEQ_NBR,'FAILURE',v_ERROR,'COMPANY');
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);
        RAISE;

END PR_MSMSTG1_LOAD_COMPANY;

/
