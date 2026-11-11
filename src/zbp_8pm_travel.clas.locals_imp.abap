CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Travel RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      keys FOR travel~calculatetotalprice.
    METHODS recalctotalprice FOR MODIFY
      keys FOR ACTION travel~recalctotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      keys FOR travel~validateheaderdata.
    METHODS precheck_create FOR PRECHECK
      entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      entities FOR UPDATE travel.
    METHODS accepttravel FOR MODIFY
      keys FOR ACTION travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE Travel.

    METHODS earlynumbering_cba_Booking FOR NUMBERING
       entities FOR CREATE Travel\_Booking.

   types : t_entity_create
            type table for create z8pm_travel,
           t_entity_update
            type table for update z8pm_travel,
           t_entity_rep
            type table for reported z8pm_travel,
           t_entity_err
            type table for failed z8pm_travel.

   methods precheck_8pm_reuse
    importing
        entities_u TYPE t_entity_update optional
        entities_c TYPE t_entity_create optional
    exporting
        reported TYPE t_entity_rep
        failed TYPE t_entity_err.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    DATA : ls_result like line of result.
    "step 1 :- get the data of my instance
        Read entities of z8pm_travel in LOCAL mode
            entity Travel
            fields ( TravelId OverallStatus )
            with CORRESPONDING #( keys )
            result data(lt_travel)
            failed data(lt_failed).

    "step 2 :- we will loop over it.
    LOOP at lt_travel into data(ls_travel).

    "step 3 :- check if the instance was having status or not
    if ( ls_travel-OverallStatus = 'X' ).
        data(lv_auth) = abap_false.
    else.
        lv_auth = abap_true.
    endif.
    "step 4 :- check the authorization

    "step 5 :- if the permission is denied -> then reject the edit

    ls_result = value #( TravelId = ls_travel-TravelId
                %update = cond #( when lv_auth eq abap_false
                    then if_abap_behv=>auth-unauthorized
                   else
                        if_abap_behv=>auth-allowed
                 )
     ).

     "finally we will append this to the exporting result
        append ls_result to result.


    endloop.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create. " create for parent
    "logic for auto generating the primary keys
    DATA : entity        TYPE STRUCTURE FOR CREATE z8pm_travel,
           travel_id_max TYPE /dmo/travel_id.

    "Step 1 :- Ensure that travel id must be empty/
    "otherwise, we will immediately perform create
    LOOP AT  entities INTO  entity WHERE TravelId IS NOT INITIAL.
      "immediately perform insert

      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    "Step 2 :- Get the sequence number from SNRO
    DATA(entities_wo_travelId) = entities.
    DELETE entities_wo_travelid WHERE TravelId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*        ignore_buffer     =
            nr_range_nr       = '01' "getting one number at a time
            object            = '/DMO/TRAVL'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*    CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        "Step 3 :- IF there is any exception, we will throw the error
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #(
             %cid = entity-%cid
             %key = entity-%key
          ) TO failed-travel.

          APPEND VALUE #(
             %cid = entity-%cid
             %key = entity-%key
             %msg = lx_number_ranges
          ) TO reported-travel.


        ENDLOOP.



    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        "Step 4 :- Handle special cases where the number range exceeds criticality
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #(
             %cid = entity-%cid
             %key = entity-%key
             %fail-cause = if_abap_behv=>cause-conflict
          ) TO failed-travel.

          APPEND VALUE #(
             %cid = entity-%cid
             %key = entity-%key
             %msg = NEW /dmo/cm_flight_messages(
                 textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                 severity = if_abap_behv_message=>severity-warning
             )
          ) TO reported-travel.


        ENDLOOP.

      WHEN '2' OR '3'.
        "Step 5 :- if the number range returns the last number, or number range exhausted
        LOOP AT entities_wo_travelid INTO entity.
      APPEND VALUE #(
         %cid = entity-%cid
         %key = entity-%key
         %fail-cause = if_abap_behv=>cause-conflict
      ) TO failed-travel.

      APPEND VALUE #(
         %cid = entity-%cid
         %key = entity-%key
         %msg = NEW /dmo/cm_flight_messages(
             textid = /dmo/cm_flight_messages=>not_sufficient_numbers
             severity = if_abap_behv_message=>severity-warning
         )
      ) TO reported-travel.


    ENDLOOP.

    ENDCASE.


    "Step 6 :- final check for all numbers
    "final check to ensure the number count should be same as total
        "entities are there
        assert number_range_returned_quantity = lines( entities_wo_travelid ).
    "Step 7 :- we will loop over all the incoming travel data from UI
    "perform the insert operation
        travel_id_max = number_range_key - number_range_returned_quantity.
    LOOP at entities_wo_travelid into entity.
        travel_id_max += 1. "this will be our new primary key
        entity-TravelId = travel_id_max.

        APPEND value #(
            %cid = entity-%cid
            %key = entity-%key
            "for draft we need to mention to mapped also
            %is_draft = entity-%is_draft
        ) to mapped-travel.  "mapped ensure
            "RAP Framework will be told to generate
                "a new record

    endloop.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking. "create for child
  DATA : max_booking_id type /dmo/booking_id.
    "Step 1 :- get all the travel requests and their bookign
            "data
      Read Entities of z8pm_travel in local mode
        entity Travel by \_Booking
        from corresponding #( entities )
        link data(bookings).

   LOOP at entities assigning FIELD-symbol(<travel_group>)
    group by <travel_group>-TravelId.
    "step 2 :- get the highest booking number which is
            "already there
     LOOP at bookings into data(ls_booking) using
        key entity where source-TravelId = <travel_group>-TravelId.
        "we will check
        if max_booking_id < ls_booking-target-BookingId.
            max_booking_id = ls_booking-target-BookingId.

        endif.

    endloop.
    "step 3 :- get the assigned booking numbers for all
        "incoming requests
     LOOP at entities into data(ls_entity) using key
        entity where TravelId = <travel_group>-TravelId.

        LOOP AT ls_entity-%target into data(ls_target).
            if max_booking_id < ls_target-BookingId.
                max_booking_id = ls_target-BookingId.
            endif.
        endloop.



    endloop.

    "step 4 :- assign the primary key to create new record

       LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>)
       using key entity where TravelId = <travel_group>-TravelId.
        "assign the primary key


        LOOP AT <travel>-%target
                ASSIGNING FIELD-SYMBOL(<booking_wo_keys>).

        append CORRESPONDING #( <booking_wo_keys> )
        to mapped-booking ASSIGNING FIELD-SYMBOL(<mapped_booking>).
        if <mapped_booking>-BookingId is INITIAL.
            max_booking_id += 1.
            <mapped_booking>-BookingId = max_booking_id.

        endif.


        endloop.
    endloop.


  endloop.
  ENDMETHOD.

  METHOD get_instance_features.
    "Step 1 :- Read the travel data with the status
        Read entities of z8pm_travel in local mode
            entity Travel
            Fields ( TravelId OverallStatus )
            with corresponding #( keys )
            result data(travels)
            failed failed.
    "Step 2 :- Return the result with the booking creation
        "either possible or not
        read table travels into data(ls_travel) index 1.
        if ( ls_travel-OverallStatus = 'X' ).
            "not allow
            data(lv_allow) = if_abap_behv=>fc-o-disabled.
       else.
            "allow
             lv_allow = if_abap_behv=>fc-o-enabled.
       endif.


       result = value #( for travel in travels
                (
                    %tky = travel-%tky
                    %assoc-_Booking = lv_allow
                )
        ).


  ENDMETHOD.

  METHOD calculateTotalPrice.
    Modify entities of Z8pm_travel in local mode
        entity Travel
        execute reCalcTotalPrice
        from CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD reCalcTotalPrice.
  "logic to calculate our total price

  "step 1 :- Define a structure and internal table
    "where we can store amount and currency
  types : begin of ty_amount_per_currency,
        amount type /dmo/total_price,
        currency_code type /dmo/currency_code,
      end of ty_amount_per_currency.

  DATA : amounts_per_currencycode type table of ty_amount_per_currency.


  "step 2 :- we will read all the instances of our
    "travel -> booking and booking supplements
   Read entities of z8pm_travel in local mode
    entity Travel
    fields ( BookingFee CurrencyCode )
    with corresponding #( keys )
    result data(travels).


  Read entities of z8pm_travel in local mode
    entity Travel by \_Booking
    fields ( FlightPrice CurrencyCode )
    with corresponding #( travels )
    result data(bookings).


  Read entities of z8pm_travel IN local mode
    entity Booking by \_BookSuppl
    fields ( Price CurrencyCode )
    with corresponding #( bookings )
    result data(bookingsupplements).


  "step 4 :- delete all the records where the currency is empty
  delete travels where CurrencyCode is initial.
  delete bookings where CurrencyCode is initial.
  delete bookingsupplements where CurrencyCode is initial.

  "step 3 :- We will do a total of booking and supplements
    "Amounts which are in common currency


  LOOP at travels ASSIGNING FIELD-symbol(<travel>).

    "transfer all the values to our custom internal table
    amounts_per_currencycode = value #( (
            amount = <travel>-BookingFee
            currency_code = <travel>-CurrencyCode
    ) ).


    "loop at bookings
    LOOP at bookings  into data(ls_booking)
        where TravelId = <travel>-TravelId.

        "collect all the booking fee together and add to our
            "custom internal table

        collect value ty_amount_per_currency(
            amount = ls_booking-FlightPrice
            currency_code = ls_booking-CurrencyCode
        )  into amounts_per_currencycode.


    endloop.

    LOOP at bookingsupplements  into data(ls_bookingsupplement)
        where TravelId = <travel>-TravelId.

        "collect all the booking fee together and add to our
            "custom internal table

        collect value ty_amount_per_currency(
            amount = ls_bookingsupplement-Price
            currency_code = ls_bookingsupplement-CurrencyCode
        )  into amounts_per_currencycode.


    endloop.

    "clear total price
    clear <travel>-TotalPrice.


    LOOP at amounts_per_currencycode into
            data(amount_per_currencycode).
         "if currency is same
        if amount_per_currencycode-currency_code
                eq <travel>-CurrencyCode.
            <travel>-TotalPrice += amount_per_currencycode-amount.

        else.
            "we need to do currency conversion
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = data(total_booking_amt)
          ).


            <travel>-TotalPrice += total_booking_amt.

        endif.


    endloop.


  endloop.


  "step 5 :- if there is a different currency, perform
    "Currency conversion along with amount

 "step 6 :- put back the total amount


 "step 7 :- return the total amount to mapped or updated
    "So that the framework can perform update for you.

  modify entities of z8pm_travel in local mode
    entity Travel
    update fields ( TotalPrice )
    with CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD validateHeaderData.
    "step 1 :- We can read the travel information
    Read entities of z8pm_travel in local mode
        entity Travel
        fields ( CustomerId BeginDate EndDate )
        with CORRESPONDING #( keys )
        result data(lt_travel).

    "step 2 :- declare a internal table for my
        "customer to check all the available customer data
      DATA : customers type sorted table of /dmo/customer
                WITH UNIQUE key customer_id.

   "step 3 :- extract the unique customer ids from customer
    "table
    customers = CORRESPONDING #( lt_travel discarding
            duplicates mapping customer_id = CustomerId
                EXCEPT * ).

   "step 4 :- if any customer id is empty we can delete it
   delete customers where customer_id is initial.

    "apply your validation.
   if customers is NOT initial.
    "i will read all the data from customer table
        Select from /dmo/customer fields customer_id
            for all entries in @customers
            where customer_id = @customers-customer_id
            into table @data(lt_cust_db).

      "we will apply loop

      LOOP at lt_travel into data(ls_travel).
        if ( ls_travel-CustomerId is initial
            or not line_exists( lt_cust_db[ customer_id = ls_travel-CustomerId ] ) ).

            "inform the RAP Framework and give the error

          append value #( %tky = ls_travel-%tky )
          to failed-travel.


          append value #( %tky = ls_travel-%tky
                %element-customerId = if_abap_behv=>mk-on
                %msg = new /dmo/cm_flight_messages(
                    textid = /dmo/cm_flight_messages=>customer_unkown
                    customer_id = ls_travel-CustomerId
                    severity = if_abap_behv_message=>severity-error
                )
             ) to reported-travel.


        endif.

        if ( ls_travel-BeginDate > ls_travel-EndDate ).

            "inform the RAP Framework there is some issue
            "and terminate the operation

          append value #( %tky = ls_travel-%tky )
          to failed-travel.


          append value #( %tky = ls_travel-%tky
                %element-BeginDate = if_abap_behv=>mk-on
                %element-EndDate = if_abap_behv=>mk-on
                %msg = new /dmo/cm_flight_messages(
                    textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                    begin_date = ls_travel-BeginDate
                    end_date = ls_travel-EndDate
                    severity = if_abap_behv_message=>severity-error
                )
             ) to reported-travel.

        endif.

      endloop.
   endif.

  ENDMETHOD.

  METHOD precheck_create.
    precheck_8pm_reuse(
      EXPORTING
*        entities_u =
        entities_c = entities
      IMPORTING
        reported   = reported-travel
        failed     = failed-travel
    ).

  ENDMETHOD.

  METHOD precheck_update.
    precheck_8pm_reuse(
      EXPORTING
        entities_u = entities
*        entities_c = entities
      IMPORTING
        reported   = reported-travel
        failed     = failed-travel
    ).
  ENDMETHOD.

  METHOD precheck_8pm_reuse.
    "step 1 :- declaration
    DATA : entities type t_entity_update,
           operation type if_abap_behv=>t_char01,
           agencies type sorted table of /dmo/agency
            WITH unique key agency_id,
           customers type sorted table of /dmo/customer
            WITH unique key customer_id.
    "step 2 :- check the entity_c was pass or
              "entity_u was passed
    assert not ( entities_c is initial
        equiv entities_u is INITIAL
    ).


     "step 3 :- perform the validation
              "only if the agency or customer is changed
    if entities_c is not INITIAL.
        entities = CORRESPONDING #( entities_c ).
        operation = if_abap_behv=>op-m-create.

    else.
        entities = CORRESPONDING #( entities_u ).
        operation = if_abap_behv=>op-m-update.

    endif.

    delete entities where %control-AgencyId = if_abap_behv=>mk-off
        and %control-CustomerId = if_abap_behv=>mk-off.


     "step 4 :- get all unique agency and customers in a table

     agencies = CORRESPONDING #( entities DISCARDING DUPLICATES
            mapping agency_id = AgencyId EXCEPT * ).

     customers = CORRESPONDING #( entities DISCARDING DUPLICATES
            mapping customer_id = CustomerId EXCEPT * ).
     "step 5 :- select the agency id and customer data
            "in the database table
     Select from /dmo/agency fields agency_id, country_code
                for ALL ENTRIES IN @agencies
                 where agency_id = @agencies-agency_id
                 into table @data(agency_country_codes).

     Select from /dmo/customer fields customer_id, country_code
            for ALL entries in @customers
            where customer_id = @customers-customer_id
            into table @data(customer_country_codes).


     "step 6 :- simply loop over all the incoming requests

            "and check the customer country and agency country
    LOOP at entities into data(entity).



    read table agency_country_codes with key agency_id
        = entity-AgencyId into data(ls_agency).

    read table customer_country_codes WITH key customer_id
        = entity-CustomerId into data(ls_customer).

     if ls_agency-country_code <> ls_customer-country_code.
     "step 7 : if the country is not matching, throw the error

     append value #(
        %cid = cond #( when operation = if_abap_behv=>op-m-create
            then entity-%cid_ref
        )
        %fail-cause = if_abap_behv=>cause-conflict
     ) to failed.

     append value #(
        %cid = cond #( when operation = if_abap_behv=>op-m-create
            then entity-%cid_ref
        )
        %is_draft = entity-%is_draft
        %msg = new /dmo/cm_flight_messages(
            textid = value #(
                msgid = 'SY'
                msgno = '499'
                attr1 = 'The Country Codes and Customer are not matching!'
            )
            agency_id = entity-AgencyId
            customer_id = entity-CustomerId
            severity = if_abap_behv_message=>severity-error
        )
        %element-agencyId = if_abap_behv=>mk-on

     ) to reported.

     endif.


    endloop.
  ENDMETHOD.

  METHOD acceptTravel.
    "perform the change of the BO instance to
        "change the status
      Modify entities of z8pm_travel in local mode
        entity Travel
        update fields ( OverallStatus )
        with value #( for key in keys (
            %tky = key-%tky
            %is_draft = key-%is_draft
            OverallStatus = 'A' "approved
        ) ).


     "read the bo instance on which we want the changes
    Read entities of z8pm_travel in local mode
        entity Travel
        all fields
            with corresponding #( keys )
            result data(lt_result).

     "send the response the result

   result = value #( for travel in lt_Result
        (
            %tky = travel-%tky
            %param = travel
        )
    ).

  ENDMETHOD.

  METHOD rejectTravel.
   "perform the change of the BO instance to
        "change the status
      Modify entities of z8pm_travel in local mode
        entity Travel
        update fields ( OverallStatus )
        with value #( for key in keys (
            %tky = key-%tky
            %is_draft = key-%is_draft
            OverallStatus = 'X'  "rejected
        ) ).


     "read the bo instance on which we want the changes
    Read entities of z8pm_travel in local mode
        entity Travel
        all fields
            with corresponding #( keys )
            result data(lt_result).

     "send the response the result

   result = value #( for travel in lt_Result
        (
            %tky = travel-%tky
            %param = travel
        )
    ).

  ENDMETHOD.

ENDCLASS.
