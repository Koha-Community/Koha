# ***************************************************************************************
#
#            Addition to UKRMARC (UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC RECORDS)
#
#            Доповнення до структури Koha УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# Based on local fields 099,942,952 (items),999 and subfields 9 (in any fields)
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
 ('', '', '010', '9', 0, 1, 'Тираж', '',                                -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '011', '9', 0, 0, 'Тираж', '',                                -1, NULL, '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '020', '9', 0, 0, 'Основна назва видання Української/іншої національної книжкової палати', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '099', '', '', 'Локальні дані (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '099', 'c', 0, 0, 'Дата створення біб-запису (в Koha)', '',   -1, NULL, 'biblio.datecreated', '', '', NULL, NULL, NULL, NULL),
 ('', '', '099', 'd', 0, 0, 'Дата останнього редагування біб-запису (в Koha)', '', -1, NULL, 'biblio.timestamp', '', '', NULL, NULL, NULL, NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '410', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', NULL, 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '454', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', NULL, 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '461', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '464', '9', 0, 0, 'Внутрішній код Koha', '',                   1, 1, '', '', '', 0, '', '001@', NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '500', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '601', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '602', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '604', '9', 0, 0, 'Внутрішній код Koha', '',                   2, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '605', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '606', '9', 0, 0, 'Визначення локальної системи (внутрішній код Коха)', '', 1, 1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '607', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '608', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '615', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '686', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7009, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '701', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7019, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '702', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7029, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '710', '9', 0, 0, 'Внутрішній код Koha', '',                   3, -1, '', '', '', 0, '', 7109, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '711', '9', 0, 0, 'Внутрішній код Koha', '',                   3, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '712', '9', 0, 0, 'Внутрішній код Koha', '',                   3, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '942', '', '', 'Додаткові дані (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '942', '0', 0, 0, 'Koha issues (borrowed), all copies', '',    9, -5,'biblioitems.totalissues', '', '', 0, '', '', NULL),
 ('', '', '942', '2', 0, 0, 'Код системи класифікації для розстановки фонду','',9,0, 'biblioitems.cn_source', '', '', 0, '', '', NULL),
 ('', '', '942', '6', 0, 0, 'Нормалізована класифікація Коха для сортування','',-1,7,'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '942', '@', 0, 0, 'Внутрішній № запису в старій системі', '',  9, 4, '', '', '', 0, '', '', NULL),
 ('', '', '942', 'a', 0, 0, 'Тип одиниці [ЗАСТАРІЛЕ]', '',               9, -5,'', '', '', 0, '', '', NULL),
 ('', '', '942', 'b', 0, 0, 'Код структури запису Коха', '',             9, -5,'biblio.frameworkcode', '', '', 0, '', '', NULL),
 ('', '', '942', 'c', 1, 0, 'Тип одиниці (рівень запису)', '',           9, 0, 'biblioitems.itemtype', 'itemtypes', '', 0, '', '', NULL),
 ('', '', '942', 'e', 0, 0, 'Видання /частина шифру/', '',               9, 0, NULL, '', '', 0, '', '', NULL),
 ('', '', '942', 'h', 0, 0, 'Класифікаційна частина шифру збереження','',9, 0, 'biblioitems.cn_class', '', '', 0, '', '', NULL),
 ('', '', '942', 'i', 0, 1, 'Примірникова частина шифру збереження', '', 9, 9, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'j', 0, 0, 'Шифр зберігання (повністю)','Шифр замовлення',9,-5,'', '', '', 0, '', '', NULL),
 ('', '', '942', 'k', 0, 0, 'Префікс шифру зберігання', '',              9, 0, 'biblioitems.cn_prefix', '', '', 0, '', '', NULL),
 ('', '', '942', 'm', 0, 0, 'Суфікс шифру зберігання', '',               9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('', '', '942', 'n', 0, 0, 'Статус приховування в ЕК', '',              9, 0, '', 'SUPPRESS', '', 0, '', '', NULL),
 ('', '', '942', 's', 0, 0, 'Serial record flag', 'Serial record',       9, -5,'biblio.serial', '', '', 0, '', '', NULL),
 ('', '', '942', 't', 0, 0, 'Номер комплекту/примірника', '',            9, -5,'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'v', 0, 0, 'Авторський (кеттерівський) знак, дати чи термін, що додаються до класифікаційного індексу', '', 9, -5, '', '', '', 0, '', '', NULL),
 ('', '', '942', 'æ', 0, 0, 'Внутрішній № запису в старій системі', '',  9, 4, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '952', '', '', 'Дані про примірники та розташування (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '952', '0', 0, 0, 'Статус вилучення', '',                     10, 0, 'items.withdrawn', 'WITHDRAWN', '', 0, '', '', NULL),
 ('', '', '952', '1', 0, 0, 'Статус доступності', '',                   10, 0, 'items.itemlost', 'LOST', '', 0, '', '', NULL),
 ('', '', '952', '2', 0, 0, 'Джерело класифікації чи схема поличного розташування', '', 10, 0, 'items.cn_source', 'cn_source', '', NULL, '', '', NULL),
 ('', '', '952', '3', 0, 0, 'Ідентифікація описуваного матеріалу (об’єднаний том чи інша частина)', '', 10, -1, 'items.materials', '', '', NULL, '', '', NULL),
 ('', '', '952', '4', 0, 0, 'Стан пошкодження', '',                     10, 0, 'items.damaged', 'DAMAGED', '', NULL, '', '', NULL),
 ('', '', '952', '5', 0, 0, 'Статус обмеження доступу', '',             10, 0, 'items.restricted', 'RESTRICTED', '', 0, '', '', NULL),
 ('', '', '952', '6', 0, 0, 'Нормалізована класифікація Коха для сортування','',-1 7,'items.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '952', '7', 0, 0, 'Не для випожичання', '',                   10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('', '', '952', '8', 0, 0, 'Зібрання', '',                             10, 0, 'items.ccode', 'CCODE', '', 0, '', '', NULL),
 ('', '', '952', '9', 0, 0, 'Внутрішній № примірника (items.itemnumber)','',-1,0,'items.itemnumber', '', '', 0, '', '', NULL),
 ('', '', '952', '@', 0, 0, 'Внутрішній № примірника в старій системі','',10,4, '', '', '', NULL, '', '', NULL),
 ('', '', '952', 'a', 0, 0, 'Постійне місце зберігання', '',            10, 0, 'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'b', 0, 0, 'Поточне місце зберігання', '',             10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'c', 0, 0, 'Загальне розташування полиці', '',         10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('', '', '952', 'd', 0, 0, 'Дата отримання', '',                       10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', 0, '', '', NULL),
 ('', '', '952', 'e', 0, 0, 'Джерело надходження', '',                  10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('', '', '952', 'f', 0, 0, 'Кодований визначник розташування', '',     10, 0, 'items.coded_location_qualifier', '', '', NULL, '', '', NULL),
 ('', '', '952', 'g', 0, 0, 'Вартість, звичайна закупівельна ціна', '', 10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('', '', '952', 'h', 0, 0, 'Нумерування/хронологія серіального видання', 'Serial Enumeration / chronology',10,0,'items.enumchron', '', '', 0, '', '', NULL),
 ('', '', '952', 'i', 0, 0, 'Інвентарний номер', '',                    10, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '952', 'j', 0, 0, 'Поличний контрольний номер', '',           10, -1, 'items.stack', 'STACK', '', NULL, '', '', NULL),
 ('', '', '952', 'k', 0, 0, 'Дата останнього редагування примірника','',10, -1, 'items.timestamp', '', '', NULL, '', '', NULL),
 ('', '', '952', 'l', 0, 0, 'Видач загалом', '',                        10, -5, 'items.issues', '', '', NULL, '', '', NULL),
 ('', '', '952', 'm', 0, 0, 'Продовжень загалом', '',                   10, -5, 'items.renewals', '', '', NULL, '', '', NULL),
 ('', '', '952', 'n', 0, 0, 'Загалом резервувань', '',                  10, -5, 'items.reserves', '', '', NULL, '', '', NULL),
 ('', '', '952', 'o', 0, 0, 'Повний (примірниковий) шифр збереження', '', 10, 0,'items.itemcallnumber', '', NULL, 0, '', '', NULL),
 ('', '', '952', 'p', 0, 0, 'Штрих-код', '',                            10, 0,  'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('', '', '952', 'q', 0, 0, 'Видано (дата)', '',                        10, -5, 'items.onloan', '', '', NULL, '', '', NULL),
 ('', '', '952', 'r', 0, 0, 'Дата, коли останній раз бачено примірник','',10,-5,'items.datelastseen', '', '', NULL, '', '', NULL),
 ('', '', '952', 's', 0, 0, 'Дата останнього випожичання', '',          10, -5, 'items.datelastborrowed', '', '', NULL, '', '', NULL),
 ('', '', '952', 't', 0, 0, 'Порядковий номер комплекту/примірника', '', 10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('', '', '952', 'u', 0, 0, 'Уніфікований ідентифікатор ресурсів', '',  10, 0,  'items.uri', '', '', 1, '', '', NULL),
 ('', '', '952', 'v', 0, 0, 'Вартість, ціна заміни', '',                10, 0,  'items.replacementprice', '', '', 0, '', '', NULL),
 ('', '', '952', 'w', 0, 0, 'Дата, для якої чинна ціна', '',            10, 0,  'items.replacementpricedate', '', '', 0, '', '', NULL),
 ('', '', '952', 'x', 0, 1, 'Службова примітка (lost item payment)', '', 10, 4, 'items.paidfor', '', '', NULL, '', '', NULL),
 ('', '', '952', 'y', 0, 0, 'Тип одиниці (рівень примірника)', '',      10, 0,  'items.itype', 'itemtypes', '', NULL, '', '', NULL),
 ('', '', '952', 'z', 0, 0, 'Загальнодоступна примітка', '',            10, 0,  'items.itemnotes', '', '', NULL, '', '', NULL),
 ('', '', '952', 'æ', 0, 0, 'Внутрішній № примірника в старій системі','',10,4, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '999', '', '', 'Внутрішні контрольні номери (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '999', '9', 0, 0, 'Внутрішній № біб-запису (biblio.biblionumber)',              '',-1,-5,'biblio.biblionumber',         '', '', 0, '', '', NULL),
 ('', '', '999', 'a', 0, 0, 'Внутрішній № біб-прим-запису (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);
