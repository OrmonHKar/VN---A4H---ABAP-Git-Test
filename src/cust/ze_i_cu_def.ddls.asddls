@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Construction unit master data'
define root view entity ZE_I_CU_DEF
  as select from zetc_cu_def as CUDef
{
  key company_code as CompanyCode,
  key cu_id as CuID,
  unit as Unit,
  @Semantics.amount.currencyCode : 'Currency'
  price_unit as PriceUnit,
  currency as Currency,
  type as Type,
  ttype as Ttype,
  voltage as Voltage,
  action_cu as ActionCu,
  distr_logic as DistrLogic,
  zespecial_function as ZespecialFunction,
  zinactive as Zinactive,
  zcu_substitute as ZcuSubstitute,
  zcu_template as ZcuTemplate,
  cu_desc as CUDesc,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
