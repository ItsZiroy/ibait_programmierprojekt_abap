**********************************************************************
*
* Class for querying flights
*
**********************************************************************
CLASS zg_cl_flights_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Getting last minute flights from database
    CLASS-METHODS get_last_minutes_flights
        IMPORTING: i_days TYPE i i_s_date TYPE s_date i_e_date TYPE s_date
        RETURNING VALUE(r_flights) TYPE zg_flights_table.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zg_cl_flights_repo IMPLEMENTATION.
  METHOD get_last_minutes_flights.
*when there is days given
    IF i_s_date IS INITIAL AND i_e_date IS INITIAL.
        DATA(until) = sy-datum + i_days.
        SELECT FROM spfli AS flying
        INNER JOIN sflight AS flight ON flying~connid = flight~connid
        INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
        FIELDS carr~carrname,
        flight~fldate, flying~deptime, flying~arrtime, flying~cityfrom, flying~cityto,
        flight~price, flight~currency,
        ( seatsmax - seatsocc ) AS seatsfree
        "
        WHERE ( seatsmax - seatsocc ) > 0 AND ( flight~fldate BETWEEN @sy-datum AND @until )
       ORDER BY flight~fldate ASCENDING
      INTO CORRESPONDING FIELDS OF TABLE @r_flights.

*when there is a range of dates
        ELSE.

              SELECT FROM spfli AS flying
            INNER JOIN sflight AS flight ON flying~connid = flight~connid
            INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
            FIELDS  carr~carrname,
            flight~fldate, flying~deptime, flying~arrtime, flying~cityfrom, flying~cityto,
            flight~price, flight~currency,
            ( seatsmax - seatsocc ) AS seatsfree
           WHERE flight~fldate >=   @i_s_date AND flight~fldate <= @i_e_date
          ORDER BY flight~fldate ASCENDING
         INTO CORRESPONDING FIELDS OF TABLE @r_flights.
      ENDIF.
  ENDMETHOD.

ENDCLASS.
