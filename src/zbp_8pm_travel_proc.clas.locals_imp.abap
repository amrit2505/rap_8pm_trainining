CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
       entities FOR CREATE Travel.

    METHODS precheck_create FOR PRECHECK
       entities FOR CREATE Travel.

    METHODS precheck_update FOR PRECHECK
       entities FOR UPDATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD augment_create.
    DATA : travel_create type table for create z8pm_travel.
    travel_create = CORRESPONDING #( entities ).


  LOOP at travel_create ASSIGNING FIELD-SYMBOL(<travel>).
    <travel>-AgencyId = '070002'.
    <travel>-CustomerId = '000001'.
    <travel>-OverallStatus = 'N'. "New Status
    <travel>-%control-AgencyId = if_abap_behv=>mk-on.
    <travel>-%control-CustomerId = if_abap_behv=>mk-on.
    <travel>-%control-OverallStatus = if_abap_behv=>mk-on.

  endloop.

  "modify the travel entity with this.
  modify augmenting entities of z8pm_travel
    entity Travel
    create from travel_create.

  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

ENDCLASS.
