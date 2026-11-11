@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement as Child Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z8PM_BOOKSUPPL 
as select from /dmo/booksuppl_m

association to parent Z8PM_BOOKING as _Booking
on $projection.BookingId = _Booking.BookingId
and $projection.TravelId = _Booking.TravelId

association[1..1] to Z8PM_TRAVEL as _Travel
on $projection.TravelId = _Travel.TravelId

association[1..1] to /DMO/I_Supplement as _Supplement
on $projection.SupplementId = _Supplement.SupplementID

association[1..*] to /DMO/I_SupplementText as _SupplementText
on $projection.SupplementId = _SupplementText.SupplementID
{
    key travel_id as TravelId,
    key booking_id as BookingId,
    key booking_supplement_id as BookingSupplementId,
    supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    //Exposing the associations
    _Travel,
    _Supplement,
    _SupplementText,
    _Booking
}
