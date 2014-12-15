-- На основе MARC21-структуры на английском «Fast Add Frameworks»
-- Перевод/адаптация: Сергей Дубик, Ольга Баркова (2011)

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '090', '', 1, 'Шифры', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '090', 'a', 0, 0, 'Полочный индекс', '',                    0, 5, '', '', '', 0, '', '', NULL),
 ('FA', '', '090', 'b', 0, 0, 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 0, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '099', '', 1, 'Периодические издания', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '100', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                   1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '942', '', '', 'Дополнительные данные (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '942', '0', 0, 0, 'Количество выдач для всех экземпляров', '', 9, 5, 'biblioitems.totalissues', '', '', NULL, '', '', NULL),
 ('FA', '', '942', 'c', 1, 0, 'Тип единицы (уровень записи)', '',       9, 5, 'biblioitems.itemtype', 'itemtypes', '', NULL, '', '', NULL),
 ('FA', '', '942', 'n', 0, 0, 'Статус сокрытия в ЭК', '',               9, 5, NULL, '', '', 0, '', '', NULL),
 ('FA', '', '942', 's', 0, 0, 'Отметка о записи сериального издания', 'Запись сериального издания', 9, 5, 'biblio.serial', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '952', '', 1, 'Данные о экземплярах и расположение (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '952', '0', 0, 0, 'Статус изъятия', '',                     10, 0, 'items.withdrawn', 'WITHDRAWN', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '1', 0, 0, 'Статус потери/отсутствия', '',           10, 0, 'items.itemlost', 'LOST', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '2', 0, 0, 'Источник классификации или схема полочного расположения', '', 10, 0, 'items.cn_source', 'cn_source', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '3', 0, 0, 'Нумерация (объединенный том или иная часть)', '', 10, 0, 'items.materials', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '4', 0, 0, 'Статус повреждения', '',                 10, 0, 'items.damaged', 'DAMAGED', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '5', 0, 0, 'Статус ограничения доступа', '',         10, 0, 'items.restricted', 'RESTRICTED', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '6', 0, 0, 'Нормализованная классификация Коха для сортировки', '', 10, 0, 'items.cn_sort', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '7', 0, 0, 'Тип оборота (не для выдачи)', '',        10, 0, 'items.notforloan', 'NOT_LOAN', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '8', 0, 0, 'Вид собрания', '',                       10, 0, 'items.ccode', 'CCODE', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '9', 0, 0, 'Внутренний № экземпляра в Koha (items.itemnumber)', 'Внутренний № экземпляра в Koha', -1, 0, 'items.itemnumber', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'a', 0, 1, 'Исходное место хранения экземпляра (домашнее подразделение)', '', 10, 0, 'items.homebranch', 'branches', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'b', 0, 1, 'Место временного хранения или выдачи (подразделение хранения)', '', 10, 0, 'items.holdingbranch', 'branches', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'c', 0, 0, 'Полочное расположение', '',              10, 0, 'items.location', 'LOC', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'd', 0, 0, 'Дата поступления', '',                   10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', NULL, '', NULL, NULL),
 ('FA', '', '952', 'e', 0, 0, 'Источник поступления (поставщик)', '',   10, 0, 'items.booksellerid', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'f', 0, 0, 'Кодированный определитель местоположения', '', 10, 0, 'items.coded_location_qualifier', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'g', 0, 0, 'Стоимость, обычная закупочная цена', '', 10, 0, 'items.price', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'h', 0, 0, 'Нумерация/хронология сериальных изданий', '', 10, 0, 'items.enumchron', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'i', 0, 0, 'Инвентарный номер', '',                  10, 0, 'items.stocknumber', '', '', NULL, '', '', NULL),
 ('FA', '', '952', 'j', 0, 0, 'Полочный контрольный номер', '',         10, 0, 'items.stack', 'STACK', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'l', 0, 0, 'Выдач в целом', '',                      10, 0, 'items.issues', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'm', 0, 0, 'Продлено в целом', '',                   10, 0, 'items.renewals', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'n', 0, 0, 'Всего резервирований', '',               10, 0, 'items.reserves', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'o', 0, 0, 'Полный (экземплярный) шифр хранения', '', 10, 0, 'items.itemcallnumber', '', NULL, NULL, '', NULL, NULL),
 ('FA', '', '952', 'p', 0, 0, 'Штрих-код', '',                          10, 0, 'items.barcode', '', 'barcode.pl', NULL, '', NULL, NULL),
 ('FA', '', '952', 'q', 0, 0, 'Дата окончания срока выдачи', '',        10, 0, 'items.onloan', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'r', 0, 0, 'Дата, когда последний раз видели экземпляр', '', 10, 0, 'items.datelastseen', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 's', 0, 0, 'Дата последней выдачи или возвращения', '', 10, 0, 'items.datelastborrowed', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 't', 0, 0, 'Порядковый номер комплекта/экземпляра', '', 10, 0, 'items.copynumber', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'u', 0, 0, 'Унифицированный идентификатор ресурсов', '', 10, 0, 'items.uri', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'v', 0, 0, 'Стоимость, цена замены', '',             10, 0, 'items.replacementprice', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'w', 0, 0, 'Дата, для которой действительна цена замены', '', 10, 0, 'items.replacementpricedate', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'x', 0, 1, 'Служебное (необщедоступное) примечание', '', 10, 0, 'items.itemnotes_nonpublic', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'y', 0, 0, 'Тип единицы (уровень экземпляра)', '',   10, 0, 'items.itype', 'itemtypes', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'z', 0, 0, 'Общедоступное примечание о экземпляре', '', 10, 0, 'items.itemnotes', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '999', '', 1, 'Системные контрольные номера (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', NULL, '999', 'c', 0, 0, '«biblionumber» (Коха)', '',            -1, -5, 'biblio.biblionumber', NULL, '', NULL, '', '', NULL),
 ('FA', NULL, '999', 'd', 0, 0, '«biblioitemnumber» (Коха)', '',        -1, -5, 'biblioitems.biblioitemnumber', NULL, '', NULL, '', '', NULL);
