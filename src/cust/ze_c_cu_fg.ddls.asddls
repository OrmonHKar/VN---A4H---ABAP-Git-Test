@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_CU_FG'
@ObjectModel.semanticKey: [ 'CompanyCode', 'FinView', 'Area', 'BusinessArea', 'CuID', 'StartDate', 'GroupID' ]
define root view entity ZE_C_CU_FG
  provider contract transactional_query
  as projection on ZE_I_CU_FG
{
  key companycode,
  key finview,
  key area,
  key businessarea,
  key cuid,
  key startdate,
  key groupid,
  percentage,
  locallastchanged
  
}
