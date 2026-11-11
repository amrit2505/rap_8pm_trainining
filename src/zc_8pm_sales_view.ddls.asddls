@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_8pm_SALES_VIEW 
as select from ZI_8PM_SALES_COMPOSITE
{
    key OrderId,
    OrderNo,
    Buyer,
    GrossAmount,
    CurrencyCode,
    Product,
    Quantity,
    UnitOfMeasure,
    _BPA.CompanyName as CompanyName,
    _BPA.Country as Country,
    _Product.Discount as ProductDiscount,
    _Product.Name as ProductName
}
