*&---------------------------------------------------------------------*
*& Report zgf_transactioncodes
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgf_transactioncodes.


*read in wished transaction code in lowercase
PARAMETERS zgf_tac TYPE zg_tac.
*transform to upper case
TRANSLATE zgf_tac TO UPPER CASE.

*call transaction
CALL TRANSACTION zgf_tac.
