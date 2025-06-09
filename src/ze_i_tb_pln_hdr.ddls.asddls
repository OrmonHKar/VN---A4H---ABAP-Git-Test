@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning header data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*@UI.headerInfo: {
    typeName: 'Financial planning header',
    typeNamePlural: 'Financial planning headers',
    title: {
        label: 'Financial planning header',
        value: 'PlnHdrGuid'
    }
}*/
define root view entity ZE_I_TB_PLN_HDR
  as select from zetb_pln_hdr
  composition [0..*] of ZE_I_TB_INST_CU as _InstCu
  composition [0..*] of ZE_I_TB_INST_RU as _InstRu
  composition [0..*] of ZE_I_TB_FG_BAS  as _FGBas
  composition [0..*] of ZE_I_TB_ADD     as _Add
  composition [0..*] of ZE_I_TB_PLN_ATT as _Attachments
{
  key zetb_pln_hdr.pln_hdr_guid          as PlnHdrGuid,
      zetb_pln_hdr.obj_id                as ObjId,
      zetb_pln_hdr.fin_view              as FinView,
      zetb_pln_hdr.plng_type             as PlngType,
      zetb_pln_hdr.has_cu                as HasCu,
      zetb_pln_hdr.has_ru                as HasRu,
      zetb_pln_hdr.has_fg                as HasFg,
      zetb_pln_hdr.has_manual_ci         as HasManualCi,
      zetb_pln_hdr.is_rollup             as IsRollup,
      zetb_pln_hdr.periv                 as Periv,
      zetb_pln_hdr.obtyp                 as Obtyp,
      zetb_pln_hdr.start_date            as StartDate,
      zetb_pln_hdr.end_date              as EndDate,
      zetb_pln_hdr.currency              as Currency,
      zetb_pln_hdr.company_code          as CompanyCode,
      zetb_pln_hdr.business_area         as BusinessArea,
      zetb_pln_hdr.area                  as Area,
      zetb_pln_hdr.category              as Category,
      zetb_pln_hdr.anlue                 as Anlue,
      zetb_pln_hdr.pf_guid               as PfGuid,
      zetb_pln_hdr.periodtype            as Periodtype,
      zetb_pln_hdr.comm_install_id       as CommInstallId,    
      zetb_pln_hdr.created_by            as CreatedBy,
      zetb_pln_hdr.created_at            as CreatedAt,
      zetb_pln_hdr.last_changed_by       as LastChangedBy,
      zetb_pln_hdr.last_changed_at       as LastChangedAt,
      zetb_pln_hdr.local_last_changed_at as LocalLastChangedAt,
      _InstCu,
      _InstRu,
      _FGBas,
      _Add,
      _Attachments
}
