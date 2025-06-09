CLASS lhc_ZE_I_TB_PLN_HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Plan_Header RESULT result.

    METHODS setinitialdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR plan_header~setinitialdata.

    METHODS setDefaultInstCu FOR DETERMINE ON MODIFY
      IMPORTING keys FOR plan_header~setDefaultInstCu.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR plan_header~validatedates.

    METHODS validatemandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR plan_header~validatemandatory.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR plan_header RESULT result.

    METHODS copyHdr FOR MODIFY
      IMPORTING keys FOR ACTION plan_header~copyHdr.

    METHODS getTotals FOR MODIFY
      IMPORTING keys FOR ACTION Plan_Header~getTotals RESULT result.

ENDCLASS.

CLASS lhc_ZE_I_TB_PLN_HDR IMPLEMENTATION.

**********************************************************************************************
* METHOD get_instance_authorizations - Comprobacion de autorizaciones
**********************************************************************************************
  METHOD get_instance_authorizations.

* Los boton de calcular distribución solo se verán al visualizar
    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
           %tky = key-%tky
           %action-copyHdr    = COND #( WHEN key-%is_draft = if_abap_behv=>mk-off
                                                            THEN if_abap_behv=>fc-o-enabled
                                                            ELSE if_abap_behv=>fc-o-disabled )
                     ) TO result.
    ENDLOOP.

  ENDMETHOD.

**********************************************************************************************
* METHOD setInitialData - Establecer valores por defecto
**********************************************************************************************
  METHOD setInitialData.

* Leemos la entidad del plan
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY Plan_Header
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_pln_hdr).

* Solo nos quedamos con las entidades sin fechas
    DELETE lt_pln_hdr WHERE StartDate IS NOT INITIAL OR EndDate IS NOT INITIAL.

* Establecemos los datos por defecto de fechas
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
      UPDATE
        FIELDS ( StartDate EndDate )
        WITH VALUE #( FOR ls_pln_hdr IN lt_pln_hdr
                      ( %tky             = ls_pln_hdr-%tky
                        StartDate        = ( cl_abap_context_info=>get_system_date( ) - 365 )
                        EndDate          = ( cl_abap_context_info=>get_system_date( ) + 365 )
                         )
                         )
    REPORTED DATA(update_reported).

* Actualizamos el dato
    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

**********************************************************************************************
* METHOD validateDates - Validar las fechas del plan respecto a sus hijos
**********************************************************************************************
  METHOD validateDates.

* Variables locales
    DATA: ls_t100 TYPE scx_t100key.

* Obtenemos la entidad actual
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_pln_hdr).

* Recorremos los planes financieros
    LOOP AT lt_pln_hdr INTO DATA(ls_pln_hdr).

* Limpiamos los mensajes que pudiera tener
      APPEND VALUE #(  %tky               = ls_pln_hdr-%tky
                       %state_area        = 'HDR_VALIDATE_DATES' )
              TO reported-plan_header.

* Validamos la coherencia de las fechas de cabecera entre ellas
      IF ls_pln_hdr-StartDate > ls_pln_hdr-EndDate.

        ls_t100-msgid = |ZE_PPM|.
        ls_t100-msgno = |005|.
        cl_abap_datfm=>conv_date_int_to_ext(
          EXPORTING
            im_datint    = ls_pln_hdr-StartDate
          IMPORTING
            ex_datext    =  ls_t100-attr1
        ).

        cl_abap_datfm=>conv_date_int_to_ext(
          EXPORTING
            im_datint    = ls_pln_hdr-EndDate
          IMPORTING
            ex_datext    =  ls_t100-attr2
        ).
*        ls_t100-attr1 = conv string( ls_pln_hdr-StartDate ).
*        ls_t100-attr2 = conv string( ls_pln_hdr-EndDate ).

        APPEND VALUE #( %tky = ls_pln_hdr-%tky ) TO failed-plan_header.

        APPEND VALUE #( %tky        = ls_pln_hdr-%tky
                        %state_area = 'HDR_VALIDATE_DATES'
                        %msg        = NEW zcl_e_pln_hdr_excp(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = ls_t100 )
                      )
        TO reported-plan_header.

        CONTINUE.

      ENDIF.

