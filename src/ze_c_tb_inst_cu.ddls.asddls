@EndUserText.label: 'Financial planning - CU installations - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_INST_CU as projection on ZE_I_TB_INST_CU
{
    key PlnHdrGuid,
    key SrcPlnHdrGuid,
    key Guid,
@Consumption.valueHelpDefinition: [{ entity : {name: 'ZE_I_T087U', element: 'ANLUE'  } }]    
@ObjectModel.text.element: ['InstDesc']        
    InstallationId,
      _InstDesc.AnlueTxt                 as InstDesc,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    LocalLastChangedAt,
    /* Associations */
    _CU : redirected to composition child ZE_C_TB_CU_BAS,
    _PlnHdr : redirected to parent ZE_C_TB_PLN_HDR
}
