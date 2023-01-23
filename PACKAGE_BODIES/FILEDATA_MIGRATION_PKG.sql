--------------------------------------------------------
--  DDL for Package Body FILEDATA_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "ASB_STG"."FILEDATA_MIGRATION_PKG" 
as
     /*************************************************************************
     * Description: Populate file dates as per file loaded 
     *
     *
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------_
     19/05/2022     1.1   Shikha Sharma                Initial Version
     25/07/2022     1.2   Shikha Sharma                SRPTEAM-18849 Issue fixed for filename 'RES_METERING_<DATE>.CSV' Eg: RES_METERING_201912141.CSV  
     27/07/2022     1.3   Sirisha                      SRPTEAM-18849 Hard coded VERSION number 99 changed to P_VERSION.
     30/09/2022     1.4   Amit Gupta                   SRPTEAM-20201 Modified PR_ASB_MSM2_FILEDATA proc- Removed .DAT extension from I014 filename while sending data to STGADM.
     *************************************************************************/
FUNCTION get_filedate (p_filename VARCHAR2) RETURN DATE AS
  v_filedate  DATE;
BEGIN

  IF instr(p_filename,'RES_REDEC')>0 
    OR instr(p_filename,'RES_INSTRUCT')>0 
    OR instr(p_filename,'RES_AVAIL') >0  THEN
    v_filedate := TO_DATE(substr(p_filename,instr(p_filename,'.')+1,9),'DDMONYYYY HH24:MI:SS');
  ELSIF instr(p_filename,'I014')>0 THEN
    v_filedate:=TO_DATE(regexp_substr(REPLACE(p_filename,'I014',''),'[0-9]+'),'YYYYMMDD HH24:MI:SS');
  ELSE
    v_filedate:=TO_DATE(substr(regexp_substr(p_filename,'[0-9]+'),1,8),'YYYYMMDD HH24:MI:SS');--Including files with syntax '%<DATE%>1.CSV'   
 END IF;

  RETURN nvl(v_filedate,sysdate);

END get_filedate;


     /*************************************************************************
     * Description: Populate different file_types in table
     *
     *
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------
     19/05/2022     1.1   Shikha Sharma                Initial Version
     *
     *************************************************************************/

FUNCTION get_filetype (p_filename VARCHAR2) RETURN VARCHAR2 AS
  v_filedate  DATE;
  v_type VARCHAR2(50);
BEGIN

  IF  instr(p_filename,'I014')>0 THEN
     v_type :='SAA_I014';
  ELSE
     v_type := RTRIM(RTRIM(regexp_substr(p_filename,'[^0-9]+'),'_'),'.');
  END IF;

  RETURN v_type;
END get_filetype;


/*************************************************************************
     * Description: Populate different message_classification, service_types and
                    transactional_bo_object according to different file_types 
     *
     *
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------
     19/05/2022     1.1   Shikha Sharma                Initial Version
     *
     *************************************************************************/
FUNCTION get_file_msg_bo_data (
    p_file_type VARCHAR2,
    p_data_type VARCHAR2
) RETURN VARCHAR2 AS
    v_msg_type VARCHAR2(50);
    v_tbo_type VARCHAR2(50);