* Obtenemos ahora los grupos financieros de plan directo bajo el plan
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
      ENTITY fg_bas
      ALL FIELDS WITH VALUE #( ( PlnHdrGuid = ls_pln_hdr-PlnHdrGuid ) )
      RESULT DATA(lt_fg_bas).

* Recorremos los grupos financieros
      LOOP AT lt_fg_bas INTO DATA(ls_fg_bas).

* Comparamos las fechas del plan con las fechas de cada FG Bas
        IF ls_fg_bas-InitialDate < ls_pln_hdr-StartDate OR ls_fg_bas-InitialDate > ls_pln_hdr-EndDate OR
           ls_fg_bas-CommissionedDate < ls_pln_hdr-StartDate OR ls_fg_bas-CommissionedDate > ls_pln_hdr-EndDate.

          ls_t100-msgid = |ZE_PPM|.
          ls_t100-msgno = |006|.
          ls_t100-attr1 = ls_fg_bas-GroupId.
          ls_t100-attr2 = ls_fg_bas-InitialDate.
          ls_t100-attr3 = ls_fg_bas-CommissionedDate.

          APPEND VALUE #( %tky = ls_pln_hdr-%tky ) TO failed-plan_header.

          APPEND VALUE #( %tky        = ls_pln_hdr-%tky
                          %state_area = 'HDR_VALIDATE_DATES'
                          %msg        = NEW zcl_e_pln_hdr_excp(
                                            severity = if_abap_behv_message=>severity-error
                                            textid   = ls_t100 )
                        )
          TO reported-plan_header.

          CONTINUE.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

**********************************************************************************************
* METHOD valideteMandatory - Validar obligatoriedad de campos marcados como "Mandatory"
**********************************************************************************************
  METHOD validateMandatory.

* Variables locales
    DATA: ls_t100 TYPE scx_t100key.
    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST ze_i_tb_pln_hdr.
    DATA reported_header LIKE LINE OF reported-plan_header.

    DATA(description_permission_request) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( permission_request-%field ) ) ).
    DATA(components_permission_request) = description_permission_request->get_components(  ).

    LOOP AT components_permission_request INTO DATA(component_permission_request).
      permission_request-%field-(component_permission_request-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    " Get current field values
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

** Limpiamos los mensajes que pudiera tener
*      APPEND VALUE #(  %tky               = entity-%tky
*                       %state_area        = 'HDR_VALIDATE_DATES' )
*              TO reported-plan_header.

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ze_i_tb_pln_hdr
                FROM VALUE #( ( PlnHdrGuid = entity-PlnHdrGuid ) )
                REQUEST permission_request
                RESULT DATA(permission_result)
                FAILED DATA(failed_permission_result)
                REPORTED DATA(reported_permission_result).

      LOOP AT components_permission_request INTO component_permission_request.

        "permission result for instances (field ( features : instance ) MandFieldInstfeat;) is stored in an internal table.
        "So we have to retrieve the information for the current entity
        "whereas the global information (field ( mandatory ) MandFieldBdef;) is stored in a structure

        IF ( permission_result-instances[ PlnHdrGuid = entity-PlnHdrGuid ]-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory OR
             permission_result-global-%field-(component_permission_request-name) = if_abap_behv=>fc-f-mandatory ) AND
             entity-(component_permission_request-name) IS INITIAL.

          APPEND VALUE #( %tky = entity-%tky ) TO failed-plan_header.

          CLEAR reported_header.
          reported_header-%tky = entity-%tky.
          reported_header-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_header-%msg = new_message( id       = 'ZE_PPM'
                                                           number   = 007
                                                           severity = if_abap_behv_message=>severity-error
                                                           v1       = |{ component_permission_request-name }| ).
          APPEND reported_header  TO reported-plan_header.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

**********************************************************************************************
* METHOD setdefaultinstcu - Establece la InstCu por defecto
**********************************************************************************************
  METHOD setdefaultinstcu.

* Variables locales
    DATA: lt_instCuId TYPE TABLE OF zetc_t087u.

* Leemos si existe instCU
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY Plan_Header BY \_InstCu
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_instCu).

* Comprueba si existe instCU
    IF lt_instcu IS INITIAL.

* Leemos la entidad del plan
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
         ENTITY Plan_Header
           ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(lt_hdr).

      DATA(ls_pln_hdr) = lt_hdr[ 1 ].

      IF ls_pln_hdr-%is_draft = '00'.

