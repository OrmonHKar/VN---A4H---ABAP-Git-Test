CLASS zcl_e_distr DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

**********************************************************************
* Methods - Definicion de los metodos estaticos y publicos de la clase
**********************************************************************
    CLASS-METHODS at_the_end
      IMPORTING
        i_date_from    TYPE dats
        i_date_to      TYPE dats
        i_total_amount TYPE ze_tv_mon_amount
      EXPORTING
        et_mon_val     TYPE zet_mon_values.

    CLASS-METHODS lin_cal
      IMPORTING
        i_date_from    TYPE dats
        i_date_to      TYPE dats
        i_total_amount TYPE ze_tv_mon_amount
      EXPORTING
        et_mon_val     TYPE zet_mon_values.

    CLASS-METHODS fact_cal
      IMPORTING
        i_date_from    TYPE dats
        i_date_to      TYPE dats
        i_total_amount TYPE ze_tv_mon_amount
      EXPORTING
        et_mon_val     TYPE zet_mon_values.

    CLASS-METHODS s_curve
      IMPORTING
        i_date_from    TYPE dats
        i_date_to      TYPE dats
        i_total_amount TYPE ze_tv_mon_amount
      EXPORTING
        et_mon_val     TYPE zet_mon_values.

    CLASS-METHODS get_periods
      IMPORTING
                i_date_from      TYPE dats
                i_date_to        TYPE dats
      RETURNING VALUE(r_periods) TYPE zet_mon_values.

    CLASS-METHODS set_amount_rest
      IMPORTING
                i_total_amount  TYPE ze_tv_mon_amount
                i_rest          TYPE ze_tv_mon_amount
                i_result        TYPE zet_mon_values
      RETURNING VALUE(r_result) TYPE zet_mon_values.

     CLASS-METHODS calculate
      IMPORTING
        i_initial_date    TYPE gjahr
        i_end_date      TYPE gjahr
        i_amount TYPE ze_tv_mon_amount
      EXPORTING
        et_mon_val     TYPE ZET_MON_VALUES_PER_YEAR.

     CLASS-METHODS get_years
      IMPORTING
                i_date_from      TYPE gjahr
                i_date_to        TYPE gjahr
      RETURNING VALUE(r_periods) TYPE ZET_MON_VALUES_PER_YEAR.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_e_distr IMPLEMENTATION.

  METHOD at_the_end.
**********************************************************************************************************************
* METHOD at_the_end - Guarda el importe a gastar dentro del plazo marcado en el ultimo año y mes establecido de fin
**********************************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA(lv_total_amount) = i_total_amount.
    DATA lv_result TYPE zet_mon_values.
    FIELD-SYMBOLS <lf_amount_values> TYPE zes_mon_values.

* llamo al metodo get_periods para obtener los periodos que hay entre las fechas seleccionadas
    lv_result = get_periods(
        EXPORTING
           i_date_from = lv_date_from
           i_date_to = lv_date_to
    ).

* Se recorre los periodos y se le asigna en la ultima posicion la cantidad elegida
    LOOP AT lv_result ASSIGNING <lf_amount_values>.
      IF sy-tabix = lines( lv_result ).
        <lf_amount_values>-amount = lv_total_amount.
      ENDIF.
    ENDLOOP.

    et_mon_val = lv_result.

  ENDMETHOD.


  METHOD fact_cal.
*******************************************************************************************************
* METHOD fact_cal - Reparte el importe a gastar entre los meses dentro de las fechas seleccionadas
*******************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA(lv_total_amount) = i_total_amount.
    FIELD-SYMBOLS <lf_amount_values> TYPE zes_mon_values.
    DATA lv_amount TYPE ze_tv_mon_amount.
    DATA lv_rest TYPE ze_tv_mon_amount.

* llamo al metodo get_periods para obtener los periodos que hay entre las fechas seleccionadas
    DATA(lv_result) = get_periods(
        EXPORTING
           i_date_from = lv_date_from
           i_date_to = lv_date_to
    ).

    lv_amount = lv_total_amount / lines( lv_result ).