BEGIN
    IF p_file_type = 'STOR_ACCEPTED_TENDER' THEN
        v_msg_type := 'ACTNDRBOFEOF';
        v_tbo_type := 'CM-ACPTTNDBOFEOFSvcTsk';
    ELSIF p_file_type = 'SAA_I014' THEN
        v_msg_type := 'BMIO14BOFEOF';
        v_tbo_type := 'CM-MIO14BOFEOFSrvTsk';
    ELSIF p_file_type = 'RURE' THEN
        v_msg_type := 'RUREBOFEOF';
        v_tbo_type := 'CM-BOFEOFRURESrvTsk';
    ELSIF p_file_type = 'MNZT' THEN
        v_msg_type := 'MNZTBOFEOF';
        v_tbo_type := 'CM-BOFEOFMNZTSrvTsk';
    ELSIF p_file_type = 'MZT' THEN
        v_msg_type := 'MZTBOFEOF';
        v_tbo_type := 'CM-BOFEOFMZTSrvTsk';
    ELSIF p_file_type IN ( 'RES_AVAIL', 'RES_REDEC' ) THEN
        v_msg_type := 'MNGDECBOFEOF';
        v_tbo_type := 'CM-MngDecBOFEOFSrvcTask';
    ELSIF p_file_type = 'NDZ' THEN
        v_msg_type := 'NDZBOFEOF';
        v_tbo_type := 'CM-BOFEOFNDZSrvTsk';
    ELSIF p_file_type = 'NTO' THEN
        v_msg_type := 'NTOBOFEOF';
        v_tbo_type := 'CM-BOFEOFNTOSrvTsk';
    ELSIF p_file_type = 'RDRE' THEN
        v_msg_type := 'RDREBOFEOF';
        v_tbo_type := 'CM-BOFEOFRDRESrvTsk';
    ELSIF p_file_type = 'RDRI' THEN
        v_msg_type := 'RDRIBOFEOF';
        v_tbo_type := 'CM-BOFEOFRDRISrvTsk';
    ELSIF p_file_type = 'RURI' THEN
        v_msg_type := 'RURIBOFEOF';
        v_tbo_type := 'CM-BOFEOFRURISrvTsk';
    ELSIF p_file_type = 'RES_METERING' THEN
        v_msg_type := 'SRDMTRBOFEOF';
        v_tbo_type := 'CM-SRDMTRBOFEOFSrvTsk';
    ELSIF p_file_type = 'RES_INSTRUCT' THEN
        v_msg_type := 'INSTBOFEOF';
        v_tbo_type := 'CM-INSTBODEOFSvcTsk';
    ELSIF p_file_type = 'WINDOW_BID_PRICE' THEN
        v_msg_type := 'WINBIDBOFEOF';
        v_tbo_type := 'CM-WinBidBOFEOFSrvcTsk';
    END IF;

    IF p_data_type IN ( 'MSG', 'SER' ) THEN
        RETURN v_msg_type;
    ELSIF p_data_type = 'TBO' THEN
        RETURN v_tbo_type;
    END IF;

END get_file_msg_bo_data;


      /*************************************************************************
     * Description: Load file data from  ASB_STG Table to MSM_STG2 Tables
     *
     *
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------
     19/05/2022     1.1   Shikha Sharma                Initial Version
     25/07/2022     1.2   Shikha Sharma                SRPTEAM-18849 Removed new line character from FILE_DATA.filename
     30/09/2022     1.3   Amit Gupta                   SRPTEAM-20201 Removed .DAT extension from I014 filename while sending data to STGADM.
     30/09/2022     1.4   Amit Gupta                   SRPTEAM-20201 Modified Update statement to process lowercase filenames.
     *************************************************************************/
PROCEDURE PR_ASB_MSM2_FILEDATA(P_VERSION IN NUMBER)
as
    v_count   NUMBER := 0;
    v_update_count NUMBER;
    v_table_name varchar2(100);
    v_proc_name varchar2(100) := 'PR_ASB_MSM2_FILEDATA';
    v_entity_name varchar2(100) := 'FILEDATA';
    v_action varchar2(20);

BEGIN
--Updating FILE_DATA Table
    v_action := 'Updating';
    v_table_name:= 'FILE_DATA';
       UPDATE file_data
        SET filename=replace (filename,chr(13)), --Removed new line character from FILE_DATA.filename
            datetime = get_filedate(upper(filename)),
            task_id = sq_filedata_taskid.NEXTVAL,
            file_type = get_filetype(upper(filename)),
            msg_class = get_file_msg_bo_data(get_filetype(upper(filename)),'MSG'),
            trans_bo = get_file_msg_bo_data(get_filetype(upper(filename)),'TBO');

       asb_stg.proc_process_log(v_proc_name, NULL, 'SUCCESS', sql%rowcount || ' records updated in '||v_table_name, v_entity_name); 
    commit;

