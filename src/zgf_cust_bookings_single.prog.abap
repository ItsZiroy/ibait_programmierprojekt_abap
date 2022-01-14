*&---------------------------------------------------------------------*
*& Report zgf_cust_bookings_single
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_cust_bookings_single.

*Input flight parameters
PARAMETERS p_carrid TYPE zg_carrid Obligatory.
PARAMETERS p_connid TYPE zg_connid obligatory.
PARAMETERS p_fldate TYPE s_date obligatory.
PARAMETERS p_custom type zg_cust_id obligatory.

*Creating flight structure
DATA g_booking TYPE zgbooking_detailed.

*Filling flight structure
SELECT SINGLE FROM sbook AS booking
    LEFT JOIN sflight AS flight ON booking~connid = flight~connid AND booking~fldate = flight~fldate
    LEFT JOIN scarr AS carr ON carr~carrid = flight~carrid
    LEFT JOIN spfli AS connection ON booking~connid = connection~connid AND booking~carrid = connection~carrid
    LEFT JOIN SFLIMEAL as FlightMenu on FlightMenu~carrid = flight~carrid
    LEFT JOIN smealt as mealdescription on mealdescription~carrid = flight~carrid and mealdescription~mealnumber = FlightMenu~mealnumber
    LEFT JOIN sticket as ticket on ticket~carrid = flight~carrid and ticket~connid = flight~connid and ticket~fldate = flight~fldate and ticket~customid = booking~customid
    FIELDS booking~bookid, carr~carrname, flight~planetype,
    flight~fldate, connection~deptime, connection~arrtime, booking~class, booking~forcuram, booking~forcurkey, connection~distance,connection~distid,
     connection~fltime, flightmenu~mealnumber, mealdescription~text, ticket~place
    WHERE booking~carrid = @p_carrid AND booking~connid = @p_connid AND booking~fldate = @p_fldate AND booking~customid = @p_custom

    INTO @DATA(g_result).

     g_booking = CORRESPONDING #( g_result ).

* Changing classID to class name

    zg_cl_booking_repo=>transform(
      CHANGING
        i_booking = g_booking
    ).

.

*Showing detailed flight information

    SKIP 2.
    WRITE: 'Airline: ', g_booking-carrname.
    WRITE:/ 'Airplane type: ', g_booking-planetype.
    WRITE:/ 'Class: ', g_booking-class.
    IF g_result is not initial.
   WRITE:/ 'Seat: ', g_result-place.
    endif.

    SKIP 2.

    WRITE:/ 'Departure time: ', g_booking-deptime.
    WRITE:/ 'Arrival time: ', g_booking-arrtime.
    WRITE:/ 'Travel time: ', g_booking-fltime NO-GAP, 'h'.
    WRITE:/ 'Distance: ', g_booking-distance, g_booking-distid.


    SKIP 3.

    WRITE: '----------  Menu  ----------'.

    skip 1.

*Check if information for flight meal is given
*Write result
    IF g_booking-mealnumber = 0.

    WRITE:/ 'No information given'.
    ELSE.
   WRITE:/ 'Meal: ', g_result-text.

    ENDIF.

    skip 1.

    WRITE: '----------------------------'.
