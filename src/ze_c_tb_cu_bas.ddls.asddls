@EndUserText.label: 'Financial planning - CUs - Projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZE_C_TB_CU_BAS
  as projection on ZE_I_TB_CU
{
  key PlnHdrGuid,
  key SrcPlnHdrGuid,
  key Guid,
      ParentGuid,
      @Consumption.valueHelpDefinition: [{ entity : {name: 'ZE_I_CU_DEF', element: 'CuID'  } }]
      @ObjectModel.text.element: ['CUDesc']
      CuId,
      _CU_Def.CUDesc as CUDesc,
      Quantity,
      Unit,
      TotalAmount,
      Currency,
      IsUnitCostManual,
      DistrLogic,
      InitialDate,
      CommissionedDate,
      ManualQuantityMaintained,
      Comments,
      TradingPartner,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      CompanyCode    as CompanyCode,

      /* Associations */
      _CU_FG  : redirected to composition child ZE_C_TB_CU_FG,
      /*_CU_RU_MAP,*/
      _InstCU : redirected to parent ZE_C_TB_INST_CU,
      _PlnHdr : redirected to ZE_C_TB_PLN_HDR,
      _CU_Def : redirected to ZE_C_CU_DEF
}
