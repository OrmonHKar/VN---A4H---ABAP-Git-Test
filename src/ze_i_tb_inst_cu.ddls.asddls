@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CU installations'
define view entity ZE_I_TB_INST_CU
  as select from zetb_inst_cu
  association to parent ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
  association [1..1] to ZE_I_T087U      as _InstDesc on $projection.InstallationId = _InstDesc.Anlue
  composition [0..*] of ZE_I_TB_CU      as _CU
{
  key zetb_inst_cu.pln_hdr_guid          as PlnHdrGuid,
  key zetb_inst_cu.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_inst_cu.guid                  as Guid,
      zetb_inst_cu.installation_id       as InstallationId,
      zetb_inst_cu.created_by            as CreatedBy,
      zetb_inst_cu.created_at            as CreatedAt,
      zetb_inst_cu.last_changed_by       as LastChangedBy,
      zetb_inst_cu.last_changed_at       as LastChangedAt,
      zetb_inst_cu.local_last_changed_at as LocalLastChangedAt,
      _PlnHdr,
      _InstDesc,
      _CU
}
