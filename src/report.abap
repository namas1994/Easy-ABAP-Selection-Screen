*&---------------------------------------------------------------------*
*& Report ZR_SEL_SIMPLE
*&---------------------------------------------------------------------*
*& Description: Program to demonstrate easy handling of complex Selection
*&      Screen
*&---------------------------------------------------------------------*
*& Author: Namasivaym Mani
*&---------------------------------------------------------------------*

REPORT zr_sel_simple.

TYPES:
  BEGIN OF gty_scn_field_auth,
    excel_upd   TYPE boolean,
    display_del TYPE boolean,
    execute     TYPE boolean,
  END OF gty_scn_field_auth.

DATA gs_scn_field_auth TYPE gty_scn_field_auth.

DATA:
  gv_div    TYPE spart,
  gv_month  TYPE /bi0/oicalmonth,
  gv_bucket TYPE /sapapo/snpbucke,
  gv_date   TYPE d,
  gv_plant  TYPE werks_d.

**********************************************************************
*** START OF SELECTION SCREEN DESIGN
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
PARAMETERS:
  r_s_mstr RADIOBUTTON GROUP g1 MODIF ID r1 USER-COMMAND rad1 DEFAULT 'X', "Table Maintence
  r_log_rp RADIOBUTTON GROUP g1 MODIF ID r1. "SNP Log and Deployment
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.
PARAMETERS:
  r_s_dsp RADIOBUTTON GROUP g2 MODIF ID r6 USER-COMMAND rad2 DEFAULT 'X',
  r_s_upd RADIOBUTTON GROUP g2 MODIF ID r2. "excel upload
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-s03.PARAMETER:
  p_file TYPE char1024 MODIF ID f1. "file path
SELECTION-SCREEN PUSHBUTTON:
  /1(25) btn_guid USER-COMMAND btn_guide MODIF ID f1, "excel guide
  53(25) btn_frmt USER-COMMAND btn_format MODIF ID f1. "Excel format
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-s04.
PARAMETERS:
  r_snplog RADIOBUTTON GROUP g3 MODIF ID r3 USER-COMMAND rad2 DEFAULT 'X', "SNP Optimizer Log
  r_deploy RADIOBUTTON GROUP g3 MODIF ID r3. "Deployment Data
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE TEXT-s05.
PARAMETERS:
  r_gnrt   RADIOBUTTON GROUP g4 MODIF ID r4 USER-COMMAND rad3, "generate report
  r_dp_bas RADIOBUTTON GROUP g4 MODIF ID r5, "Base data display
  r_dp_r   RADIOBUTTON GROUP g4 MODIF ID r5, "RO wise report
  r_dp_tzn RADIOBUTTON GROUP g4 MODIF ID r5. "TZone Wise dispaly
SELECTION-SCREEN END OF BLOCK b5.

SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE TEXT-s06.
PARAMETERS:
  p_log TYPE /sapapo/sessionname MODIF ID m1.
SELECT-OPTIONS:
  s_div FOR gv_div MODIF ID m2,
  s_plant FOR gv_plant MODIF ID m3,
  s_month FOR gv_month MODIF ID m2 NO-EXTENSION,
  s_cal_dt FOR gv_date MODIF ID m4,
  s_bucket FOR gv_bucket MODIF ID m5,
  s_date FOR gv_date NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b6.

**********************************************************************
*** END OF SELECTION SCREEN DESIGN
**********************************************************************

INITIALIZATION.
  btn_guid = 'Excel File Guidence' .
  btn_frmt = 'Download File Format'.
  PERFORM check_auth.

AT SELECTION-SCREEN OUTPUT.
  PERFORM modify_screen.

START-OF-SELECTION.
  PERFORM start_program_execution.

FORM check_auth.

**********************************************************************
** for demonstration purpose I have set the values manually
** in real program you must have set the fields using
** AUTHORITY CHECK object, if the user has authorization
**********************************************************************

*  gs_scn_field_auth-excel_upd = abap_true.
  gs_scn_field_auth-display_del = abap_true.
  gs_scn_field_auth-execute     = abap_true.

ENDFORM.

FORM modify_screen.

  DATA:
*    variable to hold list of modif ids to be visible for selected ratio button
    lv_selected        TYPE string,
*    variable to hold list of modif ids for not authorized fields
    lv_auth            TYPE string,

*    radio button: table maintenance
    lv_r_tab_maint     TYPE string VALUE 'R3,R4,R5,M1,M2,M5,M4',

