# ***************************************************************************************
#                                  Electronic (EL)
#            Addition to UKRMARC (UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC RECORDS)
#                               Електронні видання (EL)
#            Доповнення до структури Koha УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# Based on local fields 090,099,942,995 (items) and subfields 9 (in any fields)
#
# version 0.1 (5.1.2011) - first extract only local and koha specific fileds/subfields
#
# Serhij Dubyk (Сергій Дубик), serhijdubyk@gmail.com, 2011
#
# ***************************************************************************************

# *****************************************************************
#                  ПОЛЯ/ПІДПОЛЯ КОХА ТА ЛОКАЛЬНІ
#             LOCAL AND KOHA SPECIFIC FIELDS/SUBFIELDS
# *****************************************************************

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '010', '9', 0, 1, 'Тираж', '',                                -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '011', '9', 0, 0, 'Тираж', '',                                -1, NULL, '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '020', '9', 0, 0, 'Основна назва видання Української/іншої національної книжкової палати', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

# 090 used in:
# record.abs: melm 090$9      Local-number,Local-number:n
# UNIMARCslim2OPACDetail.xsl: <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
#                             other 3 lines
# UNIMARCslim2OPACResults.xsl: <xsl:variable name="biblionumber" select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '090', '', '', 'Внутрішні контрольні номери (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '090', '9', 0, 0, 'Внутрішній № біб-запису (biblio.biblionumber)',              '',-1,-5,'biblio.biblionumber',         '', '', 0, '', '', NULL),
 ('EL', '', '090', 'a', 0, 0, 'Внутрішній № біб-прим-запису (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);

# 099 used in:
# record.abs: melm 099$c      date-entered-on-file:s,date-entered-on-file:n,date-entered-on-file:y,Date-of-acquisition,Date-of-acquisition:d,Date-of-acquisition:s
#             melm 099$d      Date/time-last-modified:s,Date/time-last-modified:n,Date/time-last-modified:y
#             melm 099$t      ccode:w
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '099', '', '', 'Локальні дані (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '099', 'c', 0, 0, 'Дата створення біб-запису (в Koha)', '',   -1, NULL, 'biblio.datecreated', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '099', 'd', 0, 0, 'Дата останнього редагування біб-запису (в Koha)', '', -1, NULL, 'biblio.timestamp', '', '', NULL, NULL, NULL, NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '410', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '454', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '461', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '464', '9', 0, 0, 'Внутрішній код Koha', '',                   1, 1, '', '', '', 0, '', '001@', NULL);

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
 ('EL', '', '500', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '501', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '510', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '512', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '513', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '514', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '515', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '516', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '517', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '518', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '519', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '520', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '530', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '531', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '532', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '540', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '541', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '545', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);

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
 ('EL', '', '600', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '601', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '\'6019\',\'6069\'', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '602', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '603', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '604', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '605', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '606', '9', 0, 0, 'Визначення локальної системи (внутрішній код Коха)', '', -1, 1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '607', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', 6079, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '608', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '610', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '615', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '630', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '631', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '632', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '633', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '634', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '635', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '636', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '686', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);

# used in:
# UNIMARCslimUtils.xsl: <xsl:when test="marc:subfield[@code=9]"> <xsl:attribute name="href">/cgi-bin/koha/opac-search.pl?q=an:<xsl:value-of select="marc:subfield[@code=9]"/></xsl:attribute>
# record.abs: melm 700$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 701$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 702$9      Koha-Auth-Number,Koha-Auth-Number:n
#             melm 710$9        Koha-Auth-Number,Koha-Auth-Number:n
#             melm 711$9        Koha-Auth-Number,Koha-Auth-Number:n
#             melm 712$9        Koha-Auth-Number,Koha-Auth-Number:n
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '700', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '\'7019\',\'7029\'', 7009, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '701', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7019, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '702', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7029, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '710', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', 7109, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '711', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '712', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);

# added 942^z for old system bib-numbers
INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '942', '', '', 'Додаткові дані (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '942', '0', 0, 0, 'Кількість видач (випожичань) для усіх примірників', '',    9, -5,'biblioitems.totalissues', '', '', 0, '', '', NULL),
 ('EL', '', '942', '2', 0, 0, 'Код системи класифікації для розстановки фонду','',9,0, 'biblioitems.cn_source', '', '', 0, '', '', NULL),
 ('EL', '', '942', '6', 0, 0, 'Нормалізована класифікація Коха для сортування','',-1,7,'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'b', 0, 0, 'Код структури запису Коха', '',             9, -5,'biblio.frameworkcode', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'c', 1, 0, 'Тип одиниці (рівень запису)', '',           9, 0, 'biblioitems.itemtype', 'itemtypes', '', 0, '', '', NULL),
 ('EL', '', '942', 'h', 0, 0, 'Класифікаційна частина шифру збереження','',9, 0, 'biblioitems.cn_class', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'i', 0, 1, 'Примірникова частина шифру збереження', '', 9, 9, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'j', 0, 0, 'Шифр зберігання (повністю)','Шифр замовлення',9,-5,'', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'm', 0, 0, 'Суфікс шифру зберігання', '',               9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'n', 0, 0, 'Статус приховування в ЕК', '',              9, 0, '', 'SUPPRESS', '', 0, '', '', NULL),
 ('EL', '', '942', 's', 0, 0, 'Позначка про запис серіального видання','Запис серіального видання',9,-5,'biblio.serial','', '', 0, '', '', NULL),
 ('EL', '', '942', 't', 0, 0, 'Номер комплекту/примірника', '',            9, -5,'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'v', 0, 0, 'Авторський (кеттерівський) знак, дати чи термін, що додаються до класифікаційного індексу', '', 9, -5, '', '', '', 0, '', '', NULL),
 ('EL', '', '942', 'z', 0, 0, 'Внутрішній № біб-запису в старій системі', '',9,4, '', '', '', 0, '', '', NULL);
# next 2 is obsoete (not found biblioitems.cn_edition, biblioitems.cn_prefix, CN_EDITION)
#  ('EL', '', '942', 'e', 0, 0, 'Видання /частина шифру/ (?)', '',            9, 0, 'biblioitems.cn_edition', 'CN_EDITION', '', 0, '', '', NULL),
#  ('EL', '', '942', 'k', 0, 0, 'Префікс шифру зберігання (?)', '',          9, 0, 'biblioitems.cn_prefix', '', '', 0, '', '', NULL),
#****************** biblioitems.COLUMNS and it connect to 942,090
# biblioitemnumber			090^a		Внутрішній № біб-прим-запису (biblioitems.biblioitemnumber)
# biblionumber
# volume
# number
# itemtype						942^c		Тип одиниці (рівень запису)
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
# cn_source						942^2		Код системи класифікації для розстановки фонду
# cn_class						942^h		Класифікаційна частина шифру збереження
# cn_item						942^i		Примірникова частина шифру збереження
# cn_suffix						942^m		Суфікс шифру зберігання
# cn_sort						942^6		Нормалізована класифікація Коха для сортування
# totalissues					942^0		Кількість видач (випожичань) для усіх примірників
# marcxml
#*************************************************
#**** some connected to biblio.COLUMNS
# frameworkcode				942^b		Код структури запису Коха
# serial							942^s		Позначка про запис серіального видання : Запис серіального видання
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
 ('EL', '995', '', '', 'Дані про примірники та розташування (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '995', '0', 0, 0, 'Статус вилучення', '',                     10, 0, 'items.withdrawn',  'WTHDRAWN',   '', 0, '', '', NULL),
 ('EL', '', '995', '1', 0, 0, 'Стан пошкодження', '',                     10, 0, 'items.damaged',   'DAMAGED',    '', 0, '', '', NULL),
 ('EL', '', '995', '2', 0, 0, 'Статус втрати/відсутності', '',            10, 0, 'items.itemlost',  'LOST',       '', 0, '', '', NULL),
 ('EL', '', '995', '3', 0, 0, 'Статус обмеження доступу', '',             10, 0, 'items.restricted','RESTRICTED', '', 0, '', '', NULL),
 ('EL', '', '995', '4', 0, 0, 'Джерело класифікації чи схема поличного розташування','',10,0,'items.cn_source','cn_source', '', NULL, '', '', NULL),
 ('EL', '', '995', '5', 0, 0, 'Дата надходження', '',                     10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', NULL, '', '', NULL),
 ('EL', '', '995', '6', 0, 0, 'Порядковий номер комплекту/примірника', '',10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('EL', '', '995', '7', 0, 0, 'Уніфікований ідентифікатор ресурсів', '',  10, 0, 'items.uri', '', '', 0, '', '', NULL),
 ('EL', '', '995', '9', 0, 0, 'Внутрішній № примірника (items.itemnumber)','',-1,-5,'items.itemnumber', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'a', 0, 0, 'Джерельне місце зберігання примірника (домашній підрозділ), текст','',   10, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'b', 0, 0, 'Джерельне місце зберігання примірника (домашній підрозділ), код','',     10, -1,'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('EL', '', '995', 'c', 1, 0, 'Місце тимчасового зберігання чи видачі (підрозділ зберігання), код','',  10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('EL', '', '995', 'd', 0, 0, 'Місце тимчасового зберігання чи видачі (підрозділ зберігання), текст','',10, -1,'', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'e', 0, 0, 'Поличкове розташування', '',               10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('EL', '', '995', 'f', 0, 0, 'Штрих-код', '',                            10, 0, 'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('EL', '', '995', 'g', 0, 0, 'Дата останнього редагування примірника','',10, -1, 'items.timestamp', '', '', NULL, '', '', NULL),
 ('EL', '', '995', 'h', 0, 0, 'Вид зібрання', '',                         10, 0, 'items.ccode', 'CCODE', '', 0, NULL, '', ''),
 ('EL', '', '995', 'i', 0, 0, 'Дата, коли останній раз бачено примірник','',10,-5,'items.datelastseen', '', '', NULL, '', '', NULL),
 ('EL', '', '995', 'j', 0, 0, 'Інвентарний номер', '',                    10, 0, 'items.stocknumber ', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'k', 0, 0, 'Повний (примірниковий) шифр збереження','',10, 0, 'items.itemcallnumber', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'l', 0, 0, 'Нумерація (об’єднаний том чи інша частина)','',10,0,'items.materials', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'm', 0, 0, 'Дата останнього випожичання чи повернення','', 10,-5,'items.datelastborrowed', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'n', 0, 0, 'Дата завершення терміну випожичання','',   10, -1, 'items.onloan', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'o', 0, 0, 'Тип обігу (не для випожичання)', '',       10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('EL', '', '995', 'p', 0, 0, 'Вартість, звичайна закупівельна ціна', '', 10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'r', 1, 0, 'Тип одиниці (рівень примірника)','',       10, 0, 'items.itype','itemtypes', '', 0, '', '', NULL),
 ('EL', '', '995', 's', 0, 0, 'Джерело надходження (постачальник)', '',   10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'u', 0, 0, 'Загальнодоступна примітка про примірник','', 10,0, 'items.itemnotes', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'v', 0, 0, 'Нумерування/хронологія серіальних видань','',10,-1,'items.enumchron', '', '', 0, '', '', NULL),
 ('EL', '', '995', 'x', 0, 1, 'Службова (незагальнодоступна) примітка', '', 10, 4, '', '', '', NULL, '', '', NULL),
 ('EL', '', '995', 'z', 0, 0, 'Внутрішній № примірника в старій системі','',10,4, '', '', '', NULL, '', '', NULL);
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
# itemnumber					995^9		внутрішній № примірника (items.itemnumber)
# biblionumber								внутрішній biblionumber номер біб-запису
# biblioitemnumber						внутрішній biblioitemnumber номер біб-запису
# barcode						995^f		штрих-код
# dateaccessioned				995^5		дата доступу
# booksellerid					995^s		джерело надходження (постачальник)
# homebranch					995^b		джерельне місце зберігання примірника (домашній підрозділ), код
# price							995^p		вартість, звичайна закупівельна ціна
# replacementprice						вартість, ціна заміни
# replacementpricedate					дата, для якої чинна ціна
# datelastborrowed			995^m		дата останнього випожичання чи повернення
# datelastseen					995^i		дата, коли останній раз бачено примірник
# stack										поличний контрольний номер
# notforloan					995^o		тип обігу (не для випожичання)
# damaged						995^1		стан пошкодження
# itemlost						995^2		статус доступності
# withdrawn						995^0		статус вилучення
# itemcallnumber				995^k		повний (примірниковий) шифр збереження
# issues										видач загалом
# renewals									продовжень загалом
# reserves									загалом резервувань
# restricted					995^3		статус обмеження доступу
# itemnotes						995^u		загальнодоступна примітка про примірник
# holdingbranch				995^с		місце тимчасового зберігання чи видачі (підрозділ зберігання), код
# paidfor									платіж за втрачений примірник
# timestamp						995^g		дата останнього редагування примірника
# location						995^e		поточне поличкове розташування
# permanent_location						постійне поличкове розташування
# onloan							995^n		дата завершення терміну випожичання
# cn_source						995^4		джерело класифікації чи схема поличного розташування
# cn_sort									нормалізована класифікація Коха для сортування
# ccode							995^h		вид зібрання
# materials						995^l		нумерація (об’єднаний том чи інша частина)
# uri								995^7		уніфікований ідентифікатор ресурсів
# itype							995^r		тип одиниці (рівень примірника)
# more_subfields_xml						решту підполів (для яких немає колонок items.*) у форматі marcxml
# enumchron						995^v		нумерування/хронологія серіальних видань
# copynumber					995^6		порядковий номер комплекту/примірника
# stocknumber					995^j		інвентарний номер
#********************************************************
# not used subfields from 952:
# INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
# ('EL', '', '952', '6', 0, 0, 'Нормалізована класифікація Коха для сортування','',-1 7,'items.cn_sort', '', '', 0, '', '', NULL),
# ('EL', '', '952', 'j', 0, 0, 'Поличний контрольний номер', '',           10, -1, 'items.stack', 'STACK', '', NULL, '', '', NULL),
#-- ('EL', '', '952', 'l', 0, 0, 'Видач загалом', '',                        10, -5, 'items.issues', '', '', NULL, '', '', NULL),
#-- ('EL', '', '952', 'm', 0, 0, 'Продовжень загалом', '',                   10, -5, 'items.renewals', '', '', NULL, '', '', NULL),
#-- ('EL', '', '952', 'n', 0, 0, 'Загалом резервувань', '',                  10, -5, 'items.reserves', '', '', NULL, '', '', NULL),
# ('EL', '', '952', 'v', 0, 0, 'Вартість, ціна заміни', '',                10, 0,  'items.replacementprice', '', '', 0, '', '', NULL),
# ('EL', '', '952', 'w', 0, 0, 'Дата, для якої чинна ціна', '',            10, 0,  'items.replacementpricedate', '', '', 0, '', '', NULL),
#***************************************************************************************************************************************

# moved to 090
-- INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
-- ('EL', '999', '', '', 'Внутрішні контрольні номери (Koha)', '', '');
-- INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
-- ('EL', '', '999', '9', 0, 0, 'Внутрішній № біб-запису (biblio.biblionumber)',              '',-1,-5,'biblio.biblionumber',         '', '', 0, '', '', NULL),
-- ('EL', '', '999', 'a', 0, 0, 'Внутрішній № біб-прим-запису (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);
