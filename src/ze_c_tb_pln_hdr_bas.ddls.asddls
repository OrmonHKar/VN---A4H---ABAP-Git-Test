@EndUserText.label: 'Financial planning header data - FG'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZE_C_TB_PLN_HDR_BAS
  as projection on ZE_I_TB_PLN_HDR
{
  key PlnHdrGuid,
      ObjId,
      FinView,
      PlngType,
      HasCu,
      HasRu,
      HasFg,
      HasManualCi,
      IsRollup,
      Periv,
      Obtyp,
      StartDate,
      EndDate,
      Currency,
      CompanyCode,
      BusinessArea,
      Area,
      Category,
      Anlue,
      PfGuid,
      Periodtype,
      CommInstallId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _FGBas       : redirected to composition child ZE_C_TB_FG_BAS,
      _Attachments : redirected to composition child ZE_C_TB_PLN_ATT

}
