@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED PPM Objects'
define root view entity ZE_I_PPM_OBJ
  as select from zetc_ppm_obj as PPMObj
{
  key object_id as ObjectID,
  key object_type as ObjectType,
  object_desc as ObjectDesc,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed as LastChanged
  
}
