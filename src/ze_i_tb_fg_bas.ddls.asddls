@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - Direct financial group'
define view entity ZE_I_TB_FG_BAS
  as select from zetb_fg_bas
  association to parent ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
  association [1..1] to ZE_I_FG_DEF as _FinGrpDesc on $projection.GroupId = _FinGrpDesc.GroupID
  composition [0..*] of ZE_I_TB_FG_BAS_MON_VAL as _FG_BAS_MON_VAL
{
  key zetb_fg_bas.pln_hdr_guid          as PlnHdrGuid,
  key zetb_fg_bas.src_pln_hdr_guid      as SrcPlnHdrGuid,
  key zetb_fg_bas.guid                  as Guid,
      zetb_fg_bas.group_id              as GroupId,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_fg_bas.total_amount          as TotalAmount,
      zetb_fg_bas.logsys                as Logsys,
      zetb_fg_bas.distr_logic           as DistrLogic,
      zetb_fg_bas.initial_date          as InitialDate,
      zetb_fg_bas.commissioned_date     as CommissionedDate,
      zetb_fg_bas.trading_partner       as TradingPartner,
      zetb_fg_bas.comments              as Comments,
      zetb_fg_bas.created_by            as CreatedBy,
      zetb_fg_bas.created_at            as CreatedAt,
      zetb_fg_bas.last_changed_by       as LastChangedBy,
      zetb_fg_bas.last_changed_at       as LastChangedAt,
      zetb_fg_bas.local_last_changed_at as LocalLastChangedAt,
      _PlnHdr.Currency  as Currency,
      _PlnHdr, // Make association public
      _FG_BAS_MON_VAL,
      _FinGrpDesc
}
