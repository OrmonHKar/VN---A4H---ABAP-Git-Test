@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CU - FG'
define view entity ZE_I_TB_CU_FG
  as select from zetb_cu_fg
  association        to parent ZE_I_TB_CU     as _CU     on  $projection.PlnHdrGuid    = _CU.PlnHdrGuid
                                                         and $projection.SrcPlnHdrGuid = _CU.SrcPlnHdrGuid
                                                         and $projection.ParentGuid    = _CU.Guid
  composition [0..*] of ZE_I_TB_CU_FG_MON_VAL as _CU_FG_MON_VAL
  association [1..1] to ZE_I_TB_PLN_HDR       as _PlnHdr on  $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
{
  key zetb_cu_fg.pln_hdr_guid          as PlnHdrGuid,
  key zetb_cu_fg.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_cu_fg.guid                  as Guid,
      zetb_cu_fg.parent_guid           as ParentGuid,
      zetb_cu_fg.group_id              as GroupId,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_cu_fg.total_amount          as TotalAmount,
      zetb_cu_fg.logsys                as Logsys,
      zetb_cu_fg.comments              as Comments,
      zetb_cu_fg.trading_partner       as TradingPartner,
      zetb_cu_fg.created_by            as CreatedBy,
      zetb_cu_fg.created_at            as CreatedAt,
      zetb_cu_fg.last_changed_by       as LastChangedBy,
      zetb_cu_fg.last_changed_at       as LastChangedAt,
      zetb_cu_fg.local_last_changed_at as LocalLastChangedAt,
      _PlnHdr.Currency                 as Currency,
      _CU,
      _CU_FG_MON_VAL,
      _PlnHdr
}
