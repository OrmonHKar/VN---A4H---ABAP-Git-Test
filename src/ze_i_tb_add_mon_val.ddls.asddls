@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - Add. Cost - Mon Val'
define view entity ZE_I_TB_ADD_MON_VAL
  as select from zetb_mon_val
  association to parent ZE_I_TB_ADD as _Add on  $projection.PlnHdrGuid    = _Add.PlnHdrGuid
                                            and $projection.SrcPlnHdrGuid = _Add.SrcPlnHdrGuid
                                            and $projection.ParentGuid    = _Add.Guid
  association [1..1] to ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid                                            
{
  key zetb_mon_val.pln_hdr_guid          as PlnHdrGuid,
  key zetb_mon_val.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_mon_val.guid                  as Guid,
  key zetb_mon_val.fyear                 as Fyear,
  key zetb_mon_val.period                as Period,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_mon_val.amount                as Amount,
      zetb_mon_val.parent_guid           as ParentGuid,
      zetb_mon_val.created_by            as CreatedBy,
      zetb_mon_val.created_at            as CreatedAt,
      zetb_mon_val.last_changed_by       as LastChangedBy,
      zetb_mon_val.last_changed_at       as LastChangedAt,
      zetb_mon_val.local_last_changed_at as LocalLastChangedAt,
      _Add._PlnHdr.Currency              as Currency,
      _Add,
      _PlnHdr
}
