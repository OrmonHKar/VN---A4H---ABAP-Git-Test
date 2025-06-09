@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Category master data'
@ObjectModel.dataCategory: #TEXT
define root view entity ZE_I_CATEGORY
  as select from zetc_category as Category
{
  key category as Category,
@Semantics.language: true  
  key langu    as langu,
@Semantics.text: true  
  text as Text,
  textc as Textc,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
