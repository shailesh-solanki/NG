--------------------------------------------------------
--  DDL for Package FILEDATA_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "ASB_STG"."FILEDATA_MIGRATION_PKG" AS

    FUNCTION get_filedate (  p_filename VARCHAR2) RETURN DATE;

    FUNCTION get_filetype ( p_filename VARCHAR2 ) RETURN VARCHAR2;

    FUNCTION get_file_msg_bo_data ( p_file_type VARCHAR2, p_data_type VARCHAR2) RETURN VARCHAR2;
    
    PROCEDURE pr_asb_msm2_filedata (P_VERSION IN NUMBER );
     
    PROCEDURE pr_msm2_stgadm_filedata;
     
END filedata_migration_pkg;

/

