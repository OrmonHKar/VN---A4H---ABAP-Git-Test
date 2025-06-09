@EndUserText.label: 'Attachments for financial planning'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_PLN_ATT as projection on ZE_I_TB_PLN_ATT
{
    key PlnHdrGuid,
    key AttGuid,
    Comments,
    Attachment,
    Mimetype,
    Filename,
    LocalLastChangedAt,
    /* Associations */
    _PlnHdr : redirected to parent ZE_C_TB_PLN_HDR_BAS
}
