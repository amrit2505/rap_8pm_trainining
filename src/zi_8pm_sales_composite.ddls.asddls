@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite View'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #COMPOSITE
@Analytics.dataCategory: #CUBE
define view entity ZI_8PM_SALES_COMPOSITE 
as select from ZI_8PM_SALES_VIEW
association[1] to ZI_8PM_VIEW_BPA as _BPA
on $projection.Buyer = _BPA.BpId
association[1] to ZI_8PM_VIEW_PROD as _Product
on $projection.Product = _Product.ProductId 
{
    key OrderId,
    OrderNo,
    Buyer,
    @DefaultAggregation: #SUM
    GrossAmount,
    CurrencyCode,
    Product,
    @DefaultAggregation: #SUM
    _Items.qty as Quantity,
    _Items.uom as UnitOfMeasure,
    /* Associations */
    _Items,
    _BPA,
    _Product
}
