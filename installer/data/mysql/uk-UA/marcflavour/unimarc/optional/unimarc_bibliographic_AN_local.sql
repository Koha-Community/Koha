# ***************************************************************************************
#                                Analitical (AN)
#            Addition to UKRMARC (UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC RECORDS)
#                            Аналітичні описи (AN)
#            Доповнення до структури Koha УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# Based on local fields 090,099,942,995 (items) and subfields 9 (in any fields)
#
# version 0.1 (5.1.2011) - first extract only local and koha specific fields/subfields
#
# Serhij Dubyk (Сергій Дубик), serhijdubyk@gmail.com, 2011-2017
#
# ***************************************************************************************

# *****************************************************************
#                  ПОЛЯ/ПІДПОЛЯ КОХА ТА ЛОКАЛЬНІ
#             LOCAL AND KOHA SPECIFIC FIELDS/SUBFIELDS
# *****************************************************************

SET FOREIGN_KEY_CHECKS=0;


INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '010', '9', 0, 1, 'Тираж', '',                                -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '011', '9', 0, 0, 'Тираж', '',                                -1, NULL, '', '', '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '020', '9', 0, 0, 'Основна назва видання Української/іншої національної книжкової палати', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '090', '', '', 'Внутрішні контрольні номери (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '090', 'a', 0, 0, 'Внутрішній № біб-прим-запису (biblioitems.biblioitemnumber)','',-1,-5,'biblioitems.biblioitemnumber','', '', 0, '', '', NULL);


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '099', '', '', 'Локальні дані (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '099', 'c', 0, 0, 'Дата створення біб-запису (в Koha)', '',   -1, NULL, 'biblio.datecreated', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '099', 'd', 0, 0, 'Дата останнього редагування біб-запису (в Koha)', '', -1, NULL, 'biblio.timestamp', '', '', NULL, NULL, NULL, NULL);


INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '410', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '454', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '461', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '001@', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '464', '9', 0, 0, 'Внутрішній код Koha', '',                   1, 1, '', '', '', 0, '', '001@', NULL);


INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '500', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '501', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '510', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '512', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '513', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '514', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '515', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '516', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '517', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '518', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '519', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '520', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '530', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '531', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '532', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '540', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '541', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '545', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 0, '', '', '', 0, '', '', NULL);


INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '600', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '601', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '\'6019\',\'6069\'', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '602', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '604', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '605', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '606', '9', 0, 0, 'Визначення локальної системи (внутрішній код Коха)', '', -1, 1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '607', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', 6079, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '608', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '610', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '615', '9', 0, 0, 'Визначення локальної системи', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '686', '9', 0, 0, 'Визначення локальної системи', '',         -1, 0, '', '', '', 0, '', '', NULL);


INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '700', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '\'7019\',\'7029\'', 7009, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '701', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7019, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '702', '9', 0, 0, 'Внутрішній код Koha', '',                  -1, 1, '', '', '', 0, '', 7029, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '710', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', 7109, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '711', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '712', '9', 0, 0, 'Внутрішній код Koha', '',                   -1, -1, '', '', '', 0, '', '', NULL);


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '942', '', '', 'Додаткові дані (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '942', '0', 0, 0, 'Кількість видач (випожичань) для усіх примірників', '',    9, -5,'biblioitems.totalissues', '', '', 0, '', '', NULL),
 ('AN', '', '942', '2', 0, 0, 'Код системи класифікації для розстановки фонду','',9,0, 'biblioitems.cn_source', '', '', 0, '', '', NULL),
 ('AN', '', '942', '6', 0, 0, 'Нормалізована класифікація Коха для сортування','',-1,7,'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'b', 0, 0, 'Код структури запису Коха', '',             9, -5,'biblio.frameworkcode', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'c', 1, 0, 'Тип одиниці (рівень запису)', '',           9, 0, 'biblioitems.itemtype', 'itemtypes', '', 0, '', '', NULL),
 ('AN', '', '942', 'h', 0, 0, 'Класифікаційна частина шифру збереження','',9, 0, 'biblioitems.cn_class', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'i', 0, 1, 'Примірникова частина шифру збереження', '', 9, 9, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'j', 0, 0, 'Шифр зберігання (повністю)','Шифр замовлення',9,-5,'', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'm', 0, 0, 'Суфікс шифру зберігання', '',               9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'n', 0, 0, 'Статус приховування в ЕК', '',              9, 0, '', 'SUPPRESS', '', 0, '', '', NULL),
 ('AN', '', '942', 's', 0, 0, 'Позначка про запис серіального видання','Запис серіального видання',9,-5,'biblio.serial','', '', 0, '', '', NULL),
 ('AN', '', '942', 't', 0, 0, 'Номер комплекту/примірника', '',            9, -5,'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'v', 0, 0, 'Авторський (кеттерівський) знак, дати чи термін, що додаються до класифікаційного індексу', '', 9, -5, '', '', '', 0, '', '', NULL),
 ('AN', '', '942', 'z', 0, 0, 'Внутрішній № біб-запису в старій системі', '',9,4, '', '', '', 0, '', '', NULL);


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '995', '', '1', 'Дані про примірники та розташування (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '995', '0', 0, 0, 'Статус вилучення', '',                     10, 0, 'items.withdrawn',  'WITHDRAWN',   '', 0, '', '', NULL),
 ('AN', '', '995', '1', 0, 0, 'Стан пошкодження', '',                     10, 0, 'items.damaged',   'DAMAGED',    '', 0, '', '', NULL),
 ('AN', '', '995', '2', 0, 0, 'Статус втрати/відсутності', '',            10, 0, 'items.itemlost',  'LOST',       '', 0, '', '', NULL),
 ('AN', '', '995', '3', 0, 0, 'Статус обмеження доступу', '',             10, 0, 'items.restricted','RESTRICTED', '', 0, '', '', NULL),
 ('AN', '', '995', '4', 0, 0, 'Джерело класифікації чи схема поличного розташування','',10,0,'items.cn_source','cn_source', '', NULL, '', '', NULL),
 ('AN', '', '995', '5', 0, 0, 'Дата надходження', '',                     10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', NULL, '', '', NULL),
 ('AN', '', '995', '6', 0, 0, 'Порядковий номер комплекту/примірника', '',10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('AN', '', '995', '7', 0, 0, 'Уніфікований ідентифікатор ресурсів', '',  10, 0, 'items.uri', '', '', 0, '', '', NULL),
 ('AN', '', '995', '9', 0, 0, 'Внутрішній № примірника (items.itemnumber)','',-1,-5,'items.itemnumber', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'a', 0, 0, 'Джерельне місце зберігання примірника (домашній підрозділ), текст','',   10, 0, '', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'b', 0, 0, 'Джерельне місце зберігання примірника (домашній підрозділ), код','',     10, -1,'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('AN', '', '995', 'c', 1, 0, 'Місце тимчасового зберігання чи видачі (підрозділ зберігання), код','',  10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('AN', '', '995', 'd', 0, 0, 'Місце тимчасового зберігання чи видачі (підрозділ зберігання), текст','',10, -1,'', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'e', 0, 0, 'Поличкове розташування', '',               10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('AN', '', '995', 'f', 0, 0, 'Штрих-код', '',                            10, 0, 'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('AN', '', '995', 'g', 0, 0, 'Дата останнього редагування примірника','',10, -1, 'items.timestamp', '', '', NULL, '', '', NULL),
 ('AN', '', '995', 'h', 0, 0, 'Вид зібрання', '',                         10, 0, 'items.ccode', 'CCODE', '', 0, NULL, '', ''),
 ('AN', '', '995', 'i', 0, 0, 'Дата, коли останній раз бачено примірник','',10,-5,'items.datelastseen', '', '', NULL, '', '', NULL),
 ('AN', '', '995', 'j', 0, 0, 'Інвентарний номер', '',                    10, 0, 'items.stocknumber', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'k', 0, 0, 'Повний (примірниковий) шифр збереження','',10, 0, 'items.itemcallnumber', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'l', 0, 0, 'Зазначення матеріалів (нумерація, частина …)','',10,0,'items.materials', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'm', 0, 0, 'Дата останнього випожичання чи повернення','', 10,-5,'items.datelastborrowed', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'n', 0, 0, 'Дата завершення терміну випожичання','',   10, -1, 'items.onloan', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'o', 0, 0, 'Тип обігу (не для випожичання)', '',       10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('AN', '', '995', 'p', 0, 0, 'Вартість, звичайна закупівельна ціна', '', 10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'r', 1, 0, 'Тип одиниці (рівень примірника)','',       10, 0, 'items.itype','itemtypes', '', 0, '', '', NULL),
 ('AN', '', '995', 's', 0, 0, 'Джерело надходження (постачальник)', '',   10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'u', 0, 0, 'Загальнодоступна примітка про примірник','', 10,0, 'items.itemnotes', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'v', 0, 0, 'Нумерування/хронологія серіальних видань','',10,-1,'items.enumchron', '', '', 0, '', '', NULL),
 ('AN', '', '995', 'x', 0, 1, 'Службова (незагальнодоступна) примітка', '', 10, 4, '', '', '', NULL, '', '', NULL),
 ('AN', '', '995', 'z', 0, 0, 'Внутрішній № примірника в старій системі','',10, 4, '', '', '', NULL, '', '', NULL);

SET FOREIGN_KEY_CHECKS=1;

