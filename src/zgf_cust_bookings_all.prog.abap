*&---------------------------------------------------------------------*
*& Report zgf_cust_bookings_all
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_cust_bookings_all.


*Input customer name
PARAMETERS p_custid TYPE zg_cust_id OBLIGATORY.

*Creation of customers flights table
DATA g_bookings TYPE zg_bookings_table.

*filling customers flights structure
g_bookings = zg_cl_booking_repo=>get_bookings( p_custid ).

LOOP AT g_bookings REFERENCE INTO DATA(o_booking).
  zg_cl_booking_repo=>transform_ref(
    CHANGING
      i_booking = o_booking
  ).
ENDLOOP.


*Changing class id to class name
cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = DATA(o_alv)
  CHANGING
    t_table        = g_bookings
).

o_alv->display( ).
