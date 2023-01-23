--------------------------------------------------------
--  DDL for Procedure PR_ASB_GEN_REJECT_FILE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_ASB_GEN_REJECT_FILE" 
/**************************************************************************************
*
* Program Name           :PR_ASB_GEN_REJECT_FILE
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :24-03-2021
* Description            :This is a generic Pl/SQL procedure which 
*                         generates file for rejected data along with error description.
*
* Calling Program        :None
* Called Program         :PR_ASB_LOAD_RESOURCE_MAIN
*                         PR_ASB_LOAD_COMP_MAIN
*                         
* Input files            :None
* Output files           :None
* Input Parameter        :load sequence number, Error_Code List, Entity Name, Table Name
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
(pi_load_seq_nbr IN NUMBER,v_ERR_CD_LIST IN VARCHAR2,v_ENTITY IN VARCHAR2,v_TABLE IN VARCHAR2)
AS

  lv_vc_file_name utl_file.file_type;
  lv_abfile BFILE;
  lv_vc_dir_path varchar2(500);
  lv_vc_log_file_name varchar2(50);

TYPE t_rej_files is table of rejected_files%rowtype;
lv_vc_rej_recs t_rej_files;

TYPE T_ERR_CODE IS TABLE OF ERROR_CODE.ERROR_CODE%TYPE;
lv_ERROR_CODE T_ERR_CODE;

CURSOR CUR_COL IS
SELECT COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE TABLE_NAME = v_TABLE
and column_name not in ('LOAD_SEQ_NBR','DATE_CREATED','ERROR_CODE') and owner = 'ASB_STG' order by column_id;

lc_vc_error_desc varchar2(1000);
v_string varchar2(32000);
v_string_final varchar2(32000);
v_string_header varchar2(4000);
v_SQL_STMT varchar2(1000);
v_CNT NUMBER := 0;

BEGIN

  LV_VC_DIR_PATH := 'REJECTED_FILES';

  LV_VC_LOG_FILE_NAME := V_ENTITY|| '_REJECTED_'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')||'.csv';

  lv_abfile := BFILENAME(LV_VC_DIR_PATH, LV_VC_LOG_FILE_NAME);

  LV_VC_FILE_NAME := UTL_FILE.FOPEN(LV_VC_DIR_PATH, LV_VC_LOG_FILE_NAME, 'W', 4000);

    DELETE FROM REJECTED_FILES;

    -- Generate Header columns list
    v_CNT := 0;
    FOR j IN  cur_COL
    LOOP
    V_CNT := V_CNT + 1;
          IF (v_CNT = 1) THEN
              V_STRING_HEADER := TRIM(J.COLUMN_NAME);
              v_string := j.column_name;
          ELSE
              V_STRING_HEADER := V_STRING_HEADER||','||TRIM(J.COLUMN_NAME);
              v_string := v_string||'||'''||','||'''||'||trim(j.column_name);
          END IF;
    END LOOP;

    -- Generate an array list for error codes passed
    V_SQL_STMT := 'SELECT regexp_substr(''' ||V_ERR_CD_LIST||''',''[^,]+'',1, LEVEL) FROM DUAL CONNECT BY LEVEL <= regexp_count(''' || V_ERR_CD_LIST|| ''','','')+1';
    DBMS_OUTPUT.PUT_LINE(V_SQL_STMT);    

    EXECUTE IMMEDIATE V_SQL_STMT BULK COLLECT INTO lv_ERROR_CODE;

    -- Insert rejected records in REJECTED_FILES Table
    FOR I IN 1..lv_ERROR_CODE.count
    LOOP
      SELECT NVL(ERROR_DESC, 'No Error Description found') INTO LC_VC_ERROR_DESC FROM ERROR_CODE WHERE ERROR_CODE = lv_ERROR_CODE(i);

      v_STRING_FINAL := 'select '||v_string||'||'''||','||'''||e.error_desc as QUERY_STRING from ' ||v_TABLE ||' c, error_code e where c.error_code = '
      ||lv_ERROR_CODE(i)||' and c.error_code = e.error_code';

      dbms_output.put_line('INSERT into rejected_files '|| v_string_final);

      EXECUTE IMMEDIATE ('INSERT into rejected_files '|| V_STRING_FINAL);

    END LOOP;

  BEGIN  
  select rejected_rows bulk collect into lv_vc_rej_recs from rejected_files;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    PROC_PROCESS_LOG('PR_ASB_REJECT_FILE: ' || v_ENTITY,pi_load_seq_nbr,'SUCCESS','No data rejected','COMPANY');
  END;

  -- Write header row in the rejected file
  v_string_header := v_string_header||',ERROR_DESC';
  utl_file.put_line(lv_vc_file_name, v_string_header);
  utl_file.fflush(lv_vc_file_name); 

  -- Write rejected records in the file
  FOR I IN 1..LV_VC_REJ_RECS.COUNT
  LOOP
    v_string:=lv_vc_rej_recs(i).rejected_rows;
    utl_file.put_line(lv_vc_file_name, v_string);
    utl_file.fflush(lv_vc_file_name);   
  END LOOP;

  utl_file.fclose(lv_vc_file_name);

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        PROC_PROCESS_LOG('PR_ASB_GEN_REJECT_FILE: ' || v_ENTITY,pi_load_seq_nbr,'SUCCESS','No data found for rejection','COMPANY');

    WHEN OTHERS THEN   
        PROC_PROCESS_LOG('PR_ASB_GEN_REJECT_FILE: ' || V_ENTITY,PI_LOAD_SEQ_NBR,'FAILURE',SQLERRM,'COMPANY');
        dbms_output.put_line('ERROR --> ' || SQLERRM);
        
    RAISE;
END PR_ASB_GEN_REJECT_FILE;

/
