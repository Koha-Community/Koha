-- На основі MARC21-структури англійською „Fast Add Framework“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '090', '', 1, 'Шифри', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '090', 'a', 0, 0, 'Поличний індекс', '',                    0, 5, '', '', '', 0, '', '', NULL),
 ('FA', '', '090', 'b', 0, 0, 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 0, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '099', '', 1, 'Періодичні видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '100', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                   1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '942', '', '', 'Додаткові дані (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '942', '0', 0, 0, 'Кількість видач (випожичань) для усіх примірників', '', 9, 5, 'biblioitems.totalissues', '', '', NULL, '', '', NULL),
 ('FA', '', '942', 'c', 1, 0, 'Тип одиниці (рівень запису)', '',        9, 5, 'biblioitems.itemtype', 'itemtypes', '', NULL, '', '', NULL),
 ('FA', '', '942', 'n', 0, 0, 'Статус приховування в ЕК', '',           9, 5, NULL, '', '', 0, '', '', NULL),
 ('FA', '', '942', 's', 0, 0, 'Позначка про запис серіального видання', 'Запис серіального видання', 9, 5, 'biblio.serial', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '952', '', 1, 'Дані про примірники та розташування (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '952', '0', 0, 0, 'Статус вилучення', '',                   10, 0, 'items.withdrawn', 'WITHDRAWN', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '1', 0, 0, 'Статус втрати/відсутності', '',          10, 0, 'items.itemlost', 'LOST', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '2', 0, 0, 'Джерело класифікації чи схема поличного розташування', '', 10, 0, 'items.cn_source', 'cn_source', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '3', 0, 0, 'Нумерація (об’єднаний том чи інша частина)', '', 10, 0, 'items.materials', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '4', 0, 0, 'Стан пошкодження', '',                   10, 0, 'items.damaged', 'DAMAGED', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '5', 0, 0, 'Статус обмеження доступу', '',           10, 0, 'items.restricted', 'RESTRICTED', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '6', 0, 0, 'Нормалізована класифікація Коха для сортування', '', 10, 0, 'items.cn_sort', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '7', 0, 0, 'Тип обігу (не для випожичання)', '',     10, 0, 'items.notforloan', 'NOT_LOAN', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '8', 0, 0, 'Вид зібрання', '',                       10, 0, 'items.ccode', 'CCODE', '', NULL, '', NULL, NULL),
 ('FA', '', '952', '9', 0, 0, 'Внутрішній № примірника (items.itemnumber)', 'Внутрішній № примірника', -1, 0, 'items.itemnumber', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'a', 0, 1, 'Джерельне місце зберігання примірника (домашній підрозділ)', '', 10, 0, 'items.homebranch', 'branches', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'b', 0, 1, 'Місце тимчасового зберігання чи видачі (підрозділ зберігання)', '', 10, 0, 'items.holdingbranch', 'branches', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'c', 0, 0, 'Поличкове розташування', '',             10, 0, 'items.location', 'LOC', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'd', 0, 0, 'Дата надходження', '',                   10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', NULL, '', NULL, NULL),
 ('FA', '', '952', 'e', 0, 0, 'Джерело надходження (постачальник)', '', 10, 0, 'items.booksellerid', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'f', 0, 0, 'Кодований визначник розташування', '',   10, 0, 'items.coded_location_qualifier', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'g', 0, 0, 'Вартість, звичайна закупівельна ціна', '', 10, 0, 'items.price', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'h', 0, 0, 'Нумерування/хронологія серіальних видань', '', 10, 0, 'items.enumchron', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'i', 0, 0, 'Інвентарний номер', '',                  10, 0, 'items.stocknumber', '', '', NULL, '', '', NULL),
 ('FA', '', '952', 'j', 0, 0, 'Поличний контрольний номер', '',         10, 0, 'items.stack', 'STACK', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'l', 0, 0, 'Видач загалом', '',                      10, 0, 'items.issues', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'm', 0, 0, 'Продовжень загалом', '',                 10, 0, 'items.renewals', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'n', 0, 0, 'Загалом резервувань', '',                10, 0, 'items.reserves', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'o', 0, 0, 'Повний (примірниковий) шифр збереження', '', 10, 0, 'items.itemcallnumber', '', NULL, NULL, '', NULL, NULL),
 ('FA', '', '952', 'p', 0, 0, 'Штрих-код', '',                          10, 0, 'items.barcode', '', 'barcode.pl', NULL, '', NULL, NULL),
 ('FA', '', '952', 'q', 0, 0, 'Дата завершення терміну випожичання', '', 10, 0, 'items.onloan', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'r', 0, 0, 'Дата, коли останній раз бачено примірник', '', 10, 0, 'items.datelastseen', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 's', 0, 0, 'Дата останнього випожичання чи повернення', '', 10, 0, 'items.datelastborrowed', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 't', 0, 0, 'Порядковий номер комплекту/примірника', '', 10, 0, 'items.copynumber', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'u', 0, 0, 'Уніфікований ідентифікатор ресурсів', '', 10, 0, 'items.uri', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'v', 0, 0, 'Вартість, ціна заміни', '',              10, 0, 'items.replacementprice', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'w', 0, 0, 'Дата, для якої чинна ціна заміни', '',   10, 0, 'items.replacementpricedate', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'x', 0, 1, 'Службова (незагальнодоступна) примітка', '', 10, 0, 'items.paidfor', '', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'y', 0, 0, 'Тип одиниці (рівень примірника)', '',    10, 0, 'items.itype', 'itemtypes', '', NULL, '', NULL, NULL),
 ('FA', '', '952', 'z', 0, 0, 'Загальнодоступна примітка щодо примірника', '', 10, 0, 'items.itemnotes', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '999', '', 1, 'Системні контрольні номери (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', NULL, '999', 'c', 0, 0, '„biblionumber“ (Коха)', '',            -1, -5, 'biblio.biblionumber', NULL, '', NULL, '', '', NULL),
 ('FA', NULL, '999', 'd', 0, 0, '„biblioitemnumber“ (Коха)', '',        -1, -5, 'biblioitems.biblioitemnumber', NULL, '', NULL, '', '', NULL);
