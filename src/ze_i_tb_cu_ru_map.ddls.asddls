@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CU-RU map'
define view entity ZE_I_TB_CU_RU_MAP
  as select from zetb_cu_ru
  association to parent ZE_I_TB_CU as _CU on  $projection.PlnHdrGuid    = _CU.PlnHdrGuid
                                          and $projection.SrcPlnHdrGuid = _CU.SrcPlnHdrGuid
                                          and $projection.ParentGuid    = _CU.Guid
  association [1..1] to ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid                                           
{
  key zetb_cu_ru.pln_hdr_guid          as PlnHdrGuid,
  key zetb_cu_ru.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_cu_ru.guid                  as Guid,
      zetb_cu_ru.parent_guid           as ParentGuid,
      zetb_cu_ru.trg_ru_bas_guid       as TrgRuBasGuid,
      zetb_cu_ru.trg_ru_id             as TrgRuId,
      zetb_cu_ru.cost_transfer_rate    as CostTransferRate,
      zetb_cu_ru.unit_transfer_rate    as UnitTransferRate,
      zetb_cu_ru.created_by            as CreatedBy,
      zetb_cu_ru.created_at            as CreatedAt,
      zetb_cu_ru.last_changed_by       as LastChangedBy,
      zetb_cu_ru.last_changed_at       as LastChangedAt,
      zetb_cu_ru.local_last_changed_at as LocalLastChangedAt,
      _CU,
      _PlnHdr
}