* Obtenemos la installationId por defecto
        SELECT SINGLE
        FROM ze_i_t087u
        FIELDS ( anlue )
        WHERE anlue = '999999957'
        INTO @DATA(lt_installationId).

        APPEND lt_installationId TO lt_instcuid.
        APPEND ls_pln_hdr-Anlue TO lt_instcuid.

        DATA create TYPE TABLE FOR CREATE ze_i_tb_pln_hdr\_InstCu.
        DATA ls_create LIKE LINE OF create.

        CLEAR ls_create.
*            ls_create-%is_draft = if_abap_behv=>mk-on.
        ls_create-%is_draft = if_abap_behv=>mk-off.
        ls_create-PlnHdrGuid = ls_pln_hdr-PlnHdrGuid.
        ls_Create-%target = VALUE #( FOR ls_instcuid IN lt_instcuid (
                                        PlnHdrGuid = ls_pln_hdr-PlnHdrGuid
                                        InstallationId = ls_instcuid ) ).

        APPEND ls_create TO create.

* Añadimos la InstCu por defecto
        MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
              ENTITY Plan_Header
              CREATE BY \_InstCu
              AUTO FILL CID
              FIELDS ( PlnHdrGuid InstallationId )
              WITH create
        MAPPED DATA(mon_val_mapped)
        REPORTED DATA(mon_val_reported)
        FAILED DATA(mon_val_failed).

      ENDIF.
    ENDIF.

  ENDMETHOD.


**********************************************************************************************
* METHOD copyHdr - Realiza una copia de la entidad
**********************************************************************************************
  METHOD copyHdr.

* Variables locales
    DATA: lt_hdr       TYPE TABLE FOR CREATE ze_i_tb_pln_hdr,
          lv_fin_view  TYPE ze_tv_fin_view,
          lv_plng_type TYPE ze_tv_plng_type.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_copy>) WITH KEY %cid = ' '.
    ASSERT <ls_copy> IS NOT ASSIGNED.

* Obtengo el financial view elegido
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      lv_fin_view = <ls_keys>-%param-fin_view.
    ENDLOOP.

* Leer el header a copiar
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY Plan_Header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_hdr_result)
        FAILED DATA(lt_hdr_failed).

* Obtengo el financial type elegido
    LOOP AT lt_hdr_result ASSIGNING FIELD-SYMBOL(<ls_hdr>).
      lv_plng_type = <ls_hdr>-PlngType.
    ENDLOOP.

* Compruebo si el planingType son FG
    IF lv_plng_type EQ 'FG'.

      DATA: lt_fg         TYPE TABLE FOR CREATE ze_i_tb_pln_hdr\_FGBas,
            lt_fg_monval  TYPE TABLE FOR CREATE ze_i_tb_fg_bas\_fg_bas_mon_val,
            lt_attachment TYPE TABLE FOR CREATE ze_i_tb_pln_hdr\_Attachments.

* Leo los datos de las entidades
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY Plan_Header BY \_FGBas
          ALL FIELDS WITH CORRESPONDING #( lt_hdr_result )
          RESULT DATA(lt_fgbas_result).

      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY fg_bas BY \_fg_bas_mon_val
          ALL FIELDS WITH CORRESPONDING #( lt_fgbas_result )
          RESULT DATA(lt_fgbas_monval_result).

      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY Plan_Header BY \_Attachments
          ALL FIELDS WITH CORRESPONDING #( lt_hdr_result )
          RESULT DATA(lt_attachment_result).

* Recorro las entidades a copiar y las copio en mis entidades locales
      LOOP AT lt_hdr_result ASSIGNING FIELD-SYMBOL(<ls_hdr_result>).

        APPEND VALUE #(  %cid      = keys[ KEY entity %key = <ls_hdr_result>-%key ]-%cid
*                              %is_draft = keys[ KEY entity %key = <ls_hdr_result>-%key ]-%param-%is_draft
                         %is_draft = '0'
                         %data = CORRESPONDING #( <ls_hdr_result> EXCEPT plnhdrguid ) ) TO lt_hdr ASSIGNING FIELD-SYMBOL(<ls_new_hdr>).

        APPEND VALUE #( %cid_ref = <ls_new_hdr>-%cid ) TO lt_fg ASSIGNING FIELD-SYMBOL(<lt_fgbas_aux>).

        APPEND VALUE #( %cid_ref = <ls_new_hdr>-%cid ) TO lt_attachment ASSIGNING FIELD-SYMBOL(<lt_attachment_aux>).

