@AbapCatalog.sqlViewName: 'Z8PM_VIEW_DDIC' //DDIC View in SE11
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'First CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view Z8PM_FIRST_CDS_VIEW 
as select from z8pm_tab_bpa
{
    key bp_id as BpId,
    bp_role as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City
}
