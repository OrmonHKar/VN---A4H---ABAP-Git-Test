@EndUserText.label: 'Financial planning - RU - FG - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_RU_FG as projection on ZE_I_TB_RU_FG
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    ParentGuid,
    GroupId,
    Logsys,
    Comments,
    TradingPartner,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR,
    _RU : redirected to parent ZE_C_TB_RU_BAS,
    _RU_FG_MON_VAL : redirected to composition child ZE_C_TB_RU_FG_MON_VAL
}
