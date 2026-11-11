CLASS z8pm_class_pool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    DATA : itab type table of string.
    methods : project_sap.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z8pm_class_pool IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    me->project_sap( ).

    "display the output
    out->write( itab ).
  ENDMETHOD.
  METHOD project_sap.
    data(lo_delhi) = new zcl_delhiairport( ).
    data(lo_bengalore) = new zcl_bengalore_airport( ).
    data(lo_waldorf) = new zcl_waldorf_airport( ).
    DATA : lv_value type string.

    lv_Value = lo_delhi->reached_airport( ).
    append lv_Value to itab.
    lv_value = lo_delhi->onboarding( ).
    append lv_value to itab.
    lv_value = lo_delhi->start_engine( ).
    append lv_value to itab.
    lv_value = lo_bengalore->landed_to_airport( ).
    append lv_value to itab.
    lv_value = lo_bengalore->onboarding( ).
    append lv_Value to itab.
    lv_value = lo_bengalore->start_engine( ).
    append lv_Value to itab.
    lv_value = lo_waldorf->landed_to_airport( ).
    append lv_Value to itab.
    lv_value = lo_waldorf->booking_uber( ).
    append lv_value to itab.
    lv_value = lo_waldorf->project_delivery( ).
    append lv_value to itab.


  ENDMETHOD.

ENDCLASS.
