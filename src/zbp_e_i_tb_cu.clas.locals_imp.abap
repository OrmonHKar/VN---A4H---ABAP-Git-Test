CLASS lhc_ZE_I_TB_CU DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setInitialCUData FOR DETERMINE ON MODIFY
      IMPORTING keys FOR cu~setInitialCUData.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR cu~calculateTotalPrice.

    METHODS calculateCUMonVal FOR MODIFY
      IMPORTING keys FOR ACTION cu~calculateCUMonVal RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR cu RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR cu RESULT result.

*    METHODS copyHdr FOR MODIFY
*      IMPORTING keys FOR ACTION cu~copyHdr.

ENDCLASS.

CLASS lhc_ZE_I_TB_CU IMPLEMENTATION.

**********************************************************************************************
* METHOD setInitialCUData - Establece los datos por defecto de la CU
**********************************************************************************************
  METHOD setInitialCUData.

* Leemos la entidad de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY cu
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Leemos los datos de la cabecera
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY Plan_Header
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_pln_hdr).

    DATA(ls_pln_hdr) = lt_pln_hdr[ 1 ].

* Establecemos los datos por defecto
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY cu
      UPDATE
        FIELDS ( InitialDate CommissionedDate DistrLogic )
        WITH VALUE #( FOR ls_fg_bas IN lt_fg_bas
                      ( %tky             = ls_fg_bas-%tky
                        InitialDate      = ls_pln_hdr-StartDate
                        CommissionedDate = ls_pln_hdr-EndDate
                        DistrLogic       = 'LIN_CAL'
                        Quantity         = 1 ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

* Indicamos a nivel de cabecera que la planificación es de tipo CU
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
      UPDATE
        FIELDS ( PlngType )
        WITH VALUE #( (  %tky             = ls_pln_hdr-%tky
                         PlngType         = 'CU' ) )
    REPORTED DATA(update_reported_hdr).

  ENDMETHOD.

**********************************************************************************************
* METHOD calculateCuMonval - Establece los datos por defecto de la CU_FG y las CU_FG_MonVal
**********************************************************************************************
  METHOD calculateCUMonVal.

* Variables locales
    DATA: lt_mon_values TYPE zet_mon_values,
          ls_mon_values LIKE LINE OF lt_mon_values,
          ls_amount TYPE ze_tv_mon_amount,
          ls_t100 TYPE scx_t100key,
          lt_cu_fg TYPE zetc_CU_FG_T.

* Leemos las entidades cufg existentes
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY cu
       BY \_cu_fg
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_cu_fg_data).

* Comprobamos si hay algo que borrar
     IF lt_cu_fg_data IS NOT INITIAL.

* Primero borramos las entidades de cufg hijas
        MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
             ENTITY cufg
             DELETE FROM VALUE #( FOR ls_cu_fg_data IN lt_cu_fg_data ( %tky = ls_cu_fg_data-%tky ) ).

    ENDIF.

* Comprobar si se han borrado las CU_FG (MI PRUEBA)
*    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
*       ENTITY cu
*       BY \_cu_fg
*         ALL FIELDS WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_cu_fg_dataa).

* Leemos las entidades de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY cu
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_cu_bas).

* Recorremos las entidades
    LOOP AT lt_cu_bas INTO DATA(ls_cu_bas).

* Leemos los datos de la cabecera
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY Plan_Header
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_pln_hdr).

      DATA(ls_pln_hdr) = lt_pln_hdr[ 1 ].

* Obtiene las cu_fg a calcular
      CALL METHOD zcl_e_derivation=>search_cu_fg
            EXPORTING
              i_COMPANY_CODE    = ls_pln_hdr-CompanyCode
              i_FIN_VIEW      = ls_pln_hdr-FinView
              i_AREA = ls_pln_hdr-Area
              i_BUSINESS_AREA = ls_pln_hdr-BusinessArea
              i_CU_ID = ls_cu_bas-CuId
            IMPORTING
              et_cu_fg_values     = lt_cu_fg.

* Comprueba si hay cu_fg
    IF  lt_cu_fg IS NOT INITIAL.

        DATA createCUFG TYPE TABLE FOR CREATE ze_i_tb_cu\_cu_fg.
        DATA ls_createCUFG LIKE LINE OF createCUFG.

        CLEAR ls_createCUFG.

*          ls_createCUFG-%is_draft = if_abap_behv=>mk-on.
*          ls_createCUFG-%is_draft = if_abap_behv=>mk-off.
          ls_createCUFG-PlnHdrGuid = ls_cu_bas-PlnHdrGuid.
          ls_createCUFG-Guid = ls_cu_bas-Guid.
          ls_createCUFG-%target = VALUE #( FOR ls_cu_fg IN lt_cu_fg (
                                           PlnHdrGuid = ls_cu_bas-PlnHdrGuid
                                           ParentGuid = ls_cu_bas-Guid
                                           GroupId = ls_cu_fg-group_id
                                         )  ).

      APPEND ls_createCUFG TO createCUFG.

