@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - RU - FG - Mon Val'
define view entity ZE_I_TB_RU_FG_MON_VAL
  as select from zetb_mon_val
  association to parent ZE_I_TB_RU_FG as _RU_FG on  $projection.PlnHdrGuid    = _RU_FG.PlnHdrGuid
                                                and $projection.SrcPlnHdrGuid = _RU_FG.SrcPlnHdrGuid
                                                and $projection.ParentGuid    = _RU_FG.Guid
  association [1..1] to ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid                                                 
{
  key zetb_mon_val.pln_hdr_guid           as PlnHdrGuid,
  key zetb_mon_val.src_pln_hdr_guid       as SrcPlnHdrGuid,
  key zetb_mon_val.guid                   as Guid,
  key zetb_mon_val.fyear                  as Fyear,
  key zetb_mon_val.period                 as Period,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_mon_val.amount                 as Amount,
      zetb_mon_val.parent_guid            as ParentGuid,
      zetb_mon_val.created_by             as CreatedBy,
      zetb_mon_val.created_at             as CreatedAt,
      zetb_mon_val.last_changed_by        as LastChangedBy,
      zetb_mon_val.last_changed_at        as LastChangedAt,
      zetb_mon_val.local_last_changed_at  as LocalLastChangedAt,
      _RU_FG._RU._InstRU._PlnHdr.Currency as Currency,
      _RU_FG,
      _PlnHdr
}
