@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_FG_DEF'
@ObjectModel.semanticKey: [ 'GroupID' ]
define root view entity ZE_C_FG_DEF
  provider contract transactional_query
  as projection on ZE_I_FG_DEF
{
  key groupid,
  groupdesc,
  locallastchanged
  
}
