--------------------------------------------------------
--  DDL for Procedure PR_MSM1_LOAD_COMPANY_DMY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSM1_LOAD_COMPANY_DMY" (p_LOAD_SEQ_NBR IN NUMBER)AS 
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

BEGIN
   FOR rec in cur_CI_PER_NAME_CHAR
   LOOP
       
        IF (rec.ASB_COMP_NAME IS NOT NULL) THEN
        INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (555, rec.PER_ID, 1, NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE), 'PRIM', 99,'Y', UPPER(NVL(rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)) ,SYSDATE);
        END IF ;

      INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (555, rec.PER_ID, 2,coalesce(rec.REG_COMP_NAME,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE),
        'LCDS', 99,'N', upper(coalesce(rec.REG_COMP_NAME,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)),
         SYSDATE);
         
      INSERT INTO MSM_STG1.CI_PER_NAME(LOAD_SEQ_NBR, PER_ID, SEQ_NUM, ENTITY_NAME, NAME_TYPE_FLG, VERSION, PRIM_NAME_SW, ENTITY_NAME_UPR, DATE_CREATED)
        values (555, rec.PER_ID, 3,coalesce(rec.INV_RECPT,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE),
       'IREC', 99,'N', UPPER(coalesce(rec.INV_RECPT,rec.ASB_COMP_NAME,rec.ASB_COMP_CODE)), SYSDATE);


   

   END LOOP; 

  EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
        v_ERROR:=SQLCODE||' '||SUBSTR(sqlerrm,1,120);
        ASB_STG.PR_PROCESS_LOG('PR_MSMSTG1_LOAD_COMPANY',p_LOAD_SEQ_NBR,'FAILURE',v_ERROR);
        DBMS_OUTPUT.PUT_LINE('Error --> '||SQLERRM);

END PR_MSM1_LOAD_COMPANY_DMY;

/
