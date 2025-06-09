@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Construction unit master data'
define root view entity ZE_I_CU_DEF_SPECIFIC
  with parameters hdr_companycode : ze_tv_bukrs
  as select from zetc_cu_def as CUDef
//  inner join zetb_pln_hdr as hdr on CUDef.company_code = hdr.company_code
{
  key CUDef.company_code as CompanyCode,
  key CUDef.cu_id as CuID,
  CUDef.unit as Unit,
  CUDef.type as Type,
  CUDef.ttype as Ttype,
  CUDef.voltage as Voltage,
  CUDef.action_cu as ActionCu,
  CUDef.distr_logic as DistrLogic,
  CUDef.zespecial_function as ZespecialFunction,
  CUDef.zinactive as Zinactive,
  CUDef.zcu_substitute as ZcuSubstitute,
  CUDef.zcu_template as ZcuTemplate,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  CUDef.local_last_changed as LocalLastChanged,
  @Semantics.systemDateTime.lastChangedAt: true
  CUDef.last_changed as LastChanged
  
} where CUDef.company_code = $parameters.hdr_companycode;
