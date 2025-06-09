CLASS lhc_ZE_I_TB_FG_BAS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR fg_bas~validateDates.

    METHODS validateGroupId FOR VALIDATE ON SAVE
      IMPORTING keys FOR fg_bas~validateGroupId.

    METHODS validateTradingPartner FOR VALIDATE ON SAVE
      IMPORTING keys FOR fg_bas~validateTradingPartner.

    METHODS setInitialFGBasData FOR DETERMINE ON MODIFY
      IMPORTING keys FOR fg_bas~setInitialFGBasData.

    METHODS validateMandatory FOR VALIDATE ON SAVE
      IMPORTING keys FOR fg_bas~validateMandatory.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR fg_bas RESULT result.

    METHODS calculatemonval FOR MODIFY
      IMPORTING keys FOR ACTION fg_bas~calculatemonval RESULT result.

    METHODS deletemonval FOR MODIFY
      IMPORTING keys FOR ACTION fg_bas~deletemonval RESULT result.

ENDCLASS.





CLASS lhc_ZE_I_TB_FG_BAS IMPLEMENTATION.

**********************************************************************************************
* METHOD get_instance_authorizations - Condiciones por instancia
**********************************************************************************************
  METHOD get_instance_authorizations.

* Los botones de borrar y calcular distribución solo se verán al visualizar
    LOOP AT keys INTO DATA(key).
      APPEND VALUE #(
           %tky = key-%tky
           %action-calculateMonVal    = COND #( WHEN key-%is_draft = if_abap_behv=>mk-off
                                                            THEN if_abap_behv=>fc-o-enabled
                                                            ELSE if_abap_behv=>fc-o-disabled )
           %action-deleteMonVal       = COND #( WHEN key-%is_draft = if_abap_behv=>mk-off
                                                            THEN if_abap_behv=>fc-o-enabled
                                                            ELSE if_abap_behv=>fc-o-disabled )
                     ) TO result.
    ENDLOOP.


  ENDMETHOD.


**********************************************************************************************
* METHOD validateDates - Validar las fechas del grupo financiero basico
**********************************************************************************************
  METHOD validateDates.

* Variables locales
    DATA: ls_t100 TYPE scx_t100key.

* Leemos la cabecera del plan
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
        ENTITY Plan_Header
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_pln_hdr).

    DATA(ls_pln_hdr) = lt_pln_hdr[ 1 ].

* Leemos la entidad de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Recorremos los registros recogidos
    LOOP AT lt_fg_bas INTO DATA(ls_fg_bas).

* Limpiamos los mensajes que pudiera tener
      APPEND VALUE #(  %tky               = ls_fg_Bas-%tky
                       %state_area        = 'VALIDATE_DATES' )
              TO reported-fg_bas.

* Verificamos la coherencia del rango inicio-fin
      IF ls_fg_bas-InitialDate GE ls_fg_bas-CommissionedDate.

        ls_t100-msgid = |ZE_PPM|.
        ls_t100-msgno = |002|.
        ls_t100-attr1 = ls_fg_bas-InitialDate.
        ls_t100-attr2 = ls_fg_bas-CommissionedDate.

        APPEND VALUE #( %tky = ls_fg_bas-%tky ) TO failed-fg_bas.

        APPEND VALUE #( %tky        = ls_fg_bas-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_e_pln_hdr_excp(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = ls_t100 )
                      )
        TO reported-fg_bas.

        CONTINUE.

      ENDIF.

* Validamos la coherencia de las fechas del FG
      IF ls_fg_bas-InitialDate < ls_pln_hdr-StartDate OR ls_fg_bas-InitialDate > ls_pln_hdr-EndDate OR
         ls_fg_bas-CommissionedDate < ls_pln_hdr-StartDate OR ls_fg_bas-CommissionedDate > ls_pln_hdr-EndDate.

        ls_t100-msgid = |ZE_PPM|.
        ls_t100-msgno = |001|.
        ls_t100-attr1 = ls_fg_bas-InitialDate.
        ls_t100-attr2 = ls_fg_bas-CommissionedDate.
        ls_t100-attr3 = ls_pln_hdr-StartDate.
        ls_t100-attr4 = ls_pln_hdr-EndDate.

        APPEND VALUE #( %tky = ls_fg_bas-%tky ) TO failed-fg_bas.

        APPEND VALUE #( %tky        = ls_fg_bas-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_e_pln_hdr_excp(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = ls_t100 )
                      )
        TO reported-fg_bas.

        CONTINUE.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.