* Se recorre los periodos y se le asigna la parte proporcinal de la cantidad elegida entre los periodos establecidos entre las fechas seleccionadas
    LOOP AT lv_result ASSIGNING <lf_amount_values>.
      <lf_amount_values>-amount = lv_amount.
      lv_rest += lv_amount.
    ENDLOOP.

    IF lv_rest NE lv_total_amount.
* llamo al metodo set_amount_rest para añadir los centimos sobrantes/restantes al ultimo periodo
      lv_result = set_amount_rest(
          EXPORTING
              i_rest = lv_rest
              i_result = lv_result
              i_total_amount = lv_total_amount
      ).
    ENDIF.

    et_mon_val = lv_result.

  ENDMETHOD.

  METHOD get_periods.
**********************************************************************************************************************
* METHOD get_periods - Calcula y obtiene los periodos que hay entre las fechas seleccionadas
**********************************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA ls_AMOUNT_VALUES TYPE zes_mon_values.
    lv_date_from+6(2) = lv_date_to+6(2).

* calcula los periodos entre las fechas seleccionadas
    WHILE lv_date_from LE lv_date_to.
      ls_amount_values-fyear = lv_date_from+0(4).
      ls_amount_values-period = lv_date_from+4(2).
      APPEND ls_amount_values TO r_periods.
* Si el mes de la fecha inicial es 12, se le suma un año y se establece el mes a 1, en caso contrario se suma un mes
      IF lv_date_from+4(2) EQ 12.
        lv_date_from+4(2) = 01.
        lv_date_from+0(4) = lv_date_from+0(4) + 1.
      ELSE.
        lv_date_from+4(2) = lv_date_from+4(2) + 1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD lin_cal.
*******************************************************************************************************
* METHOD lin_cal - Reparte el importe a gastar entre los meses dentro de las fechas seleccionadas
*******************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA(lv_total_amount) = i_total_amount.
    FIELD-SYMBOLS <lf_amount_values> TYPE zes_mon_values.
    DATA lv_amount TYPE ze_tv_mon_amount.
    DATA lv_rest TYPE ze_tv_mon_amount.

* llamo al metodo get_periods para obtener los periodos que hay entre las fechas seleccionadas
    DATA(lv_result) = get_periods(
         EXPORTING
            i_date_from = lv_date_from
            i_date_to = lv_date_to
    ).

    lv_amount = lv_total_amount / lines( lv_result ).
* Se recorre los periodos y se le asigna la parte proporcinal de la cantidad elegida entre los periodos establecidos entre las fechas seleccionadas
    LOOP AT lv_result ASSIGNING <lf_amount_values>.
      <lf_amount_values>-amount = lv_amount.
      lv_rest += lv_amount.
    ENDLOOP.

    IF lv_rest NE lv_total_amount.
