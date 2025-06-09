@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - CU - FG - Mon Val - Projection view'
@Metadata.allowExtensions: true

define view entity ZE_C_TB_CU_FG_MON_VAL as projection on ZE_I_TB_CU_FG_MON_VAL
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
    _CU_FG : redirected to parent ZE_C_TB_CU_FG,
    _PlnHdr : redirected to ZE_C_TB_PLN_HDR
}
