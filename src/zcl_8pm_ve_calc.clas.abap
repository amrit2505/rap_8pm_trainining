CLASS zcl_8pm_ve_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_8pm_ve_calc IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    check not it_original_data is INITIAL.

   DATA : lt_calc_data type STANDARD table of z8pm_travel_processor
            with DEFAULT KEY,
            lv_rate type p decimals 2 value '0.02'.

      lt_calc_data = CORRESPONDING #( it_original_data ).

   LOOP at lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc>).
    <fs_calc>-CO2Tax = <fs_calc>-TotalPrice * lv_rate.
    <fs_calc>-dayOfTheFlight = 'Sunday'.


   endloop.


    ct_calculated_data = CORRESPONDING #( lt_calc_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
