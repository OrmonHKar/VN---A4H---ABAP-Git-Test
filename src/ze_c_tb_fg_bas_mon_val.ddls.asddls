@EndUserText.label: 'Financial planning - Direct FG Mon Val - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_FG_BAS_MON_VAL as projection on ZE_I_TB_FG_BAS_MON_VAL
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    key Fyear,
    key Period,
    key ParentGuid,
    Amount,    
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    Currency,
    /* Associations */
    _FG_BAS : redirected to parent ZE_C_TB_FG_BAS,
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR_BAS
}
