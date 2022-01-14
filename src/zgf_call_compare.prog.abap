*&---------------------------------------------------------------------*
*& Report zgf_call_compare
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_call_compare.


*possible categories to quickly identify and compare flights
PARAMETERS p_carrid TYPE ZG_carrid OBLIGATORY.
PARAMETERS p_connid TYPE zg_connid.

PARAMETERS p_fldate TYPE s_date "DEFAULT sy-datum"
.
PARAMETERS p_endd TYPE s_date.

*carrid always full, but following lines can be either empty or full: 2^2 possible ways
IF p_connid IS NOT INITIAL.
*1st way: second entry full, last empty
    IF p_fldate IS INITIAL.

        SELECT FROM spfli AS flying
*join table spfli with sflight
             INNER JOIN sflight AS flight ON flying~connid = flight~connid
*join table spfli with scarrid
             INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
*read following information
             FIELDS carr~carrname, flight~connid,
             flight~fldate, flying~deptime
*input parameter this way is working with now
            WHERE flying~carrid = @p_carrid AND flying~connid = @p_connid
           ORDER BY flight~fldate ASCENDING
          INTO TABLE @DATA(g_flights).
*2nd way: second and third full
     ELSE.
*in this way there is an no enddate, one point in time; but only if day today or in future
        IF p_endd IS INITIAL.
        SELECT FROM spfli AS flying
            INNER JOIN sflight AS flight ON flying~connid = flight~connid
            INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
            FIELDS carr~carrname, flight~connid,
            flight~fldate, flying~deptime
           WHERE flying~carrid = @p_carrid AND flying~connid = @p_connid
            AND (  flight~fldate >=   @sy-datum AND  flight~fldate = @p_fldate     )


          ORDER BY flight~fldate ASCENDING
         INTO TABLE @g_flights.

*in this way there is an enddate, range shown
         ELSE.
                    SELECT FROM spfli AS flying
            INNER JOIN sflight AS flight ON flying~connid = flight~connid
            INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
            FIELDS carr~carrname, flight~connid,
            flight~fldate, flying~deptime
           WHERE flying~carrid = @p_carrid AND flying~connid = @p_connid
            AND ( flight~fldate >=   @sy-datum AND flight~fldate <= @p_endd )
          ORDER BY flight~fldate ASCENDING
         INTO TABLE @g_flights.
        ENDIF.
    ENDIF.
*3rd way: second empty, third full
  ELSEIF p_fldate IS NOT INITIAL.
*one date
    IF p_endd IS INITIAL.
      SELECT FROM spfli AS flying
        INNER JOIN sflight AS flight ON flying~connid = flight~connid
        INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
        FIELDS carr~carrname, flight~connid,
        flight~fldate, flying~deptime
       WHERE flying~carrid = @p_carrid
       AND  (  flight~fldate >=   @sy-datum AND  flight~fldate = @p_fldate     )
      ORDER BY flight~fldate ASCENDING
     INTO TABLE @g_flights.
*range of dates again
    ELSE.

      SELECT FROM spfli AS flying
        INNER JOIN sflight AS flight ON flying~connid = flight~connid
        INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
        FIELDS carr~carrname, flight~connid,
        flight~fldate, flying~deptime
       WHERE flying~carrid = @p_carrid
       AND  ( flight~fldate >=   @sy-datum AND flight~fldate <= @p_endd )
      ORDER BY flight~fldate ASCENDING
     INTO TABLE @g_flights.
  ENDIF.
*4th way: second and thrid empty
ELSE.
      SELECT FROM spfli AS flying
        INNER JOIN sflight AS flight ON flying~connid = flight~connid
        INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
        FIELDS carr~carrname, flight~connid,flight~fldate, flying~deptime
       WHERE flying~carrid = @p_carrid
      ORDER BY flight~fldate ASCENDING
     INTO TABLE @g_flights.

ENDIF.

*method to add data in table
cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = DATA(o_alv)
  CHANGING
    t_table        = g_flights
).

o_alv->display( ).