**********************************************************************************************
* METHOD validateGroupId - Validar el campo de grupo financiero
**********************************************************************************************
  METHOD validateGroupId.

* Variables locales
    DATA: ls_t100        TYPE scx_t100key,
          lt_zetc_fg_def TYPE TABLE OF zetc_fg_def.

* Leemos la entidad de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Si tenemos algun registro a validar recogemos los FGs válidos
    IF lines( lt_fg_bas ) IS NOT INITIAL.

      SELECT * FROM zetc_fg_def
      INTO TABLE @lt_zetc_fg_def.

    ENDIF.

* Recorremos los registros recogidos
    LOOP AT lt_fg_bas INTO DATA(ls_fg_bas) FROM 1 WHERE GroupId IS NOT INITIAL.

* Limpiamos los mensajes que pudiera tener
      APPEND VALUE #(  %tky               = ls_fg_Bas-%tky
                       %state_area        = 'VALIDATE_FG' )
              TO reported-fg_bas.

      READ TABLE lt_zetc_fg_def TRANSPORTING NO FIELDS WITH KEY group_id = ls_fg_bas-GroupId.
      IF sy-subrc <> 0.

        ls_t100-msgid = |ZE_PPM|.
        ls_t100-msgno = |004|.
        ls_t100-attr1 = ls_fg_bas-GroupId.

        APPEND VALUE #( %tky = ls_fg_bas-%tky ) TO failed-fg_bas.

        APPEND VALUE #( %tky        = ls_fg_bas-%tky
                        %state_area = 'VALIDATE_FG'
                        %msg        = NEW zcl_e_pln_hdr_excp(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = ls_t100 )
                      )
        TO reported-fg_bas.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



**********************************************************************************************
* METHOD ValidateTradingPartner - Validar el campo de Trading Partner
**********************************************************************************************
  METHOD validateTradingPartner.

* Variables locales
    DATA: ls_t100    TYPE scx_t100key,
          lt_zetc_tp TYPE TABLE OF zetc_trading_p.

* Leemos la entidad de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Si tenemos algun registro a validar recogemos los trading partner válidos
    IF lines( lt_fg_bas ) IS NOT INITIAL.

      SELECT * FROM zetc_trading_p
      INTO TABLE @lt_zetc_tp.

    ENDIF.

* Recorremos los registros recogidos
    LOOP AT lt_fg_bas INTO DATA(ls_fg_bas) FROM 1 WHERE TradingPartner IS NOT INITIAL.

* Limpiamos los mensajes que pudiera tener
      APPEND VALUE #(  %tky               = ls_fg_Bas-%tky
                       %state_area        = 'VALIDATE_TP' )
              TO reported-fg_bas.

      READ TABLE lt_zetc_tp TRANSPORTING NO FIELDS WITH KEY rcomp = ls_fg_bas-TradingPartner.
      IF sy-subrc <> 0.

        ls_t100-msgid = |ZE_PPM|.
        ls_t100-msgno = |003|.
        ls_t100-attr1 = ls_fg_bas-TradingPartner.

        APPEND VALUE #( %tky = ls_fg_bas-%tky ) TO failed-fg_bas.

        APPEND VALUE #( %tky        = ls_fg_bas-%tky
                        %state_area = 'VALIDATE_TP'
                        %msg        = NEW zcl_e_pln_hdr_excp(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = ls_t100 )
                      )
        TO reported-fg_bas.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



**********************************************************************************************
* METHOD setInitialFGBasData - Determinacion de datos iniciales
**********************************************************************************************
  METHOD setInitialFGBasData.

* Leemos la entidad de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
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
    ENTITY fg_bas
      UPDATE
        FIELDS ( InitialDate CommissionedDate DistrLogic )
        WITH VALUE #( FOR ls_fg_bas IN lt_fg_bas
                      ( %tky             = ls_fg_bas-%tky
                        InitialDate      = ls_pln_hdr-StartDate
                        CommissionedDate = ls_pln_hdr-EndDate
                        DistrLogic       = 'LIN_CAL' ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

* Indicamos a nivel de cabecera que la planificación es de tipo FG
    MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY Plan_Header
      UPDATE
        FIELDS ( PlngType )
        WITH VALUE #( (  %tky             = ls_pln_hdr-%tky
                         PlngType         = 'FG' ) )
    REPORTED DATA(update_reported_hdr).

  ENDMETHOD.

