REPORT zrsb_desafio001.


*Seleção
*Compania Aérea (CARRID)
*Nº Voo (CONNID)
*
*Criar programa que liste:
*SCARR-CARNAME
*SFLIGHT-FLDATE
*PESO_BAGAGEM --> (soma do campo SBOOK-LUGGWEIGHT para o voo)
*QTD_PASSAGEIROS --> (contagem registros SBOOK para o voo)
*QTD_NACIONALIDADE --> (contagem países diferentes para o voo)

TABLES: scarr, spfli.

TYPES: BEGIN OF ty_saida,
         carrname TYPE scarr-carrname,
         fldate   TYPE sflight-fldate,
         peso     TYPE sbook-luggweight,
         qtd_pasg TYPE i,
         qtd_nac  TYPE i,
       END OF ty_saida.

DATA: gt_sflight TYPE TABLE OF sflight,
      gt_scarr   TYPE TABLE OF scarr,
      gt_sbook   TYPE TABLE OF sbook,
      gt_scustom TYPE TABLE OF scustom,
      gt_saida   TYPE TABLE OF ty_saida.

SELECT-OPTIONS: so_carr FOR scarr-carrid,
                so_conn FOR spfli-connid.

PERFORM zf_busca_dados.
PERFORM zf_processa_dados.
PERFORM zf_saida.
*&---------------------------------------------------------------------*
*&      Form  ZF_BUSCA_DADOS
*&---------------------------------------------------------------------*
FORM zf_busca_dados .
  DATA: lt_sflight TYPE TABLE OF sflight,
        lt_sbook   TYPE TABLE OF sbook.
  SELECT *
    FROM sflight
    INTO TABLE gt_sflight
   WHERE carrid IN so_carr
     AND connid IN so_conn.

  IF sy-subrc IS INITIAL.
    lt_sflight = gt_sflight.
    SORT lt_sflight BY carrid.
    DELETE ADJACENT DUPLICATES FROM lt_sflight COMPARING carrid.

    SELECT carrid carrname
      FROM scarr
      INTO CORRESPONDING FIELDS OF TABLE gt_scarr
       FOR ALL ENTRIES IN lt_sflight
     WHERE carrid EQ lt_sflight-carrid.

    SELECT *
      FROM sbook
      INTO TABLE gt_sbook
       FOR ALL ENTRIES IN gt_sflight
     WHERE carrid EQ gt_sflight-carrid
       AND connid EQ gt_sflight-connid
       AND fldate EQ gt_sflight-fldate.
    IF sy-subrc IS INITIAL.
      lt_sbook = gt_sbook.
      SORT lt_sbook BY customid.
      DELETE ADJACENT DUPLICATES FROM lt_sbook COMPARING customid.
      SELECT *
        FROM scustom
        INTO TABLE gt_scustom
         FOR ALL ENTRIES IN lt_sbook
       WHERE id EQ lt_sbook-customid.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_PROCESSA_DADOS
*&---------------------------------------------------------------------*
FORM zf_processa_dados .

  TYPES: BEGIN OF ty_nac,
           carrid   TYPE scarr-carrid,
           connid   TYPE sflight-connid,
           fldate   TYPE sflight-fldate,
           customid TYPE sbook-customid,
           country  TYPE scustom-country,
         END OF ty_nac.

  DATA: ls_sflight LIKE LINE OF gt_sflight,
        ls_saida   LIKE LINE OF gt_saida,
        ls_scarr   LIKE LINE OF gt_scarr.

  DATA: lt_nac  TYPE TABLE OF ty_nac.

  SORT: gt_scarr BY carrid,
        gt_sbook BY carrid connid fldate,
        gt_scustom BY id.

  LOOP AT gt_sflight INTO ls_sflight.
    CLEAR: ls_saida.

    ls_saida-fldate = ls_sflight-fldate.

    READ TABLE gt_scarr WITH KEY carrid = ls_sflight-carrid
                        BINARY SEARCH
                        INTO ls_scarr.
    ls_saida-carrname = ls_scarr-carrname.

    CLEAR: lt_nac.
    READ TABLE gt_sbook WITH KEY carrid = ls_sflight-carrid
                                 connid = ls_sflight-connid
                                 fldate = ls_sflight-fldate
                        BINARY SEARCH
                        TRANSPORTING NO FIELDS.
    CHECK sy-subrc IS INITIAL.
    LOOP AT gt_sbook FROM sy-tabix ASSIGNING FIELD-SYMBOL(<fs_sbook>).
      IF <fs_sbook>-carrid NE ls_sflight-carrid
      OR <fs_sbook>-connid NE ls_sflight-connid
      OR <fs_sbook>-fldate NE ls_sflight-fldate.
        EXIT.
      ENDIF.

      "ls_saida-peso = ls_saida-peso + sbook-luggweight.
      ADD <fs_sbook>-luggweight TO ls_saida-peso.

      ADD 1 TO ls_saida-qtd_pasg.

      READ TABLE gt_scustom WITH KEY id = <fs_sbook>-customid
                            ASSIGNING FIELD-SYMBOL(<fs_scustom>)
                            BINARY SEARCH.

      APPEND INITIAL LINE TO lt_nac ASSIGNING FIELD-SYMBOL(<fs_nac>).
      <fs_nac>-carrid   = <fs_sbook>-carrid.
      <fs_nac>-connid   = <fs_sbook>-connid.
      <fs_nac>-fldate   = <fs_sbook>-fldate.
      <fs_nac>-customid = <fs_sbook>-customid.
      <fs_nac>-country  = <fs_scustom>-country.
    ENDLOOP.

    SORT lt_nac BY country.
    DELETE ADJACENT DUPLICATES FROM lt_nac COMPARING country.

    ls_saida-qtd_nac = lines( lt_nac ).

    APPEND ls_saida TO gt_saida.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZF_SAIDA
*&---------------------------------------------------------------------*
FORM zf_saida .

ENDFORM.