--Truncating tables
    msm_stg2.pr_truncate_table_msmstg2('F1_SVC_TASK');
    msm_stg2.pr_truncate_table_msmstg2('F1_SVC_TASK_CHAR');
    msm_stg2.pr_truncate_table_msmstg2('F1_SVC_TASK_LOG');
    msm_stg2.pr_truncate_table_msmstg2('F1_SVC_TASK_LOG_PARM');

--Inserting data in tables
    v_action := 'Inserting';
--F1_SVC_TASK
    v_table_name:= 'F1_SVC_TASK';
   INSERT INTO msm_stg2.f1_svc_task(F1_SVC_TASK_ID,BUS_OBJ_CD,BO_STATUS_CD,F1_STASK_TYPE_CD,CRE_DTTM,
                                    STATUS_UPD_DTTM,EFF_DTTM,BO_DATA_AREA,VERSION,ILM_DT,ILM_ARCH_SW)
        SELECT
            task_id   f1_svc_task_id,
            trans_bo   bus_obj_cd,
           'COMPLETE'  bo_status_cd,
            msg_class f1_stask_type_cd,
            datetime  cre_dttm,
            datetime  status_upd_dttm,
            datetime   eff_dttm,
            '<interfaceCorrelationId></interfaceCorrelationId>' || '<errorFlag>N</errorFlag>'
            || '<messageClassification>'||msg_class||'</messageClassification>'
            || '<totalCount></totalCount>'||'<eofReceived>Y</eofReceived>'||'<responseCode>320</responseCode>'
            ||'<responseMessage>Record processed successfully</responseMessage>' bo_data_area,
            P_VERSION  version,
            datetime ilm_dt,
            'N' ilm_arch_sw
        FROM file_data;

    asb_stg.proc_process_log(v_proc_name, NULL, 'SUCCESS', sql%rowcount || ' records inserted in '||v_table_name, v_entity_name);
   commit;

--F1_SVC_TASK_CHAR
v_table_name := 'F1_SVC_TASK_CHAR';
    INSERT INTO msm_stg2.f1_svc_task_char(F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,VERSION)
        SELECT
            task_id    f1_svc_task_id,
            'CM-LFLNM' char_type_cd,
            '1'        seq_num,
            ' '        char_val,
            Case 
                When instr(filename,'I014')>0 then
                    replace(filename,'.DAT')
                Else 
                    filename
            End adhoc_char_val,        
            P_VERSION         version
        FROM file_data;

    v_count := sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_char(F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,VERSION)
        SELECT
            task_id    f1_svc_task_id,
            'CM-FILDT' char_type_cd,
            '1'        seq_num,
            ' '        char_val,
            to_char(cre_dttm, 'YYYY-MM-DD') adhoc_char_val,
            P_VERSION         version
        FROM msm_stg2.f1_svc_task fst, file_data  fd
        WHERE fst.f1_svc_task_id = fd.task_id;

    v_count := v_count + sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_char(F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,VERSION)
        SELECT
            task_id    f1_svc_task_id,
            'CM-RNTYP' char_type_cd,
            '1'        seq_num,
            CASE
                WHEN instr(filename, 'I014') > 0 THEN
                    substr(filename, instr(filename, '_', 1, 3) + 1, 2)
            END        char_val,
            ' '        adhoc_char_val,
            P_VERSION         version
        FROM   file_data
        WHERE filename LIKE '%I014%';

    v_count := v_count + sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_char(F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,VERSION)
        SELECT
            task_id f1_svc_task_id,
            'CMFLRPIN' char_type_cd,
            '1' seq_num,
            'N'   char_val,
            ' ' adhoc_char_val,
            P_VERSION  version
        FROM msm_stg2.f1_svc_task fst, file_data  fd
        WHERE fst.f1_svc_task_id = fd.task_id;

    v_count := v_count + sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_char(F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,VERSION)
        SELECT
            task_id    f1_svc_task_id,
            'CMFLEDIN' char_type_cd,
            '1'        seq_num,
            'N'        char_val,
            ' '        adhoc_char_val,
            P_VERSION         version
        FROM msm_stg2.f1_svc_task fst, file_data  fd
        WHERE fst.f1_svc_task_id = fd.task_id;

    v_count := v_count + sql%rowcount;

    asb_stg.proc_process_log(v_proc_name, NULL, 'SUCCESS', v_count || ' records inserted in '||v_table_name, v_entity_name);
    commit;
    v_count := 0;


