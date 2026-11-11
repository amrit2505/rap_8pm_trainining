@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Consumption'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #CONSUMPTION
define view entity ZC_8PM_CDS_TF 
as select from Z8PM_CDS_TF
{
    key company_name as CompanyName,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_Sales as TotalSales,
    currency_code as CurrencyCode,
    customer_rank as CustomerRank
}
