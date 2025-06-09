@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_T001'
@ObjectModel.semanticKey: [ 'Bukrs' ]
define root view entity ZE_C_T001
  provider contract transactional_query
  as projection on ZE_I_T001
{
  key bukrs,
  butxt,
  land1,
  locallastchanged
  
}
