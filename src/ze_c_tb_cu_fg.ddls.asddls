@EndUserText.label: 'Financial planning - CU - FG - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_CU_FG as projection on ZE_I_TB_CU_FG
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    ParentGuid,
    GroupId,
    TotalAmount,
    Currency,
    Logsys,
    Comments,
    TradingPartner,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _CU : redirected to parent ZE_C_TB_CU_BAS,
    _CU_FG_MON_VAL : redirected to composition child ZE_C_TB_CU_FG_MON_VAL,
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR
}
