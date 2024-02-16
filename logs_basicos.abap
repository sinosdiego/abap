REPORT ZTESTE_DIEGO_LOG.

DATA: ls_log        TYPE bal_s_log,
      lv_log_handle TYPE BALLOGHNDL,
      ls_msgm       TYPE BAL_S_MSG.


*-----------------------------------------------------------------------
* Cria FM Mensagens
*-----------------------------------------------------------------------
ls_log-object    = 'ZMM'.         "Código Objeto Pai   - Criado na SLG0
ls_log-subobject = 'ZMM_PEDIDO'.  "Código Objeto Filho - Criado na SLG0
ls_log-extnumber = '00001'.       "Código Id documento Log
ls_log-aluser    = sy-uname.
ls_log-altcode   = sy-tcode.
ls_log-almode    = 'D'.

CALL FUNCTION 'BAL_LOG_CREATE'
  EXPORTING
    i_s_log                 = ls_log
  IMPORTING
    e_log_handle            = lv_log_handle
  EXCEPTIONS
    log_header_inconsistent = 1
    OTHERS                  = 2.

*-----------------------------------------------------------------------
* Atribui Mensagem
*-----------------------------------------------------------------------
CLEAR ls_msgm.
ls_msgm-msgty = 'E'.
ls_msgm-msgid = 'Z0'.     "Referencia a classe de mensagem na SE91
ls_msgm-msgno = '010'.    "Referencia ao número da mensagem na SE91
ls_msgm-msgv1 = 'Informação'.
ls_msgm-msgv2 = 'Informação número 1'.

CALL FUNCTION 'BAL_LOG_MSG_ADD'
  EXPORTING
   i_log_handle              = lv_log_handle
   i_s_msg                   = ls_msgm
*IMPORTING
* E_S_MSG_HANDLE            =
* E_MSG_WAS_LOGGED          =
* E_MSG_WAS_DISPLAYED       =
 EXCEPTIONS
   log_not_found             = 1
   msg_inconsistent          = 2
   log_is_full               = 3
   OTHERS                    = 4.

IF sy-subrc <> 0.
*Implement suitable error handling here
ELSE.

ENDIF.

*-----------------------------------------------------------------------
* Atribui Mensagem
*-----------------------------------------------------------------------
CLEAR ls_msgm.
ls_msgm-msgty = 'E'.
ls_msgm-msgid = 'Z0'.     "Referencia a classe de mensagem na SE91
ls_msgm-msgno = '011'.    "Referencia ao número da mensagem na SE91
ls_msgm-msgv1 = 'Informação'.
ls_msgm-msgv2 = 'Informação número 2'.

CALL FUNCTION 'BAL_LOG_MSG_ADD'
  EXPORTING
   i_log_handle              = lv_log_handle
   i_s_msg                   = ls_msgm
*IMPORTING
* E_S_MSG_HANDLE            =
* E_MSG_WAS_LOGGED          =
* E_MSG_WAS_DISPLAYED       =
 EXCEPTIONS
   log_not_found             = 1
   msg_inconsistent          = 2
   log_is_full               = 3
   OTHERS                    = 4.

IF sy-subrc <> 0.
*Implement suitable error handling here
ELSE.

ENDIF.


*-----------------------------------------------------------------------
* Salva Log
*-----------------------------------------------------------------------

DATA: lt_new_lognumbers TYPE bal_t_lgnm,
      ls_new_lognumbers TYPE bal_s_lgnm.

REFRESH lt_new_lognumbers.
CALL FUNCTION 'BAL_DB_SAVE'
  EXPORTING
    i_save_all       = 'X'
  IMPORTING
    e_new_lognumbers = lt_new_lognumbers
  EXCEPTIONS
    log_not_found    = 1
    save_not_allowed = 2
    numbering_error  = 3
    OTHERS           = 4.

READ TABLE lt_new_lognumbers INTO ls_new_lognumbers INDEX 1.
IF sy-subrc IS INITIAL.
  lv_log_handle = ls_new_lognumbers-lognumber.
ENDIF.
