# ***************************************************************************************
#
#            Addition to RUSMARC (RUSSIAN UNIMARC FOR BIBLIOGRAPHIC RECORDS)
#
#           Дополнение к структуре Koha РУСМАРК ДЛЯ БИБЛИОГРАФИЧЕСКИХ ЗАПИСЕЙ
#
# Based on local fields 099,942,952 (items),999 and subfields 9 (in any fields)
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
 ('', '', '012', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '013', '9', 0, 0, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '015', '9', 0, 0, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '016', '9', 0, 1, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '017', '9', 0, 1, 'Тираж', 'Тираж',                           0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '020', '9', 0, 0, 'Основное заглавие издания Российской книжной палаты', 'Основное заглавие издания Российской книжной палаты', 0, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '021', '9', 0, 0, 'Номер Листа государственной регистрации', 'Номер Листа государственной регистрации', 0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '099', '', '', 'Informations locales (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '099', 'c', 0, 0, 'Date creation notice (Koha)', '',          -1, NULL, 'biblio.datecreated', '', '', NULL, NULL, NULL, NULL),
 ('', '', '099', 'd', 0, 0, 'Date modification notice (Koha)', '',      -1, NULL, 'biblio.timestamp', '', '', NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '105', '9', 0, 0, 'Код ступени высшего профессионального образования', 'Код ступени высшего профессионального образования', 1, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '141', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 1, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '316', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '317', '9', 0, 0, 'Инвентарный номер ', 'Инвентарный номер ', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '318', '9', 0, 0, 'Инвентарный номер экземпляра ', 'Инвентарный номер экземпляра ', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '345', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 3, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 6, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '601', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 6, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '606', '9', 0, 0, 'Внутрішній код Koha', 'Внутрішній код Koha', 6, 1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '607', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 6, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '608', '9', 0, 0, 'Инвентарный номер экземпляра', 'Инвентарный номер экземпляра', 6, -1, '', '', '', 0, NULL, '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '', 7009, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '701', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '', 7019, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '702', '9', 0, 0, 'Внутренний код Koha', '',                  -1, 1, '', '', '', 0, '', 7029, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '790', '9', 0, 1, 'Дополнительное подполе связи', 'Дополнительное подполе связи', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '942', '', '', 'Дополнительные данные (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '942', '0', 0, 0, 'Koha issues (borrowed), all copies', '',   9, -5, 'biblioitems.totalissues', '', '', 0, '', '', NULL),
 ('', '', '942', '2', 0, 0, 'Код системы классификации для розстановки фонда', '', 9, 0, 'biblioitems.cn_source', '', '', 0, '', '', NULL),
 ('', '', '942', '6', 0, 0, 'Нормализованная классификация Коха для сортировки', '', -1, 7, 'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '942', 'a', 0, 0, 'Тип единицы [ЗАСТАРІЛЕ]', '',              9, -5, '', '', '', 0, '', '', NULL),
 ('', '', '942', 'b', 0, 0, 'Код структуры записи Коха', '',            9, -5, 'biblio.frameworkcode', '', '', 0, '', '', NULL),
 ('', '', '942', 'c', 1, 0, 'Тип единицы (уровень записи)', '',         9, 0, 'biblioitems.itemtype', 'itemtypes', '', 0, '', '', NULL),
 ('', '', '942', 'e', 0, 0, 'Издание /часть шифра/', '',                9, 0, NULL, '', '', 0, '', '', NULL),
 ('', '', '942', 'h', 0, 0, 'Классификационная часть шифра хранения', '', 9, 0, 'biblioitems.cn_class', '', '', 0, '', '', NULL),
 ('', '', '942', 'i', 0, 1, 'Экземплярная часть шифра хранения', '',    9, 9, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'j', 0, 0, 'Шифр хранения (полностью)', 'Шифр заказа', 9, -5, '', '', '', 0, '', '', NULL),
 ('', '', '942', 'k', 0, 0, 'Префикс шифра хранения', '',               9, 0, 'biblioitems.cn_prefix', '', '', 0, '', '', NULL),
 ('', '', '942', 'm', 0, 0, 'Суффикс шифра хранения', '',               9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('', '', '942', 'n', 0, 0, 'Статус сокрытия в ЭК', '',                 9, 0, '', 'SUPPRESS', '', 0, '', '', NULL),
 ('', '', '942', 's', 0, 0, 'Serial record flag', 'Serial record',      9, -5, 'biblio.serial', '', '', 0, '', '', NULL),
 ('', '', '942', 't', 0, 0, 'Номер комплекта/экземпляра', '',           9, -5, 'biblioitems.cn_item', '', '', 0, '', '', NULL),
 ('', '', '942', 'v', 0, 0, 'Авторский (кеттеровский) знак, даты или срок, которые прилагаются к классификационному индексу', '', 9, -5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '952', '', '', 'Данные о экземплярах и расположение (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '952', '0', 0, 0, 'Статус изъятия', '',                       10, 0, 'items.withdrawn', 'WITHDRAWN', '', 0, '', '', NULL),
 ('', '', '952', '1', 0, 0, 'Статус доступности', '',                   10, 0, 'items.itemlost', 'LOST', '', 0, '', '', NULL),
 ('', '', '952', '2', 0, 0, 'Источник классификации или схема полочного расположения', '', 10, 0, 'items.cn_source', 'cn_source', '', NULL, '', '', NULL),
 ('', '', '952', '3', 0, 0, 'Идентификация описываемого материала (объединенный том или иная часть)', '', 10, -1, 'items.materials', '', '', NULL, '', '', NULL),
 ('', '', '952', '4', 0, 0, 'Состояние повреждения', '',                10, 0, 'items.damaged', 'DAMAGED', '', NULL, '', '', NULL),
 ('', '', '952', '5', 0, 0, 'Статус ограничения доступа', '',           10, 0, 'items.restricted', 'RESTRICTED', '', 0, '', '', NULL),
 ('', '', '952', '6', 0, 0, 'Нормализованная классификация Коха для сортировки', '', -1, 7, 'items.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '952', '7', 0, 0, 'Не для заёма', '',                         10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('', '', '952', '8', 0, 0, 'Коллекция', '',                            10, 0, 'items.ccode', 'CCODE', '', 0, '', '', NULL),
 ('', '', '952', '9', 0, 0, 'Внутренний № экземпляра в Koha (items.itemnumber)', '', -1, 0, 'items.itemnumber', '', '', 0, '', '', NULL),
 ('', '', '952', 'a', 0, 0, 'Постоянное место хранения', '',            10, 0, 'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'b', 0, 0, 'Текущее место хранения', '',               10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'c', 0, 0, 'Общее расположение полки', '',             10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('', '', '952', 'd', 0, 0, 'Дата получения', '',                       10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', 0, '', '', NULL),
 ('', '', '952', 'e', 0, 0, 'Источник поступления', '',                 10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('', '', '952', 'f', 0, 0, 'Кодированный определитель местоположения', '', 10, 0, 'items.coded_location_qualifier', '', '', NULL, '', '', NULL),
 ('', '', '952', 'g', 0, 0, 'Стоимость, обычная закупочная цена', '',   10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('', '', '952', 'h', 0, 0, 'Serial Enumeration / chronology', 'Serial Enumeration / chronology', 10, 0, 'items.enumchron', '', '', 0, '', '', NULL),
 ('', '', '952', 'i', 0, 0, 'Инвентарный номер', '',                    10, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '952', 'j', 0, 0, 'Полочный контрольный номер', '',           10, -1, 'items.stack', 'STACK', '', NULL, '', '', NULL),
 ('', '', '952', 'k', 0, 0, 'Дата последнего редактирования экземпляра', '', 10, -1, 'items.timestamp', '', '', NULL, '', '', NULL),
 ('', '', '952', 'l', 0, 0, 'Выдач в целом', '',                        10, -5, 'items.issues', '', '', NULL, '', '', NULL),
 ('', '', '952', 'm', 0, 0, 'Продлено в целом', '',                     10, -5, 'items.renewals', '', '', NULL, '', '', NULL),
 ('', '', '952', 'n', 0, 0, 'Всего резервирований', '',                 10, -5, 'items.reserves', '', '', NULL, '', '', NULL),
 ('', '', '952', 'o', 0, 0, 'Полный (экземплярный) шифр хранения', '',  10, 0, 'items.itemcallnumber', '', NULL, 0, '', '', NULL),
 ('', '', '952', 'p', 0, 0, 'Штрих-код', '',                            10, 0, 'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('', '', '952', 'q', 0, 0, 'Выдано (дата)', '',                        10, -5, 'items.onloan', '', '', NULL, '', '', NULL),
 ('', '', '952', 'r', 0, 0, 'Дата, когда последний раз видели экземпляр', '', 10, -5, 'items.datelastseen', '', '', NULL, '', '', NULL),
 ('', '', '952', 's', 0, 0, 'Дата последнего заёма', '',                10, -5, 'items.datelastborrowed', '', '', NULL, '', '', NULL),
 ('', '', '952', 't', 0, 0, 'Порядковый номер комплекта/экземпляра', '', 10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('', '', '952', 'u', 0, 0, 'Уніфікований ідентифікатор ресурсів', '',  10, 0, 'items.uri', '', '', 1, '', '', NULL),
 ('', '', '952', 'v', 0, 0, 'Стоимость, цена замены', '',               10, 0, 'items.replacementprice', '', '', 0, '', '', NULL),
 ('', '', '952', 'w', 0, 0, 'Дата, для которой действительна цена', '', 10, 0, 'items.replacementpricedate', '', '', 0, '', '', NULL),
 ('', '', '952', 'x', 0, 1, 'Служебное примечание (lost item payment)', '', 10, 7, 'items.paidfor', '', '', NULL, '', '', NULL),
 ('', '', '952', 'y', 0, 0, 'Тип единицы (уровень экземпляра)', '',     10, 0, 'items.itype', 'itemtypes', '', NULL, '', '', NULL),
 ('', '', '952', 'z', 0, 0, 'Общедоступное примечание', '',             10, 0, 'items.itemnotes', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '999', '', '', 'Внутренние контрольные номера (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '999', '9', 0, 0, 'Внутренний № в Koha (biblio.biblionumber)', '', -1, -5, 'biblio.biblionumber', '', '', 0, '', '', NULL),
 ('', '', '999', 'a', 0, 0, 'Внутренний № библиотечной записи  в Koha (biblioitems.biblioitemnumber)', '', -1, -5, 'biblioitems.biblioitemnumber', '', '', 0, '', '', NULL);