* Recorro los attachment
        LOOP AT lt_attachment_result ASSIGNING FIELD-SYMBOL(<ls_attachment_result>)
                                     USING KEY entity
                                     WHERE PlnHdrGuid = <ls_hdr_result>-PlnHdrGuid.

          APPEND VALUE #( %cid = <ls_new_hdr>-%cid && <ls_attachment_result>-AttGuid
                          %data = CORRESPONDING #( <ls_attachment_result> EXCEPT plnhdrguid )
                    ) TO <lt_attachment_aux>-%target.

        ENDLOOP.

* Recorro las FG
        LOOP AT lt_fgbas_result ASSIGNING FIELD-SYMBOL(<ls_fgbas_result>)
                           USING KEY entity
                           WHERE PlnHdrGuid = <ls_hdr_result>-PlnHdrGuid.

          APPEND VALUE #( %cid = <ls_new_hdr>-%cid && <ls_fgbas_result>-Guid
                          %data = CORRESPONDING #( <ls_fgbas_result> EXCEPT plnhdrguid )
                    ) TO <lt_fgbas_aux>-%target ASSIGNING FIELD-SYMBOL(<ls_fgbas_n>).

          APPEND VALUE #( %cid_ref = <ls_fgbas_n>-%cid ) TO lt_fg_monval ASSIGNING FIELD-SYMBOL(<ls_fgbas_monval>).

* Recorro las FG Mon VAL
          LOOP AT lt_fgbas_monval_result ASSIGNING FIELD-SYMBOL(<ls_fgbas_monval_result>)
                                        USING KEY entity
                                        WHERE PlnHdrGuid = <ls_fgbas_result>-PlnHdrGuid
                                        AND ParentGuid = <ls_fgbas_result>-Guid.

            APPEND VALUE #( %cid = <ls_fgbas_n>-%cid
                        && <ls_fgbas_monval_result>-Guid && <ls_fgbas_monval_result>-SrcPlnHdrGuid
                        && <ls_fgbas_monval_result>-Fyear && <ls_fgbas_monval_result>-Period
                        %data = CORRESPONDING #( <ls_fgbas_monval_result> EXCEPT plnhdrguid )
                  ) TO <ls_fgbas_monval>-%target.

          ENDLOOP.

        ENDLOOP.

      ENDLOOP.

* Actualizo el financial view
      LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdr_new>).
        <ls_hdr_new>-FinView = lv_fin_view.
      ENDLOOP.

* Creo la copia de la FG
      MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
           ENTITY Plan_Header
           CREATE FIELDS ( Anlue Area BusinessArea Category CommInstallId CompanyCode CreatedAt
           CreatedBy Currency EndDate FinView HasCu HasFg HasManualCi HasRu IsRollup LastChangedAt
           LastChangedBy LocalLastChangedAt ObjId Obtyp Periodtype Periv PfGuid
           PlngType StartDate )
           WITH lt_hdr
           ENTITY Plan_Header
               CREATE BY \_Attachments
               AUTO FILL CID
               FIELDS ( AttGuid Comments Attachment Mimetype Filename )
               WITH lt_attachment
           ENTITY Plan_Header
               CREATE BY \_FGBas
               AUTO FILL CID
               FIELDS ( Comments CommissionedDate DistrLogic TotalAmount GroupId Guid InitialDate Logsys SrcPlnHdrGuid TradingPartner )
               WITH lt_fg
               ENTITY fg_bas
                   CREATE BY \_fg_bas_mon_val
                   AUTO FILL CID
                   FIELDS ( Amount Fyear Guid Period )
                   WITH lt_fg_monval
       MAPPED DATA(lt_mapped)
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reproted).

* Compruebo si el planingType son CU
    ELSEIF lv_plng_type EQ 'CU'.

      DATA: lt_instCu      TYPE TABLE FOR CREATE ze_i_tb_pln_hdr\_InstCu,
            lt_cubas       TYPE TABLE FOR CREATE ze_i_tb_inst_cu\_cu,
            lt_cufg        TYPE TABLE FOR CREATE ze_i_tb_cu\_cu_fg,
            lt_cufg_monval TYPE TABLE FOR CREATE ze_i_tb_cu_fg\_cu_fg_mon_val.

