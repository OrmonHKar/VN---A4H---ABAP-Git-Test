@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Financial planning - Additional costs'
define view entity ZE_I_TB_ADD as select from zetb_add
association to parent ZE_I_TB_PLN_HDR as _PlnHdr
    on $projection.PlnHdrGuid = _PlnHdr.PlnHdrGuid
composition [0..*] of ze_i_tb_add_mon_val as _ADD_MON_VAL
{
    key zetb_add.pln_hdr_guid as PlnHdrGuid,
    key zetb_add.src_pln_hdr_guid as SrcPlnHdrGuid,
    key zetb_add.guid as Guid,
    zetb_add.parent_guid as ParentGuid,
    zetb_add.parent_type as ParentType,
    zetb_add.value_type as ValueType,
    zetb_add.group_id as GroupId,
    zetb_add.created_by as CreatedBy,
    zetb_add.created_at as CreatedAt,
    zetb_add.last_changed_by as LastChangedBy,
    zetb_add.last_changed_at as LastChangedAt,
    zetb_add.local_last_changed_at as LocalLastChangedAt,
    _PlnHdr,
    _ADD_MON_VAL
}
