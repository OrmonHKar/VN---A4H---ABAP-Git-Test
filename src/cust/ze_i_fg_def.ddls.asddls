@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Financial groups master'
define root view entity ZE_I_FG_DEF
  as select from zetc_fg_def as FGDef
{
  key group_id as GroupID,
  group_desc as GroupDesc,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
