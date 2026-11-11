@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BPA View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_8PM_VIEW_BPA 
as select from z8pm_tab_bpa
association[1] to I_Country as _Country
on $projection.Country = _Country.Country
{
    key bp_id as BpId,
    bp_role as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City,
    
    //Expose the association for the future reference
    _Country._Text[Language = $session.system_language].CountryName as CountryName
}
