-- На основе MARC21-структуры на английском «GENRE/FORM»
-- Перевод/адаптация: Сергей Дубик, Ольга Баркова (2011)

DELETE FROM auth_types WHERE authtypecode='GENRE/FORM';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES (155, 'GENRE/FORM', 'Термин жанра/формы', 'Термин жанра, формы и/или физических характеристик описываемых материалов');
DELETE FROM auth_tag_structure WHERE authtypecode='GENRE/FORM';
DELETE FROM auth_subfield_structure WHERE authtypecode='GENRE/FORM';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '000', 1, '', 'Маркер', 'Маркер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '000', '@', 1, 0, 'Контрольное поле фиксированной длины', 'Контрольное поле фиксированной длины', 0, 0, '', NULL, 'marc21_leader_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '001', 1, '', 'Контрольный номер', 'Контрольный номер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '001', '@', 0, 0, 'Контрольный номер', 'Контрольный номер', 0, 0, 'auth_header.authid', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '003', 1, '', 'Идентификатор контрольного номера', 'Идентификатор контрольного номера', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '003', '@', 1, 0, 'Контрольное поле', 'Контрольное поле', 0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '005', 1, '', 'Дата и время последней транзакции', 'Дата и время последней транзакции', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '005', '@', 1, 0, 'Контрольное поле', 'Контрольное поле', 0, 0, '', NULL, 'marc21_field_005.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '008', 1, '', 'Элементы данных фиксированной длины', 'Элементы данных фиксированной длины', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '008', '@', 1, 0, 'Контрольное поле фиксированной длины', 'Контрольное поле фиксированной длины', 0, 0, '', NULL, 'marc21_field_008_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '010', '', '', 'Контрольный номер Библиотеки Конгресса', 'Контрольный номер Библиотеки Конгресса', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '010', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '010', 'a', 0, 0, 'Контрольный номер БК', 'Контрольный номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '010', 'z', 0, 1, 'Аннулированный/недействующий контрольный номер БК', 'Аннулированный/недействующий контрольный номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '016', '', 1, 'Контрольный номер национального библиографического агентства', 'Контрольный номер национального библиографического агентства', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '016', '2', 0, 0, 'Источник', 'Источник',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '016', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '016', 'a', 0, 0, 'Контрольный номер записи', 'Контрольный номер записи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '016', 'z', 0, 1, 'Аннулированный/недействующий контрольный номер записи', 'Аннулированный/недействующий контрольный номер записи', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '024', '', 1, 'Другой стандартный идентификатор', 'Другой стандартный идентификатор', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '024', '2', 0, 0, 'Источник номера или кода', 'Источник номера или кода', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', 'a', 0, 0, 'Стандартний номер или код', 'Стандартний номер или код', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', 'c', 0, 0, 'Условия доступности', 'Условия доступности', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', 'd', 0, 0, 'Дополнительные коды, следующие за стандартным номером или кодом', 'Дополнительные коды, следующие за стандартным номером или кодом', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '024', 'z', 0, 1, 'Аннулированный/недействующий стандартний номер или код', 'Аннулированный/недействующий стандартний номер или код', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '035', '', 1, 'Контрольный номер системы', 'Контрольный номер системы', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '035', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '035', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '035', 'a', 0, 0, 'Контрольный номер системы', 'Контрольный номер системы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '035', 'z', 0, 1, 'Аннулированный/недействующий контрольный номер', 'Аннулированный/недействующий контрольный номер', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '040', 1, '', 'Источник каталогизации', 'Источник каталогизации', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '040', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'a', 1, 0, 'Служба первичной каталогизации', 'Служба первичной каталогизации', 0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'b', 0, 0, 'Язык каталогизации', 'Язык каталогизации', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'c', 0, 0, 'Служба перезаписи или преобразования', 'Служба перезаписи или преобразования', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'd', 0, 1, 'Служба модификации', 'Служба модификации', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'e', 0, 0, 'Description conventions', 'Description conventions', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '040', 'f', 0, 0, 'Правила составления предметных рубрик/тезауруса', 'Правила составления предметных рубрик/тезауруса', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '042', '', '', 'Код подлинности [аутентичности]', 'Код подлинности [аутентичности]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '042', 'a', 0, 1, 'Код подлинности [аутентичности]', 'Код подлинности [аутентичности]', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '043', '', '', 'Код географического региона', 'Код географического региона', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '043', '2', 0, 1, 'Source of local code', 'Source of local code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '043', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '043', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '043', 'a', 0, 1, 'Код географического региона', 'Код географического региона', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '043', 'b', 0, 1, 'Local GAC code', 'Local GAC code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '043', 'c', 0, 1, 'ISO code', 'ISO code',           0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '045', '', '', 'Хронологический период, относящийся к заголовку', 'Хронологический период, относящийся к заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '045', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '045', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '045', 'a', 0, 1, 'Код хронологического периода', 'Код хронологического периода', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '045', 'b', 0, 0, 'Форматированный хронологический период от 9999 г. до Рождества Христова и нашей эры', 'Форматированный хронологический период от 9999 г. до Рождества Христова и нашей эры', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '045', 'c', 0, 1, 'Форматированный хронологический период ранее 9999 г. до Рождества Христова', 'Форматированный хронологический период ранее 9999 г. до Рождества Христова', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '050', '', 1, 'Расстановочный шифр Библиотеки Конгресса', 'Расстановочный шифр Библиотеки Конгресса', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '050', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '050', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '050', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '050', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '050', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '050', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '052', '', 1, 'Классификационный код географического региона', 'Классификационный код географического региона', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '052', '2', 0, 0, 'Код источника', 'Код источника', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '052', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '052', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '052', 'a', 0, 0, 'Классификационный код географического региона', 'Классификационный код географического региона', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '052', 'b', 0, 1, 'Классификационный код географического подрегиона', 'Классификационный код географического подрегиона', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '053', '', 1, 'Классификационный индекс БК', 'Классификационный индекс БК', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '053', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '053', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '053', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '053', 'a', 0, 0, 'Классификационный индекс – отдельный индекс О или начальный индекс в ряду', 'Классификационный индекс – отдельный индекс О или начальный индекс в ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '053', 'b', 0, 1, 'Классификационный индекс – последний индекс в ряду', 'Классификационный индекс – последний индекс в ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '053', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '055', '', 1, 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '055', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '055', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '055', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '055', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '055', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '055', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '060', '', 1, 'Расстановочный шифр Национальной медицинской библиотеки', 'Расстановочный шифр Национальной медицинской библиотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '060', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '060', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '060', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '060', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '060', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '060', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '065', '', 1, 'OTHER Классификационный индекс', 'OTHER Классификационный индекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '065', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', 'a', 0, 0, 'Классификационный индекс element--single number or beginning of span', 'Классификационный индекс element--single number or beginning of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', 'b', 0, 0, 'Классификационный индекс element--ending number of span', 'Классификационный индекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '065', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '066', '', '', 'Используемые наборы символов', 'Используемые наборы символов', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '066', 'a', 0, 0, 'Обозначение набора символов, не являющегося по умолчанию набором ASCII G0', 'Обозначение набора символов, не являющегося по умолчанию набором ASCII G0', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '066', 'b', 0, 0, 'Обозначение набора символов, не являющегося по умолчанию набором ASCII G1', 'Обозначение набора символов, не являющегося по умолчанию набором ASCII G1', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '066', 'c', 0, 1, 'Идентификация альтернативного [переключающегося] набора графических символов', 'Идентификация альтернативного [переключающегося] набора графических символов', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '070', '', 1, 'Расстановочный шифр Национальной сельскохозяйственной библиотеки', 'Расстановочный шифр Национальной сельскохозяйственной библиотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '070', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '070', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '070', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '070', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '070', 'd', 0, 0, 'Тома/даты, для которых применяется расстановочный шифр', 'Тома/даты, для которых применяется расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '072', '', 1, 'Код тематической категории', 'Код тематической категории', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '072', '2', 0, 0, 'Код источника', 'Код источника', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '072', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '072', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '072', 'a', 0, 0, 'Код тематической категории', 'Код тематической категории', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '072', 'x', 0, 1, 'Код подраздела тематической категории', 'Код подраздела тематической категории', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '073', '', '', 'Использование подзаголовка', 'Использование подзаголовка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '073', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '073', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '073', 'a', 0, 1, 'Использование подзаголовка', 'Использование подзаголовка', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '073', 'z', 0, 0, 'Код источника', 'Код источника', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '082', '', 1, 'Расстановочный шифр по Десятичной классификации Дьюи', 'Расстановочный шифр по Десятичной классификации Дьюи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '082', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '082', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '083', '', 1, 'Классификационный индекс Десятичной классификации Дьюи', 'Классификационный индекс Десятичной классификации Дьюи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '083', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', 'a', 0, 0, 'Классификационный индекс – отдельный индекс или начальный индекс в ряду', 'Классификационный индекс – отдельный индекс или начальный индекс в ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', 'b', 0, 0, 'Классификационный индекс – последний индекс в ряду', 'Классификационный индекс – последний индекс в ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '083', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '086', '', 1, 'GOVERNMENT DOCUMENT CALL NUMBER', 'GOVERNMENT DOCUMENT CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '086', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', 'a', 0, 0, 'Call number', 'Call number',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '086', 'z', 0, 1, 'Cancelled/invalid call number', 'Cancelled/invalid call number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '087', '', 1, 'GOVERNMENT DOCUMENT Классификационный индекс', 'GOVERNMENT DOCUMENT Классификационный индекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '087', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '087', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '087', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '087', 'a', 0, 0, 'Классификационный индекс element--Single number or beginning number of span', 'Классификационный индекс element--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '087', 'b', 0, 0, 'Классификационный индекс element--Ending number of span', 'Классификационный индекс element--Ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '087', 'c', 0, 0, 'Explanatory information', 'Explanatory information', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '091', '', '', 'LOCALLY ASSIGNED LC-TYPE Классификационный индекс (OCLC); LOCAL Классификационный индекс (RLIN)', 'LOCALLY ASSIGNED LC-TYPE Классификационный индекс (OCLC); LOCAL Классификационный индекс (RLIN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '091', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', 'a', 0, 0, 'Классификационный индекс element--single number or beginning number of span', 'Классификационный индекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', 'b', 0, 0, 'Классификационный индекс element--ending number of span', 'Классификационный индекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '091', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '092', '', 1, 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '092', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '093', '', 1, 'LOCALLY ASSIGNED DEWEY Классификационный индекс (OCLC)', 'LOCALLY ASSIGNED DEWEY Классификационный индекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '093', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', 'a', 0, 0, 'Классификационный индекс element--single number or beginning number of span', 'Классификационный индекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', 'b', 0, 0, 'Классификационный индекс element--ending number of span', 'Классификационный индекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '093', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '096', '', 1, 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '096', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '097', '', 1, 'LOCALLY ASSIGNED NLM-TYPE Классификационный индекс (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE Классификационный индекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '097', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', 'a', 0, 0, 'Классификационный индекс element--single number or beginning number of span', 'Классификационный индекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', 'b', 0, 0, 'Классификационный индекс element--ending number of span', 'Классификационный индекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', 'c', 0, 0, 'Поясняющий термин', 'Поясняющий термин', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '097', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '098', '', 1, 'OTHER CLASSIFICATION SCHEMES (OCLC)', 'OTHER CLASSIFICATION SCHEMES (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '098', '2', 0, 0, 'Номер издания', 'Номер издания', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', '6', 0, 0, 'Элемент связи', 'Элемент связи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', 'b', 0, 0, 'Номер единицы', 'Номер единицы', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', 'd', 0, 0, 'Тома/даты, к которым относится расстановочный шифр', 'Тома/даты, к которым относится расстановочный шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '155', '', '', 'HEADING--GENRE/FORM TERM', 'HEADING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '155', '6', 0, 0, 'Элемент связи', 'Элемент связи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '155', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '155', 'a', 0, 0, 'Genre/form term', 'Genre/form term', 1, 0, '', NULL, NULL, 0, '\'155v\',\'155x\',\'155z\',\'155y\'', 0),
 ('', 'GENRE/FORM', '155', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '155', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '155', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '155', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '185', '', '', 'HEADING--FORM SUBDIVISION', 'HEADING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '185', '6', 0, 0, 'Элемент связи', 'Элемент связи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '185', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '185', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '185', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '185', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '185', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '260', '', 1, 'Комплексная ссылка «см.» – предмет', 'Комплексная ссылка «см.» – предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '260', '6', 0, 0, 'Элемент связи', 'Элемент связи', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '260', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '260', 'a', 0, 1, 'Заголовок, к которому делается ссылка', 'Заголовок, к которому делается ссылка', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '260', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 2, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '360', '', 1, 'Комплексная ссылка «см. также» – предмет', 'Комплексная ссылка «см. также» – предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '360', '6', 0, 0, 'Элемент связи', 'Элемент связи', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '360', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '360', 'a', 0, 1, 'Заголовок, к которому делается ссылка', 'Заголовок, к которому делается ссылка', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '360', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 3, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '400', '', 1, 'Трассировка ссылки «см.» – имя лица', 'Трассировка ссылки «см.» – имя лица', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '400', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'a', 0, 0, 'Имя лица', 'Имя лица',           4, 0, '', NULL, NULL, 0, '\'400b\',\'400c\',\'400q\',\'400d\',\'400t\',\'400o\',\'400m\',\'400r\',\'400s\',\'400k\',\'400n\',\'400p\',\'400g\',\'400l\',\'400f\',\'400h\',\'400x\',\'400z\',\'400y\',\'400v\'', 0),
 ('', 'GENRE/FORM', '400', 'b', 0, 0, 'Нумерация', 'Нумерация',         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'c', 0, 1, 'Титулы (звания) и другие слова, ассоциируемые с именем', 'Титулы (звания) и другие слова, ассоциируемые с именем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'd', 0, 0, 'Даты, ассоциируемые с именем', 'Даты, ассоциируемые с именем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'e', 0, 1, 'Термин авторского отношения', 'Термин авторского отношения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'f', 0, 0, 'Дата работы', 'Дата работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'h', 0, 0, 'Носитель', 'Носитель',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'l', 0, 0, 'Язык работы', 'Язык работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'n', 0, 1, 'Номер части/раздела работы', 'Номер части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'q', 0, 0, 'Наиболее полная форма имени', 'Наиболее полная форма имени', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 's', 0, 0, 'Версия', 'Версия',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '400', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '410', '', 1, 'Трассировка ссылки «см.» – наименование организации', 'Трассировка ссылки «см.» – наименование организации', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '410', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'a', 0, 0, 'Наименование организации или наименование юрисдикции как элемент ввода', 'Наименование организации или наименование юрисдикции как элемент ввода', 4, 0, '', NULL, NULL, 0, '\'410b\',\'410c\',\'410d\',\'410t\',\'410o\',\'410m\',\'410r\',\'410s\',\'410k\',\'410n\',\'410p\',\'410g\',\'410l\',\'410f\',\'410h\',\'410x\',\'410z\',\'410y\',\'410v\'', 0),
 ('', 'GENRE/FORM', '410', 'b', 0, 1, 'Соподчиненная единица', 'Соподчиненная единица', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'c', 0, 0, 'Место проведения мероприятия', 'Место проведения мероприятия', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'd', 0, 1, 'Дата проведения мероприятия или подписания договора', 'Дата проведения мероприятия или подписания договора', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'e', 0, 1, 'Термин авторского отношения', 'Термин авторского отношения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'f', 0, 0, 'Дата работы', 'Дата работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'h', 0, 0, 'Носитель', 'Носитель',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'l', 0, 0, 'Язык работы', 'Язык работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'n', 0, 1, 'Номер части/секции/мероприятия', 'Номер части/секции/мероприятия', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 's', 0, 0, 'Версия', 'Версия',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '410', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '411', '', 1, 'Трассировка ссылки «см.» – наименование мероприятия', 'Трассировка ссылки «см.» – наименование мероприятия', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '411', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'a', 0, 0, 'Наименование мероприятия или наименование юрисдикции как элемент ввода', 'Наименование мероприятия или наименование юрисдикции как элемент ввода', 4, 0, '', NULL, NULL, 0, '\'411e\',\'411c\',\'411d\',\'411t\',\'411s\',\'411k\',\'411n\',\'411p\',\'411g\',\'411l\',\'411f\',\'411h\',\'411x\',\'411z\',\'411y\',\'411v\'', 0),
 ('', 'GENRE/FORM', '411', 'b', 0, 0, 'Number {OBSOLETE]', 'Number {OBSOLETE]', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'c', 0, 0, 'Место проведения мероприятия', 'Место проведения мероприятия', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'd', 0, 0, 'Дата проведения мероприятия', 'Дата проведения мероприятия', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'e', 0, 1, 'Соподчиненная единица', 'Соподчиненная единица', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'f', 0, 0, 'Дата работы', 'Дата работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'h', 0, 0, 'Носитель', 'Носитель',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'l', 0, 0, 'Язык работы', 'Язык работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'n', 0, 1, 'Номер части/секции/мероприятия', 'Номер части/секции/мероприятия', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'q', 0, 0, 'Наименование мероприятия, следующее за наименованием юрисдикции, который является элементом ввода', 'Наименование мероприятия, следующее за наименованием юрисдикции, который является элементом ввода', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 's', 0, 0, 'Версия', 'Версия',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '411', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '430', '', 1, 'Трассировка ссылки «см.» – унифицированное заглавие', 'Трассировка ссылки «см.» – унифицированное заглавие', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '430', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'a', 0, 0, 'Унифицированное заглавие', 'Унифицированное заглавие', 4, 0, '', NULL, NULL, 0, '\'430o\',\'430m\',\'430r\',\'430s\',\'430d\',\'430k\',\'430n\',\'430p\',\'430g\',\'430l\',\'430f\',\'430h\',\'430t\',\'430x\',\'430z\',\'430y\',\'430v\'', 0),
 ('', 'GENRE/FORM', '430', 'd', 0, 1, 'Дата подписания договора', 'Дата подписания договора', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'f', 0, 0, 'Дата работы', 'Дата работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'h', 0, 0, 'Носитель', 'Носитель',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'l', 0, 0, 'Язык работы', 'Язык работы',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'n', 0, 1, 'Номер части/раздела работы', 'Номер части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 's', 0, 0, 'Версия', 'Версия',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '430', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '448', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL TERM', 'SEE FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '448', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'a', 0, 0, 'Chronological term', 'Chronological term', 4, 0, '', NULL, NULL, 0, '\'448y\',\'448x\',\'448z\',\'448v\'', 0),
 ('', 'GENRE/FORM', '448', 'i', 0, 1, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '448', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '450', '', 1, 'Трассировка ссылки «см.» – тематический термин', 'Трассировка ссылки «см.» – тематический термин', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '450', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'a', 0, 0, 'Topical term or Географическое название entry element', 'Topical term or Географическое название entry element', 4, 0, '', NULL, NULL, 0, '\'450x\',\'450z\',\'450y\',\'450v\'', 0),
 ('', 'GENRE/FORM', '450', 'b', 0, 0, 'Topical term following Географическое название entry element', 'Topical term following Географическое название entry element', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '450', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '451', '', 1, 'Трассировка ссылки «см.» – географическое название', 'Трассировка ссылки «см.» – географическое название', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '451', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'a', 0, 0, 'Географическое название', 'Географическое название', 4, 0, '', NULL, NULL, 0, '\'451z\',\'451x\',\'451y\',\'451v\'', 0),
 ('', 'GENRE/FORM', '451', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '451', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '455', '', 1, 'SEE FROM TRACING--GENRE/FORM TERM', 'SEE FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '455', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'a', 0, 0, 'Genre/form term', 'Genre/form term', 4, 0, '', NULL, NULL, 0, '\'455v\',\'455x\',\'455z\',\'455y\'', 0),
 ('', 'GENRE/FORM', '455', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '455', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '480', '', 1, 'SEE FROM TRACING--GENERAL SUBDIVISION', 'SEE FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '480', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '480', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '481', '', 1, 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '481', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '481', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '482', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '482', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '482', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '485', '', 1, 'SEE FROM TRACING--FORM SUBDIVISION', 'SEE FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '485', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', '6', 0, 0, 'Элемент связи', 'Элемент связи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '485', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '500', '', 1, 'Трассировка ссылки «см. также» – имя лица', 'Трассировка ссылки «см. также» – имя лица', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '500', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'a', 0, 0, 'Имя лица', 'Имя лица',           5, 0, '', NULL, NULL, 0, '\'500b\',\'500c\',\'500q\',\'500d\',\'500t\',\'500o\',\'500m\',\'500r\',\'500s\',\'500k\',\'500n\',\'500p\',\'500g\',\'500l\',\'500f\',\'500h\',\'500x\',\'500z\',\'500y\',\'500v\'', 0),
 ('', 'GENRE/FORM', '500', 'b', 0, 0, 'Нумерация', 'Нумерация',         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'c', 0, 1, 'Титулы (звания) и другие слова, ассоциируемые с именем', 'Титулы (звания) и другие слова, ассоциируемые с именем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'd', 0, 0, 'Даты, ассоциируемые с именем', 'Даты, ассоциируемые с именем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'e', 0, 1, 'Термин авторского отношения', 'Термин авторского отношения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'f', 0, 0, 'Дата работы', 'Дата работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'h', 0, 0, 'Носитель', 'Носитель',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'l', 0, 0, 'Язык работы', 'Язык работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'n', 0, 1, 'Номер части/раздела работы', 'Номер части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'q', 0, 0, 'Наиболее полная форма имени', 'Наиболее полная форма имени', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 's', 0, 0, 'Версия', 'Версия',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '500', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '510', '', 1, 'Трассировка ссылки «см. также» – наименование организации', 'Трассировка ссылки «см. также» – наименование организации', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '510', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'a', 0, 0, 'Наименование организации или наименование юрисдикции как элемент ввода', 'Наименование организации или наименование юрисдикции как элемент ввода', 5, 0, '', NULL, NULL, 0, '\'510b\',\'510c\',\'510d\',\'510t\',\'510o\',\'510m\',\'510r\',\'510s\',\'510k\',\'510n\',\'510p\',\'510g\',\'510l\',\'510f\',\'510h\',\'510x\',\'510z\',\'510y\',\'510v\'', 0),
 ('', 'GENRE/FORM', '510', 'b', 0, 1, 'Соподчиненная единица', 'Соподчиненная единица', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'c', 0, 0, 'Место проведения мероприятия', 'Место проведения мероприятия', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'd', 0, 1, 'Дата проведения мероприятия или подписания договора', 'Дата проведения мероприятия или подписания договора', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'e', 0, 1, 'Термин авторского отношения', 'Термин авторского отношения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'f', 0, 0, 'Дата работы', 'Дата работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'h', 0, 0, 'Носитель', 'Носитель',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'l', 0, 0, 'Язык работы', 'Язык работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'n', 0, 1, 'Номер части/секции/мероприятия', 'Номер части/секции/мероприятия', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 's', 0, 0, 'Версия', 'Версия',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '510', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '511', '', 1, 'Трассировка ссылки «см. также» – наименование мероприятия', 'Трассировка ссылки «см. также» – наименование мероприятия', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '511', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'a', 0, 0, 'Наименование мероприятия или наименование юрисдикции как элемент ввода', 'Наименование мероприятия или наименование юрисдикции как элемент ввода', 5, 0, '', NULL, NULL, 0, '\'511e\',\'511c\',\'511d\',\'511t\',\'511s\',\'511k\',\'511n\',\'511p\',\'511g\',\'511l\',\'511f\',\'511h\',\'511x\',\'511z\',\'511y\',\'511v\'', 0),
 ('', 'GENRE/FORM', '511', 'c', 0, 0, 'Место проведения мероприятия', 'Место проведения мероприятия', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'd', 0, 0, 'Дата проведения мероприятия', 'Дата проведения мероприятия', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'e', 0, 1, 'Соподчиненная единица', 'Соподчиненная единица', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'f', 0, 0, 'Дата работы', 'Дата работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'h', 0, 0, 'Носитель', 'Носитель',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'l', 0, 0, 'Язык работы', 'Язык работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'n', 0, 1, 'Номер части/секции/мероприятия', 'Номер части/секции/мероприятия', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'q', 0, 0, 'Наименование мероприятия, следующее за наименованием юрисдикции, который является элементом ввода', 'Наименование мероприятия, следующее за наименованием юрисдикции, который является элементом ввода', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 's', 0, 0, 'Версия', 'Версия',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '511', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '530', '', 1, 'Трассировка ссылки «см. также» – унифицированное заглавие', 'Трассировка ссылки «см. также» – унифицированное заглавие', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '530', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'a', 0, 0, 'Унифицированное заглавие', 'Унифицированное заглавие', 5, 0, '', NULL, NULL, 0, '\'530o\',\'530m\',\'530r\',\'530s\',\'530d\',\'530k\',\'530n\',\'530p\',\'530g\',\'530l\',\'530f\',\'530h\',\'530t\',\'530x\',\'530z\',\'530y\',\'530v\'', 0),
 ('', 'GENRE/FORM', '530', 'd', 0, 1, 'Дата подписания договора', 'Дата подписания договора', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'f', 0, 0, 'Дата работы', 'Дата работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'g', 0, 0, 'Прочая информация', 'Прочая информация', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'h', 0, 0, 'Носитель', 'Носитель',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'k', 0, 1, 'Подзаголовок формы', 'Подзаголовок формы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'l', 0, 0, 'Язык работы', 'Язык работы',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'm', 0, 1, 'Средство для исполнения музыкального произведения', 'Средство для исполнения музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'n', 0, 1, 'Номер части/раздела работы', 'Номер части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'o', 0, 0, 'Сведения об аранжировке музыкального произведения', 'Сведения об аранжировке музыкального произведения', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'p', 0, 1, 'Наименование части/раздела работы', 'Наименование части/раздела работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'r', 0, 0, 'Музыкальный ключ', 'Музыкальный ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 's', 0, 0, 'Версия', 'Версия',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 't', 0, 0, 'Заглавие работы', 'Заглавие работы', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '530', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '548', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '548', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'a', 0, 0, 'Chronological term', 'Chronological term', 5, 0, '', NULL, NULL, 0, '\'548y\',\'548x\',\'548z\',\'548v\'', 0),
 ('', 'GENRE/FORM', '548', 'i', 0, 1, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '548', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '550', '', 1, 'Трассировка ссылки «см. также» – тематический термин', 'Трассировка ссылки «см. также» – тематический термин', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '550', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'a', 0, 0, 'Topical term or Географическое название entry element', 'Topical term or Географическое название entry element', 5, 0, '', NULL, NULL, 0, '\'550x\',\'550z\',\'550y\',\'550v\'', 0),
 ('', 'GENRE/FORM', '550', 'b', 0, 0, 'Topical term following Географическое название entry element', 'Topical term following Географическое название entry element', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '550', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '551', '', 1, 'Трассировка ссылки «см. также» – географическое название', 'Трассировка ссылки «см. также» – географическое название', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '551', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'a', 0, 0, 'Географическое название', 'Географическое название', 5, 0, '', NULL, NULL, 0, '\'551z\',\'551x\',\'551y\',\'551v\'', 0),
 ('', 'GENRE/FORM', '551', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '551', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '555', '', 1, 'SEE ALSO FROM TRACING--GENRE/FORM TERM', 'SEE ALSO FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '555', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'a', 0, 0, 'Genre/form term', 'Genre/form term', 5, 0, '', NULL, NULL, 0, '\'555v\',\'555x\',\'555z\',\'555y\'', 0),
 ('', 'GENRE/FORM', '555', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '555', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '580', '', 1, 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '580', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '580', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '581', '', 1, 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '581', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '581', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '582', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '582', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '582', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '585', '', 1, 'SEE ALSO FROM TRACING--FORM SUBDIVISION', 'SEE ALSO FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '585', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', '6', 0, 0, 'Элемент связи', 'Элемент связи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'i', 0, 0, 'Инструктивный текст ссылки', 'Инструктивный текст ссылки', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '585', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '663', '', '', 'Комплексная ссылка «см. также» – имя/наименование', 'Комплексная ссылка «см. также» – имя/наименование', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '663', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '663', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '663', 'a', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '663', 'b', 0, 1, 'Заголовок, к которому делается ссылка', 'Заголовок, к которому делается ссылка', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '663', 't', 0, 1, 'Заглавие, к которому делается ссылка', 'Заглавие, к которому делается ссылка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '664', '', '', 'Комплексная ссылка «см.» – имя/наименование', 'Комплексная ссылка «см.» – имя/наименование', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '664', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '664', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '664', 'a', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '664', 'b', 0, 1, 'Заголовок, к которому делается ссылка', 'Заголовок, к которому делается ссылка', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '664', 't', 0, 1, 'Заглавие, к которому делается ссылка', 'Заглавие, к которому делается ссылка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '665', '', '', 'Историческая справка', 'Историческая справка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '665', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '665', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '665', 'a', 0, 1, 'Историческая ссылка', 'Историческая ссылка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '666', '', '', 'Общая пояснительная справка – имя/наименование', 'Общая пояснительная справка – имя/наименование', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '666', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '666', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '666', 'a', 0, 1, 'Общая пояснительная справка', 'Общая пояснительная справка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '667', '', 1, 'Общее примечание, не предназначенное для пользователя', 'Общее примечание, не предназначенное для пользователя', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '667', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '667', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '667', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '667', 'a', 0, 0, 'Общее примечание, не предназначенное для пользователя', 'Общее примечание, не предназначенное для пользователя', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '670', '', 1, 'Источник, в котором найдены данные', 'Источник, в котором найдены данные', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '670', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '670', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '670', 'a', 0, 0, 'Ссылка на источник', 'Ссылка на источник', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '670', 'b', 0, 0, 'Найденная информация', 'Найденная информация', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '670', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', 'Унифицированный определитель ресурса (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '675', '', '', 'Источник, в котором данные не найдены', 'Источник, в котором данные не найдены', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '675', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '675', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '675', 'a', 0, 1, 'Ссылка на источник', 'Ссылка на источник', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '678', '', 1, 'BIOGRAPHICAL OR HISTORICAL DATA', 'BIOGRAPHICAL OR HISTORICAL DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '678', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '678', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '678', 'a', 0, 1, 'Biographical or historical data', 'Biographical or historical data', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '678', 'b', 0, 0, 'Expansion', 'Expansion',         6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '678', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', 'Унифицированный определитель ресурса (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '680', '', 1, 'Общее примечание, предназначенное для пользователя', 'Общее примечание, предназначенное для пользователя', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '680', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '680', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '680', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '680', 'a', 0, 1, 'Термин для заголовка или подзаголовка', 'Термин для заголовка или подзаголовка', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '680', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '680', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '681', '', 1, 'Примечание к примеру трассировки предметного заголовка', 'Примечание к примеру трассировки предметного заголовка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '681', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '681', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '681', 'a', 0, 1, 'Термин предметного заголовка или подзаголовка', 'Термин предметного заголовка или подзаголовка', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '681', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '681', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '682', '', '', 'Информация об исключенном заголовке', 'Информация об исключенном заголовке', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '682', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '682', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '682', 'a', 0, 1, 'Заменяющий заголовок', 'Заменяющий заголовок', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '682', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '683', '', 1, 'Примечание, относящееся к истории применения', 'Примечание, относящееся к истории применения', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '683', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', '8', 0, 0, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'a', 0, 1, 'Классификационный индекс--Single number or beginning number of span', 'Классификационный индекс--Single number or beginning number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'c', 0, 1, 'Классификационный индекс--Ending number of span', 'Классификационный индекс--Ending number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'p', 0, 1, 'Corresponding classification field', 'Corresponding classification field', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '683', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '688', '', 1, 'Примечание, относящееся к истории применения', 'Примечание, относящееся к истории применения', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '688', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '688', '6', 0, 0, 'Элемент связи', 'Элемент связи', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '688', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '688', 'a', 0, 0, 'Примечание, относящееся к истории применения', 'Примечание, относящееся к истории применения', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '750', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--TOPICAL TERM', 'ESTABLISHED HEADING LINKING ENTRY--TOPICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '750', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', '6', 0, 0, 'Элемент связи', 'Элемент связи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'a', 0, 0, 'Тематический термин или географическое наименование как элемент ввода', 'Тематический термин или географическое наименование как элемент ввода', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'b', 0, 0, 'Тематический термин следующий за географическим наименованием, который используется как элемент ввода', 'Тематический термин следующий за географическим наименованием, который используется как элемент ввода', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'c', 0, 0, 'Location of event', 'Location of event', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'd', 0, 0, 'Active date', 'Active date',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '750', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '755', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--GENRE/FORM TERM', 'ESTABLISHED HEADING LINKING ENTRY--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '755', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', '6', 0, 0, 'Элемент связи', 'Элемент связи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'a', 0, 0, 'Genre/form term as entry element', 'Genre/form term as entry element', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '755', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '780', '', 1, 'SUBDIVISION LINKING ENTRY--GENERAL SUBDIVISION', 'SUBDIVISION LINKING ENTRY--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '780', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', '6', 0, 0, 'Элемент связи', 'Элемент связи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '780', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '785', '', 1, 'SUBDIVISION LINKING ENTRY--FORM SUBDIVISION', 'SUBDIVISION LINKING ENTRY--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '785', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', '6', 0, 0, 'Элемент связи', 'Элемент связи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', 'w', 0, 0, 'Контрольное подполе', 'Контрольное подполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', 'x', 0, 1, 'Общий подзаголовок', 'Общий подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', 'y', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '785', 'z', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '788', '', '', 'COMPLEX LINKING ENTRY DATA', 'COMPLEX LINKING ENTRY DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '788', '0', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', '5', 0, 1, 'Организация, которая применяет поле', 'Организация, которая применяет поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', '6', 0, 0, 'Элемент связи', 'Элемент связи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', 'a', 0, 1, 'Заголовок, к которому делается ссылка', 'Заголовок, к которому делается ссылка', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '788', 'i', 0, 1, 'Пояснительный текст', 'Пояснительный текст', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '856', '', 1, 'Местонахождение электронного ресурса и доступ к нему', 'Местонахождение электронного ресурса и доступ к нему', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '856', '2', 0, 0, 'Способ доступа', 'Способ доступа', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', '3', 0, 0, 'Область применения данных поля', 'Область применения данных поля', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', '6', 0, 0, 'Элемент связи', 'Элемент связи', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', '8', 0, 1, 'Номер связи и порядковый номер', 'Номер связи и порядковый номер', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'a', 0, 1, 'Имя сервера/домена', 'Имя сервера/домена', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'b', 0, 1, 'Номер для доступа', 'Номер для доступа', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'c', 0, 1, 'Информация о сжатии', 'Информация о сжатии', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'd', 0, 1, 'Путь', 'Путь',                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'f', 0, 1, 'Электронное имя', 'Электронное имя', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'h', 0, 0, 'Исполнитель запроса', 'Исполнитель запроса', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'i', 0, 1, 'Указания', 'Указания',           8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'j', 0, 0, 'Количество битов в секунду', 'Количество битов в секунду', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'k', 0, 0, 'Пароль', 'Пароль',               8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'l', 0, 0, 'Имя пользователя', 'Имя пользователя', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'm', 0, 1, 'Контактные данные для поддержки доступа', 'Контактные данные для поддержки доступа', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'n', 0, 0, 'Место расположения сервера', 'Место расположения сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'o', 0, 0, 'Операционная система сервера', 'Операционная система сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'p', 0, 0, 'Порт', 'Порт',                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'q', 0, 0, 'Тип электронного формата', 'Тип электронного формата', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'r', 0, 0, 'Установки', 'Установки',         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 's', 0, 1, 'Размер файла', 'Размер файла',   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 't', 0, 1, 'Эмуляция терминала', 'Эмуляция терминала', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'u', 0, 1, 'Унифицированный определитель ресурса (URI)', 'Унифицированный определитель ресурса (URI)', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'v', 0, 1, 'Часы доступа к ресурсу', 'Часы доступа к ресурсу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'w', 0, 1, 'Контрольный номер записи', 'Контрольный номер записи', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'x', 0, 1, 'Служебное примечание', 'Служебное примечание', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'y', 0, 1, 'Справочный текст', 'Справочный текст', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '856', 'z', 0, 1, 'Общедоступное примечание', 'Общедоступное примечание', 8, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('GENRE/FORM', '880', '', 1, 'Альтернативное [переключающееся] представление графических символов', 'Альтернативное [переключающееся] представление графических символов', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'GENRE/FORM', '880', '0', 0, 1, 0, 0,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '1', 0, 1, 1, 1,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '2', 0, 1, 2, 2,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '3', 0, 1, 3, 3,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '4', 0, 1, 4, 4,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '5', 0, 1, 5, 5,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '6', 0, 1, 6, 6,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '7', 0, 1, 7, 7,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', '8', 0, 1, 8, 8,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'a', 0, 1, 'a', 'a',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'b', 0, 1, 'b', 'b',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'c', 0, 1, 'c', 'c',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'd', 0, 1, 'd', 'd',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'e', 0, 1, 'e', 'e',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'f', 0, 1, 'f', 'f',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'g', 0, 1, 'g', 'g',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'h', 0, 1, 'h', 'h',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'i', 0, 1, 'i', 'i',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'j', 0, 1, 'j', 'j',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'k', 0, 1, 'k', 'k',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'l', 0, 1, 'l', 'l',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'm', 0, 1, 'm', 'm',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'n', 0, 1, 'n', 'n',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'o', 0, 1, 'o', 'o',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'p', 0, 1, 'p', 'p',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'q', 0, 1, 'q', 'q',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'r', 0, 1, 'r', 'r',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 's', 0, 1, 's', 's',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 't', 0, 1, 't', 't',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'u', 0, 1, 'u', 'u',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'v', 0, 1, 'v', 'v',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'w', 0, 1, 'w', 'w',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'x', 0, 1, 'x', 'x',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'y', 0, 1, 'y', 'y',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'GENRE/FORM', '880', 'z', 0, 1, 'z', 'z',                         8, 0, '', NULL, NULL, 0, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
