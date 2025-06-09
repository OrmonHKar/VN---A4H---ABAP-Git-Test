@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Const Transfer Rate CU to RU'
define root view entity ZE_I_CU_RU_C
  as select from zetc_cu_ru_c as CURUC
{
  key company_code as CompanyCode,
  key cu_id as CuID,
  key category as Category,
  key ru_id as RuID,
  cost_transfer as CostTransfer,
  ze_spe_gen as ZeSpeGen,
  ze_direct_cu_def as ZeDirectCuDef,
  ze_no_direct_cu_def as ZeNoDirectCuDef,
  ze_valid_to as ZeValidTo,
  ze_comment as ZeComment,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