* Leo los datos de las entidades
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY Plan_Header BY \_InstCu
          ALL FIELDS WITH CORRESPONDING #( lt_hdr_result )
          RESULT DATA(lt_instCu_result).

      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY InstCU BY \_cu
          ALL FIELDS WITH CORRESPONDING #( lt_instCu_result )
          RESULT DATA(lt_cubas_result).

      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY cu BY \_cu_fg
          ALL FIELDS WITH CORRESPONDING #( lt_cubas_result )
          RESULT DATA(lt_cufg_result).

      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY cufg BY \_cu_fg_mon_val
          ALL FIELDS WITH CORRESPONDING #( lt_cufg_result )
          RESULT DATA(lt_cufg_monval_result).

* Recorro las entidades a copiar y las copio en mis entidades locales
      LOOP AT lt_hdr_result ASSIGNING FIELD-SYMBOL(<ls_hdrCu_result>).

        APPEND VALUE #(  %cid      = keys[ KEY entity %key = <ls_hdrCu_result>-%key ]-%cid
*                              %is_draft = keys[ KEY entity %key = <ls_hdr_result>-%key ]-%param-%is_draft
                         %is_draft = '0'
                         %data = CORRESPONDING #( <ls_hdrCu_result> EXCEPT plnhdrguid ) ) TO lt_hdr ASSIGNING FIELD-SYMBOL(<ls_new_hdrCu>).

        APPEND VALUE #( %cid_ref = <ls_new_hdrCu>-%cid ) TO lt_instcu ASSIGNING FIELD-SYMBOL(<lt_instCu_aux>).

* Recorro las InstCu
        LOOP AT lt_instcu_result ASSIGNING FIELD-SYMBOL(<ls_instCu_result>)
                                 USING KEY entity
                                 WHERE PlnHdrGuid = <ls_hdrCu_result>-PlnHdrGuid.

          APPEND VALUE #( %cid = <ls_new_hdrCu>-%cid && <ls_instCu_result>-guid
                          %data = CORRESPONDING #( <ls_instCu_result> EXCEPT plnhdrguid )
                    ) TO <lt_instCu_aux>-%target ASSIGNING FIELD-SYMBOL(<ls_instCu_n>).

          APPEND VALUE #( %cid_ref = <ls_instCu_n>-%cid ) TO lt_cubas ASSIGNING FIELD-SYMBOL(<ls_cubas_aux>).

* Recorro las CU
          LOOP AT lt_cubas_result ASSIGNING FIELD-SYMBOL(<ls_cubas_result>)
                           USING KEY entity
                           WHERE PlnHdrGuid = <ls_instCu_result>-PlnHdrGuid
                           AND ParentGuid = <ls_instCu_result>-Guid.

            APPEND VALUE #( %cid = <ls_instCu_n>-%cid && <ls_cubas_result>-guid
                            %data = CORRESPONDING #( <ls_cubas_result> EXCEPT plnhdrguid )
                      ) TO <ls_cubas_aux>-%target ASSIGNING FIELD-SYMBOL(<ls_cubas_n>).

            APPEND VALUE #( %cid_ref = <ls_cubas_n>-%cid ) TO lt_cufg ASSIGNING FIELD-SYMBOL(<ls_cufg_aux>).

* Recorro las CUFG
            LOOP AT lt_cufg_result ASSIGNING FIELD-SYMBOL(<ls_cufg_result>)
                         USING KEY entity
                         WHERE PlnHdrGuid = <ls_Cubas_result>-PlnHdrGuid
                         AND ParentGuid = <ls_cubas_result>-Guid.

              APPEND VALUE #( %cid = <ls_Cubas_n>-%cid && <ls_cufg_result>-guid
                          %data = CORRESPONDING #( <ls_cufg_result> EXCEPT plnhdrguid )
                    ) TO <ls_cufg_aux>-%target ASSIGNING FIELD-SYMBOL(<ls_cufg_n>).

              APPEND VALUE #( %cid_ref = <ls_cufg_n>-%cid ) TO lt_cufg_monval ASSIGNING FIELD-SYMBOL(<ls_cufg_monval_aux>).

