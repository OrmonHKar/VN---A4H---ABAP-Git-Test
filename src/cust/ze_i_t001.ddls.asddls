@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Company code master data'
define root view entity ZE_I_T001
  as select from zetc_t001 as CompanyCode
{
  key bukrs as Bukrs,
  butxt as Butxt,
  land1 as Land1,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
