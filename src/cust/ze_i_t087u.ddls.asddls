@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Installation Master Data'
define root view entity ZE_I_T087U
  as select from zetc_t087u as Installation
{
  key anlue as Anlue,
  anlue_txt as AnlueTxt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
