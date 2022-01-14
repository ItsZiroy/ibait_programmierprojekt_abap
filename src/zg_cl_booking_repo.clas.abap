**********************************************************************
*
* Class for querying bookings
*
**********************************************************************
CLASS zg_cl_booking_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " Method gets all bookings for a customer
    CLASS-METHODS get_bookings
      IMPORTING i_cust_id         TYPE zg_cust_id
      RETURNING VALUE(r_bookings) TYPE zg_bookings_table.

    " Transform raw data into structure by ref
    CLASS-METHODS transform_ref
      CHANGING i_booking TYPE REF TO zgbooking.

    " Transform raw data into structure by hard copy
    CLASS-METHODS transform
      CHANGING i_booking TYPE zgbooking_detailed.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zg_cl_booking_repo IMPLEMENTATION.
  METHOD get_bookings.
    SELECT FROM sbook AS booking
    "Joinging tables sbook, sflight, scarr and spfli
    INNER JOIN sflight AS flight ON booking~connid = flight~connid AND booking~fldate = flight~fldate
    INNER JOIN scarr AS carr ON carr~carrid = flight~carrid
    INNER JOIN spfli AS connection ON booking~connid = connection~connid AND booking~carrid = connection~carrid

    FIELDS booking~bookid, flight~carrid,carr~carrname, flight~connid,flight~planetype,
    flight~fldate, connection~deptime, connection~arrtime, booking~class, booking~forcuram, booking~forcurkey
    WHERE customid = @i_cust_id
    ORDER BY flight~fldate
    INTO CORRESPONDING FIELDS OF TABLE @r_bookings.
  ENDMETHOD.

  METHOD transform_ref.
    CASE i_booking->class.
      WHEN 'Y'.
        i_booking->class = 'Economy'.
      WHEN 'C'.
        i_booking->class = 'Business'.
      WHEN 'F'.
        i_booking->class = 'First Class'.
    ENDCASE.
  ENDMETHOD.

  METHOD transform.
    CASE i_booking-class.
      WHEN 'Y'.
        i_booking-class = 'Economy'.
      WHEN 'C'.
        i_booking-class = 'Business'.
      WHEN 'F'.
        i_booking-class = 'First Class'.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.
