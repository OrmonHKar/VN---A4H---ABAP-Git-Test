@EndUserText.label: 'Financial planning - Direct FG'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_FG_BAS as projection on ZE_I_TB_FG_BAS
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
@Consumption.valueHelpDefinition: [{ entity : {name: 'ZE_I_FG_DEF', element: 'GROUP_ID'  } }]    
@ObjectModel.text.element: ['GroupDesc']
    GroupId,
    _FinGrpDesc.GroupDesc as GroupDesc,
    Logsys,
    DistrLogic,
    InitialDate,
    CommissionedDate,
    TradingPartner,
    Comments,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    TotalAmount,
    Currency,
    /* Associations */
    _PlnHdr : redirected to parent ZE_C_TB_PLN_HDR_BAS,
    _FG_BAS_MON_VAL : redirected to composition child ZE_C_TB_FG_BAS_MON_VAL,
    _FinGrpDesc
}
