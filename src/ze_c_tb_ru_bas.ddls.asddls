@EndUserText.label: 'Financial planning - RUs - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_RU_BAS as projection on ZE_I_TB_RU
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    ParentGuid,
    RuId,
    Quantity,
    Unit,
    ManualQuantity,
    IsQuanManual,
    CommissionedDate,
    Comments,
    TradingPartner,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _InstRU : redirected to parent ZE_C_TB_INST_RU,
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR,
    _RU_FG : redirected to composition child ZE_C_TB_RU_FG
}
