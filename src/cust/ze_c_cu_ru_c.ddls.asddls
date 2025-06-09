@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_CU_RU_C'
@ObjectModel.semanticKey: [ 'CompanyCode', 'CuID', 'Category', 'RuID' ]
define root view entity ZE_C_CU_RU_C
  provider contract transactional_query
  as projection on ZE_I_CU_RU_C
{
  key companycode,
  key cuid,
  key category,
  key ruid,
  costtransfer,
  zespegen,
  zedirectcudef,
  zenodirectcudef,
  zevalidto,
  zecomment,
  locallastchanged
  
}
