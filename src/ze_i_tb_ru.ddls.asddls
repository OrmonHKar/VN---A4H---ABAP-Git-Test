@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - RUs'
define view entity ZE_I_TB_RU
  as select from zetb_ru_bas
  association to parent ZE_I_TB_INST_RU as _InstRU on  $projection.ParentGuid    = _InstRU.Guid
                                                   and $projection.PlnHdrGuid    = _InstRU.PlnHdrGuid
                                                   and $projection.SrcPlnHdrGuid = _InstRU.SrcPlnHdrGuid
  composition [0..*] of ZE_I_TB_RU_FG   as _RU_FG
  association [1..1] to ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid 
{
  key zetb_ru_bas.pln_hdr_guid          as PlnHdrGuid,
  key zetb_ru_bas.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_ru_bas.guid                  as Guid,
      zetb_ru_bas.parent_guid           as ParentGuid,
      zetb_ru_bas.ru_id                 as RuId,
      zetb_ru_bas.quantity              as Quantity,
      zetb_ru_bas.unit                  as Unit,
      zetb_ru_bas.manual_quantity       as ManualQuantity,
      zetb_ru_bas.is_quan_manual        as IsQuanManual,
      zetb_ru_bas.commissioned_date     as CommissionedDate,
      zetb_ru_bas.comments              as Comments,
      zetb_ru_bas.trading_partner       as TradingPartner,
      zetb_ru_bas.created_by            as CreatedBy,
      zetb_ru_bas.created_at            as CreatedAt,
      zetb_ru_bas.last_changed_by       as LastChangedBy,
      zetb_ru_bas.last_changed_at       as LastChangedAt,
      zetb_ru_bas.local_last_changed_at as LocalLastChangedAt,
      _InstRU,
      _RU_FG,
      _PlnHdr
}