* Recorro las CUFG MONVAL
              LOOP AT lt_cufg_monval_result ASSIGNING FIELD-SYMBOL(<ls_cufg_monval_result>)
                       USING KEY entity
                       WHERE ParentGuid = <ls_cufg_result>-Guid
                       AND PlnHdrGuid = <ls_cufg_result>-PlnHdrGuid.

                APPEND VALUE #( %cid = <ls_cufg_n>-%cid
                    && <ls_cufg_monval_result>-Guid && <ls_cufg_monval_result>-SrcPlnHdrGuid
                    && <ls_cufg_monval_result>-Fyear && <ls_cufg_monval_result>-Period
                    %data = CORRESPONDING #( <ls_cufg_monval_result> EXCEPT plnhdrguid )
              ) TO <ls_cufg_monval_aux>-%target.

              ENDLOOP.

            ENDLOOP.

          ENDLOOP.

        ENDLOOP.

      ENDLOOP.

* Actualizo el financial view
      LOOP AT lt_hdr ASSIGNING FIELD-SYMBOL(<ls_hdrCu_new>).
        <ls_hdrCu_new>-FinView = lv_fin_view.
      ENDLOOP.

* Creo la copia de la CU
      MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
           ENTITY Plan_Header
*            CREATE SET FIELDS with lt_hdr
           CREATE FIELDS ( Anlue Area BusinessArea Category CommInstallId CompanyCode CreatedAt
           CreatedBy Currency EndDate FinView HasCu HasFg HasManualCi HasRu IsRollup LastChangedAt
           LastChangedBy LocalLastChangedAt ObjId Obtyp Periodtype Periv PfGuid
           PlngType StartDate )
           WITH lt_hdr
           ENTITY Plan_Header
               CREATE BY \_InstCu
               AUTO FILL CID
               FIELDS ( Guid InstallationId SrcPlnHdrGuid )
               WITH lt_instcu
               ENTITY InstCU
                   CREATE BY \_cu
                   AUTO FILL CID
                   FIELDS ( ParentGuid CuId Quantity Unit TotalAmount Currency IsUnitCostManual DistrLogic InitialDate CommissionedDate ManualQuantityMaintained Comments TradingPartner )
                   WITH lt_cubas
                   ENTITY cu
                       CREATE BY \_cu_fg
                       AUTO FILL CID
                       FIELDS ( Comments GroupId TotalAmount Logsys TradingPartner )
                       WITH lt_cufg
                       ENTITY cufg
                           CREATE BY \_cu_fg_mon_val
                           AUTO FILL CID
                           FIELDS ( Amount Fyear Period )
                           WITH lt_cufg_monval
       MAPPED DATA(lt_mapped_cu)
       FAILED DATA(lt_failed_cu)
       REPORTED DATA(lt_reproted_cu).

    ENDIF.


* Muestro mensaje de error al finalizar la acción
    IF lt_failed-plan_header IS NOT INITIAL OR lt_failed_cu-plan_header IS NOT INITIAL.

      IF lt_mapped-plan_header IS NOT INITIAL.
        failed-plan_header = lt_failed-plan_header.
      ELSEIF lt_mapped_cu-plan_header IS NOT INITIAL.
        failed-plan_header = lt_failed_cu-plan_header.
      ENDIF.

      reported-plan_header = VALUE #(
          ( %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-error
                    text = 'Error creating backup' )
                 ) ).

* Muestro mensaje de exito al finalizar la acción
    ELSEIF lt_mapped-plan_header IS NOT INITIAL OR lt_mapped_cu-plan_header IS NOT INITIAL.

      IF lt_mapped-plan_header IS NOT INITIAL.
        mapped-plan_header = lt_mapped-plan_header.
      ELSEIF lt_mapped_cu-plan_header IS NOT INITIAL.
        mapped-plan_header = lt_mapped_cu-plan_header.
      ENDIF.

      reported-plan_header = VALUE #(
        ( %msg = new_message_with_text(
                    severity = if_abap_behv_message=>severity-information
                    text = 'The backup has been created correctly' )
                 ) ).

    ENDIF.

  ENDMETHOD.

  METHOD getTotals.

* Variables locales
    DATA: lv_mon_val      TYPE zet_mon_values_per_year,
          lv_total_amount TYPE ze_tv_mon_amount VALUE 0,
          lv_initial_date TYPE gjahr,
          lv_end_date     TYPE gjahr.


