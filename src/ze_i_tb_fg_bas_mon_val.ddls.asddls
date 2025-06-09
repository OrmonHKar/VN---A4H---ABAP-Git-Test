@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - Direct financial group - Mon Val'
define view entity ZE_I_TB_FG_BAS_MON_VAL
  as select from zetb_mon_val
  association        to parent ZE_I_TB_FG_BAS as _FG_BAS on  $projection.PlnHdrGuid    = _FG_BAS.PlnHdrGuid
                                                         and $projection.SrcPlnHdrGuid = _FG_BAS.SrcPlnHdrGuid
                                                         and $projection.ParentGuid    = _FG_BAS.Guid
  association [1..1] to ZE_I_TB_PLN_HDR       as _PlnHdr on  $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
{
  key zetb_mon_val.pln_hdr_guid          as PlnHdrGuid,
  key zetb_mon_val.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_mon_val.guid                  as Guid,
  key zetb_mon_val.fyear                 as Fyear,
  key zetb_mon_val.period                as Period,
  key zetb_mon_val.parent_guid           as ParentGuid,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_mon_val.amount                as Amount,
      zetb_mon_val.created_by            as CreatedBy,
      zetb_mon_val.created_at            as CreatedAt,
      zetb_mon_val.last_changed_by       as LastChangedBy,
      zetb_mon_val.last_changed_at       as LastChangedAt,
      zetb_mon_val.local_last_changed_at as LocalLastChangedAt,
      _FG_BAS._PlnHdr.Currency           as Currency,
      _FG_BAS,
      _PlnHdr
}
