@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_T087U'
@ObjectModel.semanticKey: [ 'Anlue' ]
define root view entity ZE_C_T087U
  provider contract transactional_query
  as projection on ZE_I_T087U
{
  key anlue,
  anluetxt,
  locallastchanged
  
}
