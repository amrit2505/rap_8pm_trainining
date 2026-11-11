@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Processor'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity Z8PM_TRAVEL_APPROVER
  provider contract transactional_query 
as projection on Z8PM_TRAVEL
{
    @ObjectModel.text.element: [ 'Description' ]
    @Consumption.valueHelpDefinition: [{ 
        entity.name: '/DMO/I_Travel_M', //Source
        entity.element: 'travel_id' //respective column
     }]
    key TravelId,
    @ObjectModel.text.element: [ 'AgencyName' ]
    @Consumption.valueHelpDefinition: [{ 
        entity.name: '/DMO/I_Agency', //Source
        entity.element: 'AgencyID' //respective column
     }]
    AgencyId,
    _Agency.Name as AgencyName,
    @ObjectModel.text.element: [ 'CustomerName' ]
    @Consumption.valueHelpDefinition: [{ 
        entity.name: '/DMO/I_Customer', //Source
        entity.element: 'CustomerID' //respective column
     }]
    CustomerId,
    _Customer.FirstName as CustomerName,
    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,
    CurrencyCode,
    Description,
    //showing label of other column to this column
    @ObjectModel.text.element: [ 'StatusInfo' ]
    @Consumption.valueHelpDefinition: [{ 
        entity.name: '/DMO/I_Overall_Status_VH', //Source
        entity.element: 'OverallStatus' //respective column
     }]
    OverallStatus,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    StatusInfo,
    StatusColor,
    /* Associations */
    _Agency,
    _Booking : redirected to composition child Z8PM_BOOKING_APPROVER,
    _Currency,
    _Customer,
    _OverallStatus,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_8PM_VE_CALC'
    @EndUserText.label: 'CO2 Tax'
    virtual CO2Tax : abap.int4,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_8PM_VE_CALC'
    @EndUserText.label: 'Week Day'
    virtual dayOfTheFlight : abap.char(9)
}