--F1_SVC_TASK_LOG
  v_table_name:= 'F1_SVC_TASK_LOG';
    INSERT INTO msm_stg2.f1_svc_task_log(F1_SVC_TASK_ID,SEQNO,LOG_ENTRY_TYPE_FLG,LOG_DTTM,
                                        BO_STATUS_CD,MESSAGE_CAT_NBR,MESSAGE_NBR,USER_ID,VERSION)
        SELECT
            f1_svc_task_id f1_svc_task_id,
            1              seqno,
            'FICR'         log_entry_type_flg,
            cre_dttm       log_dttm,
            'INITIATED'    bo_status_cd,
            11002          message_cat_nbr,
            12151          message_nbr,
            'MIGD'         user_id,
            P_VERSION             version

        FROM
            msm_stg2.f1_svc_task;

    v_count := sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_log(F1_SVC_TASK_ID,SEQNO,LOG_ENTRY_TYPE_FLG,LOG_DTTM,
                                         BO_STATUS_CD,MESSAGE_CAT_NBR,MESSAGE_NBR,USER_ID,VERSION)
        SELECT
            f1_svc_task_id f1_svc_task_id,
            2              seqno,
            'FIST'         log_entry_type_flg,
            cre_dttm       log_dttm,
            'COMPLETE'     bo_status_cd,
            11002          message_cat_nbr,
            12150          message_nbr,
            'MIGD'         user_id,
            P_VERSION             version

        FROM msm_stg2.f1_svc_task;

    v_count := v_count + sql%rowcount;

    asb_stg.proc_process_log(v_proc_name, NULL, 'SUCCESS', v_count || ' records inserted in '||v_table_name, v_entity_name);
      commit;
    v_count := 0; 


--F1_SVC_TASK_LOG_PARM
v_table_name :='F1_SVC_TASK_LOG_PARM';
    INSERT INTO msm_stg2.f1_svc_task_log_parm(F1_SVC_TASK_ID,SEQNO,PARM_SEQ,MSG_PARM_VAL,VERSION)
        SELECT
            f1_svc_task_id f1_svc_task_id,
            '1'            seqno,
            '2'            parm_seq,
           'Pending'      msg_parm_val,
            P_VERSION             version
        FROM
            msm_stg2.f1_svc_task;

    v_count := sql%rowcount;

    INSERT INTO msm_stg2.f1_svc_task_log_parm(F1_SVC_TASK_ID,SEQNO,PARM_SEQ,MSG_PARM_VAL,VERSION)
        SELECT
            f1_svc_task_id f1_svc_task_id,
            '2'            seqno,
            '3'            parm_seq,
        'Processed'    msg_parm_val,
            P_VERSION             version
        FROM
            msm_stg2.f1_svc_task;

     v_count := v_count + sql%rowcount;
     asb_stg.proc_process_log(v_proc_name, NULL, 'SUCCESS', v_count || ' records inserted in '||v_table_name, v_entity_name);


    COMMIT;
EXCEPTION
     WHEN OTHERS THEN
        asb_stg.pr_process_log(v_proc_name, NULL, 'FAILURE', sqlerrm, v_entity_name);
        raise_application_error('-20002', 'Database procedure '|| v_proc_name || ' failed while '||v_action||' in '||v_table_name ||' with error' || sqlcode ||' - '||sqlerrm);
END  PR_ASB_MSM2_FILEDATA;

      /*************************************************************************
     * Description: Load file data from MSM_STG2 tables to STGADM Tables
     *
     *
     * Change Log
     *
     * Date        Vers    Developer                   Description
     * ----        ----   ---------                    -----------
     19/05/2022     1.1   Shikha Sharma                Initial Version
     *
     *************************************************************************/
 PROCEDURE  PR_MSM2_STGADM_FILEDATA