* llamo al metodo set_amount_rest para añadir los centimos sobrantes/restantes al primer periodo
      lv_result = set_amount_rest(
*      lv_result[ 1 ] = set_amount_rest(
          EXPORTING
              i_rest = lv_rest
              i_result = lv_result
              i_total_amount = lv_total_amount
      ).
    ENDIF.

    et_mon_val = lv_result.

  ENDMETHOD.

  METHOD s_curve.
*****************************************************************************************************************
* METHOD s_curve - Guarda el importe a gastar dentro del plazo marcado en el primer año y mes establecido de inicio
*****************************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA(lv_total_amount) = i_total_amount.
    FIELD-SYMBOLS <lf_amount_values> TYPE zes_mon_values.

* llamo al metodo get_periods para obtener los peridos que hay entre las fechas seleccionadas
    DATA(lv_result) = get_periods(
        EXPORTING
           i_date_from = lv_date_from
           i_date_to = lv_date_to
    ).

* Se recorre los peridos y se le asigna en la primera posicion la cantidad elegida
    LOOP AT lv_result ASSIGNING <lf_amount_values>.
      IF sy-tabix = 1.
        <lf_amount_values>-amount = lv_total_amount.
      ENDIF.
    ENDLOOP.

    et_mon_val = lv_result.

  ENDMETHOD.

  METHOD set_amount_rest.
*****************************************************************************************************************
* METHOD set_amount_rest - Calcula los centimos sobrantes/restantes y los suma en un periodo
*****************************************************************************************************************

* Variables locales del metodo
    DATA lv_amount_rest TYPE ze_tv_mon_amount.
    DATA lv_amount_rest_aux TYPE ze_tv_mon_amount.
    DATA(lv_result) = i_result.

* Comprueba si sobra/falta dinero por repartir y lo añade al periodo establecido
    IF i_rest < i_total_amount.
      lv_amount_rest = i_total_amount - i_rest.
      lv_result[ 1 ]-amount = lv_result[ 1 ]-amount + lv_amount_rest.
*      lv_result-amount = lv_result-amount + lv_amount_rest.
    ELSE.
        lv_amount_rest = i_rest - i_total_amount.
        IF lv_amount_rest >= lv_result[ 1 ]-amount.

            IF lv_amount_rest MOD 2 EQ 0.
                lv_amount_rest_aux = lv_amount_rest / 2.
                lv_result[ 2 ]-amount = lv_result[ 2 ]-amount - lv_amount_rest_aux.
                lv_result[ 1 ]-amount = lv_result[ 1 ]-amount - lv_amount_rest_aux.
                IF lv_amount_rest_aux * 2 < lv_amount_rest.
                    lv_result[ 3 ]-amount = lv_result[ 3 ]-amount - ( lv_amount_rest - ( lv_amount_rest_aux * 2 ) ).
                ENDIF.
            ELSE.
                lv_amount_rest_aux = lv_amount_rest / 3.
                lv_result[ 1 ]-amount = lv_result[ 1 ]-amount - lv_amount_rest_aux.
                lv_result[ 2 ]-amount = lv_result[ 2 ]-amount - lv_amount_rest_aux.
                lv_result[ 3 ]-amount = lv_result[ 3 ]-amount - lv_amount_rest_aux.
                IF lv_amount_rest_aux * 3 < lv_amount_rest.
                    lv_result[ 4 ]-amount = lv_result[ 4 ]-amount - ( lv_amount_rest - ( lv_amount_rest_aux * 3 ) ).
                ENDIF.
            ENDIF.

        ELSE.
            lv_result[ 1 ]-amount = lv_result[ 1 ]-amount - lv_amount_rest.
        ENDIF.

    ENDIF.
    r_result = lv_result.

  ENDMETHOD.

  METHOD calculate.

* Variables locales del metodo
    DATA(lv_initial_date) = i_initial_date.
    DATA(lv_end_date) = i_end_date.
    DATA(lv_amount) = i_amount.
    DATA lv_result TYPE ZET_MON_VALUES_PER_YEAR.
    FIELD-SYMBOLS <lf_amount_values> TYPE zes_mon_values_per_year.

    lv_result = get_years(
        EXPORTING
           i_date_from = lv_initial_date
           i_date_to = lv_end_date
    ).

    DATA(lv_year_diff) = ( lv_end_date - lv_initial_date ) + 1.
    DATA(lv_amount_per_year) = lv_amount / lv_year_diff.

* Se recorre los años y se le asigna la cantidad correspondiente
    LOOP AT lv_result ASSIGNING <lf_amount_values>.
        <lf_amount_values>-amount = lv_amount_per_year.
    ENDLOOP.

    et_mon_val = lv_result.

  ENDMETHOD.

    METHOD get_years.
**********************************************************************************************************************
* METHOD get_periods - Calcula y obtiene los periodos que hay entre las fechas seleccionadas
**********************************************************************************************************************

* Variables locales del metodo
    DATA(lv_date_from) = i_date_from.
    DATA(lv_date_to) = i_date_to.
    DATA ls_AMOUNT_VALUES TYPE zes_mon_values_per_year.


* calcula los periodos entre las fechas seleccionadas
    WHILE lv_date_from LE lv_date_to.
      ls_amount_values-fyear = lv_date_from.
      lv_date_from = lv_date_from + 1.
      APPEND ls_amount_values TO r_periods.
    ENDWHILE.

  ENDMETHOD.

ENDCLASS.