**********************************************************************************************
* METHOD valideteMandatory - Validar obligatoriedad de campos marcados como "Mandatory"
**********************************************************************************************
  METHOD validateMandatory.


* Variables locales
    DATA: ls_t100 TYPE scx_t100key.
    DATA permission_request TYPE STRUCTURE FOR PERMISSIONS REQUEST ze_i_tb_fg_bas.
    DATA reported_fg_bas LIKE LINE OF reported-fg_bas.

    DATA(description_permission_request) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_data_ref( REF #( permission_request-%field ) ) ).
    DATA(components_permission_request) = description_permission_request->get_components(  ).

    LOOP AT components_permission_request INTO DATA(component_permission_request).
      permission_request-%field-(component_permission_request-name) = if_abap_behv=>mk-on.
    ENDLOOP.

    " Get current field values
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
    ENTITY fg_bas
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

** Limpiamos los mensajes que pudiera tener
*      APPEND VALUE #(  %tky               = entity-%tky
*                       %state_area        = 'HDR_VALIDATE_DATES' )
*              TO reported-plan_header.

      GET PERMISSIONS ONLY INSTANCE FEATURES ENTITY ze_i_tb_fg_bas
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

          CLEAR reported_fg_bas.
          reported_fg_bas-%tky = entity-%tky.
          reported_fg_bas-%element-(component_permission_request-name) = if_abap_behv=>mk-on.
          reported_fg_bas-%msg = new_message( id       = 'ZE_PPM'
                                                            number   = 007
                                                            severity = if_abap_behv_message=>severity-error
                                                            v1       = |{ component_permission_request-name }| ).
          APPEND reported_fg_bas  TO reported-fg_bas.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



**********************************************************************************************
* METHOD calculateMonVal - Accion interna de recalculo de mon val
**********************************************************************************************
  METHOD calculateMonVal.

* Variables locales
    DATA: lt_mon_values TYPE zet_mon_values,
          ls_mon_values LIKE LINE OF lt_mon_values,
          ls_fg_bas_ref LIKE LINE OF mapped-fg_bas.

* Leemos las entidades de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Recorremos las entidades
    LOOP AT lt_fg_bas INTO DATA(ls_fg_bas).

* Leemos los datos de la cabecera
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
          ENTITY Plan_Header
            ALL FIELDS WITH CORRESPONDING #( keys )
          RESULT DATA(lt_pln_hdr).

      DATA(ls_pln_hdr) = lt_pln_hdr[ 1 ].

** Leemos las entidades a borrar
*      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
*      ENTITY FGBasMonVal
*      ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_fg_bas_mon_val).
*
** Comprobamos si hay algo que borrar
*      IF lt_fg_bas_mon_val IS NOT INITIAL.
*
** Primero borramos las entidades de Mon Val hijas
*        MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
*         ENTITY FGBasMonVal
*         DELETE FROM VALUE #( FOR ls_fg_bas_mon_val IN lt_fg_bas_mon_val ( %tky = ls_fg_bas_mon_val-%tky ) ).
*
*      ENDIF.

* Leemos las entidades a borrar
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
      ENTITY FG_Bas BY \_fg_bas_mon_val
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fg_bas_mon_val).

* Comprobamos si hay algo que borrar
      IF lt_fg_bas_mon_val IS NOT INITIAL.

* Primero borramos las entidades de Mon Val hijas
        MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
         ENTITY FGBasMonVal
         DELETE FROM VALUE #( FOR ls_fg_bas_mon_val IN lt_fg_bas_mon_val ( %tky = ls_fg_bas_mon_val-%tky
*                                                                           %is_draft = if_abap_behv=>mk-off
                                                                            ) )
         MAPPED DATA(del_mon_val_mapped)
         REPORTED DATA(del_mon_val_reported)
         FAILED DATA(del_mon_val_failed).

      ENDIF.