AS 
v_table varchar2(100);
v_proc_name varchar2(100) := 'PR_MSM2_STGADM_FILEDATA';
v_env varchar2(20) := 'STGADM';
v_entity_name varchar2(100) := 'FILEDATA';
BEGIN
--F1_SVC_TASK
v_table:='CM_SVC_TASK';

  Insert into  CM_SVC_TASK@STG_MSM_LINK
    SELECT F1_SVC_TASK_ID,BUS_OBJ_CD,BO_STATUS_CD,F1_STASK_TYPE_CD,CRE_DTTM,STATUS_UPD_DTTM,EFF_DTTM,BO_DATA_AREA,VERSION,
            BO_STATUS_REASON_CD,ILM_DT,ILM_ARCH_SW 
    from MSM_STG2.F1_SVC_TASK ;

     ASB_STG.PROC_PROCESS_LOG(v_proc_name,null,'SUCCESS',sql%rowcount||' records inserted in '||v_table||' in '||v_env,v_entity_name);
    commit;


--F1_SVC_TASK_CHAR
v_table:='CM_SVC_TASK_CHAR';

    insert INTO CM_SVC_TASK_CHAR@STG_MSM_LINK
        select F1_SVC_TASK_ID,CHAR_TYPE_CD,SEQ_NUM,CHAR_VAL,ADHOC_CHAR_VAL,
              CHAR_VAL_FK1,CHAR_VAL_FK2,CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,SRCH_CHAR_VAL,VERSION 
        from MSM_STG2.F1_SVC_TASK_CHAR ;

      ASB_STG.PROC_PROCESS_LOG(v_proc_name,null,'SUCCESS',sql%rowcount||' records inserted in '||v_table||' in '||v_env,v_entity_name );
     commit;

--CM_SVC_TASK_LOG
v_table:='CM_SVC_TASK_LOG';

insert INTO CM_SVC_TASK_LOG@STG_MSM_LINK
   select F1_SVC_TASK_ID,SEQNO,LOG_ENTRY_TYPE_FLG,LOG_DTTM,BO_STATUS_CD,DESCRLONG,
           MESSAGE_CAT_NBR,MESSAGE_NBR,CHAR_TYPE_CD,CHAR_VAL,ADHOC_CHAR_VAL,CHAR_VAL_FK1,CHAR_VAL_FK2,
           CHAR_VAL_FK3,CHAR_VAL_FK4,CHAR_VAL_FK5,USER_ID,VERSION,BO_STATUS_REASON_CD 
   from MSM_STG2.F1_SVC_TASK_LOG ;

    ASB_STG.PROC_PROCESS_LOG(v_proc_name,null,'SUCCESS',sql%rowcount||' records inserted in '||v_table||' in '||v_env,v_entity_name );
    commit;


--CM_SVC_TASK_LOG_PARM
v_table:='CM_SVC_TASK_LOG_PARM';

insert INTO CM_SVC_TASK_LOG_PARM@STG_MSM_LINK
   select F1_SVC_TASK_ID,SEQNO,PARM_SEQ,MSG_PARM_TYP_FLG,MSG_PARM_VAL,VERSION 
   from MSM_STG2.F1_SVC_TASK_LOG_PARM;

    ASB_STG.PROC_PROCESS_LOG(v_proc_name,null,'SUCCESS',sql%rowcount||' records inserted in '||v_table||' in '||v_env,v_entity_name);
    commit;

EXCEPTION
     WHEN OTHERS THEN
        asb_stg.pr_process_log(v_proc_name, NULL, 'FAILURE', sqlerrm, v_entity_name);
        raise_application_error('-20003', 'Database procedure '|| v_proc_name || ' failed while inserting in '||v_table||' from MSM_STG2 to'||v_env ||' with error' || sqlcode ||' - '||sqlerrm);
END  PR_MSM2_STGADM_FILEDATA;

END ;

/

