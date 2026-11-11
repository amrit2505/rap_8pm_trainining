CLASS z8pm_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    DATA : lv_opr type c value 'D'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z8pm_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    case lv_opr.
        when 'R'. "read operation
            READ Entities of z8pm_travel
            Entity Travel
            ALL fields with
            value #(
                (
                    TravelId = '00000001'
                )
                (
                    TravelId = '00000002'
                )
                (
                    TravelId = '00112233'
                )
            )
            result data(lt_result)
            failed data(lt_failed)
            reported data(lt_reported).

            out->write( lt_result ).
            out->write( lt_failed ).
            out->write( lt_reported ).
        when 'C'. "create operation
            data(lv_description) = 'Test ABAP'.
            data(lv_agency) = '070007'.
            data(lv_customer) = '000705'.

            Modify entities of z8pm_travel
                entity Travel
              create fields ( TravelId AgencyId
                CustomerId BeginDate EndDate Description OverallStatus )
              with value #(
                (
                    %cid = 'TEST1'
                    TravelId = '00112233'
                    AgencyId = lv_agency
                    CustomerId = lv_customer
                    BeginDate = cl_abap_context_info=>get_system_date( )
                    EndDate = cl_abap_context_info=>get_system_date( ) + 30
                    Description = lv_description
                    OverallStatus = 'A'
                )
                (
                    %cid = 'TEST2'
                    TravelId = '00112234'
                    AgencyId = lv_agency
                    CustomerId = lv_customer
                    BeginDate = cl_abap_context_info=>get_system_date( )
                    EndDate = cl_abap_context_info=>get_system_date( ) + 30
                    Description = lv_description
                    OverallStatus = 'A'
                )
                (
                    %cid = 'TEST3'
                    TravelId = '00000005'
                    AgencyId = lv_agency
                    CustomerId = lv_customer
                    BeginDate = cl_abap_context_info=>get_system_date( )
                    EndDate = cl_abap_context_info=>get_system_date( ) + 30
                    Description = lv_description
                    OverallStatus = 'A'
                )
              )
              mapped data(lt_mapped)
              failed lt_Failed
              reported lt_Reported.

              "commit and save
              commit entities. "to save at the db

              out->write( lt_mapped ).
              out->write( lt_failed ).
              out->write( lt_reported ).


        when 'U'. "update operation
            lv_description = 'Wollah'.
            lv_agency = '070028'.
            data(lv_overallstatus) = 'X'.

            Modify Entities of z8pm_travel
                Entity Travel
                    update fields ( AgencyId Description OverallStatus )
                    with value #(
                        (
                            TravelId = '00112233'
                            AgencyId = lv_agency
                            Description = lv_description
                            OverallStatus = lv_overallstatus
                        )
                        (
                            TravelId = '00112234'
                            AgencyId = lv_agency
                            Description = lv_description
                            OverallStatus = lv_overallstatus
                        )
                    )
                    mapped lt_mapped
                    failed lt_failed
                    reported lt_reported.

                    commit entities. " to save the changes in DB

                    out->write( lt_mapped ).
                    out->write( lt_failed ).
                    out->write( lt_reported ).


        when 'D'. "delete operation
            modify entities of z8pm_travel
                Entity Travel
                    delete from value #(
                        (
                            TravelId = '00112233'
                        )
                        (
                            TravelId = '00112234'
                        )
                    )
                mapped lt_mapped
                failed lt_failed
                reported lt_reported.

                commit entities.


                out->write(
                  EXPORTING
                    data   = lt_mapped
                ).
                out->write( lt_failed ).
                out->write( lt_reported ).

    ENDCASE.
  ENDMETHOD.
ENDCLASS.
