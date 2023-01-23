--------------------------------------------------------
--  DDL for Procedure PR_MSRMT_COMP_ID_REFRESH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_MSRMT_COMP_ID_REFRESH" (PI_LOAD_SEQ_NBR IN VARCHAR2)
/**************************************************************************************
*
* Program Name           :pr_msrmt_comp_id_refresh
* Author                 :IBM(Shailesh Solanki)
* Creation Date          :30-11-2021
* Description            :This is a PL/SQL procedure. This procedure is used to retrieve latest MEASR_COMP_ID from CISADM.
*                        
*
* Calling Program        :None
* Called Program         :
*                         
*
* Input files            :Load sequence number
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
as
begin
    delete from l_d1_install_evt;
    delete from l_d1_measr_comp;
    delete from l_d1_sp_identifier;

    insert into l_d1_install_evt select * from cisadm.d1_install_evt@stg_msm_link;
    insert into l_d1_measr_comp select * from cisadm.d1_measr_comp@stg_msm_link;
    insert into l_d1_sp_identifier select * from cisadm.d1_sp_identifier@stg_msm_link;
    
    PR_PROCESS_LOG('pr_msrmt_comp_id_refresh',PI_LOAD_SEQ_NBR,'Success', 'All the tables related to MEASR_COMP_ID table successfully refreshed!!!');
    
exception when others then
    PR_PROCESS_LOG('pr_msrmt_comp_id_refresh',PI_LOAD_SEQ_NBR,'FAILURE', 'Failed while migrating MEASR_COMP_ID and realted tables from CISADM to ASB_STG schema');
end;

/
