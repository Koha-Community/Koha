# ***************************************************************************************
#
#            Addition to RUSMARC (RUSSIAN UNIMARC FOR BIBLIOGRAPHIC RECORDS)
#
#           Дополнение к структуре Koha РУСМАРК ДЛЯ БИБЛИОГРАФИЧЕСКИХ ЗАПИСЕЙ
#
# Based on local fields 090,099,942,995 (items) and subfields 9 (in any fields)
#
# version 0.1 (5.1.2011) - first extract only local and koha specific fileds/subfields
#
# Serhij Dubyk (Сергей Дубик), serhijdubyk@gmail.com, 2011
#
# ***************************************************************************************

# *****************************************************************
#                  ПОЛЯ/ПІДПОЛЯ КОХА ТА ЛОКАЛЬНІ
#             LOCAL AND KOHA SPECIFIC FIELDS/SUBFIELDS
# *****************************************************************

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '010', '9', 0, 0, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '011', '9', 0, 1, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '012', '9', 0, 0, 'Инвентарный номер экземпляра', '',         0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '013', '9', 0, 0, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '015', '9', 0, 0, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '016', '9', 0, 1, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '017', '9', 0, 1, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '020', '9', 0, 0, 'Основное заглавие издания Российской книжной палаты', '', 0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '021', '9', 0, 0, 'Номер Листа государственной регистрации', '', 0, -1, '', '', '', 0, NULL, '', '');

# 090 used in:
# record.abs: melm 090$9      Local-number,Local-number:n
# UNIMARCslim2OPACDetail.xsl: <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
#                             other 3 lines
# UNIMARCslim2OPACResults.xsl: <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '090', '', '', 'Внутренние контрольные номера (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '090', '9', 0, 0, 'Внутренний № биб-записи (biblio.biblionumber)',              '',-1,-5,'biblio.biblionumber',         '', '', 0, '', '', NULL),
 ('', '', '090', 'a', 0, 0, 'Внутренний № биб-экземп-записи (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);

# 099 used in:
# record.abs: melm 099$c      date-entered-on-file:s,date-entered-on-file:n,date-entered-on-file:y,Date-of-acquisition,Date-of-acquisition:d,Date-of-acquisition:s
#             melm 099$d      Date/time-last-modified:s,Date/time-last-modified:n,Date/time-last-modified:y
#             melm 099$t      ccode:w
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '099', '', '', 'Локальные данные (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '099', 'c', 0, 0, 'Дата создания биб-записи (в Koha)', '',   -1, NULL, 'biblio.datecreated', '', '', NULL, NULL, NULL, NULL),
 ('', '', '099', 'd', 0, 0, 'Дата последнего редактирования биб-записи (в Koha)', '', -1, NULL, 'biblio.timestamp', '', '', NULL, NULL, NULL, NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '105', '9', 0, 0, 'Код ступени высшего профессионального образования', '', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '141', '9', 0, 0, 'Инвентарный номер экземпляра', '', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '316', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '317', '9', 0, 0, 'Инвентарный номер ', 'Инвентарный номер ', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '318', '9', 0, 0, 'Инвентарный номер экземпляра ', 'Инвентарный номер экземпляра ', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '345', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '410', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '454', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '461', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '464', '9', 0, 0, 'Внутренний код Koha', '',                   1, 1, '', '', '', 0, '', '001@', NULL);

# useds in:
# record.abs: Authorities Title
#             melm 500$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 501$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 503$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 510$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 512$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 513$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 514$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 515$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 516$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 517$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 518$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 519$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 520$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 530$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 531$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 532$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 540$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 541$9    Koha-Auth-Number,Koha-Auth-Number:n
#             melm 545$9    Koha-Auth-Number,Koha-Auth-Number:n
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '500', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '501', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '510', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '512', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '513', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '514', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '515', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '516', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '517', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '518', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '519', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '520', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '530', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '531', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '532', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '540', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '541', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '545', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);