* Creo la cufg
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
                ENTITY cu
                CREATE BY \_cu_fg
                AUTO FILL CID
                FIELDS ( PlnHdrGuid ParentGuid GroupId )
                WITH createCUFG
          MAPPED DATA(mon_val_mapped)
          REPORTED DATA(mon_val_reported)
          FAILED DATA(mon_val_failed).

* Leo las entidade cu_fg creadas
            READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
            ENTITY cu
            BY \_cu_fg
              ALL FIELDS WITH CORRESPONDING #( keys )
            RESULT DATA(lt_cu_fg1).

            LOOP AT lt_cu_fg INTO DATA(ls_cu_fg_aux).

* Reparto el total amount entre las cu_fg en relacion a su porcentaje
            IF ls_cu_bas-TotalAmount <= 0.
                ls_amount = ( 1000 * ls_cu_fg_aux-percentage ) / 100.
            ELSE.
                ls_amount = ( ls_cu_bas-TotalAmount * ls_cu_fg_aux-percentage ) / 100.
            ENDIF.

* Invocaremos un método que en función de la logica de distribución y fechas calcule la distribución
              CASE ls_cu_bas-DistrLogic.

                WHEN 'LIN_CAL'.

                  CALL METHOD zcl_e_distr=>lin_cal
                    EXPORTING
                      i_date_from    = ls_cu_bas-InitialDate
                      i_date_to      = ls_cu_bas-CommissionedDate
                      i_total_amount = ls_amount
                    IMPORTING
                      et_mon_val     = lt_mon_values.

                WHEN 'LIN_FACT_C'.

                  CALL METHOD zcl_e_distr=>fact_cal
                    EXPORTING
                      i_date_from    = ls_cu_bas-InitialDate
                      i_date_to      = ls_cu_bas-CommissionedDate
                      i_total_amount = ls_amount
                    IMPORTING
                      et_mon_val     = lt_mon_values.

                WHEN 'AT_END'.

                  CALL METHOD zcl_e_distr=>at_the_end
                    EXPORTING
                      i_date_from    = ls_cu_bas-InitialDate
                      i_date_to      = ls_cu_bas-CommissionedDate
                      i_total_amount = ls_amount
                    IMPORTING
                      et_mon_val     = lt_mon_values.

                WHEN 'S_CURVE'.

                  CALL METHOD zcl_e_distr=>s_curve
                    EXPORTING
                      i_date_from    = ls_cu_bas-InitialDate
                      i_date_to      = ls_cu_bas-CommissionedDate
                      i_total_amount = ls_amount
                    IMPORTING
                      et_mon_val     = lt_mon_values.

              ENDCASE.

* Actualizar TotalAmount de las cufg
            LOOP AT lt_cu_fg1 INTO DATA(ls_cu_fg_aux1).

                IF ls_cu_fg_aux1-GroupId EQ ls_cu_fg_aux-group_id.

* Actualizar la cantidad de las cu_fg
                    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
                        ENTITY cufg
                        UPDATE
                            FIELDS ( TotalAmount )
                            WITH VALUE #( ( %tky             = ls_cu_fg_aux1-%tky
                                            TotalAmount      = ls_amount ) )
                        REPORTED DATA(update_reported).

                     DATA create TYPE TABLE FOR CREATE ze_i_tb_cu_fg\_CU_FG_MON_VAL.
                     DATA ls_create LIKE LINE OF create.

                     CLEAR ls_create.
                     CLEAR create.

                     ls_create-%is_draft = if_abap_behv=>mk-off.
                     ls_create-%tky = ls_cu_fg_aux1-%tky.
                     ls_Create-%target = VALUE #( FOR ls_mon_val IN lt_mon_values (
                                                        PlnHdrGuid = ls_cu_fg_aux1-PlnHdrGuid
                                                        fyear = ls_mon_val-fyear
                                                        period = ls_mon_val-period
                                                        amount = ls_mon_val-amount
                                                         )  ).
                        APPEND ls_create TO create.

*             Creamos las entidades CU_FG_Mon_val
                     MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
                             ENTITY cufg
                             CREATE BY \_cu_fg_mon_val
                             AUTO FILL CID
                             FIELDS ( fyear period amount PlnHdrGuid )
                             WITH create
                       MAPPED DATA(mon_val_mapped_aux)
                       REPORTED DATA(mon_val_reported_aux)
                       FAILED DATA(mon_val_failed_aux).

