@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales View'
@Metadata.ignorePropagatedAnnotations: false
@VDM.viewType: #BASIC
define view entity ZI_8PM_SALES_VIEW 
as select from z8pm_tab_so_h
association[1..*] to z8pm_tab_so_i as _Items
on $projection.OrderId = _Items.order_id
{
    key order_id as OrderId,
    order_no as OrderNo,
    buyer as Buyer,
    gross_amount as GrossAmount,
    currency_code as CurrencyCode,
    _Items.product as Product,
    //Exposing the association
    _Items
}