# used in:
# UNIMARCslimUtils.xsl: <xsl:when test="marc:subfield[@code=9]"> <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
# record.abs: SUBJECTS (6xx) ##################
#             melm 600$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 601$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 602$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 603$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 604$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 605$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 606$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 607$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 610$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 630$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 631$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 632$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 633$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 634$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 635$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 636$9      Koha-Auth-Number,Koha-Auth-Number:n
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '601', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, 0, '', '', '', 0, '\'6019\',\'6069\'', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '602', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '603', '9', 0, 0, 'Внутренний код Koha', '',                  -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '604', '9', 0, 0, 'Внутренний код Koha', '',                  -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '605', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '606', '9', 0, 0, 'Инвентарный номер экземпляра (внутренний код Коха)', '', -1, 1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '607', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, 0, '', '', '', 0, '', 6079, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '608', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '610', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '615', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '630', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '631', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '632', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '633', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '634', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '635', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '636', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '686', '9', 0, 0, 'Инвентарный номер экземпляра', '',         -1, 0, '', '', '', 0, '', '', NULL);

# used in:
# UNIMARCslimUtils.xsl: <xsl:when test="marc:subfield[@code=9]"> <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
# record.abs: melm 700$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 701$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 702$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 710$9        Koha-Auth-Number,Koha-Auth-Number:n
#             melm 711$9        Koha-Auth-Number,Koha-Auth-Number:n
#             melm 712$9        Koha-Auth-Number,Koha-Auth-Number:n
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '\'7019\',\'7029\'', 7009, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '701', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '', 7019, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '702', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '', 7029, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '710', '9', 0, 0, 'Внутренний код Koha', '',                   -1, -1, '', '', '', 0, '', 7109, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '711', '9', 0, 0, 'Внутренний код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '712', '9', 0, 0, 'Внутренний код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '790', '9', 0, 1, 'Дополнительное подполе связи', '',          -1, 0, '', '', '', 0, NULL, '', '');


