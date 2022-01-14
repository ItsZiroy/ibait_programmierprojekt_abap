*&---------------------------------------------------------------------*
*& Report zgf_brd_statistik
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_brd_statistik.

*Read in whether to query for COUNTY/CITY/AIRPORT
PARAMETERS p_loc TYPE zg_location.

DATA g_stats_departures TYPE zg_statistics_table.
DATA g_stats_arrivals TYPE zg_statistics_table.

TRANSLATE p_loc TO UPPER CASE.

* Get the stats per country/city/airport for departures
g_stats_departures = zg_cl_brd_stats=>get_departures( p_loc ).

* Get the stats per country/city/airport for arrivals
g_stats_arrivals = zg_cl_brd_stats=>get_arrivals( p_loc ).

* Merge together the two partial tables and add to result
DATA(g_stats) = zg_cl_brd_stats=>merge(
                          i_arrivals  = g_stats_arrivals
                          i_depatures = g_stats_departures
                        ).



cl_salv_table=>factory(
IMPORTING
 r_salv_table   = DATA(o_alv)
CHANGING
 t_table        = g_stats
).

o_alv->display( ).
