**********************************************************************
*
* Class for querying statistics
*
**********************************************************************
CLASS zg_cl_brd_stats DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "Utility function to merge together arrivals and departures  tables
    CLASS-METHODS merge
        IMPORTING i_arrivals TYPE zg_statistics_table i_depatures TYPE zg_statistics_table
        RETURNING VALUE(r_stats) TYPE zg_statistics_table.
    "Query arrivals for stats
    CLASS-METHODS get_arrivals
        IMPORTING i_location TYPE zg_location
        RETURNING VALUE(r_stats) TYPE zg_statistics_table.
    "Query departures for stats
    CLASS-METHODS get_departures
        IMPORTING i_location TYPE zg_location
        RETURNING VALUE(r_stats) TYPE zg_statistics_table.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zg_cl_brd_stats IMPLEMENTATION.

  METHOD merge.
    r_stats = CORRESPONDING #( i_arrivals ).
    LOOP AT i_depatures REFERENCE INTO DATA(stats).
      IF line_exists( r_stats[ location = stats->location ] ).
        r_stats[ location = stats->location ]-departures = stats->departures.
      ELSE.
        r_stats = VALUE #( BASE r_stats ( location = stats->location arrivals = stats->departures ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_arrivals.
    "Preloads data into custom table based on location so it can be used in order by later on
     WITH +locat AS ( SELECT FROM sflight AS flight
        LEFT JOIN spfli AS connection
        ON flight~connid = connection~connid AND flight~carrid = connection~carrid
        FIELDS CASE WHEN @i_location = 'COUNTRY'
                   THEN connection~countryto
               WHEN @i_location = 'CITY'
                   THEN connection~cityto
               ELSE connection~airpto END AS location )
    "Now query location and count of arrivals from preloaded table
    SELECT FROM +locat AS locat
    FIELDS locat~location, COUNT( * ) AS arrivals
    GROUP BY locat~location

    INTO CORRESPONDING FIELDS OF TABLE @r_stats.
  ENDMETHOD.

  METHOD get_departures.
    "Preloads data into custom table based on location so it can be used in order by later on
     WITH +locat AS ( SELECT FROM sflight AS flight
        LEFT JOIN spfli AS connection
        ON flight~connid = connection~connid AND flight~carrid = connection~carrid
        FIELDS CASE WHEN @i_location = 'COUNTRY'
                   THEN connection~countryfr
               WHEN @i_location = 'CITY'
                   THEN connection~cityfrom
               ELSE connection~airpfrom END AS location )

    "Now query location and count of departures from preloaded table
    SELECT FROM +locat AS locat
    FIELDS locat~location, COUNT( * ) AS departures
    GROUP BY locat~location

    INTO CORRESPONDING FIELDS OF TABLE @r_stats.
  ENDMETHOD.

ENDCLASS.
