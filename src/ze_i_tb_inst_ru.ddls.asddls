@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CU installations'
define view entity ZE_I_TB_INST_RU
  as select from zetb_inst_ru
  association to parent ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
  composition [0..*] of ZE_I_TB_RU      as _RU
{
  key zetb_inst_ru.pln_hdr_guid          as PlnHdrGuid,
  key zetb_inst_ru.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_inst_ru.guid                  as Guid,
      zetb_inst_ru.installation_id       as InstallationId,
      zetb_inst_ru.created_by            as CreatedBy,
      zetb_inst_ru.created_at            as CreatedAt,
      zetb_inst_ru.last_changed_by       as LastChangedBy,
      zetb_inst_ru.last_changed_at       as LastChangedAt,
      zetb_inst_ru.local_last_changed_at as LocalLastChangedAt,
      _PlnHdr,
      _RU
}
