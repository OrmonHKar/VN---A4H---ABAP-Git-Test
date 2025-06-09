@EndUserText.label: 'Financial planning header data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZE_C_TB_PLN_HDR as projection on ZE_I_TB_PLN_HDR
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
 @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency'} }]    
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
    //_Add,
    _InstCu : redirected to composition child ZE_C_TB_INST_CU
    //_InstRu : redirected to composition child ZE_C_TB_INST_RU
    //_FGBas : redirected to composition child ZE_C_TB_FG_BAS
}
