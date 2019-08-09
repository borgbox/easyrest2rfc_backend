class ZCL_ER2R_ICF_UTIL definition
  public
  final
  create public .

public section.

  constants ER2R_NODE type ICFNAME value 'ZER2R_ADAPTER' ##NO_TEXT.
  constants EMPTY_PARENT_GUID type ICFPARGUID value '0000000000000000000000000' ##NO_TEXT.
  constants ZER2R_PACKAGE type DEVCLASS value 'ZER2R' ##NO_TEXT.
protected section.
private section.

  class-methods GET_MAIN_NODE
    returning
      value(E_PARGUID) type ICFSERVICE-ICFNODGUID .
  class-methods CREATE_NODE_SERVICE
    importing
      !SERVICE_NODE_NAME type ICFNAME
      !SERVICE_DESCRIPTION type ICF_DOCU
    exporting
      !ET_RETURN type BAPIRET2_T
    changing
      !TRANSPORT type TRKORR .
ENDCLASS.



CLASS ZCL_ER2R_ICF_UTIL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_ER2R_ICF_UTIL=>CREATE_NODE_SERVICE
* +-------------------------------------------------------------------------------------------------+
* | [--->] SERVICE_NODE_NAME              TYPE        ICFNAME
* | [--->] SERVICE_DESCRIPTION            TYPE        ICF_DOCU
* | [<---] ET_RETURN                      TYPE        BAPIRET2_T
* | [<-->] TRANSPORT                      TYPE        TRKORR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_node_service.

    DATA: lv_language   TYPE spras,
          ls_icfservice TYPE icfservice,
          lt_icfhndlist TYPE icfhndlist,
          ls_icfserdesc TYPE icfserdesc,
          ls_icfdocu    TYPE icfdocu,
          lv_parent     TYPE icfparguid,
          lv_package    TYPE devclass,
          lv_icfnodguid	TYPE icfnodguid.

    lv_language = sy-langu.
    lv_package = zcl_er2r_icf_util=>zer2r_package.
    ls_icfdocu-icf_langu = sy-langu.

    DATA(lv_parguid_er2r) = zcl_er2r_icf_util=>get_main_node( ).

    IF lv_parguid_er2r = zcl_er2r_icf_util=>empty_parent_guid."Create parent node before

      TRY.

          ls_icfdocu-icf_docu = text-001.

          cl_icf_tree=>if_icf_tree~insert_node(
        EXPORTING
          icf_name                  = zcl_er2r_icf_util=>er2r_node
          icfparguid                = lv_parguid_er2r
          icfdocu                   = ls_icfdocu
          doculang                  = lv_language
          icfhandlst                = lt_icfhndlist
          package                   = lv_package
          application               = space
          icfserdesc                = ls_icfserdesc
          icfactive                 = abap_true
*              icfaltnme                 = is_icfservice-icfaltnme
        IMPORTING
          icfnodguid  = lv_icfnodguid
          CHANGING
            transport = transport
        EXCEPTIONS
          empty_icf_name            = 1
          no_new_virtual_host       = 2
          special_service_error     = 3
          parent_not_existing       = 4
          enqueue_error             = 5
          node_already_existing     = 6
          empty_docu                = 7
          doculang_not_installed    = 8
          security_info_error       = 9
          user_password_error       = 10
          password_encryption_error = 11
          invalid_url               = 12
          invalid_otr_concept       = 13
          formflg401_error          = 14
          handler_error             = 15
          transport_error           = 16
          tadir_error               = 17
          package_not_found         = 18
          wrong_application         = 19
          not_allow_application     = 20
          no_application            = 21
          invalid_icfparguid        = 22
          alt_name_invalid          = 23
          alternate_name_exist      = 24
          wrong_icf_name            = 25
          no_authority              = 26
          OTHERS                    = 27 ).

          COMMIT WORK.

          lv_parguid_er2r = lv_icfnodguid.

        CATCH cx_root INTO DATA(lo_exception).
          APPEND VALUE #( type         = 'E'
                          id           = 'ZER2R'
                          number       = '004'
                          message      = lo_exception->get_text( ) ) TO et_return.
          EXIT.
      ENDTRY.

    ENDIF.

    TRY .

        ls_icfdocu-icf_docu = service_description.

        cl_icf_tree=>if_icf_tree~insert_node(
      EXPORTING
        icf_name                  = service_node_name
        icfparguid                = lv_parguid_er2r
        icfdocu                   = ls_icfdocu
        doculang                  = lv_language
        icfhandlst                = lt_icfhndlist
        package                   = lv_package
        application               = space
        icfserdesc                = ls_icfserdesc
        icfactive                 = abap_true
*    icfaltnme                 = is_icfservice-icfaltnme
      EXCEPTIONS
        empty_icf_name            = 1
        no_new_virtual_host       = 2
        special_service_error     = 3
        parent_not_existing       = 4
        enqueue_error             = 5
        node_already_existing     = 6
        empty_docu                = 7
        doculang_not_installed    = 8
        security_info_error       = 9
        user_password_error       = 10
        password_encryption_error = 11
        invalid_url               = 12
        invalid_otr_concept       = 13
        formflg401_error          = 14
        handler_error             = 15
        transport_error           = 16
        tadir_error               = 17
        package_not_found         = 18
        wrong_application         = 19
        not_allow_application     = 20
        no_application            = 21
        invalid_icfparguid        = 22
        alt_name_invalid          = 23
        alternate_name_exist      = 24
        wrong_icf_name            = 25
        no_authority              = 26
        OTHERS                    = 27 ).
      CATCH cx_root INTO lo_exception.
        APPEND VALUE #( type         = 'E'
                        id           = 'ZER2R'
                        number       = '005'
                        message      = lo_exception->get_text( ) ) TO et_return.
        EXIT.

    ENDTRY.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_ER2R_ICF_UTIL=>GET_MAIN_NODE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] E_PARGUID                      TYPE        ICFSERVICE-ICFNODGUID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_main_node.

    SELECT SINGLE icfnodguid
    INTO @e_parguid
     FROM icfservice
       WHERE icf_name = @zcl_er2r_icf_util=>er2r_node.
    IF sy-subrc <> 0.
      e_parguid = zcl_er2r_icf_util=>empty_parent_guid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
