--------------------------------------------------------
--  DDL for Function GET_INDEX_RATE1
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."GET_INDEX_RATE1" (p_asb_unit_code varchar2, p_dt date)
return number
as
v_rate number;
begin

    select index_rate
      into v_rate
    from
    (
    select a.* ,
         ROW_NUMBER()
           OVER (PARTITION BY asb_unit_code ORDER BY effective desc ) rw_num
           from ASB_INDEX_RATE_STG a
        where asb_unit_code=p_asb_unit_code
        and pay_code='SRNA'
        and effective <p_dt
    )
    where rw_num=1;
    return v_rate ;
end;

/

