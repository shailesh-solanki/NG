--------------------------------------------------------
--  DDL for Function FN_CONVERT_GMT_BST1
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."FN_CONVERT_GMT_BST1" ( input_date IN DATE ) 
/**************************************************************************************
*
* Program Name           :fn_convert_gmt_bst1
* Author                 :IBM(sirisha singadi)
* Creation Date          :26-04-2021
* Description            :This is a PL/SQL Function. This function will convert 
                          Time zone from GMT to BST.
*                        
*
* Calling Program        :None
* Called Program         :PR_MSMSTG1_LOAD_SEASON_TH
*                         
*
* Input files            :None
* Output files           :None
* Input Parameter        :None
* Output Parameter       :None
* Modifications  History :None
*
* <DD-MM-YYYY>   <Modifier Name>    <Description>
*
**************************************************************************************/
RETURN DATE IS
    v_gmt_deviation    NUMBER;
    v_out_return_date       DATE;
    PRAGMA autonomous_transaction;
BEGIN
    SELECT
        gmt_deviation
    INTO v_gmt_deviation
    FROM
        asb_clock_change
    WHERE
        input_date BETWEEN clock_start AND clock_end;

    IF v_gmt_deviation = 1 THEN
    v_out_return_date := input_date + INTERVAL '1' HOUR;
        RETURN v_out_return_date;


    END IF;
 RETURN input_date;
EXCEPTION
    WHEN OTHERS THEN
        RETURN input_date;
        raise_application_error(sqlerrm,sqlcode , TRUE);
END fn_convert_gmt_bst1;

/