*                      ls_t100-msgid = |ZE_PPM|.
*                      ls_t100-msgno = |008|.
*                      ls_t100-attr1 = ls_pln_hdr-StartDate.
*                      ls_t100-attr2 = ls_pln_hdr-EndDate.
*
*                      APPEND VALUE #( %tky = ls_cu_fg_aux1-%tky ) TO failed-cu.
*
*                      APPEND VALUE #( %tky        = ls_cu_fg_aux1-%tky
*                                      %state_area = 'CALCULATE MON VAL'
*                                      %msg        = NEW zcl_e_pln_hdr_excp(
*                                                        severity = if_abap_behv_message=>severity-success
*                                                        textid   = ls_t100 ) ) TO reported-cu.

                ENDIF.

            ENDLOOP.

          ENDLOOP.

      ENDIF.

    ENDLOOP.

*    Muestro mensaje de error si da error al calcular las monval
    IF mon_val_failed_aux-cufgmonval IS NOT INITIAL.

*        lv_txt1 = 'Error'.
*        CALL FUNCTION 'POPUP_TO_INFORM'
*          EXPORTING
*            titel = lv_titel
*            txt1 = lv_txt1
*            txt2 = ''
*            txt3 = ''
*            txt4 = ''.

*        APPEND VALUE #( %tky = ls_cu_fg_aux1-%tky ) TO failed-cu.

        reported-cu = VALUE #(
            ( %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-error
                      text = 'Error al calcular las mon val' )
                   ) ).

*    Muestro mensaje de exito si se calcula las monval correctamente
    ELSEIF mon_val_mapped_aux-cufgmonval IS NOT INITIAL.

*        lv_txt1 = 'OK'.
*        CALL FUNCTION 'POPUP_TO_INFORM'
*          EXPORTING
*            titel = lv_titel
*            txt1 = lv_txt1
*            txt2 = ''
*            txt3 = ''
*            txt4 = ''.

*         RAISE SHORTDUMP NEW zcx_po( textid = VALUE #( msgid = |ZE_PPM| msgno = |002| ) ).
*
*        ls_t100-msgid = |ZE_PPM|.
*        ls_t100-msgno = |008|.
*
*
*
*        APPEND VALUE #( %tky        = ls_cu_fg_aux1-%tky
*                        %state_area = 'CALCULATE MON VAL'
*                        %msg        = NEW zcl_e_pln_hdr_excp(
*                                          severity = if_abap_behv_message=>severity-success
*                                          textid   = ls_t100 )
**                        %path = Value #(
**                                    plan_header = Value #( plnhdrguid = ls_cu_fg_aux1-%tky-PlnHdrGuid )
**                                    instcu = Value #( %tky = ls_cu_fg_aux1-%tky )
**                        )
*                            ) TO reported-cu.

        reported-cu = VALUE #(
          ( %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-information
                      text = 'Se ha calculado las mon val correctamente' )
                   ) ).

    ENDIF.

    result = VALUE #( FOR ls_cu_bas_aux IN lt_cu_bas ( %tky      = ls_cu_bas_aux-%tky
                                                       %param    = ls_cu_bas_aux ) ).

  ENDMETHOD.

**********************************************************************************************
* METHOD get_instance_authorizations - Comprobacion de autorizaciones
**********************************************************************************************
  METHOD get_instance_authorizations.

* Los boton de calcular distribución solo se verán al visualizar
    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
           %tky = key-%tky
           %action-calculateCUMonVal    = COND #( WHEN key-%is_draft = if_abap_behv=>mk-off
                                                            THEN if_abap_behv=>fc-o-enabled
                                                            ELSE if_abap_behv=>fc-o-disabled )

                     ) TO result.
    ENDLOOP.

  ENDMETHOD.

**********************************************************************************************
* METHOD calculateTotalPrice - Calcula la cantidad de CU_FG en relacion a sus unidades y el precio
**********************************************************************************************
  METHOD calculateTotalPrice.

* Leemos las entidades cu existentes
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY cu
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_cu_bas_data).

       DATA(ls_cu_bas_data) = lt_cu_bas_data[ 1 ].

* comprobamos si se ha seleccionado una cu
       IF ls_cu_bas_data-CuId IS NOT INITIAL.

* Leemos el precio por unitad
        SELECT SINGLE
        FROM ze_i_cu_def
        FIELDS ( PriceUnit )
        WHERE CuID =   @ls_cu_bas_data-CuId
        INTO @DATA(ls_cuBasPrice).

* Añadimos el precio total de la cu
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY cu
      UPDATE
        FIELDS ( TotalAmount )
        WITH VALUE #( ( %tky             = ls_cu_bas_data-%tky
                        TotalAmount      = ls_cubasprice * ls_cu_bas_data-Quantity ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

       ENDIF.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
