@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZE_I_CATEGORY'
@ObjectModel.semanticKey: [ 'Category' ]
define root view entity ZE_C_CATEGORY
  provider contract transactional_query
  as projection on ZE_I_CATEGORY
{
  key category,
  key langu,
  text,
  textc,
  locallastchanged
  
}
