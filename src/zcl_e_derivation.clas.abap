CLASS zcl_e_derivation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS search_CU_FG
      IMPORTING
        i_COMPANY_CODE  TYPE ze_tv_bukrs
        i_FIN_VIEW      TYPE ze_tv_fin_view
        i_AREA          TYPE ze_tv_area
        i_BUSINESS_AREA TYPE ze_tv_gsber
        i_CU_ID         TYPE ze_tv_cu_id
      EXPORTING
        et_cu_fg_values TYPE zetc_CU_FG_T.

    CLASS-METHODS search_CU_RU
      IMPORTING
        i_COMPANY_CODE  TYPE ze_tv_bukrs
        i_CU_ID         TYPE ze_tv_cu_id
        i_CATEGORY      TYPE ze_tv_category
      EXPORTING
        et_cu_ru_values TYPE zetc_cu_ru_c_t.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_e_derivation IMPLEMENTATION.

  METHOD search_CU_FG.
**********************************************************************************************************************
* METHOD search_CU_FG - Busca las cu_fg que cumplan los criterios de busqueda con la fecha de inicio más reciente
**********************************************************************************************************************

* Variables locales del metodo
    DATA lv_cu_fg_t TYPE zetc_CU_FG_T.
    DATA lv_start_date TYPE  ze_tv_start_date.

* Obtiene la cu_fg que cumplan los criterios de busqueda marcados y los ordena desde la fecha de inicio mas reciente a la más antigüa
    SELECT *
    FROM zetc_cu_fg
    WHERE company_code = @i_company_code AND business_area = @i_business_area AND cu_id = @i_cu_id
          AND ( fin_view = @i_fin_view OR fin_view = '00' ) AND ( area IS INITIAL OR area = @i_area )
    ORDER BY start_date DESCENDING
    INTO TABLE @lv_cu_fg_t.

* Comprueba que se hayan encontrado registros
    IF lv_cu_fg_t IS NOT INITIAL.
* Guarda la cu_fg con la fecha de inicio más reciente
      lv_start_date = lv_cu_fg_t[ 1 ]-start_date.
      LOOP AT lv_cu_fg_t INTO DATA(lv_cu_fg).
        IF lv_start_date EQ lv_cu_fg-start_date.
          APPEND lv_cu_fg TO et_cu_fg_values.
        ELSE.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD search_CU_RU.
**********************************************************************************************************************
* METHOD search_CU_RU - Busca las cu_ru que cumplan los criterios de busqueda
**********************************************************************************************************************

* Obtiene los ru y su cost_transfer de las cu_ru que cumplan los criterios de búsqueda
    SELECT ru_id, cost_transfer
    FROM zetc_cu_ru_c
    WHERE company_code = @i_company_code AND cu_id = @i_cu_id AND category = @i_category
    INTO CORRESPONDING FIELDS OF TABLE @et_cu_ru_values.

  ENDMETHOD.

ENDCLASS.