* Invocaremos un método que en función de la logica de distribución y fechas calcule la distribución
      CASE ls_fg_bas-DistrLogic.

        WHEN 'LIN_CAL'.

          CALL METHOD zcl_e_distr=>lin_cal
            EXPORTING
              i_date_from    = ls_fg_bas-InitialDate
              i_date_to      = ls_fg_bas-CommissionedDate
              i_total_amount = ls_fg_bas-TotalAmount
            IMPORTING
              et_mon_val     = lt_mon_values.

        WHEN 'LIN_FACT_C'.

          CALL METHOD zcl_e_distr=>fact_cal
            EXPORTING
              i_date_from    = ls_fg_bas-InitialDate
              i_date_to      = ls_fg_bas-CommissionedDate
              i_total_amount = ls_fg_bas-TotalAmount
            IMPORTING
              et_mon_val     = lt_mon_values.

        WHEN 'AT_END'.

          CALL METHOD zcl_e_distr=>at_the_end
            EXPORTING
              i_date_from    = ls_fg_bas-InitialDate
              i_date_to      = ls_fg_bas-CommissionedDate
              i_total_amount = ls_fg_bas-TotalAmount
            IMPORTING
              et_mon_val     = lt_mon_values.

        WHEN 'S_CURVE'.

          CALL METHOD zcl_e_distr=>s_curve
            EXPORTING
              i_date_from    = ls_fg_bas-InitialDate
              i_date_to      = ls_fg_bas-CommissionedDate
              i_total_amount = ls_fg_bas-TotalAmount
            IMPORTING
              et_mon_val     = lt_mon_values.

      ENDCASE.

*Declare internal table using derived type
      DATA create TYPE TABLE FOR CREATE ze_i_tb_fg_bas\_fg_bas_mon_val.
      DATA ls_create LIKE LINE OF create.


      CLEAR ls_create.
      ls_create-%is_draft = if_abap_behv=>mk-off.
      ls_create-PlnHdrGuid = ls_fg_bas-PlnHdrGuid.
      ls_create-Guid = ls_fg_bas-Guid.
      ls_Create-%target = VALUE #( FOR ls_mon_val IN lt_mon_values (
                                      PlnHdrGuid = ls_fg_bas-PlnHdrGuid
                                      parentguid = ls_fg_bas-guid
                                      fyear = ls_mon_val-fyear
                                      period = ls_mon_val-period
                                      amount = ls_mon_val-amount
                                       )  ).
      APPEND ls_create TO create.

* Creamos las entidades FG_BAS_Mon_val
      MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
                ENTITY FG_Bas
                CREATE BY \_fg_bas_mon_val
                AUTO FILL CID
                FIELDS ( fyear period amount PlnHdrGuid ParentGuid )
                WITH create
          MAPPED DATA(mon_val_mapped)
          REPORTED DATA(mon_val_reported)
          FAILED DATA(mon_val_failed).

    ENDLOOP.

    result = VALUE #( FOR ls_fg_bas_aux IN lt_fg_bas ( %tky      = ls_fg_bas-%tky
                                                       %param    = ls_fg_bas ) ).

  ENDMETHOD.




**********************************************************************************************
* METHOD deleteMonVal - Accion interna de recalculo de mon val
**********************************************************************************************
  METHOD deleteMonVal.

* Leemos las entidades de grupo financiero
    READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
       ENTITY fg_bas
         ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_fg_bas).

* Recorremos las entidades
    LOOP AT lt_fg_bas INTO DATA(ls_fg_bas).

* Leemos las entidades a borrar
      READ ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
      ENTITY FG_Bas BY \_fg_bas_mon_val
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_fg_bas_mon_val).

* Comprobamos si hay algo que borrar
      IF lt_fg_bas_mon_val IS NOT INITIAL.

* Primero borramos las entidades de Mon Val hijas
        MODIFY ENTITIES OF ze_i_tb_pln_hdr IN LOCAL MODE
         ENTITY FGBasMonVal
         DELETE FROM VALUE #( FOR ls_fg_bas_mon_val IN lt_fg_bas_mon_val ( %tky = ls_fg_bas_mon_val-%tky
                                                                            ) )
         MAPPED DATA(mon_val_mapped)
         REPORTED DATA(mon_val_reported)
         FAILED DATA(mon_val_failed).

      ENDIF.

    ENDLOOP.

    result = VALUE #( FOR ls_fg_bas_aux IN lt_fg_bas ( %tky      = ls_fg_bas-%tky
                                                       %param    = ls_fg_bas ) ).
*    result = CORRESPONDING #( DEEP lt_fg_bas ).

  ENDMETHOD.


ENDCLASS.
