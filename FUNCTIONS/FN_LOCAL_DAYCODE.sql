--------------------------------------------------------
--  DDL for Function FN_LOCAL_DAYCODE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "ASB_STG"."FN_LOCAL_DAYCODE" (	PparLdate   IN DATE    )	-- Business/Working
RETURN VARCHAR2
IS
	PfldDayCode	ASB_Day_Type.day_code%TYPE;
v_CNT NUMBER ;
BEGIN


    PfldDayCode := 'WD';

    v_CNT := 0 ;
    select count(1) into v_CNT from asb_ph_stg where HOLIDAY_DT = PparLdate and WORK_FLAG <> 1 ;

    IF (v_CNT > 0) THEN
        PfldDayCode := 'NWD';
    END IF;

    IF( RTRIM(TO_CHAR(PparLdate,'DAY'))='SUNDAY' ) THEN
        PfldDayCode := 'NWD';
    END IF;

	RETURN (PfldDayCode);

END FN_Local_DayCode;

/