* Leer las cu para calcular su total amount
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY Plan_Header
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_hdr_result)
        FAILED DATA(lt_hdr_failed).

    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY Plan_Header BY \_InstCu
        ALL FIELDS WITH CORRESPONDING #( lt_hdr_result )
        RESULT DATA(lt_instCu_result).

    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY InstCU BY \_cu
        ALL FIELDS WITH CORRESPONDING #( lt_instCu_result )
        RESULT DATA(lt_cubas_result).

* Recorros las CU para calcular su cantidad total y la fecha mas baja y mas alta
    LOOP AT lt_cubas_result ASSIGNING FIELD-SYMBOL(<ls_cubas_result>).

      lv_total_amount = lv_total_amount + <ls_cubas_result>-TotalAmount.

      IF lv_initial_date IS INITIAL.

        lv_initial_date = <ls_cubas_result>-InitialDate.

      ELSEIF lv_initial_date > <ls_cubas_result>-InitialDate.

        lv_initial_date = <ls_cubas_result>-InitialDate.

      ENDIF.

      IF lv_end_date IS INITIAL.

        lv_end_date = <ls_cubas_result>-CommissionedDate.

      ELSEIF lv_end_date < <ls_cubas_result>-CommissionedDate.

        lv_end_date = <ls_cubas_result>-CommissionedDate.

      ENDIF.

    ENDLOOP.

* Calculo el totla
    CALL METHOD zcl_e_distr=>calculate
      EXPORTING
        i_initial_date = lv_initial_date
        i_end_date     = lv_end_date
        i_amount       = lv_total_amount
      IMPORTING
        et_mon_val     = lv_mon_val.

    DATA create TYPE TABLE FOR CREATE ZE_I_TB_CALCULATEAMOUNT.
    DATA ls_create LIKE LINE OF create.

                     CLEAR ls_create.
                     CLEAR create.

    LOOP AT lv_mon_val ASSIGNING FIELD-SYMBOL(<ls_mon_val>).

*        ls_create-%tky = <ls_mon_val>-%tky.
        ls_create-fyear = <ls_mon_val>-fyear.
        ls_create-amount = <ls_mon_val>-amount.
        APPEND ls_create TO create.

    ENDLOOP.

*    DATA(mo_context)->get_message_container(  )->add_message_from_bapi(
*        EXPORTING
*            it_bapi_messages = lt_retun
*            iv_determine_leading_msg = /iwbep/if_message_container=>gcs_leading_msg_search_option-first
*    ).

*CALL FUNCTION 'DDIF_FIELDINFO_GET'
*          EXPORTING
*            tabname        = ls_create
*          TABLES
*            dfies_tab      = create
*          EXCEPTIONS
*            not_found      = 1
*            internal_error = 2
*            OTHERS         = 3.

*    DATA: ls_t100 TYPE scx_t100key.
*    ls_t100-msgid = |ZE_PPM|.
*       ls_t100-msgno = |007|.
*        ls_t100-attr1 = `<table><tr><td>j</td></tr><tr><td>dsdsds</td></tr></table>`.
*
*
*    APPEND VALUE #(                        %msg        = NEW zcl_e_pln_hdr_excp(
*                                          severity = if_abap_behv_message=>severity-information
*                                          textid   = ls_t100 )
*                      )
*     TO reported-plan_header.

*    MESSAGE i001( ZE_PPM ) TYPE E.

*    reported-cu = VALUE #(
*            ( %msg = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text = 'edsdsdsds' )
*                   ) ).

*    MODIFY ENTITIES OF ZE_I_TB_CALCULATEAMOUNT
*                             ENTITY calculate
*                             CREATE AUTO FILL CID
*                             FIELDS ( fyear amount )
*                             WITH create
*                       MAPPED DATA(mon_val_mapped_aux)
*                       REPORTED DATA(mon_val_reported_aux)
*                       FAILED DATA(mon_val_failed_aux).


*    result = create.

*     result-%param = create.
*    result = VALUE #( FOR ls_cu_bas_aux IN create (  %param    = ls_cu_bas_aux ) ).
*    result = VALUE #( FOR ls_cu_bas_aux IN create (  %tky      = lt_hdr_result[ 1 ]-%tky
*                                                       %param    = ls_cu_bas_aux ) ).
    result = VALUE #( FOR ls_total_amount IN create ( %param = CORRESPONDING #( ls_total_amount ) ) ).


  ENDMETHOD.

ENDCLASS.
