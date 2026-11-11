*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations


class zcl_DelhiAirport definition.
    PUBLIC section.
        methods :
            reached_Airport
                    RETURNING value(r_value) type string,
            onboarding
                    RETURNING value(r_value) type string,
            start_engine
                     RETURNING value(r_value) type string.

endclass.

class zcl_delhiairport implementation.
    method reached_airport.
        r_value = 'We have reached Delhi airport, waiting for boarding!'.
    endmethod.
    method onboarding.
        r_value = 'We have been onboarded in the flight!'.
    endmethod.
    method start_engine.
        r_value = 'Plane has started, we are flying now!'.
    endmethod.
endclass.

class zcl_bengalore_Airport definition.
    PUBLIC section.
        methods : landed_to_airport
                    RETURNING value(r_value) type string,
                  onboarding
                    RETURNING value(r_value) type string,
            start_engine
                     RETURNING value(r_value) type string.
endclass.

class zcl_bengalore_airport implementation.
    method landed_to_airport.
        r_value = 'We have successfully landed to Bengalore Airport, going for hotel'.
    endmethod.
    method onboarding.
        r_value = 'We have arrived for second flight and onboarded successfully!'.
    endmethod.
    method start_engine.
        r_value = 'Engine has started and flying to Germany!'.
    endmethod.
endclass.

class zcl_waldorf_airport definition.
    PUBLIC section.
        methods : landed_to_airport
                    RETURNING value(r_value) type string,
                  booking_uber
                    RETURNING value(r_value) type string,
                  project_delivery
                    RETURNING value(r_value) type string.
endclass.

class zcl_waldorf_airport IMPLEMENTATION.
    method landed_to_airport.
        r_value = 'We have landed to Waldorf Airport, Waiting for Uber!'.
    endmethod.
    method booking_uber.
        r_value = 'Uber has arrived, moving to SAP headquarter!'.
    endmethod.
    method project_delivery.
        r_value = 'Project has been delivered successfully, Missin Accomplished!'.
    endmethod.
endclass.

