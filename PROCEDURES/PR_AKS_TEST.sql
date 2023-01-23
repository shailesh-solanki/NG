--------------------------------------------------------
--  DDL for Procedure PR_AKS_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."PR_AKS_TEST" 
(
pv_text_identifier in varchar2
)
is
begin
insert into aks_test ( text_identifier ) values ( pv_text_identifier );
commit;
end;

/

