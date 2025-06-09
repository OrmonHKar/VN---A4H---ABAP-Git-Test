@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CUs'
define view entity ZE_I_TB_CU
  as select from zetb_cu_bas
  association        to parent ZE_I_TB_INST_CU as _InstCU on  $projection.ParentGuid    = _InstCU.Guid
                                                          and $projection.PlnHdrGuid    = _InstCU.PlnHdrGuid
                                                          and $projection.SrcPlnHdrGuid = _InstCU.SrcPlnHdrGuid
  association [1..1] to ZE_I_TB_PLN_HDR        as _PlnHdr on  $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
  association [1..1] to ZE_I_CU_DEF            as _CU_Def on  $projection.CuId = _CU_Def.CuID
                                                          and $projection.CompanyCode = _CU_Def.CompanyCode
  composition [0..*] of ZE_I_TB_CU_FG          as _CU_FG
  composition [0..*] of ZE_I_TB_CU_RU_MAP      as _CU_RU_MAP
{
  key zetb_cu_bas.pln_hdr_guid               as PlnHdrGuid,
  key zetb_cu_bas.src_pln_hdr_guid           as SrcPlnHdrGuid,
  key zetb_cu_bas.guid                       as Guid,
      zetb_cu_bas.parent_guid                as ParentGuid,
      zetb_cu_bas.cu_id                      as CuId,
      zetb_cu_bas.quantity                   as Quantity,
      zetb_cu_bas.unit                       as Unit,
      @Semantics.amount.currencyCode: 'Currency'
      zetb_cu_bas.total_amount               as TotalAmount,
      zetb_cu_bas.is_unit_cost_manual        as IsUnitCostManual,
      zetb_cu_bas.distr_logic                as DistrLogic,
      zetb_cu_bas.initial_date               as InitialDate,
      zetb_cu_bas.commissioned_date          as CommissionedDate,
      zetb_cu_bas.manual_quantity_maintained as ManualQuantityMaintained,
      zetb_cu_bas.comments                   as Comments,
      zetb_cu_bas.trading_partner            as TradingPartner,
      zetb_cu_bas.created_by                 as CreatedBy,
      zetb_cu_bas.created_at                 as CreatedAt,
      zetb_cu_bas.last_changed_by            as LastChangedBy,
      zetb_cu_bas.last_changed_at            as LastChangedAt,
      zetb_cu_bas.local_last_changed_at      as LocalLastChangedAt,
      _PlnHdr.Currency                       as Currency,
      _PlnHdr.CompanyCode                    as CompanyCode,
      _InstCU,
      _CU_FG,
      _CU_Def,
      _CU_RU_MAP,
      _PlnHdr
}
