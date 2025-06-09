@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachments for financial planning'
define view entity ZE_I_TB_PLN_ATT
  as select from zetb_pln_att
  association to parent ZE_I_TB_PLN_HDR as _PlnHdr on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
{
  key pln_hdr_guid               as PlnHdrGuid,
      @EndUserText.label: 'Attachment GUID'
  key att_guid                   as AttGuid,
      @EndUserText.label: 'Comments'
      comments                   as Comments,
      @EndUserText.label: 'Attachments'
      @Semantics.largeObject:{
          mimeType: 'Mimetype',
          fileName: 'Filename',
          contentDispositionPreference: #INLINE
      }
      attachment                 as Attachment,
      @EndUserText.label: 'File Type'
      mimetype                   as Mimetype,
      @EndUserText.label: 'File Name'
      filename                   as Filename,
      _PlnHdr.LocalLastChangedAt as LocalLastChangedAt,
      _PlnHdr
}
