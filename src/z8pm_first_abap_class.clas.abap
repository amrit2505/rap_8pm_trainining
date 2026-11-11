CLASS z8pm_first_abap_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
        INTERFACES : IF_OO_ADT_CLASSRUN.
        METHODS : ADDITION
                      IMPORTING
                        p_Value1 type i
                        p_value2 type i
                      EXPORTING
                        e_Result type i.

       METHODS : ADD_DATA.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z8pm_first_abap_class IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
        "print a message

*        OUT->WRITE( 'Welcome to AOC Journey with Amrit!' ).
       "addition method
*        ME->addition(
*          EXPORTING
*            p_value1 =  65
*            p_value2 =  49
*          IMPORTING
*            e_result = data(lv_output)
*        ).
*
*
*        OUT->WRITE( |The sum of given numbers = { lv_output }.| ).


""Adding the data in our table
me->add_data( ).
if sy-subrc eq 0.
    Select * from z8pm_emp_table
        into table @data(lt_employee).

    out->write(
      EXPORTING
        data   = lt_employee
    ).

endif.



  ENDMETHOD.

  METHOD addition.
        e_result = p_value1 + p_value2.
  ENDMETHOD.

  METHOD add_data.
       DATA : lt_emp type table of Z8PM_EMP_TABLE.

       lt_emp = value #(
                (
                    emp_id = '450005'
                    emp_name = 'Tanya'
                    emp_dept = 'SAP HCM'
                )
                (
                    emp_id = '450006'
                    emp_name = 'Naitik'
                    emp_dept = 'ABAP Development'
                )
                (
                    emp_id = '450007'
                    emp_name = 'Nikhil Kumar'
                    emp_dept = 'SAP TM'
                )
       ).

       insert z8pm_emp_table
                from table @lt_emp.

  ENDMETHOD.

ENDCLASS.
