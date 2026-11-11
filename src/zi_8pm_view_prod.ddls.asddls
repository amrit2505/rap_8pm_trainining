@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_8PM_VIEW_PROD 
as select from z8pm_tab_prod
{
    key product_id as ProductId,
    name as Name,
    category as Category,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    discount as Discount
}
