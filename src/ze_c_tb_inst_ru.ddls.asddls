@EndUserText.label: 'Financial planning - BRU installations - Interface view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_INST_RU as projection on ZE_I_TB_INST_RU
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
    InstallationId,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _PlnHdr : redirected to parent ZE_C_TB_PLN_HDR,
    _RU : redirected to composition child ZE_C_TB_RU_BAS
}
