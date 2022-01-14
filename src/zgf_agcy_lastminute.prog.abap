*&---------------------------------------------------------------------*
*& Report zgf_agcy_lastminute
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_agcy_lastminute.

*read in days till flight
PARAMETERS: p_days TYPE i,
            p_s_date TYPE s_date,
            p_e_date TYPE s_date.



*create flights table
DATA g_flights TYPE zg_flights_table.

*fill in data
g_flights = zg_cl_flights_repo=>get_last_minutes_flights(
              i_days       = p_days
              i_s_date =    p_s_date
              i_e_date   = p_e_date
            ).

*display table
cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = DATA(o_alv)
  CHANGING
    t_table        = g_flights
).

o_alv->display( ).
