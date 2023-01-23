--------------------------------------------------------
--  DDL for Procedure UPDATE_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "ASB_STG"."UPDATE_DATA" (pi_effective in date, pi_rank in number, pi_item varchar2, pi_type varchar2)
as

--type t_pn_availability_stg is table of pn_availability_stg.asb_unit_code%type;
--lv_vc_unit_code t_pn_availability_stg;

type t_pn_position_stg is table of pn_position_stg.asb_unit_code%type;
lv_vc_unit_code1 t_pn_position_stg;

begin
    --select distinct asb_unit_code bulk collect into lv_vc_unit_code from pn_availability_stg where effective >= pi_effective and item_code = pi_item;
    
    select distinct asb_unit_code bulk collect into lv_vc_unit_code1 from pn_position_stg where effective >= pi_effective and item_code = pi_item;
    
    for i in 1..lv_vc_unit_code1.count
    loop


        update msm_stg1.d1_msrmt_boa set date_created = '06-dec-2021 00:00:00' , prev_msrmt_dttm = (select max(effective) from pn_position_stg a where rank = pi_rank and item_code = pi_item and effective < pi_effective
        and asb_unit_code = lv_vc_unit_code1(i)) where prev_msrmt_dttm is null and measr_comp_id = (
    select 
         distinct dmc.measr_comp_id measr_comp_id

    from 
        pn_position_stg pas,
        l_d1_sp_identifier dsi,
        l_d1_install_evt die,
        l_d1_measr_comp dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = pi_type
        and pas.item_code = pi_item
        and pas.asb_unit_code = lv_vc_unit_code1(i)
        and pas.rank = pi_rank) and msrmt_dttm <= trunc(last_day(pi_effective)+1)-1/(24*60*60) and msrmt_dttm > pi_effective - 2;
        --and msrmt_dttm < pi_effective+1 and msrmt_dttm > pi_effective - 2 ;
    end loop;
    
    /* for i in 1..lv_vc_unit_code1.count
    loop
           update msm_stg1.d1_msrmt_fpn set date_created = sysdate , prev_msrmt_dttm = (select max(effective) from pn_availability_stg a where rank = 1 and item_code = 'FPN' and effective < pi_effective
        and asb_unit_code = lv_vc_unit_code(i)) where prev_msrmt_dttm is null and measr_comp_id = (
    select 
         distinct dmc.measr_comp_id measr_comp_id

    from 
        pn_availability_stg pas,
        l_d1_sp_identifier dsi,
        l_d1_install_evt die,
        l_d1_measr_comp dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = 'FPNSTARTMIN'
        and pas.item_code = 'FPN'
        and pas.asb_unit_code = lv_vc_unit_code(i)
        and pas.rank = 1) and msrmt_dttm < pi_effective ;
        
         update msm_stg1.d1_msrmt_fpn set date_created = sysdate , prev_msrmt_dttm = (select max(effective) from pn_availability_stg a where rank = 2 and item_code = 'FPN' and effective < pi_effective
        and asb_unit_code = lv_vc_unit_code(i)) where prev_msrmt_dttm is null and measr_comp_id = (
    select 
         distinct dmc.measr_comp_id measr_comp_id

    from 
        pn_availability_stg pas,
        l_d1_sp_identifier dsi,
        l_d1_install_evt die,
        l_d1_measr_comp dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = 'FPNENDMIN'
        and pas.item_code = 'FPN'
        and pas.asb_unit_code = lv_vc_unit_code(i)
        and pas.rank = 2) and msrmt_dttm < pi_effective ;
        
         update msm_stg1.d1_msrmt_boa set date_created = sysdate , prev_msrmt_dttm = (select max(effective) from pn_availability_stg a where rank = 1 and item_code = 'BOAL' and effective < pi_effective
        and asb_unit_code = lv_vc_unit_code(i)) where prev_msrmt_dttm is null and measr_comp_id = (
    select 
         distinct dmc.measr_comp_id measr_comp_id

    from 
        pn_availability_stg pas,
        l_d1_sp_identifier dsi,
        l_d1_install_evt die,
        l_d1_measr_comp dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = 'BOASTARTMIN'
        and pas.item_code = 'BOAL'
        and pas.asb_unit_code = lv_vc_unit_code(i)
        and pas.rank = 1) and msrmt_dttm < pi_effective ;
        
         update msm_stg1.d1_msrmt_boa set date_created = sysdate , prev_msrmt_dttm = (select max(effective) from pn_availability_stg a where rank = 2 and item_code = 'BOAL' and effective < pi_effective
        and asb_unit_code = lv_vc_unit_code(i)) where prev_msrmt_dttm is null and measr_comp_id = (
    select 
         distinct dmc.measr_comp_id measr_comp_id

    from 
        pn_availability_stg pas,
        l_d1_sp_identifier dsi,
        l_d1_install_evt die,
        l_d1_measr_comp dmc
    where 
         pas.asb_unit_code=dsi.id_value 
        and dsi.d1_sp_id=die.d1_sp_id
        AND die.device_config_id=dmc.device_config_id
        and dsi.sp_id_type_flg='D1MI' 
        and dmc.measr_comp_type_cd = 'BOAENDMIN'
        and pas.item_code = 'BOAL'
        and pas.asb_unit_code = lv_vc_unit_code(i)
        and pas.rank = 2) and msrmt_dttm < pi_effective ;
    end loop;*/
end;

/

