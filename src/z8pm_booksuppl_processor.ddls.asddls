@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Processor'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity Z8PM_BOOKSUPPL_PROCESSOR 
as projection on Z8PM_BOOKSUPPL
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking : redirected to parent Z8PM_BOOKING_PROCESSOR,
    _Supplement,
    _SupplementText,
    _Travel : redirected to Z8PM_TRAVEL_PROCESSOR
}