# added 942^z for old system bib-numbers
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '942', '', '', 'Дополнительные данные (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '942', '0', 0, 0, 'Количество выдач для всех экземпляров', '', 9, -5,'biblioitems.totalissues', '', '', 0, '', '', NULL),
 ('', '', '942', '2', 0, 0, 'Код системы классификации для розстановки фонда','',9,0, 'biblioitems.cn_source', '', '', 0, '', '', NULL),
 ('', '', '942', '6', 0, 0, 'Нормализованная классификация Коха для сортировки','',-1,7,'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '942', 'b', 0, 0, 'Код структуры записи Коха', '',             9, -5,'biblio.frameworkcode', '', '', 0, '', '', NULL),
 ('', '', '942', 'c', 1, 0, 'Тип единицы (уровень записи)', '',          9, 0, 'biblioitems.itemtype', 'itemtypes', '', 0, '', '', NULL),
 ('', '', '942', 'h', 0, 0, 'Классификационная часть шифра хранения','', 9, 0, 'biblioitems.cn_class', '', '', 0, '', '', NULL),
 ('', '', '942', 'i', 0, 1, 'Экземплярная часть шифра хранения',     '', 9, 9, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'j', 0, 0, 'Шифр хранения (полностью)', 'Шифр заказа',  9,-5,'', '', '', 0, '', '', NULL),
 ('', '', '942', 'm', 0, 0, 'Суффикс шифра хранения', '',                9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('', '', '942', 'n', 0, 0, 'Статус сокрытия в ЭК', '',                  9, 0, '', 'SUPPRESS', '', 0, '', '', NULL),
 ('', '', '942', 's', 0, 0, 'Отметка о записи сериального издания','Запись сериального издания',9,-5,'biblio.serial','', '', 0, '', '', NULL),
 ('', '', '942', 't', 0, 0, 'Номер комплекта/экземпляра', '',            9, -5,'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'v', 0, 0, 'Авторский (кеттеровский) знак, даты или срок, которые прилагаются к классификационному индексу', '', 9, -5, '', '', '', 0, '', '', NULL),
 ('', '', '942', 'z', 0, 0, 'Внутренний № биб-записи в старой системе', '',9,4, '', '', '', 0, '', '', NULL);
 ('', '', '942', 'e', 0, 0, 'Издание /часть шифра/ (?)', '',            9, 0, NULL, '', '', 0, '', '', NULL),
#  ('', '', '942', 'k', 0, 0, 'Префикс шифра хранения (?)', '',           9, 0, 'biblioitems.cn_prefix', '', '', 0, '', '', NULL),
#****************** biblioitems.COLUMNS and it connect to 942,090
# biblioitemnumber			090^a		Внутренний № биб-экземп-записи  (biblioitems.biblioitemnumber)
# biblionumber
# volume
# number
# itemtype						942^c		Тип единицы (уровень записи)
# isbn
# issn
# publicationyear
# publishercode
# volumedate
# volumedesc
# collectiontitle
# collectionissn
# collectionvolume
# editionstatement
# editionresponsibility
# timestamp
# illus
# pages
# notes
# size
# place
# lccn
# marc
# url
# cn_source						942^2		Код системы классификации для расстановки фонда
# cn_class						942^h		Классификационная часть шифра хранения
# cn_item						942^i		Экземплярная часть шифра хранения
# cn_suffix						942^m		Суффикс шифра хранения
# cn_sort						942^6		Нормализованная классификация Коха сортировки
# totalissues					942^0		Количество выдач для всех экземпляров
# marcxml
#*************************************************
#**** some connected to biblio.COLUMNS
# frameworkcode				942^b		Код структуры записи Коха
# serial							942^s		Отметка о записи сериального издания: Запись сериального издания
#*************************************************


#****************************** ITEMS - 995 *******************************
#
# Recommandation 995 is designed for interlibrary loan.  It is not designed
# for holdings even if libraries have used it for holdings.
# Adapted from:
# Recommandation 995 sur la fourniture de données locales dans les
# échanges de notices bibliographiques en UNIMARC accompagnant le prêt
# ou le dépôt de’xemplaires / ABF (Association des bibliothécaires
# français) ; FULBI (Fédération des utilisateurs de logiciels de
# bibliothèque) ; ADBDP (Association des directeurs de bibliothèques
# départementales de prêt) ; ADBGV (Association des directeurs de
# bibliothèques municipales et intercommunales des grandes villes de
# France) ADDNB (Association pour le développement des documents
# numériques en bibliothèque.
# 995 used in:
# record.abs: melm 995$r      itemtype:w,itype:w
#             melm 995$2		lost,lost:n,item
#             melm 995$a		homebranch,Host-item,item
#             melm 995$b		homebranch,Host-item,item
#             melm 995$c		holdingbranch,Record-Source,item
#             melm 995$d		holdingbranch,Record-Source,item
#             melm 995$e      location,item
#             melm 995$f		barcode,item
#             melm 995$h		ccode,item
#             melm 995$j      LC-card-number:s,item
#             melm 995$k      Call-Number,Local-Classification,lcn,Call-Number:p,Local-Classification:p,lcn:p,item
#             melm 995$n      onloan:d,onloan:n,onloan:s,onloan:w,item
#             melm 995$s      popularity:n,popularity:s,item
#             melm 995$u      Note,Note:p,item
#             melm  995       item   # just to index every subfield
# added 995^z for old system item-numbers
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '995', '', '', 'Данные о экземплярах и расположение (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '995', '0', 0, 0, 'Статус изъятия', '',                       10, 0, 'items.withdrawn',  'WITHDRAWN',   '', 0, '', '', NULL),
 ('', '', '995', '1', 0, 0, 'Статус повреждения', '',                   10, 0, 'items.damaged',   'DAMAGED',    '', 0, '', '', NULL),
 ('', '', '995', '2', 0, 0, 'Статус потери/отсутствия', '',             10, 0, 'items.itemlost',  'LOST',       '', 0, '', '', NULL),
 ('', '', '995', '3', 0, 0, 'Статус ограничения доступа', '',           10, 0, 'items.restricted','RESTRICTED', '', 0, '', '', NULL),
 ('', '', '995', '4', 0, 0, 'Источник классификации или схема полочного расположения','',10,0,'items.cn_source','cn_source', '', NULL, '', '', NULL),
 ('', '', '995', '5', 0, 0, 'Дата поступления', '',                     10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', NULL, '', '', NULL),
 ('', '', '995', '6', 0, 0, 'Порядковый номер комплекта/экземпляра', '',10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('', '', '995', '7', 0, 0, 'Унифицированный идентификатор ресурсов','',10, 0, 'items.uri', '', '', 0, '', '', NULL),
 ('', '', '995', '9', 0, 0, 'Внутренний № экземпляра в Koha (items.itemnumber)','',-1,-5,'items.itemnumber', '', '', 0, '', '', NULL),
 ('', '', '995', 'a', 0, 0, 'Исходное место хранения экземпляра (домашнее подразделение), текст','',   10, 0, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'b', 0, 0, 'Исходное место хранения экземпляра (домашнее подразделение), код','',     10, -1,'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('', '', '995', 'c', 1, 0, 'Место временного хранения или выдачи (подразделение хранения), код','',  10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('', '', '995', 'd', 0, 0, 'Место временного хранения или выдачи (подразделение хранения), текст','',10, -1,'', '', '', 0, '', '', NULL),
 ('', '', '995', 'e', 0, 0, 'Полочное расположение', '',                10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('', '', '995', 'f', 0, 0, 'Штрих-код', '',                            10, 0, 'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('', '', '995', 'g', 0, 0, 'Дата последнего редактирования экземпляра','',10, -1, 'items.timestamp', '', '', NULL, '', '', NULL),
 ('', '', '995', 'h', 0, 0, 'Вид собрания', '',                         10, 0, 'items.ccode', 'CCODE', '', 0, NULL, '', ''),
 ('', '', '995', 'i', 0, 0, 'Дата, когда последний раз видели экземпляр','',10,-5,'items.datelastseen', '', '', NULL, '', '', NULL),
 ('', '', '995', 'j', 0, 0, 'Инвентарный номер', '',                    10, 0, 'items.stocknumber ', '', '', 0, '', '', NULL),
 ('', '', '995', 'k', 0, 0, 'Полный (экземплярный) шифр хранения','',   10, 0, 'items.itemcallnumber', '', '', 0, '', '', NULL),
 ('', '', '995', 'l', 0, 0, 'Нумерация (объединенный том или иная часть)','',10,0,'items.materials', '', '', 0, '', '', NULL),
 ('', '', '995', 'm', 0, 0, 'Дата последней выдачи или возвращения','', 10,-5,'items.datelastborrowed', '', '', 0, '', '', NULL),
 ('', '', '995', 'n', 0, 0, 'Дата окончания срока выдачи','',           10, -1, 'items.onloan', '', '', 0, '', '', NULL),
 ('', '', '995', 'o', 0, 0, 'Тип оборота (не для выдачи)', '',          10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('', '', '995', 'p', 0, 0, 'Стоимость, обычная закупочная цена', '',   10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('', '', '995', 'r', 1, 0, 'Тип единицы (уровень экземпляра)','',      10, 0, 'items.itype','itemtypes', '', 0, '', '', NULL),
 ('', '', '995', 's', 0, 0, 'Источник поступления (поставщик)', '',     10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('', '', '995', 'u', 0, 0, 'Общедоступнее примечание о экземпляре', '',10,0, 'items.itemnotes', '', '', 0, '', '', NULL),
 ('', '', '995', 'v', 0, 0, 'Нумерация/хронология сериальных изданий','',10,-1,'items.enumchron', '', '', 0, '', '', NULL),
 ('', '', '995', 'x', 0, 1, 'Служебное (необщедоступное) примечание','',10, 4, '', '', '', NULL, '', '', NULL),
 ('', '', '995', 'z', 0, 0, 'Внутренний № экземпляра в старой системе','',10,4, '', '', '', NULL, '', '', NULL);
#******* free (not  used yet) subfields:
#--1		it:'Codice di sistema (classificazione specifica o altro schema e edizione)'
#--			pl:'Lost status', 'Lost status',               10, 0, 'items.itemlost', 'LOST'
#--4		it:'Classificazione normalizzata Koha per l\'ordinamento', '', -1, 7, 'items.cn_sort'
#--			pl:'Koha normalized classification for sorting', 'Koha normalized classification for sorting', -1, 7, 'items.cn_sort'
# 8		it: 'Collezione Koha', '',                      10, 0, 'items.ccode', 'CCODE'
#			pl: 'Koha collection', 'Koha collection',       10, 0, 'items.ccode', 'CCODE'
#-- g		fr:'code à barres, préfixe'
#--			it:'Prefisso del codice a barre'
#--			pl:'Barcode prefix'
#-- i		fr:'code à barres, suffixe'
#--			it:'Suffisso del codice a barre',
#--			pl:'Barcode suffix'
#--h		fr: 'code à barres, incrémentation'
#--			it:'Incremento del codice a barre'
#			pl:'Barcode incrementation'
#--p		fr:'Public', '',                               10, 0, '', 'public'
#--			pl:'Serial'
# q		it:'Pubblico destinato (età)'
#			pl:'Intended audience (age level)'
#			uk_old:'цільова публіка (за віком)'
#--s		fr:'élément de tri', '',                       -1, 0, 'items.itemlost'
#--			it:'Modalità d\'acquisto'
#			pl:'Acquisition mode'
# t		it:'Genere'
#			pl:'Genre'
# w		it:'Codice dell\'ente destinatario'
#			pl:'Recipient organisation code'
#-- x		it:'Ente destinatario, testo libero'
#--			pl:'Recipient organisation, free text'
# y		it:'Codice dell\'ente destinatario superiore'
#			pl:'Recipient parent organisation code'
#-- z		it:'Ente destinatario superiore, testo libero'
#--			pl:'Recipient parent organisation, free text'
#****************************************
#****** all items.COLUMNS and it connect to 995^subfields:
# itemnumber					995^9		внутренний № экземпляра   (items.itemnumber)
# biblionumber								внутренний biblionumber номер биб-записи
# biblioitemnumber						внутренний biblioitemnumber номер биб-записи
# barcode						995^f		штрих-код
# dateaccessioned				995^5		дата доступа
# booksellerid					995^s		источник поступления (поставщик)
# homebranch					995^b		исходное место хранения экземпляра (домашнее подразделение), код
# price							995^p		стоимость, обычная закупочная цена
# replacementprice						стоимость, цена замены
# replacementpricedate					дата, для которой действительна цена
# datelastborrowed			995^m		дата последней выдачи или возвращения
# datelastseen					995^i		дата, когда последний раз видено экземпляр
# stack										полочный контрольный номер
# notforloan					995^o		тип оборота (не для выдачи)
# damaged						995^1		статус повреждения
# itemlost						995^2		статус доступности
# withdrawn						995^0		статус изьятия
# itemcallnumber				995^k		полный (экземплярный) шифр хранения
# issues										выдач в целом
# renewals									продолжений в целом
# reserves									резервирований в целом
# restricted					995^3		статус ограничения доступа
# itemnotes						995^u		общедоступное примечание о экземпляре
# holdingbranch				995^с		место временного хранения или выдачи (подразделение хранения), код
# paidfor									платеж за утраченный экземпляр
# timestamp						995^g		дата последнего редактирования экземпляра
# location						995^e		текущее полочное расположение
# permanent_location						постоянное полочное расположение
# onloan							995^n		дата окончания срока выдачи
# cn_source						995^4		источник классификации или схема полочного расположения
# cn_sort									нормализована классификация Коха для сортировки
# ccode							995^h		вид собрания
# materials						995^l		нумерация (объединенный том или иная часть)
# uri								995^7		унифицированный идентификатор ресурсов
# itype							995^r		тип единицы (уровень экземпляра)
# more_subfields_xml						остальные подполя (для которых нет колонок items.*) в формате marcxml
# enumchron						995^v		нумерацию/хронология сериальных изданий
# copynumber					995^6		порядковый номер комплекта/экземпляра
# stocknumber					995^j		инвентарный номер
#********************************************************
# not used subfields from 952:
# INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
# ('', '', '952', '6', 0, 0, 'Нормализованная классификация Коха для сортировки','',-1 7,'items.cn_sort', '', '', 0, '', '', NULL),
# ('', '', '952', 'j', 0, 0, 'Полочный контрольный номер', '',           10, -1, 'items.stack', 'STACK', '', NULL, '', '', NULL),
#-- ('', '', '952', 'l', 0, 0, 'Выдач в целом', '',                      10, -5, 'items.issues', '', '', NULL, '', '', NULL),
#-- ('', '', '952', 'm', 0, 0, 'Продлено в целом', '',                   10, -5, 'items.renewals', '', '', NULL, '', '', NULL),
#-- ('', '', '952', 'n', 0, 0, 'Всего резервирований', '',               10, -5, 'items.reserves', '', '', NULL, '', '', NULL),
# ('', '', '952', 'v', 0, 0, 'Стоимость, цена замены', '',               10, 0,  'items.replacementprice', '', '', 0, '', '', NULL),
# ('', '', '952', 'w', 0, 0, 'Дата, для которой действительна цена', '', 10, 0,  'items.replacementpricedate', '', '', 0, '', '', NULL),
#***************************************************************************************************************************************

# moved to 090
-- INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
-- ('', '999', '', '', 'Внутренние контрольные номера (Koha)', '', '');
-- INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
-- ('', '', '999', '9', 0, 0, 'Внутренний № биб-записи в Koha (biblio.biblionumber)',              '',-1,-5,'biblio.biblionumber',         '', '', 0, '', '', NULL),
-- ('', '', '999', 'a', 0, 0, 'Внутренний № биб-экземпл-запису (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);
