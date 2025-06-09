@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_PPM_OBJ'
@ObjectModel.semanticKey: [ 'ObjectID', 'ObjectType' ]
define root view entity ZE_C_PPM_OBJ
  provider contract transactional_query
  as projection on ZE_I_PPM_OBJ
{
  key objectid,
  key objecttype,
  objectdesc,
  locallastchanged
  
}
