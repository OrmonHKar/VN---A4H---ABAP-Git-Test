@EndUserText.label: 'Financial planning - RU - FG - Mon Val - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_RU_FG_MON_VAL as projection on ZE_I_TB_RU_FG_MON_VAL
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    key Fyear,
    key Period,
    Amount,
    ParentGuid,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    Currency,
    /* Associations */
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR,
    _RU_FG : redirected to parent ZE_C_TB_RU_FG
}