*    radio button: excel upload
    lv_r_tab_maint_upd TYPE string VALUE 'M3',

*    radio button: table display/delete
    lv_r_tab_maint_dsp TYPE string VALUE 'F1',

*    radio button: data source selection
    lv_r_data_src      TYPE string VALUE 'F1,R2,R6,M3,',
*    radio button: snp optimizer log
    lv_r_snplog        TYPE string VALUE 'M4,',
*    radio button: snp deployment
    lv_r_deployment    TYPE string VALUE 'M1,M5,'.

  IF gs_scn_field_auth-display_del = abap_false.
    CONCATENATE lv_auth 'R6' INTO lv_auth SEPARATED BY ','.
*    CONCATENATE lv_auth 'R2' INTO lv_auth SEPARATED BY ','.
  ENDIF.

  IF gs_scn_field_auth-execute = abap_false.
    lv_auth = 'R4'.
  ENDIF.

  IF gs_scn_field_auth-excel_upd = abap_false.
    CONCATENATE lv_auth 'R2' INTO lv_auth SEPARATED BY ','.
  ENDIF.

*  checking for which radion button has been selected
  CASE abap_true.

    WHEN r_s_mstr. "Table Maintence

      CASE abap_true.
        WHEN r_s_upd. "Excel Upload
          CONCATENATE lv_r_tab_maint lv_r_tab_maint_upd INTO lv_selected SEPARATED BY ','.
        WHEN r_s_dsp. "table display/change/delete
          CONCATENATE lv_r_tab_maint lv_r_tab_maint_dsp INTO lv_selected SEPARATED BY ','.
      ENDCASE.

    WHEN r_log_rp. "SNP Log and Deployment

      CASE abap_true.
        WHEN r_snplog. "snp optimizer log data
          CONCATENATE lv_r_data_src lv_r_snplog INTO lv_selected SEPARATED BY ','.
          IF r_gnrt = abap_true OR r_dp_bas = abap_true.
            CONCATENATE lv_selected 'M5' INTO lv_selected SEPARATED BY ','.
          ENDIF.
        WHEN r_deploy. "deployment data
          CONCATENATE lv_r_data_src lv_r_deployment
            INTO lv_selected SEPARATED BY ','.
          IF r_gnrt = abap_true OR r_dp_bas = abap_true.
            CONCATENATE lv_selected 'M4' INTO lv_selected SEPARATED BY ','.
          ENDIF.
      ENDCASE.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group1 IS NOT INITIAL.
*      hide the fields which are not required for selected ratio button
      IF lv_selected CS screen-group1.
        screen-active = 0. "hide field
        MODIFY SCREEN.
      ENDIF.

*      disable radio button for which the user does not have the authorization
      IF lv_auth CS screen-group1.
        screen-input = 0. "gray out field
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM start_program_execution.


*  checking for which radion button has been selected
  CASE abap_true.

    WHEN r_s_mstr. "Table Maintence

      CASE abap_true.
        WHEN r_s_upd. "Excel Upload
          MESSAGE 'Excel Upload Selected' TYPE 'I'.
        WHEN r_s_dsp. "table display/delete
          MESSAGE 'Table Display/Delete Selected' TYPE 'I'.
      ENDCASE.

    WHEN r_log_rp. "SNP Log and Deployment

      CASE abap_true.
        WHEN r_snplog. "snp optimizer log data
          CASE abap_true.
            WHEN r_gnrt  .
              MESSAGE 'SNP Log: Generate Data Selected' TYPE 'I'.
            WHEN r_dp_bas.
              MESSAGE 'SNP Log: Base Data Display Selected' TYPE 'I'.
            WHEN r_dp_r  .
              MESSAGE 'SNP Log: Region Display Selected' TYPE 'I'.
            WHEN r_dp_tzn.
              MESSAGE 'SNP Log: Transportation Zone Display Selected' TYPE 'I'.
          ENDCASE.
        WHEN r_deploy. "deployment data
          CASE abap_true.
            WHEN r_gnrt  .
              MESSAGE 'Deployment: Generate Data Selected' TYPE 'I'.
            WHEN r_dp_bas.
              MESSAGE 'Deployment: Base Data Display Selected' TYPE 'I'.
            WHEN r_dp_r  .
              MESSAGE 'Deployment: Region Display Selected' TYPE 'I'.
            WHEN r_dp_tzn.
              MESSAGE 'Deployment: Transportation Zone Display Selected' TYPE 'I'.
          ENDCASE.
      ENDCASE.
  ENDCASE.

ENDFORM.