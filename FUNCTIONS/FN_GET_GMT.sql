--------------------------------------------------------
--  DDL for Function FN_GET_GMT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."FN_GET_GMT" ( input_date IN DATE, sett_per IN NUMBER)-- ,out_date OUT DATE) 
/**************************************************************************************
*
* Program Name           :fn_convert_bst_gmt
* Author                 :IBM(vasanth Danda)
* Creation Date          :30-08-2021
* Description            :This is a PL/SQL Function. This function converts 
                          time zone from BST to GMT.
*                        
*
* Calling Program        :None
* Called Program         :
*                         
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*30-08-2021     Vasanth Danda       Initial  version
**************************************************************************************/
RETURN DATE IS
    v_gmt_deviation         NUMBER;
    v_out_return_date       DATE;
    v_time                 NUMBER;
    --v_bst  DATE;
PRAGMA autonomous_transaction;
BEGIN
  SELECT gmt_deviation INTO v_gmt_deviation
   FROM   ASB_clock_change
   WHERE  clock_start <= input_date
   AND    clock_end   >= input_date;

    IF input_date IS NOT NULL THEN
    v_time := (sett_per-1) * 0.5;
    END IF;

  IF v_gmt_deviation IS NOT NULL THEN
    v_out_return_date := TRUNC(input_date) + (v_time - v_gmt_deviation) * 0.041666667+0.02083;
  END IF;

  -- BST Time
  --out_date := fn_convert_gmt_bst1(v_out_return_date);

  -- GMT TIME Return
  RETURN (v_out_return_date);
EXCEPTION
    WHEN OTHERS THEN
    --out_date := fn_convert_gmt_bst1(input_date);
        RETURN input_date;
        raise_application_error(sqlerrm,sqlcode , TRUE);
END fn_get_gmt;

/

