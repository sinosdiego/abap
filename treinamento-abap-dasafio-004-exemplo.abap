REPORT zrsb_desafio004.

TYPES: BEGIN OF ty_custom_agen,
         customid  TYPE sbook-customid,
         agencynum TYPE sbook-agencynum,
         cont      TYPE i,
       END OF ty_custom_agen.



DATA: lt_sbook     TYPE TABLE OF sbook,
      lt_custom    TYPE TABLE OF sbook,
      lt_sbook_aux TYPE TABLE OF sbook,
      lt_cust_agen TYPE TABLE OF ty_custom_agen.

SELECT * FROM sbook
  INTO TABLE lt_sbook
 WHERE customid = '936'.

SORT lt_sbook by customid agencynum.

lt_custom = lt_sbook.
SORT lt_custom BY customid.
DELETE ADJACENT DUPLICATES FROM lt_custom COMPARING customid.

lt_sbook_aux = lt_sbook.
SORT lt_sbook_aux BY customid agencynum.
DELETE ADJACENT DUPLICATES FROM lt_sbook_aux COMPARING customid agencynum.

"Percorre os clientes
LOOP AT lt_custom ASSIGNING FIELD-SYMBOL(<fs_custom>).
  
  "Percorre os clientes x agencias (já unitárias
  READ TABLE lt_sbook_aux WITH KEY customid = <fs_custom>-customid
                          TRANSPORTING NO FIELDS BINARY SEARCH.
  LOOP AT lt_sbook_aux ASSIGNING FIELD-SYMBOL(<fs_agen>) FROM sy-tabix.
    IF <fs_agen>-customid NE <fs_custom>-customid.
      EXIT.
    ENDIF.
      
    "Adiciona cada cliente x agencia em uma tabela com estrutura particular
    APPEND INITIAL LINE TO lt_cust_agen ASSIGNING FIELD-SYMBOL(<fs_cust>).
    <fs_cust>-customid  = <fs_agen>-customid.
    <fs_cust>-agencynum = <fs_agen>-agencynum.

    "Percorre os dados do cliente x agencia para contabilizar
    READ TABLE lt_sbook WITH KEY customid = <fs_agen>-customid
                                 agencynum = <fs_agen>-agencynum
                            TRANSPORTING NO FIELDS BINARY SEARCH.
    LOOP AT lt_sbook FROM sy-tabix ASSIGNING FIELD-SYMBOL(<fs_sbook>).
      IF <fs_sbook>-customid  NE <fs_agen>-customid
      OR <fs_sbook>-agencynum NE <fs_agen>-agencynum.
        EXIT.
      ENDIF.

      ADD 1 TO <fs_cust>-cont.
    ENDLOOP.

  ENDLOOP.
  
  "Ordena do maior para o menor
  SORT lt_cust_agen by customid cont DESCENDING agencynum DESCENDING .

  "Pega o primeiro registro (que será o maior)
  READ TABLE lt_cust_agen index 1 ASSIGNING <fs_cust>.  
  
  "Exibe
  WRITE: / <fs_cust>-customid,
          <fs_cust>-agencynum,
          <fs_cust>-cont.  

ENDLOOP.



