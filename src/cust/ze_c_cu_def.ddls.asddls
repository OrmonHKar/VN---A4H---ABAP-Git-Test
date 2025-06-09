@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_CU_DEF'
@ObjectModel.semanticKey: [ 'CompanyCode', 'CuID' ]
define root view entity ZE_C_CU_DEF
  provider contract transactional_query
  as projection on ZE_I_CU_DEF
{
  key CompanyCode,
  key CuID,
  Unit,
  PriceUnit,
  Currency,
  Type,
  Ttype,
  Voltage,
  ActionCu,
  DistrLogic,
  ZespecialFunction,
  Zinactive,
  ZcuSubstitute,
  ZcuTemplate,
  CUDesc,
  LocalLastChanged
  
}
