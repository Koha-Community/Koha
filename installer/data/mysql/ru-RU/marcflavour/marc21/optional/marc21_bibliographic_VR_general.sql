-- На основе MARC21-структуры на английском «DVDs, VHS»
-- Перевод/адаптация: Сергей Дубик, Ольга Баркова (2011)

DELETE FROM biblio_framework WHERE frameworkcode='VR';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('VR', 'Видеоматериаллы (DVD, VHS)');
DELETE FROM marc_tag_structure WHERE frameworkcode='VR';
DELETE FROM marc_subfield_structure WHERE frameworkcode='VR';


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '000', 1, '', 'Маркер записи', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '000', '@', 1, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, 0, '', '', 'marc21_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '001', '', '', 'Контрольный номер', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '001', '@', 0, 0, 'Контрольное поле', 'Контрольное поле',   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '003', '', '', 'Принадлежность контрольного номера', 'Принадлежность контрольного номера', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '003', '@', 0, 0, 'Контрольное поле', 'Контрольное поле',   0, -6, '', '', 'marc21_orgcode.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '005', '', '', 'Дата корректировки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '005', '@', 0, 0, 'Контрольное поле', 'Контрольное поле',   0, -1, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '006', '', 1, 'Дополнительные элементы данных фиксированной длины', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '006', '@', 0, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, -1, '', '', 'marc21_field_006.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '007', '', 1, 'Кодируемые данные (физ. описан.)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '007', '@', 0, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, 0, '', '', 'marc21_field_007.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '008', 1, '', 'Кодируемые данные', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '008', '@', 1, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, 0, '', '', 'marc21_field_008.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '009', '', 1, 'Фиксированные поля физического описания для архивных коллекций (устаревшее)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '009', '@', 0, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '010', '', '', 'Контрольный номер записи в Библиотеке Конгресса США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '010', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', NULL, 0, '', '', NULL),
 ('VR', '', '010', 'a', 0, 0, 'Контрольный номер записи БК', '',        0, -6, 'biblioitems.lccn', '', '', 0, '', '', NULL),
 ('VR', '', '010', 'b', 0, 1, 'Контрольный номер записи NUCMC (Национальный объединенный каталог рукописных собраний)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '010', 'z', 0, 1, 'Отменённый/ошибочный контрольный номер БК', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '011', '', '', 'Контрольный номер ссылки Библиотеки Конгресса (устаревшее)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '011', 'a', 0, 1, 'Контрольный номер записи БК', '',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '013', '', 1, 'Патентная информация', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '013', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', NULL, 0, '', '', NULL),
 ('VR', '', '013', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'a', 0, 0, 'Номер патентного документа', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'b', 0, 0, 'Код страны', '',                         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'c', 0, 0, 'Тип патента', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'd', 0, 1, 'Дата выдачи (ггггммдд)', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'e', 0, 1, 'Статус патента', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '013', 'f', 0, 1, 'Участник создания', '',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '015', '', 1, 'Номер в национальной библиографии', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '015', '2', 0, 1, 'Источник номера', '',                    0, -6, '', '', NULL, 0, '', '', NULL),
 ('VR', '', '015', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '015', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '015', 'a', 0, 1, 'Номер в национальной библиографии', '',  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '016', '', 1, 'Контрольный номер национального библиографического агентства', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '016', '2', 0, 1, 'Организация-источник контрольного номера', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '016', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '016', 'a', 0, 0, 'Контрольный номер записи', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '016', 'z', 0, 1, 'Отменённый/ошибочный контрольный номер', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '017', '', 1, 'Номер регистрации авторского права или обязательного экземпляра', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '017', '2', 0, 1, 'Источник номера', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '017', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '017', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '017', 'a', 0, 1, 'Номер государственной регистрации', '',  0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '017', 'b', 0, 0, 'Организация, присвоившая номер', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '017', 'd', 0, 0, 'Дата регистрации авторского права', '',  0, -6, '', '', NULL, 0, '', '', NULL),
 ('VR', '', '017', 'i', 0, 0, 'Пояснительный текст/вводные слова', '',  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '018', '', '', 'Код копирайта', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '018', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '018', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '018', 'a', 0, 0, 'Код копирайта', '',                      0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '020', '', 1, 'Индекс  ISBN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '020', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '020', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '020', 'a', 0, 0, 'ISBN', '',                               0, -6, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('VR', '', '020', 'c', 0, 0, 'Цена, тираж', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '020', 'z', 0, 1, 'Отмененный/ошибочный  ISBN', '',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '022', '', 1, 'Индекс  ISSN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '022', '2', 0, 0, 'Source', 'Source',                       0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '022', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '022', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '022', 'a', 0, 0, 'ISSN', '',                               0, -6, 'biblioitems.issn', '', '', 0, '', '', NULL),
 ('VR', '', '022', 'y', 0, 1, 'Ошибочный  ISSN', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '022', 'z', 0, 1, 'Отмененный  ISSN', '',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '023', '', 1, 'Стандартный номер фильма [удалено]', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '023', 'a', 0, 0, 'Стандартный номер фильма', '',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '024', '', 1, 'Прочие стандартные номера', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '024', '2', 0, 0, 'Источник номера', '',                    0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', 'a', 0, 0, 'Стандартный номер', '',                  0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', 'b', 0, 0, 'Additional codes following the standard number (устаревшее)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', 'c', 0, 1, 'Условие получения (цена, тираж)', '',    0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', 'd', 0, 0, 'Дополнительные коды', '',                0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '024', 'z', 0, 1, 'Отменененный/ошибочный номер', '',       0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '025', '', 1, 'Номер зарубежного приобретения', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '025', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '025', 'a', 0, 1, 'Номер зарубежного приобретения', '',     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '026', '', 1, 'Фингерпринт', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '026', '2', 0, 0, 'Использованное руководство', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', '5', 0, 0, 'Принадлежность поля организации', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', 'a', 0, 0, 'Первая и вторая группы символов', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', 'b', 0, 0, 'Третья и четвёртая группы символов', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', 'c', 0, 0, 'Дата (026)', '',                         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', 'd', 0, 1, 'Номер тома или части', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '026', 'e', 0, 0, 'Фингерпринт без разбивки на группы', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '027', '', 1, 'Стандартный номер технического отчёта (STRN)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '027', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '027', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '027', 'a', 0, 0, 'Стандартный номер технического отчёта (STRN)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '027', 'z', 0, 1, 'Отменённый/ошибочный номер технического отчета', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '028', '', 1, 'Номер издателя', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '028', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '028', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '028', 'a', 0, 0, 'Номер издателя', '',                     0, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '028', 'b', 0, 0, 'Источник  № издателя', '',               0, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '029', '', 1, 'Контрольный номер для других систем (OCLC)', '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '030', '', 1, 'Обозначение CODEN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '030', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '030', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '030', 'a', 0, 0, 'Действующий номер CODEN', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '030', 'z', 0, 1, 'Отмененный/недействительный номер CODEN', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '031', '', 1, 'Музыкальный инципит', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '031', '2', 0, 0, 'Код системы', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'a', 0, 0, 'Порядковый номер произведения в каталогизируемой единице', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'b', 0, 0, 'Порядковый номер темпа в произведении', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'c', 0, 0, 'Порядковый номер инципита внутри темпа', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'd', 0, 1, 'Заглавие или заголовок инципита', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'e', 0, 0, 'Наименование символа распева инципита (вокал)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'g', 0, 0, 'Ключ', '',                               0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'm', 0, 0, 'Голос/инструмент', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'n', 0, 0, 'Обозначение тональности', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'o', 0, 0, 'Обозначение такта', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'p', 0, 0, 'Музыкальная нотация', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'q', 0, 0, 'Примечание', '',                         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'r', 0, 0, 'Тональность', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 's', 0, 1, 'Код проверки правильности', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 't', 0, 1, 'Литературный инципит', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'u', 0, 1, 'Унифицированный определитель ресурса ( U R I)', '', 0, -6, '', '', '', 1, '', '', NULL),
 ('VR', '', '031', 'y', 0, 1, 'Cвязывающий текст', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '031', 'z', 0, 1, 'Примечание для ЭК', '',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '032', '', 1, 'Номер почтовой регистрации', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '032', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', NULL, 0, '', '', NULL),
 ('VR', '', '032', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '032', 'a', 0, 0, 'Номер почтовой регистрации', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '032', 'b', 0, 0, 'Источник (агентство, присвоившее номер)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '033', '', 1, 'Дата/время и место мероприятия', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '033', '3', 0, 0, 'Область применения данных поля', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '033', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '033', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '033', 'a', 0, 1, 'Дата/время в формате', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '033', 'b', 0, 1, 'Код географической классификации региона', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '033', 'c', 0, 1, 'Код географической классификации области (части региона)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '034', '', 1, 'Кодированные картографические математические данные', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '034', '2', 0, 0, 'Source', 'Source',                       0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'a', 0, 0, 'Категория масштаба  a — линейный,  b — угловой масштаб,  z — масштаб другого типа', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'b', 0, 1, 'Постоянный линейный горизонтальный масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'c', 0, 1, 'Постоянный линейный вертикальный масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'd', 0, 0, 'Координаты — самая западная долгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'e', 0, 0, 'Координаты — самая восточная долгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'f', 0, 0, 'Координаты — самая северная долгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'g', 0, 0, 'Координаты — самая южная долгота', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'h', 0, 1, 'Угловой масштаб', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'j', 0, 0, 'Склонение — северная граница', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'k', 0, 0, 'Склонение — южная граница', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'm', 0, 0, 'Прямое восхождение — восточная граница', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'n', 0, 0, 'Прямое восхождение — западная граница', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'p', 0, 0, 'Равноденствие', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'r', 0, 0, 'Distance from earth', 'Distance from earth', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 's', 0, 1, 'Широта  G-контура', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 't', 0, 1, 'Долгота  G-контура', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'x', 0, 0, 'Beginning date', 'Beginning date',       0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'y', 0, 0, 'Ending date', 'Ending date',             0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '034', 'z', 0, 0, 'Name of extraterrestrial body', 'Name of extraterrestrial body', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '035', '', 1, 'Системный контрольный номер', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '035', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '035', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '035', 'a', 0, 0, 'Системный контрольный номер', '',        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '035', 'z', 0, 1, 'Аннулир. контрольный номер', '',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '036', '', '', 'Первоначальный номер, присв. компьют. файлу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '036', '6', 0, 1, 'Элемент полей', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '036', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '036', 'a', 0, 0, 'Первоначально присвоенный номер', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '036', 'b', 0, 1, 'Агентство, присвоевшее номер', '',       0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '037', '', 1, 'Данные для комплектования', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '037', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'a', 0, 0, 'Номер по прейскуранту и т. д', '',       0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'b', 0, 0, 'Продавец. распространитель, издатель, изготовитель', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'c', 0, 1, 'Условия получения, цена', '',            0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'f', 0, 1, 'Форма распространяемого материала', '',  0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'g', 0, 1, 'Дополнительные характеристики материала', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '037', 'n', 0, 1, 'Примечание', '',                         0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '038', '', '', 'Организация, давшая права интеллектуальной собственности на содержимое записи', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '038', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '038', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '038', 'a', 0, 0, 'Код организации, давшей права интеллектуальной собственности на содержимое записи', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '039', '', '', 'Уровень библиографического контроля и кодирования (устаревшее)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '039', 'a', 0, 0, 'Level of rules in bibliographic description', 'Level of rules in bibliographic description', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '039', 'b', 0, 0, 'Level of effort used to assign nonsubject heading access points', 'Level of effort used to assign nonsubject heading access points', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '039', 'c', 0, 0, 'Level of effort used to assign subject headings', 'Level of effort used to assign subject headings', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '039', 'd', 0, 0, 'Level of effort used to assign classification', 'Level of effort used to assign classification', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '039', 'e', 0, 0, 'Number of fixed field character positions coded', 'Number of fixed field character positions coded', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '040', '', '', 'Источник каталогиз.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '040', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', 'a', 0, 0, 'Служба первич. каталог.', '',            0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', 'b', 0, 0, 'Код языка каталог.', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', 'c', 0, 0, 'Служба, преобразующая запись', '',       0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', 'd', 0, 1, 'Организация, изменившая запись', '',     0, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '040', 'e', 0, 0, 'Правила каталог.', '',                   0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '041', '', 1, 'Код языка издания', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '041', '2', 0, 0, 'Код языка оригинала', '',                0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '041', 'a', 0, 1, 'Код языка текста', '',                   0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'b', 0, 1, 'Код языка предисловия', '',              0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'c', 0, 1, 'Languages of separate titles (VM) (устаревшее); Languages of available translation  (SE) (устаревшее)', '', 0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'd', 0, 1, 'Код языка текста для пения и речи', '',  0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'e', 0, 1, 'Код языка либретто', '',                 0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'f', 0, 1, 'Код языка содержания', '',               0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'g', 0, 1, 'Код языка сопров. матер.', '',           0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('VR', '', '041', 'h', 0, 1, 'Код языка оригинала', '',                0, -1, '', 'LANG', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '042', '', '', 'Код аутентификации записи', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '042', 'a', 0, 0, 'Код аутентификации', '',                 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '043', '', '', 'Код географического региона', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '043', '2', 0, 1, 'Источник локального кода', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '043', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '043', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '043', 'a', 0, 1, 'Код географического региона', '',        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '043', 'b', 0, 1, 'Локальный код географ. региона', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '043', 'c', 0, 1, 'ISO code', 'ISO code',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '044', '', '', 'Код страны публикации', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '044', '2', 0, 1, 'Источник локального кода', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '044', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '044', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '044', 'a', 0, 1, 'Код страны публикации', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '044', 'b', 0, 1, 'Локальный код места', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '044', 'c', 0, 1, 'Код места издания по ISO', '',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '045', '', '', 'Период времени, охватываемый содержанием документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '045', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '045', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '045', 'a', 0, 1, 'Код периода времени', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '045', 'b', 0, 1, 'Форматированное обозначение периода времени с н. э. по 9999 до н. э.', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '045', 'c', 0, 1, 'Форматированное обозначение периода времени до 9999 до н.э.', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '046', '', 1, 'Специальные кодированные даты', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '046', '2', 0, 0, 'Источник даты', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'a', 0, 0, 'Тип кода даты', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'b', 0, 0, 'Дата 1 (дата до н.э.)', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'c', 0, 0, 'Дата 1 (дата н.э.)', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'd', 0, 0, 'Дата 2 (дата до н.э.)', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'e', 0, 0, 'Дата 2 (дата н.э.)', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'j', 0, 0, 'Изменение источника даты', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'k', 0, 0, 'Дата или начало диапазона даты создания (ресурса)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'l', 0, 0, 'Дата окончания создания (ресурса)', '',  0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'm', 0, 0, 'Beginning of date valid', 'Beginning of date valid', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '046', 'n', 0, 0, 'End of date valid', 'End of date valid', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '047', '', 1, 'Код формы муз. композиции', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '047', '2', 0, 0, 'Источник кода', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '047', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '047', 'a', 0, 1, 'Код формы муз. композиции', '',          0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '048', '', 1, 'Код количества муз. инст. или голосов', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '048', '2', 0, 0, 'Источник кода', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '048', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '048', 'a', 0, 1, 'Исполнитель или ансамбль', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '048', 'b', 0, 1, 'Soloist', 'Soloist',                     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '049', '', '', 'Локальное хранение (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '049', 'a', 0, 1, 'Holding library', 'Holding library',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'c', 0, 1, 'Copy statement', 'Copy statement',       0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'd', 0, 1, 'Definition of bibliographic subdivisions', 'Definition of bibliographic subdivisions', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'l', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'm', 0, 1, 'Missing elements', 'Missing elements',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'n', 0, 0, 'Notes about holdings', 'Notes about holdings', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'o', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'p', 0, 1, 'Secondary bibliographic subdivision', 'Secondary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'q', 0, 1, 'Third bibliographic subdivision', 'Third bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'r', 0, 1, 'Fourth bibliographic subdivision', 'Fourth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 's', 0, 0, 'Fifth bibliographic subdivision', 'Fifth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 't', 0, 1, 'Sixth bibliographic subdivision', 'Sixth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'u', 0, 1, 'Seventh bibliographic subdivision', 'Seventh bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'v', 0, 1, 'Primary bibliographic subdivision', 'Primary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '049', 'y', 0, 0, 'Inclusive dates of publication or coverage', 'Inclusive dates of publication or coverage', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '050', '', 1, 'Расстановочный код библ. Конгресса', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '050', '3', 0, 0, 'Область применения данных поля', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '050', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '050', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '050', 'a', 0, 1, 'Классификационный индекс', '',           0, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '050', 'b', 0, 0, 'Номер единицы', '',                      0, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '050', 'd', 0, 0, 'Supplementary class number (MU) (устаревшее)', 'Supplementary class number (MU) (устаревшее)', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '051', '', 1, 'Сведения о копии, выпуске, отдельном оттиске Библиотеки Конгресса США', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '051', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '051', 'a', 0, 0, 'Классификационный номер', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '051', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '051', 'c', 0, 0, 'Сведения о копии', '',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '052', '', 1, 'Код географической классификации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '052', '2', 0, 0, 'Источник кода', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', '6', 0, 0, 'Связь', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', '8', 0, 1, 'Связь поля и её порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', 'a', 0, 0, 'Код географической классификации региона', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', 'b', 0, 1, 'Код географической классификации области региона', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', 'c', 0, 1, 'Название населённого пункта', '',        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '055', '', 1, 'Классификационный номер, присвоенный в Канаде', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '055', '2', 0, 0, 'Source of call/class number', '',        0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '055', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '055', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '055', 'a', 0, 0, 'Классификационный номер', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '055', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '060', '', 1, 'Шифр хранения Национальной медицинской библиотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '060', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '060', 'a', 0, 1, 'Классификационный номер', '',          0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '060', 'b', 0, 0, 'Номер объекта', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '061', '', 1, 'Сведения об экземпляре Национальной медицинской библиотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '061', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '061', 'a', 0, 1, 'Классификационный номер', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '061', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '061', 'c', 0, 0, 'Сведения о копии', '',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '066', '', '', 'Используемые наборы символов', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '066', 'a', 0, 0, 'Набор символов  G0', '',               0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '066', 'b', 0, 0, 'Набор символов  G1', '',               0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '066', 'c', 0, 1, 'Альтернативный набор символов', '',    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '070', '', 1, 'Шифр хранения Национальной сельскохозяйственной библиотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '070', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '070', 'a', 0, 1, 'Классификационный номер', '',          0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '070', 'b', 0, 0, 'Номер объекта', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '071', '', 1, 'Сведения об экземпляре Национальной сельскохозяйственной библиотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '071', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '071', 'a', 0, 1, 'Классификационный номер', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '071', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '071', 'c', 0, 0, 'Сведения о копии', '',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '072', '', 1, 'Код предметной/темат. категории', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '072', '2', 0, 0, 'Источник кода', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '072', '6', 0, 0, 'Элемент связи', 'Элемент связи',       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '072', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '072', 'a', 0, 0, 'Код предметной/темат. категории', '',  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '072', 'x', 0, 1, 'Код нижестоящей предм./темат. категории', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '074', '', 1, 'Номер GPO объекта описания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '074', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '074', 'a', 0, 0, 'Номер объекта GPO ', '',               0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '074', 'z', 0, 1, 'Аннулированный/ошибочный номер объекта GPO', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '080', '', 1, 'Индекс УДК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '080', '2', 0, 0, 'Идентификатор издания', '',            0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '080', '6', 0, 0, 'Элемент связи', 'Элемент связи',       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '080', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '080', 'a', 0, 0, 'Индекс УДК', '',                       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '080', 'b', 0, 0, 'Номер единицы', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '080', 'x', 0, 0, 'Вспомогательное деление общего характера', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '082', '', 1, 'Индекс Дьюи', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '082', '2', 0, 0, 'Номер издания', '',                      0, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '082', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '082', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '082', 'a', 0, 1, 'Индекс Дьюи', '',                        0, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '082', 'b', 0, 0, 'Номер единицы', '',                      0, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '084', '', 1, 'Индекс другой классификации/Индекс ББК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '084', '2', 0, 0, 'Источник индекса', '',                 0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '084', '6', 0, 0, 'Элемент связи', 'Элемент связи',       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '084', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '084', 'a', 0, 1, 'Индекс другой классификации/Индекс ББК', '', 0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '084', 'b', 0, 0, 'Номер единицы', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '086', '', 1, 'Классификационный номер документа органа государственной власти', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '086', '2', 0, 0, 'Источник индекса', '',                 0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '086', '6', 0, 0, 'Связь', '',                            0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '086', '8', 0, 1, 'Связь поля и её порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '086', 'a', 0, 0, 'Классификационный номер/номер документа', '', 0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '086', 'z', 0, 1, 'Отменённый/ошибочный классификационный номер/номер документа', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '087', '', 1, 'Номер отчета (устаревшее, CAN/MARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '087', 'a', 0, 0, 'Номер отчета (устаревшее, CAN/MARC)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '087', 'z', 0, 1, 'Аннулированный/ошибочный номер отчета (устаревшее, CAN/MARC)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '088', '', 1, 'Номер отчёта', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '088', '6', 0, 0, 'Связь', '',                            0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '088', '8', 0, 1, 'Связь поля и её порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '088', 'a', 0, 0, 'Номер отчёта', '',                     0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '088', 'z', 0, 1, 'Отменённый/ошибочный номер отчета', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '091', '', '', 'Индексы/коды', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '091', 'a', 0, 0, 'Индекс ББК', '',                         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '092', '', 1, 'Индексы/коды (МАРС)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '092', '2', 0, 0, 'Edition number', 'Edition number',       0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '092', 'a', 0, 0, 'Индекс ГРНТИ (МАРС)', '',                0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '092', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '092', 'e', 0, 0, 'Feature heading', 'Feature heading',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '096', '', 1, 'Локально присвоенный NLM-номер заявки (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '096', 'a', 0, 0, 'Классификационный номер', '',            0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '096', 'b', 0, 0, 'Номер объекта', '',                      0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '096', 'e', 0, 0, 'Feature heading', 'Feature heading',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '098', '', 1, 'Другие схемы классификации (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '098', 'e', 0, 0, 'Feature heading', 'Feature heading',     0, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '100', '', '', 'Автор', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '100', '4', 0, 1, 'Код отношения', '',                      1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', '6', 0, 0, 'Связь', '',                              1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', '8', 0, 1, 'Связь поля и её порядковый номер', '',   1, -6, '', '', '', 0, '', '', NULL),
 ('VR', 'PERSO_NAME', '100', 'a', 0, 0, 'Автор', '',                    1, -1, 'biblio.author', '', '', 0, '\'100b\',\'100c\',\'100q\',\'100d\',\'100e\',\'110a\',\'110b\',\'110c\',\'110d\',\'110e\',\'111a\',\'111e\',\'111c\',\'111d\',\'130a\',\'700a\',\'700b\',\'700c\',\'700q\',\'700d\',\'700e\',\'710a\',\'710b\',\'710c\',\'710d\',\'710e\',\'711a\',\'711e\',\'711c\',\'711d\',\'720a\',\'720e\',\'796a\',\'796b\',\'796c\',\'796q\',\'796d\',\'796e\',\'797a\',\'797b\',\'797c\',\'797d\',\'797e\',\'798a\',\'798e\',\'798c\',\'798d\',\'800a\',\'800b\',\'800c\',\'800q\',\'800d\',\'800e\',\'810a\',\'810b\',\'810c\',\'810d\',\'810e\',\'811a\',\'811e\',\'811c\',\'811d\',\'896a\',\'896b\',\'896c\',\'896q\',\'896d\',\'896e\',\'897a\',\'897b\',\'897c\',\'897d\',\'897e\',\'898a\',\'898e\',\'898c\',\'898d\',\'505r\'', '', NULL),
 ('VR', '', '100', 'b', 0, 0, 'Династ. номер', '',                      1, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'c', 0, 0, 'Титул (звания)', '',                     1, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'd', 0, 0, 'Дата', '',                               1, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'e', 0, 1, 'Роль лиц', '',                           1, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'f', 0, 0, 'Дата публикации', '',                    1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'g', 0, 0, 'Прочие сведения', '',                    1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'j', 0, 1, 'Принадлежность неизвестного автора к последователям, ученикам, сторонникам, школе и т. д.', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'k', 0, 1, 'Подзаголовок формы', '',                 1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'l', 0, 0, 'Язык работы', '',                        1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'q', 0, 0, 'Полное имя', '',                         1, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 't', 0, 0, 'Заглавие работы', '',                    1, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '100', 'u', 0, 0, 'Дополнение', '',                         1, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '110', '', '', 'Автор — организация', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '110', '4', 0, 1, 'Код отношения', '',                      1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', '6', 0, 0, 'Связь', '',                              1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', '8', 0, 1, 'Связь поля и её порядковый номер', '',   1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '110', 'a', 0, 0, 'Организация/юрисдикция', '',   1, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'b', 0, 1, 'Подчиненная единица', '',                1, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'c', 0, 0, 'Место', '',                              1, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'd', 0, 1, 'Дата', '',                               1, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'e', 0, 1, 'Термин отношения', '',                   1, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'f', 0, 0, 'Дата работы', '',                        1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'g', 0, 0, 'Прочая информация', '',                  1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'k', 0, 1, 'Подзаголовок формы', '',                 1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'l', 0, 0, 'Язык работы', '',                        1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'n', 0, 1, 'Номер части/раздела/мероприятия', '',    1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'p', 0, 1, 'Название части/раздела работы', '',      1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 't', 0, 0, 'Заглавие работы', '',                    1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '110', 'u', 0, 0, 'Дополнительные сведения', '',            1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '111', '', '', 'Автор — мероприятие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '111', '4', 0, 1, 'Код отношения', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', '6', 0, 0, 'Связь', '',                            1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', '8', 0, 1, 'Связь поля и её порядковый номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '111', 'a', 0, 0, 'Наименов. мероприятия', '',    1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'b', 0, 0, 'Number (устаревшее)', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'c', 0, 0, 'Место мероприятия', '',                1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'd', 0, 0, 'Дата мероприятия', '',                 1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'e', 0, 0, 'Соподчин. единица', '',                1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'f', 0, 0, 'Дата работы', '',                      1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'g', 0, 0, 'Проч. информация', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'j', 0, 1, 'Термин отношений (роль)', '',          1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'k', 0, 1, 'Подзаголовок формы', '',               1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'l', 0, 0, 'Язык работы', '',                      1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'n', 0, 0, '№ части/секции', '',                   1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'p', 0, 0, '№ части/раздела', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'q', 0, 0, 'Наименование мероприятия, подчиненного юрисдикции', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 't', 0, 0, 'Заглавие работы', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '111', 'u', 0, 0, 'Дополнительные сведения', '',          1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '130', '', '', 'Заголовок — унифицированное заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '130', '6', 0, 0, 'Элемент связи', 'Элемент связи',       1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '130', 'a', 0, 0, 'Унифицированное заглавие', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'd', 0, 1, 'Дата подписания договора', '',         1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'f', 0, 0, 'Дата публикации', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'g', 0, 0, 'Прочие сведения', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'h', 0, 0, 'Физический носитель', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'k', 0, 1, 'Форма, вид, жанр', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'l', 0, 0, 'Язык произведения', '',                1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'n', 0, 1, 'Номер части/раздела', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'o', 0, 0, 'Обозначение аранжировки', '',          1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'p', 0, 1, 'Заглавие части/раздела', '',           1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 'r', 0, 0, 'Тональность', '',                      1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 's', 0, 0, 'Версия, издание', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '130', 't', 0, 0, 'Заглавие работы', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '210', '', 1, 'Сокращенное заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '210', '2', 0, 1, 'Источник сведений', '',                2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '210', '6', 0, 0, 'Элемент связи', 'Элемент связи',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '210', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '210', 'a', 0, 0, 'Сокращенное заглавие', '',             2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '210', 'b', 0, 0, 'Идентифицирующие признаки', '',        2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '211', '', 1, 'Сокращенное наименование или сокращенное название (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '211', '6', 0, 0, 'Элемент связи', 'Элемент связи',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '211', 'a', 0, 0, 'Сокращенное наименование или сокращенное название', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '212', '', 1, 'Вариант доступного названия (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '212', '6', 0, 0, 'Элемент связи', 'Элемент связи',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '212', 'a', 0, 0, 'Вариант доступного названия', '',      2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '214', '', 1, 'Расширенное название (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '214', '6', 0, 0, 'Элемент связи', 'Элемент связи',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '214', 'a', 0, 0, 'Расширенное название', '',             2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '222', '', 1, 'Ключевое заглавие сериального издания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '222', '6', 0, 0, 'Элемент связи', 'Элемент связи',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '222', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '222', 'a', 0, 0, 'Ключевое заглавие сериал. изд.', '',   2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '222', 'b', 0, 0, 'Идентифицирующие признаки', '',        2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '240', '', '', 'Условное заглавие', '', 'Unititle');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '240', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'a', 0, 0, 'Условное заглавие', '',                  2, -1, 'biblio.unititle', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'd', 0, 1, 'Дата подписания договора', '',           2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'f', 0, 0, 'Дата публикации', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'g', 0, 0, 'Прочие сведения', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'h', 0, 0, 'Физический носитель (обозн. материала)', '', 2, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'k', 0, 1, 'Форма, вид, жанр', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'l', 0, 0, 'Язык произведения', '',                  2, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'n', 0, 1, '№ части/раздела', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'o', 0, 0, 'Обозначение аранжировки', '',            2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'p', 0, 1, 'Название части/раздела', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 'r', 0, 0, 'Тональность', '',                        2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '240', 's', 0, 0, 'Версия, издание и т.д.', '',             2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '241', '', '', 'Лицензированное название (устаревшее)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '241', 'a', 0, 0, 'Лицензированное название', '',         2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '241', 'h', 0, 0, 'Физический носитель', '',              2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '242', '', 1, 'Перевод заглавия каталог. организацией', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '242', '6', 0, 0, 'Элемент связи', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'a', 0, 0, 'Перевод заглавия', '',                 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'b', 0, 0, 'Сведения, относящиеся к заглавию', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'c', 0, 0, 'Ответственность', '',                  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '242', 'd', 0, 0, 'Designation of section (BK AM MP MU VM SE) (устаревшее)', 'Designation of section (BK AM MP MU VM SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '242', 'e', 0, 0, 'Name of part/section (BK AM MP MU VM SE) (устаревшее)', 'Name of part/section (BK AM MP MU VM SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'h', 0, 0, 'Физический носитель (обозн. материала)', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'n', 0, 1, 'Номер части/раздела', '',              2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'p', 0, 1, 'Название части/раздела', '',           2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '242', 'y', 0, 0, 'Код языка перевода', '',               2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '243', '', '', 'Обобщающее заглавие', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '243', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'a', 0, 0, 'Обобщающее заглавие', '',                2, -1, '', '', '', 1, '', '', NULL),
 ('VR', '', '243', 'd', 0, 1, 'Дата подписания договора', '',           2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'f', 0, 0, 'Дата публикации', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'g', 0, 0, 'Прочие сведения', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'h', 0, 0, 'Физический носитель', '',                2, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'k', 0, 1, 'Форма, вид, жанр', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'l', 0, 0, 'Язык произведения', '',                  2, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'm', 0, 0, 'Средство для исполнения музыкальных произведений', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'n', 0, 1, 'Номер части/раздела', '',                2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'p', 0, 1, 'Название части/раздела', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 'r', 0, 0, 'Музыкальный ключ', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '243', 's', 0, 0, 'Версия, издание', '',                    2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '245', 1, '', 'Заглавие', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '245', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'a', 0, 0, 'Заглавие', '',                           2, 0, 'biblio.title', '', '', NULL, '\'245b\',\'245f\',\'245g\',\'245k\',\'245n\',\'245p\',\'245s\',\'245h\',\'246i\',\'246a\',\'246b\',\'246f\',\'246g\',\'246n\',\'246p\',\'246h\',\'242a\',\'242b\',\'242n\',\'242p\',\'242h\'', '', NULL),
 ('VR', '', '245', 'b', 0, 0, 'Продолж. заглавия', '',                  2, 0, 'bibliosubtitle.subtitle', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'c', 0, 0, 'Ответственность', '',                    2, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'd', 0, 0, 'Designation of section/part/series (SE) (устаревшее)', 'Designation of section section/part/series: (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'e', 0, 0, 'Name of part/section/series (SE) (устаревшее)', 'Name of part/section/series (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'f', 0, 0, 'Даты создания произведения', '',         2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'g', 0, 0, 'Даты создания осн. части произв.', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'h', 0, 0, 'Физичисский носитель', '',               2, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'k', 0, 1, 'Форма, вид, жанр', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'n', 0, 1, 'Номер части/раздела', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 'p', 0, 1, 'Название части/раздела', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '245', 's', 0, 0, 'Версия', '',                             2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '246', '', 1, 'Другая форма заглавия', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '246', '5', 0, 0, 'Принадлежность поля организации', '',    2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'a', 0, 0, 'Другая форма заглавия', '',              2, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'b', 0, 0, 'Сведения, относящиеся к заглавию', '',   2, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'd', 0, 0, 'Designation of section/part/series (SE) (устаревшее)', 'Designation of section section/part/series (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'e', 0, 0, 'Name of part/section/series (SE) (устаревшее)', 'Name of part/section/series (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'f', 0, 0, 'Том, выпуск и/или дата', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'g', 0, 0, 'Прочая информация', '',                  2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'h', 0, 1, 'Физический носитель', '',                2, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'i', 0, 1, 'Пояснительный текст', '',                2, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'n', 0, 1, 'Номер части/раздела', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '246', 'p', 0, 1, 'Название части', '',                     2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '247', '', 1, 'Сформированный заголовок', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '247', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'a', 0, 0, 'Заголовок', '',                          2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'b', 0, 0, 'Remainder of title', 'Remainder of title', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'd', 0, 0, 'Designation of section (SE) (устаревшее)', 'Designation of section (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'e', 0, 0, 'Name of part/section (SE) (устаревшее)', 'Name of part/section (SE) (устаревшее)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'f', 0, 0, 'Date or sequential designation', 'Date or sequential designation', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'g', 0, 0, 'Прочие сведения', '',                    2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'h', 0, 0, 'Физический носитель', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '247', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '250', '', '', 'Сведения об издании', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '250', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '250', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '250', 'a', 0, 0, 'Основные сведения об издании', '',       2, -1, 'biblioitems.editionstatement', '', '', NULL, '', '', NULL),
 ('VR', '', '250', 'b', 0, 0, 'Дополнительные сведения об издании', '', 2, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '254', '', '', 'Представление музыкального произведения', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '254', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '254', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '254', 'a', 0, 0, 'Представление музыкального произведения', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '255', '', 1, 'Картографические математические данные', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '255', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'a', 0, 1, 'Картографические математические данные', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'b', 0, 0, 'Сведения о проекции', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'c', 0, 0, 'Сведения о координатах', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'd', 0, 0, 'Сведения о зоне', '',                    2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'e', 0, 0, 'Сведения о равноденствии', '',           2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'f', 0, 0, 'Внешние коорд. пары  G-колец', '',       2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '255', 'g', 0, 0, 'Исключ. коорд. пары  G-колец', '',       2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '256', '', '', 'Характеристики компьютерного файла', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '256', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '256', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '256', 'a', 0, 0, 'Характеристики компьютерного файла', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '257', '', '', 'Страна производителя архивных фильмов', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '257', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '257', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '257', 'a', 0, 0, 'Страна производителя архивных фильмов', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '258', '', 1, 'Данные о филателистическом материале', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '258', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '258', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '258', 'a', 0, 0, 'Issuing jurisdiction', 'Issuing jurisdiction', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '258', 'b', 0, 0, 'Denomination', 'Denomination',           2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '260', '', 1, 'Выходные данные', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '260', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'a', 0, 1, 'Место издания', '',                      2, -1, 'biblioitems.place', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'b', 0, 1, 'Издательство', '',                       2, -1, 'biblioitems.publishercode', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'c', 0, 1, 'Дата издания', '',                       2, -1, 'biblio.copyrightdate', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'd', 0, 0, 'Plate or publishers number for music (Pre-AACR 2) (устаревшее, CAN/MARC), (локальное, США)', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'e', 0, 0, 'Место печатания', '',                    2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'f', 0, 0, 'Типография', '',                         2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'g', 0, 0, 'Дата печатания', '',                     2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'k', 0, 0, 'Identification/manufacturer number (устаревшее, CAN/MARC]', 'Identification/manufacturer number (устаревшее, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '260', 'l', 0, 0, 'Matrix and/or take number (устаревшее, CAN/MARC]', 'Matrix and/or take number (устаревшее, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '261', '', '', 'Выходные данные фильма (устаревшее, Канада) (локальное, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '261', '6', 0, 0, 'Элемент связи', 'Элемент связи',         2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'a', 0, 1, 'Producing company', 'Producing company', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'b', 0, 1, 'Releasing company (primary distributor)', 'Releasing company (primary distributor)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'c', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'd', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'e', 0, 1, 'Contractual producer', 'Contractual producer', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '261', 'f', 0, 1, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '262', '', '', 'Выходные данные звукозаписи (локальное, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '262', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', 'a', 0, 0, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', 'b', 0, 0, 'Publisher or trade name', 'Publisher or trade name', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', 'c', 0, 0, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', 'k', 0, 0, 'Serial identification', 'Serial identification', 2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '262', 'l', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '263', '', '', 'Планируемая дата публикации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '263', '6', 0, 0, 'Элемент связи', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '263', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '263', 'a', 0, 0, 'Планируемая дата публикации', '',        2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '265', '', '', 'Источник приобретения / подписка на рассылку (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '265', '6', 0, 0, 'Элемент связи (устаревшее)', '',         2, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '265', 'a', 0, 1, 'Источник приобретения / подписка на рассылку (устаревшее)', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '270', '', 1, 'Адрес', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '270', '4', 0, 1, 'Код отношения', '',                    9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', '6', 0, 0, 'Элемент связи', 'Элемент связи',       9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'a', 0, 1, 'Адрес', '',                            9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'b', 0, 0, 'City', 'City',                         9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'c', 0, 0, 'State or province', 'State or province', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'd', 0, 0, 'Country', 'Country',                   9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'e', 0, 0, 'Postal code', 'Postal code',           9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'f', 0, 0, 'Terms preceding attention name', 'Terms preceding attention name', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'g', 0, 0, 'Attention name', 'Attention name',     9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'h', 0, 0, 'Attention position', 'Attention position', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'i', 0, 0, 'Type of address', 'Type of address',   9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'j', 0, 1, 'Specialized telephone number', 'Specialized telephone number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'k', 0, 1, 'Telephone number', 'Telephone number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'l', 0, 1, 'Fax number', 'Fax number',             9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'm', 0, 1, 'Electronic mail address', 'Electronic mail address', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'n', 0, 1, 'TDD or TTY number', 'TDD or TTY number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'p', 0, 1, 'Contact person', 'Contact person',     9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'q', 0, 1, 'Title of contact person', 'Title of contact person', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'r', 0, 1, 'Hours', 'Hours',                       9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '270', 'z', 0, 1, 'Примечание для ЭК', '',                9, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '300', 1, 1, 'Физическое описание', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '300', '3', 0, 0, 'Область применения данных поля', '',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', '6', 0, 0, 'Элемент связи', 'Элемент связи',         3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'a', 0, 1, 'Объем', '',                              3, 0, 'biblioitems.pages', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'b', 0, 0, 'Иллюстрации/тип воспроизводства', '',    3, 0, 'biblioitems.illus', '', '', 0, '', '', NULL),
 ('VR', '', '300', 'c', 0, 1, 'Размеры', '',                            3, 0, 'biblioitems.size', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'd', 0, 0, 'Accompanying material [устаревшее, CAN/MARC]', 'Accompanying material (устаревшее, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'e', 0, 0, 'Сопроводительные материалы', '',         3, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'f', 0, 1, 'Тип единицы', '',                        3, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'g', 0, 1, 'Размер единицы', '',                     3, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'k', 0, 0, 'Speed [Videodiscs, pre-AACR2 records only] (устаревшее, CAN/MARC]', 'Speed [Videodiscs, pre-AACR2 records only] (устаревшее, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'm', 0, 0, 'Identification/manufacturer number [pre-AACR2 records only] (устаревшее, CAN/MARC]', 'Identification/manufacturer number [pre-AACR2 records only] (устаревшее, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '300', 'n', 0, 0, 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] (устаревшее, CAN/MARC]', 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] (устаревшее, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '301', '', '', 'Физическое описание фильма (устаревшее, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '301', 'a', 0, 0, 'Extent of item', 'Extent of item',       3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '301', 'b', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '301', 'c', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', NULL, NULL, '', '', NULL),
 ('VR', '', '301', 'd', 0, 0, 'Dimensions', 'Dimensions',               3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '301', 'e', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '301', 'f', 0, 0, 'Speed', 'Speed',                         3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '302', '', '', 'Количество страниц или элементов (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '302', 'a', 0, 0, 'Количество страниц', '',                 3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '303', '', '', 'Единица измерения (устаревшее, USMARC))', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '303', 'a', 0, 0, 'Unit count', 'Unit count',               3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '304', '', '', 'Линейный размер (устаревшее, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '304', 'a', 0, 0, 'Linear footage', 'Linear footage',       3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '305', '', '', 'Физические характеристики звуковой записи (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '305', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'a', 0, 0, 'Extent', 'Extent',                       3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'b', 0, 0, 'Other physical details', 'Other physical details', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'c', 0, 0, 'Dimensions', 'Dimensions',               3, -6, '', '', NULL, NULL, '', '', NULL),
 ('VR', '', '305', 'd', 0, 0, 'Microgroove or standard', 'Microgroove or standard', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'e', 0, 0, 'Stereophonic, monaural', 'Stereophonic, monaural', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'f', 0, 0, 'Number of tracks', 'Number of tracks',   3, -6, '', '', NULL, NULL, '', '', NULL),
 ('VR', '', '305', 'm', 0, 0, 'Serial identification', 'Serial identification', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '305', 'n', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '306', '', '', 'Продолжительность звуковой записи', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '306', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '306', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '306', 'a', 0, 1, 'Продолжительность звуковой записи (ччммсс)', '', 3, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '307', '', 1, 'Часы', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '307', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '307', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '307', 'a', 0, 0, 'Часы', '',                               3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '307', 'b', 0, 0, 'Дополнительная информация', '',          3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '308', '', 1, 'Физические характеристика фильма (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '308', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'a', 0, 0, 'Number of reels', 'Number of reels',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'b', 0, 0, 'Footage', 'Footage',                     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'c', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'd', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'e', 0, 0, 'Width', 'Width',                         3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '308', 'f', 0, 0, 'Presentation format', 'Presentation format', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '310', '', '', 'Периодичность в н.в.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '310', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '310', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '310', 'a', 0, 0, 'Периодичность в н.в.', '',             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '310', 'b', 0, 0, 'Дата введения период.', '',            3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '315', '', '', 'Частотность (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '315', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '315', 'a', 0, 1, 'Frequency', 'Frequency',                 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '315', 'b', 0, 1, 'Dates of frequency', 'Dates of frequency', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '321', '', 1, 'Прежняя периодичность', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '321', '6', 0, 0, 'Элемент связи', 'Элемент связи',       3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '321', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '321', 'a', 0, 0, 'Прежняя периодичность', '',            3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '321', 'b', 0, 0, 'Дата существующей периодичности', '',  3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '340', '', 1, 'Физический носитель', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '340', '3', 0, 0, 'Область применения данных поля', '',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'a', 0, 1, 'Материальная основа', '',                3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'b', 0, 1, 'Размеры', '',                            3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'c', 0, 1, 'Материал покрытия', '',                  3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'd', 0, 1, 'Техника записи', '',                     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'e', 0, 1, 'Средство крепления', '',                 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'f', 0, 1, 'Production rate/ratio', 'Production rate/ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'h', 0, 1, 'Location within medium', 'Location within medium', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '340', 'i', 0, 1, 'Technical specifications of medium', 'Technical specifications of medium', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '342', '', 1, 'Геопространственные справочные данные', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '342', '2', 0, 0, 'Reference method used', 'Reference method used', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'a', 0, 1, 'Name', 'Name',                           3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'b', 0, 0, 'Coordinate or distance units', 'Coordinate or distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'c', 0, 0, 'Latitude resolution', 'Latitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'd', 0, 0, 'Longitude resolution', 'Longitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'e', 0, 1, 'Standard parallel or oblique line latitude', 'Standard parallel or oblique line latitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'f', 0, 1, 'Oblique line longitude', 'Oblique line longitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'g', 0, 0, 'Longitude of central meridian or projection center', 'Longitude of central meridian or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'h', 0, 0, 'Latitude of projection origin or projection center', 'Latitude of projection origin or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'i', 0, 0, 'False easting', 'False easting',         3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'j', 0, 0, 'False northing', 'False northing',       3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'k', 0, 0, 'Scale factor', 'Scale factor',           3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'l', 0, 0, 'Height of perspective point above surface', 'Height of perspective point above surface', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'm', 0, 0, 'Azimuthal angle', 'Azimuthal angle',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'n', 0, 0, 'Azimuth measure point longitude or straight vertical longitude from pole', 'Azimuth measure point longitude or straight vertical longitude from pole', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'o', 0, 0, 'Landsat number and path number', 'Landsat number and path number', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'p', 0, 0, 'Zone identifier', 'Zone identifier',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'q', 0, 0, 'Ellipsoid name', 'Ellipsoid name',       3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'r', 0, 0, 'Semi-major axis', 'Semi-major axis',     3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 's', 0, 0, 'Denominator of flattening ratio', 'Denominator of flattening ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 't', 0, 0, 'Vertical resolution', 'Vertical resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'u', 0, 0, 'Vertical encoding method', 'Vertical encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'v', 0, 0, 'Local planar, local, or other projection or grid description', 'Local planar, local, or other projection or grid description', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '342', 'w', 0, 0, 'Local planar or local georeference information', 'Local planar or local georeference information', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '343', '', 1, 'Данные о плоских координатах', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '343', '6', 0, 0, 'Элемент связи', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'a', 0, 1, 'Planar coordinate encoding method', 'Planar coordinate encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'b', 0, 0, 'Planar distance units', 'Planar distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'c', 0, 0, 'Abscissa resolution', 'Abscissa resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'd', 0, 0, 'Ordinate resolution', 'Ordinate resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'e', 0, 0, 'Distance resolution', 'Distance resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'f', 0, 0, 'Bearing resolution', 'Bearing resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'g', 0, 0, 'Bearing unit', 'Bearing unit',           3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'h', 0, 0, 'Bearing reference direction', 'Bearing reference direction', 3, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '343', 'i', 0, 0, 'Bearing reference meridian', 'Bearing reference meridian', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '350', '', 1, 'Цена (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '350', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '350', 'a', 0, 1, 'Цена', '',                             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '350', 'b', 0, 1, 'Form of issue', 'Form of issue',       3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '351', '', 1, 'Внутренняя организация материала', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '351', '3', 0, 0, 'Область применения данных поля', '',   3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '351', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '351', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '351', 'a', 0, 1, 'Organization', 'Organization',         3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '351', 'b', 0, 1, 'Arrangement', 'Arrangement',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '351', 'c', 0, 0, 'Hierarchical level', 'Hierarchical level', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '352', '', 1, 'Цифровое графическое представление', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '352', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'a', 0, 0, 'Direct reference method', 'Direct reference method', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'b', 0, 1, 'Object type', 'Object type',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'c', 0, 1, 'Object count', 'Object count',         3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'd', 0, 0, 'Row count', 'Row count',               3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'e', 0, 0, 'Column count', 'Column count',         3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'f', 0, 0, 'Vertical count', 'Vertical count',     3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'g', 0, 0, 'VPF topology level', 'VPF topology level', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '352', 'i', 0, 0, 'Indirect reference description', 'Indirect reference description', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '355', '', 1, 'Контроль в соответствии с классификацией секретности', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '355', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', '8', 0, 1, 'Связь полей и номер последовательности', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'a', 0, 0, 'Классификация секретности', '',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'b', 0, 1, 'Операционные инструкции', '',          3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'c', 0, 1, 'Информация о внешнем распространении', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'd', 0, 0, 'Информация об уменьшении секретности или рассекречивании', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'e', 0, 0, 'Классификационная система', '',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'f', 0, 0, 'Код страны создания классификации', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'g', 0, 0, 'Дата уменьшения степени секретности', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'h', 0, 0, 'Дата рассекречивания', '',             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '355', 'j', 0, 1, 'Санкционирование', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '357', '', '', 'Авторский контроль за распространением', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '357', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '357', '8', 0, 1, 'Связь полей и номер последовательности', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '357', 'a', 0, 0, 'Термин, обозначающий авторский контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '357', 'b', 0, 1, 'Организация-создатель, ответственная за контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '357', 'c', 0, 1, 'Получатели материала, имеющие разрешение', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '357', 'g', 0, 0, 'Другие ограничения', '',               3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '359', '', '', 'Цена арендной платы (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '359', 'a', 0, 0, 'Цена арендной платы', '',              3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '362', '', 1, 'Даты публикации или номер тома', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '362', '6', 0, 0, 'Элемент связи', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '362', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '362', 'a', 0, 0, 'Даты публикации или номер тома', '',   3, -6, 'biblioitems.volumedesc', NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '362', 'z', 0, 0, 'Источник сведений', '',                3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '365', '', 1, 'Розничная цена', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '365', '2', 0, 0, 'Source of price type code', 'Source of price type code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', '6', 0, 0, 'Элемент связи', '',                      9, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   9, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'a', 0, 0, 'Price type code', 'Price type code',     9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'b', 0, 0, 'Price amount', 'Price amount',           9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'c', 0, 0, 'Price type code', 'Price type code',     9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'd', 0, 0, 'Unit of pricing', 'Unit of pricing',     9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'e', 0, 0, 'Price note', 'Price note',               9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'f', 0, 0, 'Price effective from', 'Price effective from', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'g', 0, 0, 'Price effective until', 'Price effective until', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'h', 0, 0, 'Tax rate 1', 'Tax rate 1',               9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'i', 0, 0, 'Tax rate 2', 'Tax rate 2',               9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'j', 0, 0, 'ISO country code', 'ISO country code',   9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'k', 0, 0, 'MARC country code', 'MARC country code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '365', 'm', 0, 0, 'Identification of pricing entity', 'Identification of pricing entity', 9, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '366', '', 1, 'Сведения для покупки у издателя', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '366', '2', 0, 0, 'Source of availability status code', 'Source of availability status code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', '6', 0, 0, 'Элемент связи', '',                      9, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   9, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'a', 0, 0, 'Publishers compressed title identification', 'Publishers compressed title identification', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'b', 0, 0, 'Detailed date of publication', 'Detailed date of publication', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'c', 0, 0, 'Availability status code', 'Availability status code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'd', 0, 0, 'Expected next availability date', 'Expected next availability date', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'e', 0, 0, 'Note', 'Note',                           9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'f', 0, 0, 'Publishers discount category', 'Publishers discount category', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'g', 0, 0, 'Date made out of print', 'Date made out of print', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'j', 0, 0, 'ISO country code', 'ISO country code',   9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'k', 0, 0, 'MARC country code', 'MARC country code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '366', 'm', 0, 0, 'Identification of agency', 'Identification of agency', 9, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '400', '', 1, 'Область серии / добавочный поисковый признак — индивидуальное имя (устаревшее, CAN/MARC), (локальное, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '400', '4', 0, 1, 'Код отношения', '',                      4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', '6', 0, 0, 'Элемент связи', '',                      4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'a', 0, 0, 'Personal name', 'Personal name',         4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'b', 0, 0, 'Numeration', 'Numeration',               4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'e', 0, 1, 'Термин отношений (роль)', '',            4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'f', 0, 0, 'Дата публикации', '',                    4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'g', 0, 0, 'Прочие сведения', '',                    4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'k', 0, 1, 'Подзаголовок формы', '',                 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'l', 0, 0, 'Язык работы', '',                        4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 't', 0, 0, 'Заглавие работы', '',                    4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'u', 0, 0, 'Дополнительные сведения', '',            4, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '400', 'v', 0, 0, 'Обозначение и номер тома / порядковое обозначение', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '400', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '410', '', 1, 'Область серии / добавочный поисковый признак — имя организации (устаревшее, CAN/MARC), (локальное, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '410', '4', 0, 1, 'Код отношения', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', '6', 0, 0, 'Элемент связи', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',   4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'e', 0, 1, 'Термин отношений (роль)', '',            4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'f', 0, 0, 'Дата публикации', '',                    4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'g', 0, 0, 'Прочие сведения', '',                    4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'k', 0, 1, 'Подзаголовок формы', '',                 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'l', 0, 0, 'Язык работы', '',                        4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 't', 0, 0, 'Заглавие работы', '',                    4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'u', 0, 0, 'Дополнительные сведения', '',            4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'v', 0, 0, 'Обозначение и номер тома / порядковое обозначение', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '410', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '411', '', 1, 'Область серии / добавочный поисковый признак — название мероприятия (устаревшее, CAN/MARC), (локальное, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '411', '4', 0, 1, 'Код отношения', '',                    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', '6', 0, 0, 'Элемент связи', '',                    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'b', 0, 0, 'Number (устаревшее)', 'Number (устаревшее)', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'd', 0, 0, 'Date of meeting', 'Date of meeting',   4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'f', 0, 0, 'Дата публикации', '',                  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'g', 0, 0, 'Прочие сведения', '',                  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'k', 0, 1, 'Подзаголовок формы', '',               4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'l', 0, 0, 'Язык работы', '',                      4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 't', 0, 0, 'Заглавие работы', '',                  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '411', 'u', 0, 0, 'Дополнительные сведения', '',          4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '411', 'v', 0, 0, 'Обозначение и номер тома / порядковое обозначение', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '411', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '440', '', 1, 'Серия', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '440', '6', 0, 0, 'Элемент связи', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '440', '8', 0, 1, 'Связь полей и номер последовательности', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '440', 'a', 0, 0, 'Серия', '',                    4, 0, 'biblio.seriestitle', '', '', NULL, '\'440n\',\'440p\',\'490a\',\'830a\',\'830n\',\'830p\',\'899a\'', '', NULL),
 ('VR', '', '440', 'n', 0, 1, 'Номер части', '',                        4, 0, 'biblioitems.number', '', '', NULL, '', '', NULL),
 ('VR', '', '440', 'p', 0, 1, 'Название части', '',                     4, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '440', 'v', 0, 0, '№ тома', '',                             4, 0, 'biblioitems.volume', '', '', NULL, '', '', NULL),
 ('VR', '', '440', 'x', 0, 0, 'ISSN серии', '',                         4, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '490', '', 1, 'Серия', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '490', '6', 0, 0, 'Элемент связи', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '490', '8', 0, 1, 'Связь полей и номер последовательности', '', 4, -6, '', '', NULL, NULL, '', '', NULL),
 ('VR', '', '490', 'a', 0, 1, 'Заглавие серии', '',                     4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '490', 'l', 0, 0, 'Library of Congress call number', 'Library of Congress call number', 4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '490', 'v', 0, 1, '№ тома', '',                             4, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '490', 'x', 0, 0, 'ISSN серии', '',                         4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '500', '', 1, 'Примечания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '500', '3', 0, 0, 'Область применения данных поля', '',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', 'a', 0, 0, 'Примечание', '',                         5, -1, 'biblio.notes', '', '', NULL, '', '', NULL),
 ('VR', '', '500', 'l', 0, 0, 'Library of Congress call number (SE) (устаревшее)', 'Library of Congress call number (SE) (устаревшее)', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', 'n', 0, 0, 'n (RLIN) (устаревшее)', 'n (RLIN) (устаревшее)', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', 'x', 0, 0, 'International Standard Serial Number (SE) (устаревшее)', 'International Standard Serial Number (SE) (устаревшее)', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '500', 'z', 0, 0, 'Source of note information (AM SE) (устаревшее)', 'Source of note information (AM SE) (устаревшее)', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '501', '', 1, 'Примечание ’с ...', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '501', '5', 0, 0, 'Организация, для которой применяется поле', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '501', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '501', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '501', 'a', 0, 0, 'Примечание ’с ...', '',                  5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '502', '', 1, 'Примечание о диссертации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '502', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '502', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '502', 'a', 0, 0, 'Примечание о диссертации', '',           5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '503', '', 1, 'Примечание о библиографической истории (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '503', '8', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '503', 'a', 0, 0, 'Примечание о библиографической истории', '', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '504', '', 1, 'Библиография', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '504', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '504', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '504', 'a', 0, 0, 'Библиография', '',                     5, -6, '', NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '504', 'b', 0, 0, 'Number of references', 'Number of references', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '505', '', 1, 'Форматированное содержание', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '505', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', 'a', 0, 0, 'Форматированное содержание', '',         5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', 'g', 0, 1, 'Прочие сведения', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', 'r', 0, 1, 'Statement of responsibility', 'Statement of responsibility', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', 't', 0, 1, 'Title', 'Title',                         5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '505', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '506', '', 1, 'Ограничения на доступ к материалу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '506', '2', 0, 0, 'Источник термина', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', '3', 0, 0, 'Область применения данных поля', '',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'a', 0, 0, 'Terms governing access', 'Terms governing access', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'b', 0, 1, 'Jurisdiction', 'Jurisdiction',           5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'c', 0, 1, 'Physical access provisions', 'Physical access provisions', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'd', 0, 1, 'Authorized users', 'Authorized users',   5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'e', 0, 1, 'Authorization', 'Authorization',         5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'f', 0, 1, 'Standardized terminology for access restriction', 'Standardized terminology for access restriction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '506', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '507', '', '', 'Примечание о масштабе для графического материала', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '507', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '507', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '507', 'a', 0, 0, 'Representative fraction of scale note', 'Representative fraction of scale note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '507', 'b', 0, 0, 'Remainder of scale note', 'Remainder of scale note', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '508', '', 1, 'Примечание о соисполнителях создания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '508', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '508', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '508', 'a', 0, 0, 'Примечание о соисполнителях создания', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '509', '', '', 'Примечание в произвольной форме', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '509', 'a', 0, 0, 'Примечание в произвольной форме', '',  5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '510', '', 1, 'Примечание о ссылках', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '510', '3', 0, 0, 'Область применения данных поля', '',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', 'a', 0, 0, 'Примечание о ссылках', '',               5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', 'b', 0, 0, 'Coverage of source', 'Coverage of source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', 'c', 0, 0, 'Location within source', 'Location within source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '510', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '511', '', 1, 'Информация об исполнителях', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '511', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '511', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '511', 'a', 0, 0, 'Информация об исполнителях', '',         5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '512', '', 1, 'Примечание к предыдущему и последующему разделителю в каталоге (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '512', '6', 0, 0, 'Элемент связи', '',                      -1, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '512', 'a', 0, 0, 'Примечание к предыдущему и последующему разделителю в каталоге', '', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '513', '', 1, 'Примечание о виде отчёта и отчётном периоде', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '513', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '513', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '513', 'a', 0, 0, 'Type of report', 'Type of report',       5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '513', 'b', 0, 0, 'Period covered', 'Period covered',       5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '514', '', '', 'Примечание о качестве данных', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '514', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'a', 0, 0, 'Attribute accuracy report', 'Attribute accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'b', 0, 1, 'Attribute accuracy value', 'Attribute accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'c', 0, 1, 'Attribute accuracy explanation', 'Attribute accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'd', 0, 0, 'Logical consistency report', 'Logical consistency report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'e', 0, 0, 'Completeness report', 'Completeness report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'f', 0, 0, 'Horizontal position accuracy report', 'Horizontal position accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'g', 0, 1, 'Horizontal position accuracy value', 'Horizontal position accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'h', 0, 1, 'Horizontal position accuracy explanation', 'Horizontal position accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'i', 0, 0, 'Vertical positional accuracy report', 'Vertical positional accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'j', 0, 1, 'Vertical positional accuracy value', 'Vertical positional accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'k', 0, 1, 'Vertical positional accuracy explanation', 'Vertical positional accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'm', 0, 0, 'Cloud cover', 'Cloud cover',             5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '514', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('VR', '', '514', 'z', 0, 1, 'Display note', 'Display note',           5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '515', '', 1, 'Примечание об особенностях нумерации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '515', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '515', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '515', 'a', 0, 0, 'Примечание об особенностях нумерации', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '515', 'z', 0, 0, 'Source of note information (SE) (устаревшее)', 'Source of note information (SE) (устаревшее)', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '516', '', 1, 'Примечание о типе компьютерных файла/данных', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '516', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '516', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '516', 'a', 0, 0, 'Примечание о типе компьютерных файла/данных', '', 5, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '517', '', '', 'Примечание о категории фильма (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '517', 'a', 0, 0, 'Different formats', 'Different formats', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '517', 'b', 0, 1, 'Content descriptors', 'Content descriptors', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '517', 'c', 0, 1, 'Additional animation techniques', 'Additional animation techniques', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '518', '', 1, 'Примечание о дате/времени и месте события', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '518', '3', 0, 0, 'Область применения данных поля', '',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '518', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '518', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '518', 'a', 0, 0, 'Date/time and place of an event note', 'Date/time and place of an event note', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '520', '', 1, 'Аннотация', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '520', '3', 0, 0, 'Область применения данных поля', '',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '520', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '520', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '520', 'a', 0, 0, 'Аннотация', '',                          5, -1, 'biblio.abstract', '', '', NULL, '', '', NULL),
 ('VR', '', '520', 'b', 0, 0, 'Примечание, содержащее расширенную аннотацию', '', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '520', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -1, '', '', '', 1, '', '', NULL),
 ('VR', '', '520', 'z', 0, 0, 'Source of note information (устаревшее)', 'Source of note information (устаревшее)', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '521', '', 1, 'Примечание о целевом назначении', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '521', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '521', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '521', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '521', 'a', 0, 1, 'Примечание о целевом назначении', '',  5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '521', 'b', 0, 0, 'Источник, определяющий целевое назначение', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '522', '', 1, 'Примечание о географичесском охвате', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '522', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '522', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '522', 'a', 0, 0, 'Примечание о географичесском охвате', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '523', '', '', 'Примечание о периоде времени в содержании (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '523', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '523', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '523', 'a', 0, 0, 'Примечание о периоде времени в содержании', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '524', '', 1, 'Примечание о предпочтительной форме ссылки на описываемый материал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '524', '2', 0, 0, 'Source of schema used', 'Source of schema used', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '524', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '524', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '524', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '524', 'a', 0, 0, 'Примечание о предпочтительной форме ссылки на описываемый материал', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '525', '', '', 'Примечание о приложении', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '525', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '525', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '525', 'a', 0, 0, 'Примечание о приложении', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '525', 'z', 0, 0, 'Source of note information (SE) (устаревшее)', 'Source of note information (SE) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '526', '', '', 'Информационное примечание об учебной программе', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '526', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'a', 0, 0, 'Program name', 'Program name',           5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'b', 0, 0, 'Interest level', 'Interest level',       5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'c', 0, 0, 'Reading level', 'Reading level',         5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'd', 0, 0, 'Title point value', 'Title point value', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'i', 0, 0, 'Display text', 'Display text',           5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'x', 0, 1, 'Служебное примечание', '',               5, 6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '526', 'z', 0, 1, 'Примечание для ЭК', '',                  5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '527', '', 1, 'Примечание о цензуре (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '527', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '527', 'a', 0, 0, 'Примечание о цензуре', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '530', '', 1, 'Примечание о допольнительных формах', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '530', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', 'a', 0, 0, 'Примечание о допольнительных формах', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', 'b', 0, 0, 'Availability source', 'Availability source', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', 'c', 0, 0, 'Availability conditions', 'Availability conditions', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', 'd', 0, 0, 'Order number', 'Order number',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '530', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL),
 ('VR', NULL, '530', 'z', 0, 0, 'Source of note information (AM CF VM SE) (устаревшее)', 'Source of note information (AM CF VM SE) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '533', '', 1, 'Примечание о копиях', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '533', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'a', 0, 0, 'Тип копии', '',                        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'b', 0, 1, 'Место копирования', '',                5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'c', 0, 1, 'Организация, ответ. за копир.', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'd', 0, 0, 'Дата копирования', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'e', 0, 0, 'Физ. описание копии', '',              5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'f', 0, 1, 'Данные о серии', '',                   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'm', 0, 1, 'Даты и поряд. обозн. воспр. вып.', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '533', 'n', 0, 1, 'Примечание к копии', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '534', '', 1, 'Примечание об оригинале', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '534', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'a', 0, 0, 'Заголовок на оригинал', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'b', 0, 0, 'Область издания', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'c', 0, 0, 'Выходные данные оригинала', '',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'e', 0, 0, 'Физические характеристики оригинала', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'f', 0, 0, 'Область серии оригинала', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'k', 0, 1, 'Ключевое заглавие оригинала', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'l', 0, 0, 'Место оригинала', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'm', 0, 0, 'Спец. характеристики', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'n', 0, 1, 'Примечание об оригинале', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'p', 0, 0, 'Вводные слова', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 't', 0, 0, 'Область заглавия на оригинал', '',     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'x', 0, 1, 'ISSN', '',                             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '534', 'z', 0, 1, 'ISBN', '',                             5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '535', '', 1, 'Примечание о хранении', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '535', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', '6', 0, 0, 'Элемент связи', 'Элемент связи',       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', 'a', 0, 0, 'Хранилище', '',                        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', 'b', 0, 1, 'Почтовый адрес', '',                   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', 'c', 0, 1, 'Страна', '',                           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', 'd', 0, 1, 'Адрес телекоммуникаций', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '535', 'g', 0, 0, 'Код хранения', '',                     5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '536', '', 1, 'Примечание о проекте, контракте и т. д., по которому финансировалась подготовка материала', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '536', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'a', 0, 0, 'Text of note', 'Text of note',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'b', 0, 1, 'Contract number', 'Contract number',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'c', 0, 1, 'Grant number', 'Grant number',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'd', 0, 1, 'Undifferentiated number', 'Undifferentiated number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'e', 0, 1, 'Program element number', 'Program element number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'f', 0, 1, 'Project number', 'Project number',     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'g', 0, 1, 'Task number', 'Task number',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '536', 'h', 0, 1, 'Work unit number', 'Work unit number', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '537', '', '', 'Примечание об источнике даты (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '537', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '537', 'a', 0, 0, 'Примечание об источнике даты', '',     5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '538', '', 1, 'Примечание о системных особенностях', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '538', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '538', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '538', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '538', 'a', 0, 0, 'Примечание о системных особенностях', '', 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '538', 'i', 0, 0, 'Display text', 'Display text',           5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '538', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '540', '', 1, 'Примечание об условиях использования и воспроизведения', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '540', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '540', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',           5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', 'c', 0, 0, 'Authorization', 'Authorization',         5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', 'd', 0, 0, 'Authorized users', 'Authorized users',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '540', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '541', '', 1, 'Примечание о непосредственном источнике комплектовании', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '541', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '541', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'a', 0, 0, 'Получено от/из', '',                     5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'b', 0, 0, 'Адрес', '',                              5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'c', 0, 0, 'Метод приобретения', '',                 5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'd', 0, 0, 'Дата приобретения', '',                  5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'e', 0, 0, 'Регистрационный номер', '',              5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'f', 0, 0, 'Владелец', '',                           5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'h', 0, 0, 'Цена покупки', '',                       5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'n', 0, 1, 'Количество, объем', '',                  5, 1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '541', 'o', 0, 1, 'Наименование единицы измерения', '',     5, 1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '543', '', 1, 'Примечание о сопроводительной информации (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '543', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '543', 'a', 0, 0, 'Примечание о сопроводительной информации', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '544', '', 1, 'Примечание о местонахождении других архивных материалов', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '544', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '544', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'a', 0, 1, 'Custodian', 'Custodian',                 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'b', 0, 1, 'Address', 'Address',                     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'c', 0, 1, 'Country', 'Country',                     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'd', 0, 1, 'Title', 'Title',                         5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'e', 0, 1, 'Provenance', 'Provenance',               5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '544', 'n', 0, 1, 'Note', 'Note',                           5, -6, '', '', '', NULL, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '545', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '545', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '545', 'a', 0, 0, 'Biographical or historical note', 'Biographical or historical note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '545', 'b', 0, 0, 'Expansion', 'Expansion',                 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '545', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '546', '', 1, 'Примечание о языке', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '546', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '546', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '546', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '546', 'a', 0, 0, 'Примечание о языке', '',               5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '546', 'b', 0, 1, 'Примечание о языке', '',               5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '546', 'z', 0, 0, 'Source of note information (SE) (устаревшее)', 'Source of note information (SE) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '547', '', 1, 'Справка на прежнее заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '547', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '547', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '547', 'a', 0, 0, 'Примечание на прежнее заглавие', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '547', 'z', 0, 0, 'Source of note information (SE) (устаревшее)', 'Source of note information (SE) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '550', '', 1, 'Примечание об издающей организации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '550', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '550', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '550', 'a', 0, 0, 'Примечание об издающей организации', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '550', 'z', 0, 0, 'Source of note information (SE) (устаревшее)', 'Source of note information (SE) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '552', '', 1, 'Информационное примечание об особенностях и характеристиках', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '552', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'a', 0, 0, 'Entity type label', 'Entity type label', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'b', 0, 0, 'Entity type definition and source', 'Entity type definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'c', 0, 0, 'Attribute label', 'Attribute label',     5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'd', 0, 0, 'Attribute definition and source', 'Attribute definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'e', 0, 1, 'Enumerated domain value', 'Enumerated domain value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'f', 0, 1, 'Enumerated domain value definition and source', 'Enumerated domain value definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'g', 0, 0, 'Range domain minimum and maximum', 'Range domain minimum and maximum', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'h', 0, 0, 'Codeset name and source', 'Codeset name and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'i', 0, 0, 'Unrepresentable domain', 'Unrepresentable domain', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'j', 0, 0, 'Attribute units of measurement and resolution', 'Attribute units of measurement and resolution', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'k', 0, 0, 'Beginning date and ending date of attribute values', 'Beginning date and ending date of attribute values', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'l', 0, 0, 'Attribute value accuracy', 'Attribute value accuracy', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'm', 0, 0, 'Attribute value accuracy explanation', 'Attribute value accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'n', 0, 0, 'Attribute measurement frequency', 'Attribute measurement frequency', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'o', 0, 1, 'Entity and attribute overview', 'Entity and attribute overview', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'p', 0, 1, 'Entity and attribute detail citation', 'Entity and attribute detail citation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '552', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('VR', '', '552', 'z', 0, 1, 'Display note', 'Display note',           5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '555', '', 1, 'Примечание о кумулятивном указателе / вспомогательных указателях', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '555', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', 'a', 0, 0, 'Примечание о кумулятивном указателе / вспомогательных указателях', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', 'b', 0, 1, 'Источник приобретения', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', 'c', 0, 0, 'Уровень контроля', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', 'd', 0, 0, 'Библиографическая ссылка', '',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '555', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '556', '', 1, 'Примечание о сопроводительной документации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '556', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '556', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '556', 'a', 0, 0, 'Примечание о сопроводительной документации', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '556', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '561', '', 1, 'История бытования', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '561', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '561', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '561', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '561', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '561', 'a', 0, 0, 'История (примечание)', '',               5, 6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '561', 'b', 0, 0, 'Time of collation (устаревшее)', 'Time of collation (устаревшее)', 5, 6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '562', '', 1, 'Примечание об идентифицирующих признаках копий или версий архивных и рукописных материалов', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '562', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', '5', 0, 0, 'Institution to which field applies', '', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', 'a', 0, 1, 'Identifying markings', 'Identifying markings', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', 'b', 0, 1, 'Copy identification', 'Copy identification', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', 'c', 0, 1, 'Version identification', 'Version identification', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', 'd', 0, 1, 'Presentation format', 'Presentation format', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '562', 'e', 0, 1, 'Number of copies', 'Number of copies', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '563', '', 1, 'Примечание о переплёте', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '563', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '563', '5', 0, 0, 'Принадлежность поля организации', '',  -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '563', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '563', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '563', 'a', 0, 0, 'Binding note', 'Binding note',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '563', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '565', '', 1, 'Примечание о характеристиках блоков файла', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '565', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', 'a', 0, 0, 'Примечание о характеристиках блоков файла', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', 'b', 0, 1, 'Название переменной величины', '',     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', 'c', 0, 1, 'Unit of analysis', 'Unit of analysis', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', 'd', 0, 1, 'Universe of data', 'Universe of data', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '565', 'e', 0, 1, 'Filing scheme or code', 'Filing scheme or code', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '567', '', 1, 'Примечание о применённом методе', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '567', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '567', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '567', 'a', 0, 0, 'Примечание о применённом методе', '',  5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '570', '', 1, 'Примечание о редакторе (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '570', '6', 0, 0, 'Элемент связи', 'Элемент связи',       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '570', 'a', 0, 0, 'Примечание о редакторе', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '570', 'z', 0, 0, 'Source of note information', 'Source of note information', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '580', '', 1, 'Примечание о связи с другими изданиями', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '580', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '580', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '580', 'a', 0, 0, 'Примечание о связи с другими изданиями', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '580', 'z', 0, 0, 'Source of note information (устаревшее)', 'Source of note information (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '581', '', 1, 'Публикации об обрабатываемом материале', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '581', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '581', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '581', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '581', 'a', 0, 0, 'Наименование публикации', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '581', 'z', 0, 1, 'ISBN публикации', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '582', '', 1, 'Примечание о связанном компьютерном файле (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '582', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '582', 'a', 0, 0, 'Примечание о связанном компьютерном файле', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '583', '', 1, 'Примечание о действиях', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '583', '2', 0, 0, 'Источник термина', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '583', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '583', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'a', 0, 0, 'Действие', '',                           5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'b', 0, 1, 'Идентификация действия', '',             5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'c', 0, 1, 'Дата и время действия', '',              5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'd', 0, 1, 'Период времени действия', '',            5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'e', 0, 1, 'Условия во время действия', '',          5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'f', 0, 1, 'Правила действия', '',                   5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'h', 0, 1, 'Ответственное лицо', '',                 5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'i', 0, 1, 'Метод выполнения', '',                   5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'j', 0, 1, 'Место действия', '',                     5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'k', 0, 1, 'Исполнитель действия', '',               5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'l', 0, 1, 'Состояние материала', '',                5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'n', 0, 1, 'Количество, объем', '',                  5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'o', 0, 1, 'Единицы измерения', '',                  5, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'u', 0, 1, 'Унифиц. идентификатор ресурса', '',      5, -1, '', '', '', 1, '', '', NULL),
 ('VR', '', '583', 'x', 0, 1, 'Служебное примечание', '',               5, 4, '', '', '', NULL, '', '', NULL),
 ('VR', '', '583', 'z', 0, 1, 'Открытое примечание', '',                5, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '584', '', 1, 'Обращаемость к материалу, темпы накопления', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '584', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '584', '5', 0, 0, 'Принадлежность поля организации', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '584', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '584', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '584', 'a', 0, 1, 'Accumulation', 'Accumulation',           5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '584', 'b', 0, 1, 'Frequency of use', 'Frequency of use',   5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '585', '', 1, 'Примечание об экспонировании', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '585', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '585', '5', -6, 0, 'Принадлежность поля организации', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '585', '6', 0, 0, 'Элемент связи', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '585', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '585', 'a', 0, 0, 'Примечание об экспонировании', '',       5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '586', '', 1, 'Примечание о наградах', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '586', '3', 0, 0, 'Область применения данных поля', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '586', '6', 0, 0, 'Элемент связи', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '586', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '586', 'a', 0, 0, 'Примечание о наградах', '',            5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '590', '', 1, 'Локальные примечания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '590', '6', 0, 0, 'Элемент связи (RLIN)', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '590', '8', 0, 1, 'Field link and sequence number (RLIN)', 'Field link and sequence number (RLIN)', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '590', 'a', 0, 0, 'Local note', 'Local note',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '590', 'b', 0, 0, 'Provenance (VM) (устаревшее)', 'Provenance (VM) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '590', 'c', 0, 0, 'Condition of individual reels (VM) (устаревшее)', 'Condition of individual reels (VM) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '590', 'd', 0, 0, 'Origin of safety copy (VM) (устаревшее)', 'Origin of safety copy (VM) (устаревшее)', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '600', '', 1, 'Персоналии', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '600', '2', 0, 0, 'Источник рубрики', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '600', 'a', 0, 0, 'Персоналии', '',               6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'b', 0, 0, 'Нумерация', '',                          6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'c', 0, 1, 'Титулы', '',                             6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'd', 0, 0, 'Даты жизни', '',                         6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'e', 0, 1, 'Роль лиц', '',                           6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'f', 0, 0, 'Дата публикации', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'g', 0, 0, 'Прочие сведения', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'h', 0, 0, 'Физический носитель', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'j', 0, 1, 'Принадлежность неизвестного автора к последователям, школе и т. д.', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'k', 0, 1, 'Форма, вид, жанр', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'l', 0, 0, 'Язык произведения', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'o', 0, 0, 'Обозначение аранжировки', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'q', 0, 0, 'Более полная форма имени', '',           6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'r', 0, 0, 'Тональность', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 's', 0, 0, 'Версия, издание', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 't', 0, 0, 'Заглавие произведения', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'u', 0, 0, 'Место работы, членство или адрес лица', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '600', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '610', '', 1, 'Наименование коллектива', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '610', '2', 0, 0, 'Источник рубрики', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '610', 'a', 0, 0, 'Наименование коллектива', '',  6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'b', 0, 1, 'Структурное подразделение', '',          6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'c', 0, 0, 'Место проведения мероприятия', '',       6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'd', 0, 1, 'Дата проведения мероприятия', '',        6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'e', 0, 1, 'Роль коллектива', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'f', 0, 0, 'Дата публикации', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'g', 0, 0, 'Прочие сведения', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'h', 0, 0, 'Физический носитель', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'k', 0, 1, 'Форма, вид, жанр', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'l', 0, 0, 'Язык произведения', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'n', 0, 1, 'Номер части', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'o', 0, 0, 'Обозначение аранжировки', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'p', 0, 1, 'Заглавие части', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'r', 0, 0, 'Тональность', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 's', 0, 0, 'Версия, издание', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 't', 0, 0, 'Заглавие произведения', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'u', 0, 0, 'Место работы, членство или адрес лица', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '610', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '611', '', 1, 'Наименование мероприятия/временного коллектива/организации как доб. предметный поисковый признак', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '611', '2', 0, 0, 'Источник рубрики или термина', '',     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', '3', 0, 0, 'Область применения данных поля', '',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', '4', 0, 1, 'Код отношения', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', '6', 0, 0, 'Элемент связи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '611', 'a', 0, 0, 'Наименование мероприятия как начальный элемент ввода', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  (устаревшее)', 'Number  (BK CF MP MU SE VM MX)  (устаревшее)', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'c', 0, 0, 'Место проведения мероприятия', '',     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'd', 0, 0, 'Дата проведения мероприятия', '',      6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'e', 0, 0, 'Структурное подразделение (соподч. единица)', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'f', 0, 0, 'Дата публикации', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'g', 0, 0, 'Прочая информация', '',                6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'h', 0, 0, 'Физический носитель (обозначение материала)', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'j', 0, 1, 'Термин отношений (роль)', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'k', 0, 1, 'Форма, вид, жанр и т. д. произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'l', 0, 0, 'Язык произведения', '',                6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'n', 0, 1, 'Обозначение и номер части/секции/мероприятия', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'q', 0, 0, 'Наименование мероприятия, подчиненного юрисдикции', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 's', 0, 0, 'Версия, издание и т. д.', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 't', 0, 0, 'Заглавие произведения', '',            6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'u', 0, 0, 'Местонахождение или адрес', '',        6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'v', 0, 1, 'Типовое деление', '',                  6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'x', 0, 1, 'Основное деление', '',                 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'y', 0, 1, 'Хронологическое деление', '',          6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '611', 'z', 0, 1, 'Географическое деление', '',           6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '630', '', 1, 'Унифицированное заглавие (доб. предм. запись)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '630', '2', 0, 0, 'Источник рубрики или термина', '',     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', '3', 0, 0, 'Область применения данных поля', '',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '630', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '630', '6', 0, 0, 'Элемент связи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '630', 'a', 0, 0, 'Унифицированное заглавие', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'd', 0, 1, 'Дата подписания договора', '',         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '630', 'e', 0, 1, 'Термин отношений (роль)', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'f', 0, 0, 'Дата публикации', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'g', 0, 0, 'Прочие сведения', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'h', 0, 0, 'Физический носитель', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'k', 0, 1, 'Форма, вид, жанр', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'l', 0, 0, 'Язык произведения', '',                6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'n', 0, 1, 'Номер части/раздела', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'o', 0, 0, 'Обозначение аранжировки', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'p', 0, 1, 'Заглавие части/раздела', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'r', 0, 0, 'Тональность', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 's', 0, 0, 'Версия, издание', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 't', 0, 0, 'Заглавие произведения', '',            6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'v', 0, 1, 'Типовое деление', '',                  6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'x', 0, 1, 'Основное деление', '',                 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'y', 0, 1, 'Хронологическое деление', '',          6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '630', 'z', 0, 1, 'Географическое деление', '',           6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '648', '', 1, 'Хронологическое понятие как добавочный предметный поисковый признак', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '648', '2', 0, 0, 'Источник рубрики или термина', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', '3', 0, 0, 'Область применения данных поля', '',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', '6', 0, 0, 'Связь', '',                            6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', '8', 0, 1, 'Связь поля и её порядковый номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'CHRON_TERM', '648', 'a', 0, 0, 'Хронологическое понятие', '',  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', 'v', 0, 1, 'Типовое деление', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', 'x', 0, 1, 'Основное деление', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', 'y', 0, 1, 'Хронологическое деление', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '648', 'z', 0, 1, 'Географическое деление', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '650', '', 1, 'Тематические рубрики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '650', '2', 0, 0, 'Источник рубрики', '',                   6, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '650', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, '', '', '', 0, '', '', NULL),
 ('VR', 'TOPIC_TERM', '650', 'a', 0, 0, 'Основная рубрика', '',         6, 0, 'bibliosubject.subject', '', '', 0, '\'6003\',\'600a\',\'600b\',\'600c\',\'600d\',\'600e\',\'600f\',\'600g\',\'600h\',\'600k\',\'600l\',\'600m\',\'600n\',\'600o\',\'600p\',\'600r\',\'600s\',\'600t\',\'600u\',\'600x\',\'600z\',\'600y\',\'600v\',\'6103\',\'610a\',\'610b\',\'610c\',\'610d\',\'610e\',\'610f\',\'610g\',\'610h\',\'610k\',\'610l\',\'610m\',\'610n\',\'610o\',\'610p\',\'610r\',\'610s\',\'610t\',\'610u\',\'610x\',\'610z\',\'610y\',\'610v\',\'6113\',\'611a\',\'611b\',\'611c\',\'611d\',\'611e\',\'611f\',\'611g\',\'611h\',\'611k\',\'611l\',\'611m\',\'611n\',\'611o\',\'611p\',\'611r\',\'611s\',\'611t\',\'611u\',\'611x\',\'611z\',\'611y\',\'611v\',\'630a\',\'630b\',\'630c\',\'630d\',\'630e\',\'630f\',\'630g\',\'630h\',\'630k\',\'630l\',\'630m\',\'630n\',\'630o\',\'630p\',\'630r\',\'630s\',\'630t\',\'630x\',\'630z\',\'630y\',\'630v\',\'6483\',\'648a\',\'648x\',\'648z\',\'648y\',\'648v\',\'6503\',\'650b\',\'650c\',\'650d\',\'650e\',\'650x\',\'650z\',\'650y\',\'650v\',\'6513\',\'651a\',\'651b\',\'651c\',\'651d\',\'651e\',\'651x\',\'651z\',\'651y\',\'651v\',\'653a\',\'6543\',\'654a\',\'654b\',\'654x\',\'654z\',\'654y\',\'654v\',\'6553\',\'655a\',\'655b\',\'655x\',\'655z\',\'655y\',\'655v\',\'6563\',\'656a\',\'656k\',\'656x\',\'656z\',\'656y\',\'656v\',\'6573\',\'657a\',\'657x\',\'657z\',\'657y\',\'657v\',\'658a\',\'658b\',\'658c\',\'658d\',\'658v\'', '', NULL),
 ('VR', '', '650', 'b', 0, 0, 'Пр. гео. рубрика', '',                   6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'c', 0, 0, 'Место события', '',                      6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'd', 0, 0, 'Даты события', '',                       6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'e', 0, 0, 'Термин отношений (роль)', '',            6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'v', 0, 1, 'Типовое деление', '',                    6, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'x', 0, 1, 'Основная подрубрика', '',                6, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'y', 0, 1, 'Хронологическая подрубрика', '',         6, 0, '', '', '', 0, '', '', NULL),
 ('VR', '', '650', 'z', 0, 1, 'Географическая подрубрика', '',          6, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '651', '', 1, 'Географическое наименование', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '651', '2', 0, 0, 'Источник рубрики или термина', '',       6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'GEOGR_NAME', '651', 'a', 0, 0, 'Географическое наименование', '', 6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'b', 0, 1, 'Geographic name following place entry element (устаревшее)', 'Geographic name following place entry element (устаревшее)', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'e', 0, 1, 'Роль, отношение', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'x', 0, 1, 'Основные подзаголовки', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'y', 0, 1, 'Хронологический подзаголовок', '',       6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '651', 'z', 0, 1, 'Географический подзаголовок', '',        6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '652', '', 1, 'Добавочный предметный поисковый признак — аннулированный географический (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '652', 'a', 0, 0, 'Geographic name of place element', 'Geographic name of place element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '652', 'x', 0, 1, 'Основное деление', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '652', 'y', 0, 1, 'Хронологическое деление', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '652', 'z', 0, 1, 'Географическое деление', '',             6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '653', '', 1, 'Ключевые слова', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '653', '6', 0, 0, 'Элемент связи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '653', '8', 0, 1, 'Связь полей и номер последовательности', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '653', 'a', 0, 1, 'Ключевые слова', '',                   6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '654', '', 1, 'Добавочный предметный поисковый признак — фасетный тематический термин', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '654', '2', 0, 0, 'Источник термина', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'TOPIC_TERM', '654', 'a', 0, 1, 'Focus term', 'Focus term',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'b', 0, 1, 'Non-focus term', 'Non-focus term',       6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'e', 0, 1, 'Термин отношений (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'v', 0, 1, 'Типовое деление', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'x', 0, 1, 'Основное деление', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'y', 0, 1, 'Хронологическое деление', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '654', 'z', 0, 1, 'Географическое деление', '',             6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '655', '', 1, 'Термин индексирования — жанр/форма', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '655', '2', 0, 0, 'Источник термина', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', '5', 0, 0, 'Принадлежность поля организации', '',    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'GENRE/FORM', '655', 'a', 0, 0, 'Жанр/форма (устаревшее)', '',  6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'b', 0, 1, 'Non-focus term', 'Non-focus term',       6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '655', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '656', '', 1, 'Термин индексирования — профессия', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '656', '2', 0, 0, 'Источник термина', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'TOPIC_TERM', '656', 'a', 0, 0, 'Occupation', 'Occupation',     6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', 'k', 0, 0, 'Форма, вид, жанр', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '656', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '657', '', 1, 'Термин индексирования — функция', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '657', '2', 0, 0, 'Источник термина', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'TOPIC_TERM', '657', 'a', 0, 0, 'Function', 'Function',         6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '657', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '658', '', 1, 'Термин индексирования — задачи учебного курса', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '658', '2', 0, 0, 'Источник термина', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '658', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '658', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'TOPIC_TERM', '658', 'a', 0, 0, 'Main curriculum objective', 'Main curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '658', 'b', 0, 1, 'Subordinate curriculum objective', 'Subordinate curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '658', 'c', 0, 0, 'Curriculum code', 'Curriculum code',     6, 0, '', '', '', NULL, '', '', NULL),
 ('VR', '', '658', 'd', 0, 0, 'Correlation factor', 'Correlation factor', 6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '662', '', 1, 'Добавочный предметный поисковый признак — иерархическое название местности', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '662', '2', 0, 0, 'Источник термина', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'GEOGR_NAME', '662', 'a', 0, 1, 'Country or larger entity', 'Country or larger entity', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'd', 0, 0, 'City', 'City',                           6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'e', 0, 1, 'Термин отношений (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'f', 0, 1, 'City subsection', 'City subsection',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '662', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '690', '', 1, 'Локальный добавочный предметный поисковый признак — тематическое имя', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '690', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', '2', 0, 0, 'Источник рубрики или термина', '',       6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', 'TOPIC_TERM', '690', 'a', 0, 0, 'Topical term or geographic name as entry element', 'Topical term or geographic name as entry element', 6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'b', 0, 0, 'Topical term following geographic name as entry element', 'Topical term following geographic name as entry element', 6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'c', 0, 0, 'Location of event', 'Location of event', 6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'd', 0, 0, 'Active dates', 'Active dates',           6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'e', 0, 0, 'Термин отношений (роль)', '',            6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'v', 0, 1, 'Типовое деление', '',                    6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'x', 0, 1, 'Основное деление', '',                   6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'y', 0, 1, 'Хронологическое деление', '',            6, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '690', 'z', 0, 1, 'Географическое деление', '',             6, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '691', '', 1, 'Локальный добавочный предметный поисковый признак — географическое имя', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '691', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '691', '2', 0, 0, 'Источник рубрики или термина', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'GEOGR_NAME', '691', 'a', 0, 0, 'Geographic name', 'Geographic name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', 'b', 0, 1, 'Geographic name following place entry element (устаревшее)', 'Geographic name following place entry element (устаревшее)', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', 'v', 0, 1, 'Типовое деление', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', 'x', 0, 1, 'Основное деление', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', 'y', 0, 1, 'Хронологическое деление', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '691', 'z', 0, 1, 'Географическое деление', '',             6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '696', '', 1, 'Локальный добавочный предметный поисковый признак — собственное имя', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '696', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '696', '2', 0, 0, 'Источник рубрики или термина', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '696', 'a', 0, 0, 'Personal name', 'Personal name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'b', 0, 0, 'Numeration', 'Numeration',               6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'e', 0, 1, 'Термин отношений (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'f', 0, 0, 'Дата публикации', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'g', 0, 0, 'Прочие сведения', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'h', 0, 0, 'Физический носитель', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'k', 0, 1, 'Подзаголовок формы', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'l', 0, 0, 'Язык работы', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'o', 0, 0, 'Обозначение аранжировки', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'r', 0, 0, 'Тональность', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 's', 0, 0, 'Версия, издание и т. д.', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 't', 0, 0, 'Заглавие работы', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'u', 0, 0, 'Дополнительные сведения', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'v', 0, 1, 'Типовое деление', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'x', 0, 1, 'Основное деление', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'y', 0, 1, 'Хронологическое деление', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '696', 'z', 0, 1, 'Географическое деление', '',             6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '697', '', 1, 'Локальный добавочный предметный поисковый признак — имя организации', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '697', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '697', '2', 0, 0, 'Источник рубрики или термина', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', '3', 0, 0, 'Область применения данных поля', '',     6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', '4', 0, 1, 'Код отношения', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', '6', 0, 0, 'Элемент связи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '697', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'e', 0, 1, 'Термин отношений (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'f', 0, 0, 'Дата публикации', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'g', 0, 0, 'Прочие сведения', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'h', 0, 0, 'Физический носитель', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'k', 0, 1, 'Подзаголовок формы', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'l', 0, 0, 'Язык работы', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'o', 0, 0, 'Обозначение аранжировки', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'r', 0, 0, 'Тональность', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 's', 0, 0, 'Версия, издание и т. д.', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 't', 0, 0, 'Заглавие работы', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'u', 0, 0, 'Дополнительные сведения', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'v', 0, 1, 'Типовое деление', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'x', 0, 1, 'Основное деление', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'y', 0, 1, 'Хронологическое деление', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '697', 'z', 0, 1, 'Географическое деление', '',             6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '698', '', 1, 'Локальный добавочный предметный поисковый признак — название мероприятия', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '698', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', NULL, '698', '2', 0, 0, 'Источник рубрики или термина', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', '3', 0, 0, 'Область применения данных поля', '',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', '4', 0, 1, 'Код отношения', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', '6', 0, 0, 'Элемент связи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '698', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  (устаревшее)', 'Number  (BK CF MP MU SE VM MX)  (устаревшее)', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'd', 0, 0, 'Date of meeting', 'Date of meeting',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'f', 0, 0, 'Дата публикации', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'g', 0, 0, 'Прочие сведения', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'h', 0, 0, 'Физический носитель', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'k', 0, 1, 'Подзаголовок формы', '',               6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'l', 0, 0, 'Язык работы', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 's', 0, 0, 'Версия, издание и т. д.', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 't', 0, 0, 'Заглавие работы', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'u', 0, 0, 'Дополнительные сведения', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'v', 0, 1, 'Типовое деление', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'x', 0, 1, 'Основное деление', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'y', 0, 1, 'Хронологическое деление', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '698', 'z', 0, 1, 'Географическое деление', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '699', '', 1, 'Локальный добавочный предметный поисковый признак — унифицированный заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '699', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   6, -6, '', '', '', 0, '', '', NULL),
 ('VR', NULL, '699', '2', 0, 0, 'Источник рубрики или термина', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', '3', 0, 0, 'Область применения данных поля', '',   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', '6', 0, 0, 'Элемент связи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '699', 'a', 0, 0, 'Унифицированное заглавие', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'd', 0, 1, 'Дата подписания договора', '',         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'f', 0, 0, 'Дата публикации', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'g', 0, 0, 'Прочие сведения', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'h', 0, 0, 'Физический носитель', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'k', 0, 1, 'Подзаголовок формы', '',               6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'l', 0, 0, 'Язык работы', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'o', 0, 0, 'Обозначение аранжировки', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'r', 0, 0, 'Тональность', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 's', 0, 0, 'Версия, издание и т. д.', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 't', 0, 0, 'Заглавие работы', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'v', 0, 1, 'Типовое деление', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'x', 0, 1, 'Основное деление', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '699', 'y', 0, 1, 'Хронологическое деление', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '700', '', 1, 'Другие авторы', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '700', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', '4', 0, 1, 'Код отношения', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', '6', 0, 0, 'Элемент связи', 'Элемент связи',         7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '700', 'a', 0, 0, 'Другие авторы', '',            7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'b', 0, 0, 'Династический номер', '',                7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'c', 0, 1, 'Титул (звание)', '',                     7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'd', 0, 0, 'Дата', '',                               7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'e', 0, 1, 'Роль лиц', '',                           7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'q', 0, 0, 'Полное имя', '',                         7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 't', 0, 0, 'Заглавие произведения', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'u', 0, 0, 'Дополнение', '',                         7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '700', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '705', '', 1, 'Добавочный поисковый признак — индивидуальное имя (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '705', 'a', 0, 0, 'Personal name', 'Personal name',         7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'b', 0, 0, 'Numeration', 'Numeration',               7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'e', 0, 1, 'Термин отношений (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '705', 't', 0, 0, 'Заглавие работы', '',                    7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '710', '', 1, 'Другие организации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '710', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', '4', 0, 1, 'Код отношения', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', '6', 0, 0, 'Элемент связи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '710', 'a', 0, 0, 'Организация/юрисдикция', '',   7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'b', 0, 1, 'Другие уровни', '',                      7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'c', 0, 0, 'Место', '',                              7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'd', 0, 1, 'Дата', '',                               7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'e', 0, 1, 'Роль коллектива', '',                    7, -1, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'g', 0, 0, 'Прочая информация', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'n', 0, 1, 'Номер', '',                              7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 't', 0, 0, 'Заглавие произведения', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'u', 0, 0, 'Дополнительные сведения', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '710', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '711', '', 1, 'Другие мероприятия', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '711', '3', 0, 0, 'Область применения данных поля', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', '4', 0, 1, 'Код отношения', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', '5', 0, 0, 'Принадлежность поля организации', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', '8', 0, 1, 'Связь поля и её порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '711', 'a', 0, 0, 'Название мероприятия', '',     7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) (устаревшее)', 'Number (BK CF MP MU SE VM MX) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'c', 0, 0, 'Место мероприятия', '',                7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'd', 0, 0, 'Дата мероприятия', '',                 7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'e', 0, 1, 'Соподчиненная единица', '',            7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'f', 0, 0, 'Дата работы', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'g', 0, 0, 'Прочие сведения', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'h', 0, 0, 'Физический носитель', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'j', 0, 1, 'Термин отношений (роль)', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'k', 0, 1, 'Подзаголовок формы', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'l', 0, 0, 'Язык работы', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'n', 0, 1, '№ части/секции', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'p', 0, 1, '№ части/раздела', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'q', 0, 0, 'Наименование мероприятия, подчиненного юрисдикции', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 's', 0, 0, 'Версия, издание и т. д.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 't', 0, 0, 'Заглавие работы', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'u', 0, 0, 'Дополнительные сведения', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '711', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '715', '', 1, 'Добавочный поисковый признак — имя организации (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '715', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   7, -6, '', '', '', 0, '', '', NULL),
 ('VR', NULL, '715', 'a', 0, 0, 'Corporate name or jurisdiction name', 'Corporate name or jurisdiction name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'b', 0, 0, 'Subordinate unit', 'Subordinate unit', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'e', 0, 1, 'Термин отношений (роль)', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'f', 0, 0, 'Дата публикации', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'g', 0, 0, 'Прочие сведения', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'h', 0, 0, 'Физический носитель', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'k', 0, 1, 'Подзаголовок формы', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'l', 0, 0, 'Язык работы', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'r', 0, 0, 'Тональность', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 's', 0, 0, 'Версия, издание и т. д.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 't', 0, 0, 'Заглавие работы', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '715', 'u', 0, 0, 'Nonprinting information', 'Nonprinting information', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '720', '', 1, 'Добавочный поисковый признак — неконтролируемое имя/наименование', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '720', '4', 0, 1, 'Код отношения', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '720', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '720', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '720', 'a', 0, 0, 'Name', 'Name',                         7, -1, '', NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '720', 'e', 0, 1, 'Термин отношений (роль)', '',          7, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '730', '', 1, 'Унифицированное заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '730', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', '6', 0, 0, 'Элемент связи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '730', 'a', 0, 0, 'Унифицированное заглавие', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'd', 0, 1, 'Дата подписания договора', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'k', 0, 1, 'Форма, вид, жанр', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'l', 0, 0, 'Язык программирования', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'n', 0, 1, 'Номер части произведения', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'p', 0, 1, 'Заглавие части/раздела', '',             7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 's', 0, 0, 'Версия, издание', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 't', 0, 0, 'Заглавие работы', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '730', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '740', '', 1, 'Связ./аналит. заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '740', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', '6', 0, 0, 'Элемент связи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', 'a', 0, 0, 'Связ./аналит. заглавие', '',             7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '740', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '752', '', 1, 'Добавочный поисковый признак — иерархическое название местности', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '752', '2', 0, 0, 'Источник рубрики или термина', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'a', 0, 0, 'Country or larger entity', 'Country or larger entity', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'd', 0, 0, 'City', 'City',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'f', 0, 1, 'City subsection', 'City subsection',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '752', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '753', '', 1, 'Системные характеристики доступа', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '753', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '753', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '753', 'a', 0, 0, 'Марка и модель машины', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '753', 'b', 0, 0, 'Язык программирования', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '753', 'c', 0, 0, 'Операционная система', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '754', '', 1, 'Добавочный поисковый признак — таксиметрическая идентификация', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '754', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', 'a', 0, 1, 'Taxonomic name', 'Taxonomic name',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', 'c', 0, 1, 'Taxonomic category', 'Taxonomic category', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', 'd', 0, 1, 'Common or alternative name', 'Common or alternative name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', 'x', 0, 1, 'Non-public note', 'Non-public note',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '754', 'z', 0, 1, 'Примечание для ЭК', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '755', '', 1, 'Добавочный поисковый признак — физические характеристики (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '755', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '755', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '755', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '755', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '755', 'a', 0, 0, 'Access term', 'Access term',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '755', 'x', 0, 1, 'Основное деление', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '755', 'y', 0, 1, 'Хронологическое деление', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '755', 'z', 0, 1, 'Географическое деление', '',             7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '760', '', 1, 'Поисковый признак на основную серию', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '760', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'b', 0, 0, 'Edition', 'Edition',                   7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'n', 0, 1, 'Note', 'Note',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 't', 0, 0, 'Title', 'Title',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '760', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '762', '', 1, 'Поисковый признак на подсерию', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '762', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'b', 0, 0, 'Edition', 'Edition',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'n', 0, 1, 'Note', 'Note',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 't', 0, 0, 'Title', 'Title',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '762', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '765', '', 1, 'Поисковый признак на язык оригинала', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '765', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'b', 0, 0, 'Edition', 'Edition',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'n', 0, 1, 'Note', 'Note',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'q', 0, 0, 'Parallel title (BK SE)  (устаревшее)', 'Parallel title (BK SE)  (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 't', 0, 0, 'Title', 'Title',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '765', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '767', '', 1, 'Поисковый признак на перевод', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '767', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'b', 0, 0, 'Edition', 'Edition',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'n', 0, 1, 'Note', 'Note',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 't', 0, 0, 'Title', 'Title',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '767', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '770', '', 1, 'Поисковый признак на приложение / специальный выпуск', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '770', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number ', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'b', 0, 0, 'Edition', 'Edition',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'n', 0, 1, 'Note', 'Note',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 't', 0, 0, 'Title', 'Title',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '770', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '772', '', 1, 'Поисковый признак на осн. единицу, к которой отн. приложение', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '772', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'a', 0, 0, 'Заголовок / основной поисковый признак на основную единицу (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'd', 0, 0, 'Место, издание и дата издания', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'x', 0, 0, 'I S S N', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '772', 'z', 0, 1, 'I S B N', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '773', '', 1, 'Источник информации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '773', '3', 0, 0, 'Область применения данных поля', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'a', 0, 0, 'Заголовок основной записи', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'd', 0, 0, 'Место и дата издания', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'g', 0, 1, 'Прочая информация', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'h', 0, 0, 'Физ. характ. связ. един.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'k', 0, 1, 'Обл. серии из связ. един.', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'm', 0, 0, 'Специф. данные', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'o', 0, 1, 'Прочие индексы', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'p', 0, 0, 'Abbreviated title', 'Abbreviated title', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 's', 0, 0, 'Унифицированное заглавие', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 't', 0, 0, 'Название источника', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'w', 0, 1, 'Контрольный № источника', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'x', 0, 0, 'I S S N', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '773', 'z', 0, 1, 'I S B N', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '774', '', 1, 'Поисковый признак на сост.часть', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '774', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'a', 0, 0, 'Заголовок основной библиографической записи на составную часть', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'c', 0, 0, 'Уточн. информ.', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'd', 0, 0, 'Место, изд. и дата изд.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'r', 0, 1, 'Номер отчета', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'u', 0, 0, 'Станд. номер тех. отчета', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'w', 0, 1, 'Контр. номер записи', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '774', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '775', '', 1, 'Библ. опис. на другое изд.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '775', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', '7', 0, 1, 'Контрольное подполе', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'a', 0, 0, 'Загол. осн. библ. записи', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'e', 0, 0, 'Language code', 'Language code',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'f', 0, 0, 'Country code', 'Country code',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'i', 0, 0, 'Display text', 'Display text',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'r', 0, 1, 'Номер отчета', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'u', 0, 0, 'Станд. номер тех. отчета', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'w', 0, 1, 'Контрольный номер записи', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '775', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '776', '', 1, 'Поисковый признак на единицу в другой физической форме', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '776', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'a', 0, 0, 'Заголовок / основной поисковый признак на единицу в другой физической форме', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '776', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '777', '', 1, 'Поисковый признак на единицу, изд. в одной обложке с опис.материалом', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '777', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'a', 0, 0, 'Заголовок / основной поисковый признак связываемой записи (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '777', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '780', '', 1, 'Поисковый признак на предшествующее издание', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '780', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'a', 0, 0, 'Заголовок / основной поисковый признак связываемой записи (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '780', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '785', '', 1, 'Поисковый признак на последующее издание', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '785', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'a', 0, 0, 'Заголовок / основной поисковый признак связываемой записи (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '785', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '786', '', 1, 'Поисковый признак на источник данных', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '786', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'a', 0, 0, 'Заголовок / основной поисковый признак на источник данных (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'j', 0, 0, 'Period of content', 'Period of content', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'p', 0, 0, 'Сокращенное заглавие', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '786', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '787', '', 1, 'Поисковый признак на единицу, связ. с описываемой др. отношениями', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '787', '6', 0, 0, 'Связь', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', '7', 0, 0, 'Контрольное поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'a', 0, 0, 'Загол./Осн. поисковый признак связываемой записи (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'b', 0, 0, 'Сведения об издании', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'c', 0, 0, 'Уточняющая информация', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'd', 0, 0, 'Место, издатель и дата издания', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'g', 0, 1, 'Сведения о связи', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'h', 0, 0, 'Физическое описание', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'i', 0, 0, 'Пояснительный текст', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'k', 0, 1, 'Область серии из связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'm', 0, 0, 'Специфические данные', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'n', 0, 1, 'Примечание', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'o', 0, 1, 'Прочие индексы, коды и т.д.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'q', 0, 0, 'Parallel title (BK SE) (устаревшее)', 'Parallel title (BK SE) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'r', 0, 1, 'Report number', 'Report number',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 's', 0, 0, 'Условное или обобщающее заглавие', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 't', 0, 0, 'Заглавие', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'w', 0, 1, 'Контрольный номер связываемой записи', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'x', 0, 0, 'ISSN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '787', 'z', 0, 1, 'ISBN', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '789', '', 1, 'Поисковый признак на составную часть объекта', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '789', '%', 0, 0, '%', '%',                                 7, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '789', '2', 0, 1, 2, 2,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '3', 0, 1, 3, 3,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '4', 0, 1, 4, 4,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '5', 0, 1, 5, 5,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '6', 0, 0, 6, 6,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '7', 0, 1, 7, 7,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', '8', 0, 1, 8, 8,                                     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'a', 0, 1, 'a', 'a',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'b', 0, 1, 'b', 'b',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'c', 0, 1, 'c', 'c',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'd', 0, 1, 'd', 'd',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'e', 0, 1, 'e', 'e',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'f', 0, 1, 'f', 'f',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'g', 0, 1, 'g', 'g',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'h', 0, 1, 'h', 'h',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'i', 0, 1, 'i', 'i',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'j', 0, 1, 'j', 'j',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'k', 0, 1, 'k', 'k',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'l', 0, 1, 'l', 'l',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'm', 0, 1, 'm', 'm',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'n', 0, 1, 'n', 'n',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'o', 0, 1, 'o', 'o',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'p', 0, 1, 'p', 'p',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'q', 0, 1, 'q', 'q',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'r', 0, 1, 'r', 'r',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 's', 0, 1, 's', 's',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 't', 0, 1, 't', 't',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'u', 0, 1, 'u', 'u',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'v', 0, 1, 'v', 'v',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'w', 0, 1, 'w', 'w',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'x', 0, 1, 'x', 'x',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'y', 0, 1, 'y', 'y',                                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '789', 'z', 0, 1, 'z', 'z',                                 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '796', '', 1, 'Локальный добавочный поисковый признак — индивидуальное имя', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '796', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   7, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '796', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', '4', 0, 1, 'Код отношения', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', '6', 0, 0, 'Элемент связи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '796', 'a', 0, 0, 'Personal name', 'Personal name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'b', 0, 0, 'Numeration', 'Numeration',               7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'e', 0, 1, 'Термин отношений (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 't', 0, 0, 'Заглавие работы', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'u', 0, 0, 'Дополнительные сведения', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '796', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '797', '', 1, 'Локальный добавочный поисковый признак — имя организации', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '797', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   7, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '797', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', '4', 0, 1, 'Код отношения', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', '6', 0, 0, 'Элемент связи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '797', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'e', 0, 1, 'Термин отношений (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 't', 0, 0, 'Заглавие работы', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'u', 0, 0, 'Дополнительные сведения', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '797', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '798', '', 1, 'Локальный добавочный поисковый признак — название мероприятия', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '798', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   7, -5, '', '', '', 0, '', '', NULL),
 ('VR', NULL, '798', '3', 0, 0, 'Область применения данных поля', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', '4', 0, 1, 'Код отношения', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', '5', 0, 0, 'Принадлежность поля организации', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', '6', 0, 0, 'Элемент связи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '798', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) (устаревшее)', 'Number (BK CF MP MU SE VM MX) (устаревшее)', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'd', 0, 0, 'Date of meeting', 'Date of meeting',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'f', 0, 0, 'Дата публикации', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'g', 0, 0, 'Прочие сведения', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'h', 0, 0, 'Физический носитель', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'k', 0, 1, 'Подзаголовок формы', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'l', 0, 0, 'Язык работы', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 's', 0, 0, 'Версия, издание и т. д.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 't', 0, 0, 'Заглавие работы', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'u', 0, 0, 'Дополнительные сведения', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '798', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '799', '', 1, 'Локальный добавочный поисковый признак — унифицированное заглавие', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '799', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   7, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '799', '3', 0, 0, 'Область применения данных поля', '',     7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', '5', 0, 0, 'Принадлежность поля организации', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', '6', 0, 0, 'Элемент связи', 'Элемент связи',         7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '799', 'a', 0, 0, 'Унифицированное заглавие', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'd', 0, 1, 'Дата подписания договора', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'f', 0, 0, 'Дата публикации', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'g', 0, 0, 'Прочие сведения', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'h', 0, 0, 'Физический носитель', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'k', 0, 1, 'Подзаголовок формы', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'l', 0, 0, 'Язык работы', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'o', 0, 0, 'Обозначение аранжировки', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'r', 0, 0, 'Тональность', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 's', 0, 0, 'Версия, издание и т. д.', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 't', 0, 0, 'Заглавие работы', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '799', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '800', '', 1, 'Заголовок добавочной библ.записи на серию — имя лица', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '800', '4', 0, 1, 'Код отношений', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '800', 'a', 0, 0, 'Имя лица', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'b', 0, 0, 'Нумерация', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'c', 0, 1, 'Идентифицирующие признаки, ассоциированные с именем лица', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'd', 0, 0, 'Даты, относящиеся к имени', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'e', 0, 1, 'Роль лица, относящиеся к имени', '',     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'j', 0, 1, 'Квалификатор атрибуции (форма, вид жанр и т.д.)', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'm', 0, 1, 'Средство для исполнения муз. произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'n', 0, 1, 'Номер части/раздела работы', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'p', 0, 1, 'Название части/раздела работы', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'q', 0, 0, 'Более полная форма имени', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'r', 0, 0, 'Музыкальный ключ', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 's', 0, 0, 'Версия', '',                             8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '800', 'v', 0, 0, 'Номер тома/последовательное обозначение', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '800', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '810', '', 1, 'Заголовок добавочной библ.записи на серию — наименование организации', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '810', '4', 0, 1, 'Код отношений', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '810', 'a', 0, 0, 'Наименование организации', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'b', 0, 1, 'Структурное подразделение', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'c', 0, 0, 'Место проведения', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'd', 0, 1, 'Дата проведения мероприятия или подписания договора', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'e', 0, 1, 'Термин отношения', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'f', 0, 0, 'Дата работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'm', 0, 1, 'Средство для исполнения муз. произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'n', 0, 1, 'Номер части/раздела работы', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'p', 0, 1, 'Название части/раздела работы', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'r', 0, 0, 'Музыкальный ключ', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 's', 0, 0, 'Версия', '',                             8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '810', 'v', 0, 0, 'Номер тома/последовательное обозначение', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '810', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '811', '', 1, 'Заголовок добавочной библ.записи на серию — наименование мероприятия', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '811', '4', 0, 1, 'Код отношений', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', '6', 0, 0, 'Элемент связи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '811', 'a', 0, 0, 'Наименование мероприятия', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) (устаревшее)', 'Number (BK CF MP MU SE VM MX) (устаревшее)', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'c', 0, 0, 'Место проведения', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'd', 0, 1, 'Дата проведения мероприятия', '',      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'e', 0, 1, 'Структурное подразделение', '',        8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'f', 0, 0, 'Дата работы', '',                      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'g', 0, 0, 'Прочие сведения', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'h', 0, 0, 'Физический носитель', '',              8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'j', 0, 1, 'Термин отношений (роль)', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'k', 0, 1, 'Подзаголовок формы', '',               8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'l', 0, 0, 'Язык работы', '',                      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'n', 0, 1, 'Номер части/раздела работы', '',       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'p', 0, 1, 'Название части/раздела работы', '',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'q', 0, 0, 'Более полная форма имени', '',         8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 's', 0, 0, 'Версия', '',                           8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 't', 0, 0, 'Заглавие работы', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'u', 0, 0, 'Дополнительные сведения', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'v', 0, 0, 'Номер тома/последовательное обозначение', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '811', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '830', '', 1, 'Заголовок добавочной библ.записи на серию — унифицированное заглавие', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '830', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '830', 'a', 0, 0, 'Унифицированное заглавие', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'd', 0, 1, 'Дата подписания договора', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'f', 0, 0, 'Дата работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'm', 0, 1, 'Средство для исполнения муз. произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'n', 0, 1, 'Номер части/раздела работы', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'p', 0, 1, 'Название части/раздела работы', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'r', 0, 0, 'Музыкальный ключ', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 's', 0, 0, 'Версия', '',                             8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '830', 'v', 0, 0, 'Номер тома/последовательное обозначение', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '830', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '840', '', 1, 'Добавочный поисковый признак на серию — название (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '840', 'a', 0, 0, 'Title', 'Title',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '840', 'h', 0, 1, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '840', 'v', 0, 0, 'Обозначение и номер тома / порядковое обозначение', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '841', '', '', 'Значения кодированных данных о фондах', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '841', 'a', 0, 0, 'Type of record', 'Type of record',     8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '841', 'b', 0, 0, 'Fixed-length data elements', 'Fixed-length data elements', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '841', 'e', 0, 0, 'Encoding level', 'Encoding level',     8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '842', '', '', 'Обозначение текстовой физической формы', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '842', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '842', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '842', 'a', 0, 0, 'Textual physical form designator', 'Textual physical form designator', 8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '843', '', 1, 'Примечание о репродуцировании', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '843', '3', 0, 0, 'Область применения данных поля', '',   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', '6', 0, 0, 'Элемент связи', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'a', 0, 0, 'Type of reproduction', 'Type of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'b', 0, 1, 'Place of reproduction', 'Place of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'c', 0, 1, 'Agency responsible for reproduction', 'Agency responsible for reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'd', 0, 0, 'Date of reproduction', 'Date of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'e', 0, 1, 'Physical description of reproduction', 'Physical description of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'f', 0, 1, 'Series statement of reproduction', 'Series statement of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'm', 0, 1, 'Dates of publication and/or sequential designation of issues reproduced', 'Dates of publication and/or sequential designation of issues reproduced', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '843', 'n', 0, 1, 'Note about reproduction', 'Note about reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '844', '', '', 'Наименование единицы', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '844', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '844', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '844', 'a', 0, 0, 'Наименование единицы', '',               8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '845', '', 1, 'Примечание об условиях регулирования использования и репродуцирования', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '845', '3', 0, 0, 'Область применения данных поля', '',   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', '5', 0, 0, 'Принадлежность поля организации', '',  8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', '6', 0, 0, 'Элемент связи', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',         8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', 'c', 0, 0, 'Authorization', 'Authorization',       8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '845', 'd', 0, 0, 'Authorized users', 'Authorized users', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '850', '', 1, 'Организация — держатель', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '850', '8', 0, 1, 'Связь полей и номер последовательности', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '850', 'a', 0, 1, 'Наименование организации', '',         8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '850', 'b', 0, 0, 'Holdings (NR) (MU VM SE) (устаревшее)', 'Holdings (NR) (MU VM SE) (устаревшее)', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '850', 'd', 0, 0, 'Inclusive dates (NR) (MU VM SE) (устаревшее)', 'Inclusive dates (NR) (MU VM SE) (устаревшее)', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '850', 'e', 0, 0, 'Retention statement (NR) (CF MU VM SE) (устаревшее)', 'Retention statement (NR) (CF MU VM SE) (устаревшее)', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '851', '', 1, 'Местонахождение (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '851', '3', 0, 0, 'Область применения данных поля', '',   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', '6', 0, 0, 'Элемент связи', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'a', 0, 0, 'Name (custodian or owner)', 'Name (custodian or owner)', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'b', 0, 0, 'Institutional division', 'Institutional division', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'c', 0, 0, 'Street address', 'Street address',     8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'd', 0, 0, 'Country', 'Country',                   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'e', 0, 0, 'Location of units', 'Location of units', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'f', 0, 0, 'Номер объекта', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '851', 'g', 0, 0, 'Repository location code', 'Repository location code', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '852', '', 1, 'Местонахождение едиицы хранения', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '852', '2', 0, 0, 'Источник схемы расстановки', '',         8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', '3', 0, 0, 'Область применения данных', '',          8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', '6', 0, 0, 'Связь', '',                              8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', '8', 0, 1, 'Sequence number', 'Sequence number',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'a', 0, 0, 'Местонахождение', '',                    8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'b', 0, 1, 'Подразделение', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'c', 0, 1, 'Местонахождение на полке', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'e', 0, 1, 'Адрес', '',                              8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'f', 0, 1, 'Кодированные данные', '',                8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'g', 0, 1, 'Особенности расстановки', '',            8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'h', 0, 0, 'Классифик. часть индекса', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'i', 0, 1, 'Расстановочный признак', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'j', 0, 0, 'Шифр хранения', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'k', 0, 0, 'Префикс шифра хранения', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'l', 0, 0, 'Расстановочная форма заглавия', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'm', 0, 0, 'Суффикс шифра хранения', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'n', 0, 0, 'Код страны', '',                         8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'p', 0, 0, 'Инвентарный номер', '',                  8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'q', 0, 0, 'Физ. особенности экз.', '',              8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 's', 0, 1, 'Copyright article-fee code', 'Copyright article-fee code', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 't', 0, 0, 'Порядковый номер экземпляра', '',        8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', '', 8, 5, '', '', '', 1, '', '', NULL),
 ('VR', '', '852', 'x', 0, 0, 'Примечание, непредназначенное для пользователя', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '852', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '853', '', 1, 'Заголовки и модель — основная библиографическая единица', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '853', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'n', 0, 0, 'Pattern note', 'Pattern note',           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 't', 0, 0, 'Copy', 'Copy',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'w', 0, 0, 'Frequency', 'Frequency',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'x', 0, 0, 'Calendar change', 'Calendar change',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '853', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '854', '', 1, 'Заголовки и модель — дополнительный материал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '854', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'n', 0, 0, 'Pattern note', 'Pattern note',           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 't', 0, 0, 'Copy', 'Copy',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'w', 0, 0, 'Frequency', 'Frequency',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'x', 0, 0, 'Calendar change', 'Calendar change',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '854', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '855', '', 1, 'Заголовки и модель — указатели', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '855', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'n', 0, 0, 'Pattern note', 'Pattern note',           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 't', 0, 0, 'Copy', 'Copy',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'w', 0, 0, 'Frequency', 'Frequency',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'x', 0, 0, 'Calendar change', 'Calendar change',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '855', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '856', '', 1, 'Электронный адрес документа', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '856', '2', 0, 0, 'Способ доступа', '',                     8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', '3', 0, 0, 'Область применения данных поля', '',     8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', '8', 0, 1, 'Связь полей и номер последовательности', '', 8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'a', 0, 1, 'Имя сервера/домена', '',                 8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'b', 0, 1, 'Номер для доступа', '',                  8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'c', 0, 1, 'Информация о сжатии', '',                8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'd', 0, 1, 'Путь', '',                               8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'f', 0, 1, 'Электронное имя', '',                    8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'h', 0, 0, 'Имя пользователя', '',                   8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'i', 0, 0, 'Пароль', '',                             8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'j', 0, 0, 'Количество битов в секунду', '',         8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'k', 0, 0, 'Пароль', '',                             8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'l', 0, 0, 'Вход/начало сеанса', '',                 8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'm', 0, 1, 'Помощь', '',                             8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'n', 0, 0, 'Местонахождение сервера', '',            8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'o', 0, 0, 'Операционная система сервера', '',       8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'p', 0, 0, 'Порт', '',                               8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'q', 0, 0, 'Тип электронного формата', '',           8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'r', 0, 1, 'Структура', '',                          8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 's', 0, 1, 'Размер файла', '',                       8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 't', 0, 1, 'Эмуляция терминала', '',                 8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'u', 0, 1, 'URL', '',                                8, -1, 'biblioitems.url', '', '', 1, '', '', NULL),
 ('VR', '', '856', 'v', 0, 1, 'Часы доступа к ресурсу', '',             8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'w', 0, 1, 'Контрольный номер записи', '',           8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'x', 0, 1, 'Служебное примечание', '',               8, 1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'y', 0, 1, 'Справочный текст', '',                   8, -1, '', '', '', 0, '', '', NULL),
 ('VR', '', '856', 'z', 0, 1, 'Примечание для пользователя', '',        8, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '859', '', 1, 'Локальная контрольная информация', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '859', 'b', 0, 0, 'Operators initials, OID (RLIN)', 'Operators initials, OID (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'c', 0, 0, 'Catalogers initials, CIN (RLIN)', 'Catalogers initials, CIN (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'd', 0, 0, 'TDC (RLIN)', 'TDC (RLIN)',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'l', 0, 0, 'LIB (RLIN)', 'LIB (RLIN)',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'p', 0, 0, 'PRI (RLIN)', 'PRI (RLIN)',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'r', 0, 0, 'REG (RLIN)', 'REG (RLIN)',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'v', 0, 0, 'VER (RLIN)', 'VER (RLIN)',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '859', 'x', 0, 0, 'LDEL (RLIN)', 'LDEL (RLIN)',             8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '863', '', 1, 'Нумерация и хронология — основная библиографическая единица', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '864', '', 1, 'Нумерация и хронология — дополнительный материал', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '865', '', 1, 'Нумерация и хронология — указатели', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '866', '', 1, 'Текстовое описание фонда — основная библиографическая единица', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '866', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '866', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '866', 'a', 0, 0, 'Textual string', 'Textual string',       8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '866', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '866', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '867', '', 1, 'Текстовое описание фонда — дополнительный материал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '867', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '867', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '867', 'a', 0, 0, 'Textual string', 'Textual string',       8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '867', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '867', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '868', '', 1, 'Текстовое описание фонда — указатели', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '868', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '868', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '868', 'a', 0, 0, 'Textual string', 'Textual string',       8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '868', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', 0, '', '', NULL),
 ('VR', '', '868', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '870', '', 1, 'Вариант индивидуального имени (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '870', '4', 0, 1, 'Код отношения', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'a', 0, 0, 'Personal name', 'Personal name',         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'b', 0, 0, 'Numeration', 'Numeration',               8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'e', 0, 1, 'Термин отношений (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '870', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '871', '', 1, 'Вариант фирменного имени (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '871', '4', 0, 1, 'Код отношения', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'e', 0, 1, 'Термин отношений (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '871', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '872', '', 1, 'Вариант названия конференции или мероприятия (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '872', '4', 0, 1, 'Код отношения', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', '6', 0, 0, 'Элемент связи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'b', 0, 0, 'Number (устаревшее)', 'Number (устаревшее)', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'd', 0, 0, 'Date of meeting', 'Date of meeting',   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'f', 0, 0, 'Дата публикации', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'g', 0, 0, 'Прочие сведения', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', '', '872', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'k', 0, 1, 'Подзаголовок формы', '',               8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'l', 0, 0, 'Язык работы', '',                      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 't', 0, 0, 'Заглавие работы', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '872', 'u', 0, 0, 'Дополнительные сведения', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '873', '', 1, 'Вариант унифицированного заголовка (устаревшее)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '873', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'a', 0, 0, 'Унифицированное заглавие', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'd', 0, 1, 'Дата подписания договора', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'o', 0, 0, 'Обозначение аранжировки', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 'r', 0, 0, 'Тональность', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 's', 0, 0, 'Версия, издание и т. д.', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '873', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '876', '', 1, 'Информация об экземпляре — основная библиографическая единица', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '876', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', '8', 0, 1, 'Sequence number', 'Sequence number',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'c', 0, 1, 'Cost', 'Cost',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'd', 0, 1, 'Date acquired', 'Date acquired',         8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'h', 0, 1, 'Use restrictions', 'Use restrictions',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'j', 0, 1, 'Item status', 'Item status',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 't', 0, 0, 'Copy number', 'Copy number',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '876', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '877', '', 1, 'Информация об экземпляре — дополнительный материал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '877', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', '8', 0, 1, 'Sequence number', 'Sequence number',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'c', 0, 1, 'Cost', 'Cost',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'd', 0, 1, 'Date acquired', 'Date acquired',         8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'h', 0, 1, 'Use restrictions', 'Use restrictions',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'j', 0, 1, 'Item status', 'Item status',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 't', 0, 0, 'Copy number', 'Copy number',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '877', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '878', '', 1, 'Информация об экземпляре — указатели', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '878', '3', 0, 0, 'Область применения данных поля', '',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', '6', 0, 0, 'Элемент связи', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', '8', 0, 1, 'Sequence number', 'Sequence number',     8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'c', 0, 1, 'Cost', 'Cost',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'd', 0, 1, 'Date acquired', 'Date acquired',         8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'h', 0, 1, 'Use restrictions', 'Use restrictions',   8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'j', 0, 1, 'Item status', 'Item status',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 't', 0, 0, 'Copy number', 'Copy number',             8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'x', 0, 1, 'Служебное примечание', '',               8, 5, '', '', '', NULL, '', '', NULL),
 ('VR', '', '878', 'z', 0, 1, 'Примечание для ЭК', '',                  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '880', '', 1, 'Данные в иной графике', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '880', '2', 0, 1, 2, 2,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '3', 0, 1, 3, 3,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '4', 0, 1, 4, 4,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '5', 0, 1, 5, 5,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '7', 0, 1, 7, 7,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', '8', 0, 1, 8, 8,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'a', 0, 1, 'a', 'a',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'b', 0, 1, 'b', 'b',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'c', 0, 1, 'c', 'c',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'd', 0, 1, 'd', 'd',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'e', 0, 1, 'e', 'e',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'f', 0, 1, 'f', 'f',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'g', 0, 1, 'g', 'g',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'h', 0, 1, 'h', 'h',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'i', 0, 1, 'i', 'i',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'j', 0, 1, 'j', 'j',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'k', 0, 1, 'k', 'k',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'l', 0, 1, 'l', 'l',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'm', 0, 1, 'm', 'm',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'n', 0, 1, 'n', 'n',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'o', 0, 1, 'o', 'o',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'p', 0, 1, 'p', 'p',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'q', 0, 1, 'q', 'q',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'r', 0, 1, 'r', 'r',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 's', 0, 1, 's', 's',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 't', 0, 1, 't', 't',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'u', 0, 1, 'u', 'u',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'v', 0, 1, 'v', 'v',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'w', 0, 1, 'w', 'w',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'x', 0, 1, 'x', 'x',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'y', 0, 1, 'y', 'y',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '880', 'z', 0, 1, 'z', 'z',                                 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '886', '', 1, 'Поле MARC-формата, отличного от MARC 21', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '886', '0', 0, 1, 0, 0,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '1', 0, 1, 1, 1,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '2', 0, 1, 2, 2,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '3', 0, 1, 3, 3,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '4', 0, 1, 4, 4,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '5', 0, 1, 5, 5,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '6', 0, 1, 6, 6,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '7', 0, 1, 7, 7,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', '8', 0, 1, 8, 8,                                     8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'a', 0, 1, 'a', 'a',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'b', 0, 1, 'b', 'b',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'c', 0, 1, 'c', 'c',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'd', 0, 1, 'd', 'd',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'e', 0, 1, 'e', 'e',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'f', 0, 1, 'f', 'f',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'g', 0, 1, 'g', 'g',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'h', 0, 1, 'h', 'h',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'i', 0, 1, 'i', 'i',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'j', 0, 1, 'j', 'j',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'k', 0, 1, 'k', 'k',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'l', 0, 1, 'l', 'l',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'm', 0, 1, 'm', 'm',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'n', 0, 1, 'n', 'n',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'o', 0, 1, 'o', 'o',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'p', 0, 1, 'p', 'p',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'q', 0, 1, 'q', 'q',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'r', 0, 1, 'r', 'r',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 's', 0, 1, 's', 's',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 't', 0, 1, 't', 't',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'u', 0, 1, 'u', 'u',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'v', 0, 1, 'v', 'v',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'w', 0, 1, 'w', 'w',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'x', 0, 1, 'x', 'x',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'y', 0, 1, 'y', 'y',                                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '886', 'z', 0, 1, 'z', 'z',                                 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '887', '', 1, 'Поле формата, отличного от MARC', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', NULL, '887', '2', 0, 0, 'Source of data', 'Source of data',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '887', 'a', 0, 0, 'Content of non-MARC field', 'Content of non-MARC field', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '896', '', 1, 'Локальный добавочный поисковый признак на серию — индивидуальное имя', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '896', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '896', '4', 0, 1, 'Код отношения', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'PERSO_NAME', '896', 'a', 0, 0, 'Personal name', 'Personal name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'b', 0, 0, 'Numeration', 'Numeration',               8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'e', 0, 1, 'Термин отношений (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'o', 0, 0, 'Обозначение аранжировки', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'r', 0, 0, 'Тональность', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 's', 0, 0, 'Версия, издание и т. д.', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '896', 'v', 0, 0, 'Обозначение и номер тома / порядковая нумерация', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '897', '', 1, 'Локальный добавочный поисковый признак на серию — имя организации ', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '897', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '897', '4', 0, 1, 'Код отношения', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', '6', 0, 0, 'Элемент связи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'CORPO_NAME', '897', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'e', 0, 1, 'Термин отношений (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'o', 0, 0, 'Обозначение аранжировки', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'r', 0, 0, 'Тональность', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 's', 0, 0, 'Версия, издание и т. д.', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'u', 0, 0, 'Дополнительные сведения', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '897', 'v', 0, 0, 'Обозначение и номер тома / порядковая нумерация', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '898', '', 1, 'Локальный добавочный поисковый признак на серию — название мероприятия', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '898', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   8, -6, '', '', '', 0, '', '', NULL),
 ('VR', NULL, '898', '4', 0, 1, 'Код отношения', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', '6', 0, 0, 'Элемент связи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', '8', 0, 1, 'Field link and sequence number ', 'Field link and sequence number ', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', 'MEETI_NAME', '898', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) (устаревшее)', 'Number (BK CF MP MU SE VM MX) (устаревшее)', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'd', 0, 0, 'Date of meeting', 'Date of meeting',   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'f', 0, 0, 'Дата публикации', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'g', 0, 0, 'Прочие сведения', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'h', 0, 0, 'Физический носитель', '',              8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'k', 0, 1, 'Подзаголовок формы', '',               8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'l', 0, 0, 'Язык работы', '',                      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 's', 0, 0, 'Версия, издание и т. д.', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 't', 0, 0, 'Заглавие работы', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'u', 0, 0, 'Дополнительные сведения', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('VR', NULL, '898', 'v', 0, 0, 'Обозначение и номер тома / порядковая нумерация', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('VR', '899', '', 1, 'Локальный добавочный поисковый признак на серию — унифицированное заглавие', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('VR', '', '899', '%', 0, 0, '% (RLIN)', '% (RLIN)',                   8, -6, '', '', '', 0, '', '', NULL),
 ('VR', '', '899', '6', 0, 0, 'Элемент связи', 'Элемент связи',         8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', 'UNIF_TITLE', '899', 'a', 0, 0, 'Унифицированное заглавие', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'd', 0, 1, 'Дата подписания договора', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'f', 0, 0, 'Дата публикации', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'g', 0, 0, 'Прочие сведения', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'h', 0, 0, 'Физический носитель', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'k', 0, 1, 'Подзаголовок формы', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'l', 0, 0, 'Язык работы', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'm', 0, 1, 'Средство исполнения музыкального произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'o', 0, 0, 'Обозначение аранжировки', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'r', 0, 0, 'Тональность', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 's', 0, 0, 'Версия, издание и т. д.', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 't', 0, 0, 'Заглавие работы', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('VR', '', '899', 'v', 0, 0, 'Обозначение и номер тома / порядковое обозначение', '', 8, 5, '', '', '', NULL, '', '', NULL);
