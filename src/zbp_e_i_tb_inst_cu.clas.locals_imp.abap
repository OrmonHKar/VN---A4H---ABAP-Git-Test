CLASS lhc_ZE_I_TB_INST_CU DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
  METHODS setinitialhdrdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR InstCU~setinitialhdrdata.
  METHODS get_instance_features FOR INSTANCE FEATURES
    IMPORTING keys REQUEST requested_features FOR InstCU RESULT result.
ENDCLASS.

CLASS lhc_ZE_I_TB_INST_CU IMPLEMENTATION.

**********************************************************************************************
* METHOD setInitialData - Establecer valores por defecto
**********************************************************************************************
    METHOD setInitialHDRData.

* Leemos la entidad del plan
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY Plan_Header
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_pln_hdr).

    DELETE lt_pln_hdr WHERE PlngType IS NOT INITIAL.

* Establecemos el planning type a CU
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
      UPDATE
        FIELDS ( PlngType )
        WITH VALUE #( FOR ls_pln_hdr IN lt_pln_hdr
                      ( %tky             = ls_pln_hdr-%tky
                        PlngType        = 'CU'

                         )
                         )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.
  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
