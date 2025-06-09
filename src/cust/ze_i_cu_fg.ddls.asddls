@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Financial Group breakdown CU'
define root view entity ZE_I_CU_FG
  as select from zetc_cu_fg as CUFGDef
{
  key company_code as CompanyCode,
  key fin_view as FinView,
  key area as Area,
  key business_area as BusinessArea,
  key cu_id as CuID,
  key start_date as StartDate,
  key group_id as GroupID,
  percentage as Percentage,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
