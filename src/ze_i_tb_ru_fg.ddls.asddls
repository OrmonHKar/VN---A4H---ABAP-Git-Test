@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - RU - FG'
define view entity ZE_I_TB_RU_FG
  as select from zetb_ru_fg
  association to parent ZE_I_TB_RU            as _RU on  $projection.PlnHdrGuid    = _RU.PlnHdrGuid
                                                     and $projection.SrcPlnHdrGuid = _RU.SrcPlnHdrGuid
                                                     and $projection.ParentGuid    = _RU.Guid
  composition [0..*] of ZE_I_TB_RU_FG_MON_VAL as _RU_FG_MON_VAL
  association [1..1] to ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid 
{
  key zetb_ru_fg.pln_hdr_guid          as PlnHdrGuid,
  key zetb_ru_fg.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_ru_fg.guid                  as Guid,
      zetb_ru_fg.parent_guid           as ParentGuid,
      zetb_ru_fg.group_id              as GroupId,
      zetb_ru_fg.logsys                as Logsys,
      zetb_ru_fg.comments              as Comments,
      zetb_ru_fg.trading_partner       as TradingPartner,
      zetb_ru_fg.created_by            as CreatedBy,
      zetb_ru_fg.created_at            as CreatedAt,
      zetb_ru_fg.last_changed_by       as LastChangedBy,
      zetb_ru_fg.last_changed_at       as LastChangedAt,
      zetb_ru_fg.local_last_changed_at as LocalLastChangedAt,
      _RU,
      _RU_FG_MON_VAL,
      _PlnHdr
}
