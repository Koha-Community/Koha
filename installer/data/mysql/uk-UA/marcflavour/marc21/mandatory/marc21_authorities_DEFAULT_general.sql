-- На основі MARC21-структури англійською „DEFAULT“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

DELETE FROM auth_types WHERE authtypecode='';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES ('', '', 'За умовчанням', '');
DELETE FROM auth_tag_structure WHERE authtypecode='';
DELETE FROM auth_subfield_structure WHERE authtypecode='';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '000', 1, '', 'Маркер', 'Маркер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '000', '@', 1, 0, 'Контрольне поле фіксованої довжини', 'Контрольне поле фіксованої довжини', 0, 0, '', NULL, 'marc21_leader_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '001', 1, '', 'Контрольний номер', 'Контрольний номер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '001', '@', 0, 0, 'Контрольний номер', 'Контрольний номер',   0, 0, 'auth_header.authid', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '003', 1, '', 'Ідентифікатор контрольного номера', 'Ідентифікатор контрольного номера', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '003', '@', 1, 0, 'Контрольне поле', 'Контрольне поле',       0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '005', 1, '', 'Дата і час останньої транзакції', 'Дата і час останньої транзакції', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '005', '@', 1, 0, 'Контрольне поле', 'Контрольне поле',       0, 0, '', NULL, 'marc21_field_005.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '008', 1, '', 'Елементи даних фіксованої довжини', 'Елементи даних фіксованої довжини', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '008', '@', 1, 0, 'Контрольне поле фіксованої довжини', 'Контрольне поле фіксованої довжини', 0, 0, '', NULL, 'marc21_field_008_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '010', '', '', 'Контрольний номер Бібліотеки Конгресу', 'Контрольний номер Бібліотеки Конгресу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '010', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '010', 'a', 0, 0, 'Контрольний номер БК', 'Контрольний номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '010', 'z', 0, 1, 'Анульований/недіючий контрольний номер БК', 'Анульований/недіючий контрольний номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '014', '', 1, 'Зв’язок з бібліографічним записом на серіальну чи багатотомну одиницю', 'Зв’язок з бібліографічним записом на серіальну чи багатотомну одиницю', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '014', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '014', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '014', 'a', 0, 0, 'Контрольний номер взаємозалежного бібліографічного запису', 'Контрольний номер взаємозалежного бібліографічного запису', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '016', '', 1, 'Контрольний номер національної бібліографічної агенції', 'Контрольний номер національної бібліографічної агенції', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '016', '2', 0, 0, 'Джерело', 'Джерело',                       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '016', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '016', 'a', 0, 0, 'Контрольний номер запису', 'Контрольний номер запису', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '016', 'z', 0, 1, 'Анульований/недіючий контрольний номер запису', 'Анульований/недіючий контрольний номер запису', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '020', '', 1, 'Міжнародний стандартний книжковий номер ISBN', 'Міжнародний стандартний книжковий номер ISBN', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '020', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '020', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '020', 'a', 0, 0, 'ISBN', 'ISBN',                             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '020', 'c', 0, 0, 'Умови придбання', 'Умови придбання',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '020', 'z', 0, 1, 'Анульований/недіючий ISBN', 'Анульований/недіючий ISBN', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '022', '', 1, 'Міжнародний стандартний номер серіального видання ISSN', 'Міжнародний стандартний номер серіального видання ISSN', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '022', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '022', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '022', 'a', 0, 0, 'ISSN', 'ISSN',                             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '022', 'y', 0, 1, 'Помилковий ISSN', 'Помилковий ISSN',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '022', 'z', 0, 1, 'Анульованій ISSN', 'Анульованій ISSN',     0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '024', '', 1, 'Інший стандартний ідентифікатор', 'Інший стандартний ідентифікатор', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '024', '2', 0, 0, 'Джерело номера чи коду', 'Джерело номера чи коду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', 'a', 0, 0, 'Стандартний номер чи код', 'Стандартний номер чи код', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', 'c', 0, 0, 'Умови доступності', 'Умови доступності',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', 'd', 0, 0, 'Додаткові коди, що йдуть за стандартним номером або кодом', 'Додаткові коди, що йдуть за стандартним номером або кодом', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '024', 'z', 0, 1, 'Анульований/недіючий стандартний номер чи код', 'Анульований/недіючий стандартний номер чи код', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '031', '', 1, 'MUSICAL INCIPITS INFORMATION', 'MUSICAL INCIPITS INFORMATION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '031', '2', 0, 0, 'System code', 'System code',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'a', 0, 0, 'Number of work', 'Number of work',         0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'b', 0, 0, 'Number of movement', 'Number of movement', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'c', 0, 0, 'Number of excerpt', 'Number of excerpt',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'd', 0, 1, 'Caption or heading', 'Caption or heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'e', 0, 0, 'Role', 'Role',                             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'g', 0, 0, 'Clef', 'Clef',                             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'm', 0, 0, 'Voice/instrument', 'Voice/instrument',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'n', 0, 0, 'Key signature', 'Key signature',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'o', 0, 0, 'Time signature', 'Time signature',         0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'p', 0, 0, 'Musical notation', 'Musical notation',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'q', 0, 1, 'General note', 'General note',             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'r', 0, 0, 'Key or mode', 'Key or mode',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 's', 0, 1, 'Coded validity note', 'Coded validity note', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 't', 0, 1, 'Text incipit', 'Text incipit',             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '031', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '034', '', 1, 'CODED CARTOGRAPHIC MATHEMATICAL DATA', 'CODED CARTOGRAPHIC MATHEMATICAL DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '034', '2', 0, 0, 'Джерело', 'Джерело',                       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'd', 0, 0, 'Coordinates--westernmost longitude', 'Coordinates--westernmost longitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'e', 0, 0, 'Coordinates--easternmost longitude', 'Coordinates--easternmost longitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'f', 0, 0, 'Coordinates--northernmost latitude', 'Coordinates--northernmost latitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'g', 0, 0, 'Coordinates--southernmost latitude', 'Coordinates--southernmost latitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'j', 0, 0, 'Declination--northern limit', 'Declination--northern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'k', 0, 0, 'Declination--southern limit', 'Declination--southern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'm', 0, 0, 'Right ascension--eastern limit', 'Right ascension--eastern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'n', 0, 0, 'Right ascension--western limit', 'Right ascension--western limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'p', 0, 0, 'Equinox', 'Equinox',                       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'r', 0, 1, 'Distance from earth', 'Distance from earth', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 's', 0, 1, 'G-ring latitude', 'G-ring latitude',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 't', 0, 1, 'G-ring longitude', 'G-ring longitude',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'x', 0, 0, 'Beginning date', 'Beginning date',         0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'y', 0, 0, 'Ending date', 'Ending date',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '034', 'z', 0, 0, 'Name of extraterrestrial body', 'Name of extraterrestrial body', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '035', '', 1, 'Контрольний номер системи', 'Контрольний номер системи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '035', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '035', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '035', 'a', 0, 0, 'Контрольний номер системи', 'Контрольний номер системи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '035', 'z', 0, 1, 'Анульований/недіючий контрольний номер', 'Анульований/недіючий контрольний номер', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '040', 1, '', 'Джерело каталогізації', 'Джерело каталогізації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '040', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', 'a', 1, 0, 'Служба первинної каталогізації', 'Служба первинної каталогізації', 0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0),
 ('', '', '040', 'b', 0, 0, 'Мова каталогізації', 'Мова каталогізації', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', 'c', 0, 0, 'Управління перезапису або перетворення', 'Управління перезапису або перетворення', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', 'd', 0, 1, 'Служба змін', 'Служба змін',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', 'e', 0, 0, 'Description conventions', 'Description conventions', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '040', 'f', 0, 0, 'Правила складання предметних рубрик/тезаурусу', 'Правила складання предметних рубрик/тезаурусу', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '042', '', '', 'Код справжності [автентичності]', 'Код справжності [автентичності]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '042', 'a', 0, 1, 'Код справжності [автентичності]', 'Код справжності [автентичності]', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '043', '', '', 'Код географічного регіону', 'Код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '043', '2', 0, 1, 'Source of local code', 'Source of local code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '043', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '043', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '043', 'a', 0, 1, 'Код географічного регіону', 'Код географічного регіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '043', 'b', 0, 1, 'Local GAC code', 'Local GAC code',         0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '043', 'c', 0, 1, 'ISO code', 'ISO code',                     0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '045', '', '', 'Хронологічний період, що відноситься до заголовку', 'Хронологічний період, що відноситься до заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '045', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '045', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '045', 'a', 0, 1, 'Код хронологічного періоду', 'Код хронологічного періоду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '045', 'b', 0, 0, 'Форматований хронологічний період від 9999 р. до Різдва Христового і нашої ери', 'Форматований хронологічний період від 9999 р. до Різдва Христового і нашої ери', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '045', 'c', 0, 1, 'Форматований хронологічний період раніше 9999 до Різдва Христового', 'Форматований хронологічний період раніше 9999 до Різдва Христового', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '050', '', 1, 'Расстановочний шифр Бібліотеки Конгресу', 'Расстановочний шифр Бібліотеки Конгресу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '050', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує полеОрганізація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '050', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '050', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '050', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '050', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '050', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '052', '', 1, 'Класифікаційний код географічного регіону', 'Класифікаційний код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '052', '2', 0, 0, 'Код джерела', 'Код джерела',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '052', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '052', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '052', 'a', 0, 0, 'Класифікаційний код географічного регіону', 'Класифікаційний код географічного регіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '052', 'b', 0, 1, 'Класифікаційний код географічного підрегіону', 'Класифікаційний код географічного підрегіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '053', '', 1, 'Класифікаційний індекс БК', 'Класифікаційний індекс БК', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '053', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '053', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '053', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '053', 'a', 0, 0, 'Класифікаційний індекс — окремий індекс О або початковий індекс у ряду', 'Класифікаційний індекс — окремий індекс О або початковий індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '053', 'b', 0, 1, 'Класифікаційний індекс - останній індекс у ряду', 'Класифікаційний індекс - останній індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '053', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '055', '', 1, 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '055', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '055', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '055', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '055', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '055', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '055', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '058', '', 1, 'LC Класифікаційний індекс ASSIGNED IN CANADA [OBSOLETE, CAN/MARC]', 'LC Класифікаційний індекс ASSIGNED IN CANADA [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '058', '5', 0, 1, 'Library to which class number applies', 'Library to which class number applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '058', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '058', 'a', 0, 0, 'LC Класифікаційний індекс--Single number or beginning number of a range', 'LC Класифікаційний індекс--Single number or beginning number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '058', 'b', 0, 0, 'LC Класифікаційний індекс--End number of a range', 'LC Класифікаційний індекс--End number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '058', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '060', '', 1, 'Розстановочний шифр Національної медичної бібліотеки', 'Розстановочний шифр Національної медичної бібліотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '060', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '060', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '060', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '060', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '060', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '060', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '063', '', 1, 'NLM Класифікаційний індекс ASSIGNED BY NLM [OBSOLETE, CAN/MARC]', 'NLM Класифікаційний індекс ASSIGNED BY NLM [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '063', 'a', 0, 0, 'NLM Класифікаційний індекс--Single number or beginning number of a range', 'NLM Класифікаційний індекс--Single number or beginning number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '063', 'b', 0, 0, 'NLM Класифікаційний індекс--End number of a range', 'NLM Класифікаційний індекс--End number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '063', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '065', '', 1, 'OTHER Класифікаційний індекс', 'OTHER Класифікаційний індекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '065', '2', 0, 0, 'Number source', 'Number source',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning of span', 'Класифікаційний індекс element--single number or beginning of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '065', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '066', '', '', 'Використовувані набори символів', 'Використовувані набори символів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '066', 'a', 0, 0, 'Позначення набору символів, який не є за умовчанням набором ASCII G0', 'Позначення набору символів, який не є за умовчанням набором ASCII G0', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '066', 'b', 0, 0, 'Позначення набору символів, який не є за умовчанням набором ASCII G1', 'Позначення набору символів, який не є за умовчанням набором ASCII G1', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '066', 'c', 0, 1, 'Ідентифікація альтернативного [що перемикається] до G0 і G1 набору графічних символів', 'Ідентифікація альтернативного [що перемикається] до G0 і G1 набору графічних символів', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '068', '', 1, 'NLM Класифікаційний індекс ASSIGNED IN CANADA [OBSOLETE, CAN/MARC]', 'NLM Класифікаційний індекс ASSIGNED IN CANADA [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '068', '5', 0, 1, 'Library to which class number applies', 'Library to which class number applies', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '068', 'a', 0, 0, 'NLM Класифікаційний індекс--Single number or beginning number of a range', 'NLM Класифікаційний індекс--Single number or beginning number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '068', 'b', 0, 0, 'NLM Класифікаційний індекс--End number of a range', 'NLM Класифікаційний індекс--End number of a range', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '068', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '070', '', 1, 'Розстановочний шифр Національної сільськогосподарської бібліотеки', 'Розстановочний шифр Національної сільськогосподарської бібліотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '070', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '070', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '070', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '070', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '070', 'd', 0, 0, 'Тома/дати, для яких застосовується розстановочний шифр', 'Тома/дати, для яких застосовується розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '072', '', 1, 'Код тематичної категорії', 'Код тематичної категорії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '072', '2', 0, 0, 'Код джерела', 'Код джерела',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '072', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '072', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '072', 'a', 0, 0, 'Код тематичної категорії', 'Код тематичної категорії', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '072', 'x', 0, 1, 'Код підрозбиття тематичної категорії', 'Код підрозбиття тематичної категорії', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '073', '', '', 'Використання підзаголовку', 'Використання підзаголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '073', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '073', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '073', 'a', 0, 1, 'Використання підзаголовку', 'Використання підзаголовку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '073', 'z', 0, 0, 'Код джерела', 'Код джерела',               0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '082', '', 1, 'Розстановочний шифр за Десятковою класифікацією Дьюї', 'Розстановочний шифр за Десятковою класифікацією Дьюї', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '082', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '082', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '083', '', 1, 'Класифікаційний індекс Десяткової класифікації Дьюї', 'Класифікаційний індекс Десяткової класифікації Дьюї', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '083', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', 'a', 0, 0, 'Класифікаційний індекс — окремий індекс або початковий індекс у ряду', 'Класифікаційний індекс — окремий індекс або початковий індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', 'b', 0, 0, 'Класифікаційний індекс — останній індекс у ряду', 'Класифікаційний індекс — останній індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '083', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '084', '', '', 'CLASSIFICATION SCHEME AND EDITION [CLASSIFICATION FORMAT]', 'CLASSIFICATION SCHEME AND EDITION [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '084', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'a', 0, 0, 'Classification scheme code', 'Classification scheme code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'b', 0, 0, 'Edition title', 'Edition title',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'c', 0, 0, 'Edition identifier', 'Edition identifier', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'd', 0, 0, 'Source edition identifier', 'Source edition identifier', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'e', 0, 1, 'Language code', 'Language code',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'f', 0, 1, 'Authorization', 'Authorization',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '084', 'n', 0, 1, 'Variations', 'Variations',                 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '086', '', 1, 'GOVERNMENT DOCUMENT CALL NUMBER', 'GOVERNMENT DOCUMENT CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '086', '2', 0, 0, 'Number source', 'Number source',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', 'a', 0, 0, 'Call number', 'Call number',               0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '086', 'z', 0, 1, 'Cancelled/invalid call number', 'Cancelled/invalid call number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '087', '', 1, 'GOVERNMENT DOCUMENT Класифікаційний індекс', 'GOVERNMENT DOCUMENT Класифікаційний індекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '087', '2', 0, 0, 'Number source', 'Number source',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '087', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '087', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '087', 'a', 0, 0, 'Класифікаційний індекс element--Single number or beginning number of span', 'Класифікаційний індекс element--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '087', 'b', 0, 0, 'Класифікаційний індекс element--Ending number of span', 'Класифікаційний індекс element--Ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '087', 'c', 0, 0, 'Explanatory information', 'Explanatory information', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '088', '', 1, 'DOCUMENT SHELVING NUMBER (CODOC) [OBSOLETE, CAN/MARC]', 'DOCUMENT SHELVING NUMBER (CODOC) [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '088', 'a', 0, 0, 'Document shelving number (CODOC)', 'Document shelving number (CODOC)', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '091', '', '', 'LOCALLY ASSIGNED LC-TYPE Класифікаційний індекс (OCLC); LOCAL Класифікаційний індекс (RLIN)', 'LOCALLY ASSIGNED LC-TYPE Класифікаційний індекс (OCLC); LOCAL Класифікаційний індекс (RLIN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '091', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '091', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '092', '', 1, 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '092', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '093', '', 1, 'LOCALLY ASSIGNED DEWEY Класифікаційний індекс (OCLC)', 'LOCALLY ASSIGNED DEWEY Класифікаційний індекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '093', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '093', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '096', '', 1, 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '096', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '097', '', 1, 'LOCALLY ASSIGNED NLM-TYPE Класифікаційний індекс (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE Класифікаційний індекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '097', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '097', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '098', '', 1, 'OTHER CLASSIFICATION SCHEMES (OCLC)', 'OTHER CLASSIFICATION SCHEMES (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '098', '2', 0, 0, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '100', '', '', 'Заголовок – ім’я особи', 'Заголовок – ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '100', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',                 1, 0, '', NULL, NULL, 0, '\'100b\',\'100c\',\'100q\',\'100d\',\'100t\',\'100o\',\'100m\',\'100r\',\'100s\',\'100k\',\'100n\',\'100p\',\'100g\',\'100l\',\'100f\',\'100h\',\'100x\',\'100z\',\'100y\',\'100v\'', 0),
 ('', '', '100', 'b', 0, 0, 'Нумерація', 'Нумерація',                   1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'h', 0, 0, 'Носій', 'Носій',                           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 's', 0, 0, 'Версія', 'Версія',                         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '100', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '110', '', '', 'Заголовок — найменування організації', 'Заголовок — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '110', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 1, 0, '', NULL, NULL, 0, '\'110b\',\'110c\',\'110d\',\'110t\',\'110o\',\'110m\',\'110r\',\'110s\',\'110k\',\'110n\',\'110p\',\'110g\',\'110l\',\'110f\',\'110h\',\'110x\',\'110z\',\'110y\',\'110v\'', 0),
 ('', '', '110', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'h', 0, 0, 'Носій', 'Носій',                           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 's', 0, 0, 'Версія', 'Версія',                         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '110', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '111', '', '', 'Заголовок – назва заходу', 'Заголовок – назва заходу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '111', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 1, 0, '', NULL, NULL, 0, '\'111e\',\'111c\',\'111d\',\'111t\',\'111s\',\'111k\',\'111n\',\'111p\',\'111g\',\'111l\',\'111f\',\'111h\',\'111x\',\'111z\',\'111y\',\'111v\'', 0),
 ('', '', '111', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]',   1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'd', 0, 0, 'Дата проведеного заходу', 'Дата проведеного заходу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'h', 0, 0, 'Носій', 'Носій',                           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'j', 0, 0, 'Термін авторського відношення', 'Термін авторського відношення', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 's', 0, 0, 'Версія', 'Версія',                         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '111', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '130', '', '', 'Заголовок — уніфікований заголовок', 'Заголовок — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '130', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 1, 0, '', NULL, NULL, 0, '\'130o\',\'130m\',\'130r\',\'130s\',\'130d\',\'130k\',\'130n\',\'130p\',\'130g\',\'130l\',\'130f\',\'130h\',\'130t\',\'130x\',\'130z\',\'130y\',\'130v\'', 0),
 ('', '', '130', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'h', 0, 0, 'Носій', 'Носій',                           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 's', 0, 0, 'Версія', 'Версія',                         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '130', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '140', '', 1, 'Уніфікований заголовок [OBSOLETE, CAN/MARC]', 'Уніфікований заголовок [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '140', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'd', 0, 1, 'Date of treaty', 'Date of treaty',         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'h', 0, 0, 'Загальне позначення матеріалу', '', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'l', 0, 0, 'Language', 'Language',                     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'n', 0, 1, 'Number of part or section/serial, thematic, or opus number', 'Number of part or section/serial, thematic, or opus number', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'o', 0, 0, 'Arranged or arr. for music', 'Arranged or arr. for music', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'p', 0, 1, 'Part or section', 'Part or section',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'x', 0, 1, 'General subject subdivision', 'General subject subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'y', 0, 1, 'Period subject subdivision', 'Period subject subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '140', 'z', 0, 1, 'Place subject subdivision', 'Place subject subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '143', '', 1, 'COLLECTIVE TITLE [OBSOLETE, CAN/MARC]', 'COLLECTIVE TITLE [OBSOLETE, CAN/MARC]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '143', 'a', 0, 0, 'Collective title', 'Collective title',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'd', 0, 1, 'Date of treaty', 'Date of treaty',         1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'h', 0, 0, 'Загальне позначення матеріалу', '', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'l', 0, 0, 'Language', 'Language',                     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'n', 0, 1, 'Number of part or section/serial, thematic, or opus number', 'Number of part or section/serial, thematic, or opus number', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'o', 0, 0, 'Arranged or arr. for music', 'Arranged or arr. for music', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'p', 0, 1, 'Part or section', 'Part or section',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '143', 's', 0, 1, 'Версія', 'Версія',                         1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '148', '', '', 'HEADING--CHRONOLOGICAL TERM', 'HEADING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '148', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '148', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '148', 'a', 0, 0, 'Chronological term', 'Chronological term', 1, 0, '', NULL, NULL, 0, '\'148y\',\'148x\',\'148z\',\'148v\'', 0),
 ('', '', '148', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '148', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '148', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '148', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '150', '', '', 'Заголовок — тематичний термін', 'Заголовок — тематичний термін', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '150', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', 'a', 0, 0, 'Тематичний термін чи географічне найменування як елемент вводу', 'Тематичний термін чи географічне найменування як елемент вводу', 1, 0, '', NULL, NULL, 0, '\'150x\',\'150z\',\'150y\',\'150v\'', 0),
 ('', '', '150', 'b', 0, 0, 'Тематичний термін, що йде за географічним найменуванням, який використовується як елемент вводу', 'Тематичний термін, що йде за географічним найменуванням, який використовується як елемент вводу', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '150', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '151', '', '', 'Заголовок — географічна назва', 'Заголовок — географічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '151', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', 'a', 0, 0, 'Географічна назва', 'Географічна назва',   1, 0, '', NULL, NULL, 0, '\'151z\',\'151x\',\'151y\',\'151v\'', 0),
 ('', '', '151', 'b', 0, 0, 'Name following place as an entry element {OBSOLETE]', 'Name following place as an entry element {OBSOLETE]', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '151', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '153', '', '', 'Класифікаційний індекс [CLASSIFICATION FORMAT]', 'Класифікаційний індекс [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '153', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'h', 0, 1, 'Caption hierarchy', 'Caption hierarchy',   1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'j', 0, 0, 'Caption', 'Caption',                       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'k', 0, 1, 'Summary number span caption hierarchy', 'Summary number span caption hierarchy', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '153', 'z', 0, 0, 'Table identification', 'Table identification', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '154', '', '', 'GENERAL EXPLANATORY INDEX TERM [CLASSIFICATION FORMAT]', 'GENERAL EXPLANATORY INDEX TERM [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '154', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '154', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '154', 'a', 0, 0, 'General explanatory index term', 'General explanatory index term', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '154', 'b', 0, 1, 'General explanatory index term--Succeeding level', 'General explanatory index term--Succeeding level', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '154', 'f', 0, 1, 'Schedule identification', 'Schedule identification', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '155', '', '', 'HEADING--GENRE/FORM TERM', 'HEADING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '155', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '155', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '155', 'a', 0, 0, 'Genre/form term', 'Genre/form term',       1, 0, '', NULL, NULL, 0, '\'155v\',\'155x\',\'155z\',\'155y\'', 0),
 ('', '', '155', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '155', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '155', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '155', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '180', '', '', 'HEADING--GENERAL SUBDIVISION', 'HEADING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '180', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '180', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '180', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '180', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '180', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '180', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '181', '', '', 'HEADING--GEOGRAPHIC SUBDIVISION', 'HEADING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '181', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '181', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '181', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '181', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '181', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '181', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '182', '', '', 'HEADING--CHRONOLOGICAL SUBDIVISION', 'HEADING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '182', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '182', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '182', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '182', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '182', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '182', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '185', '', '', 'HEADING--FORM SUBDIVISION', 'HEADING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '185', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '185', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '185', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '185', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '185', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '185', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '253', '', 1, 'COMPLEX SEE REFERENCE [CLASSIFICATION FORMAT]', 'COMPLEX SEE REFERENCE [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '253', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', 'a', 0, 1, 'Класифікаційний індекс referred to--Single number or beginning number of span', 'Класифікаційний індекс referred to--Single number or beginning number of span', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', 'c', 0, 1, 'Класифікаційний індекс referred to--Ending number of span', 'Класифікаційний індекс referred to--Ending number of span', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '253', 'z', 0, 1, 'Table identification', 'Table identification', 2, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '260', '', 1, 'Комплексне посилання „див.“ — предмет', 'Комплексне посилання „див.“ — предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '260', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '260', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '260', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '260', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 2, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '353', '', 1, 'COMPLEX SEE ALSO REFERENCE [CLASSIFICATION FORMAT]', 'COMPLEX SEE ALSO REFERENCE [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '353', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', 'a', 0, 1, 'Класифікаційний індекс referred to--Single number or beginning number of span', 'Класифікаційний індекс referred to--Single number or beginning number of span', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', 'c', 0, 1, 'Класифікаційний індекс referred to--Ending number of span', 'Класифікаційний індекс referred to--Ending number of span', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '353', 'z', 0, 1, 'Table identification', 'Table identification', 3, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '360', '', 1, 'Комплексне посилання „див. також“ — предмет', 'Комплексне посилання „див. також“ — предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '360', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '360', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '360', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '360', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 3, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '400', '', 1, 'Трасування посилання „див.“ — ім’я особи', 'Трасування посилання „див.“ — ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '400', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',                 4, 0, '', NULL, NULL, 0, '\'400b\',\'400c\',\'400q\',\'400d\',\'400t\',\'400o\',\'400m\',\'400r\',\'400s\',\'400k\',\'400n\',\'400p\',\'400g\',\'400l\',\'400f\',\'400h\',\'400x\',\'400z\',\'400y\',\'400v\'', 0),
 ('', '', '400', 'b', 0, 0, 'Нумерація', 'Нумерація',                   4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'h', 0, 0, 'Носій', 'Носій',                           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 's', 0, 0, 'Версія', 'Версія',                         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '400', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '410', '', 1, 'Трасування посилання „див.“ — назва організації', 'Трасування посилання „див.“ — назва організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '410', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 4, 0, '', NULL, NULL, 0, '\'410b\',\'410c\',\'410d\',\'410t\',\'410o\',\'410m\',\'410r\',\'410s\',\'410k\',\'410n\',\'410p\',\'410g\',\'410l\',\'410f\',\'410h\',\'410x\',\'410z\',\'410y\',\'410v\'', 0),
 ('', '', '410', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'h', 0, 0, 'Носій', 'Носій',                           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 's', 0, 0, 'Версія', 'Версія',                         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '410', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '411', '', 1, 'Трасування посилання „див.“ — назва заходу', 'Трасування посилання „див.“ — назва заходу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '411', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 4, 0, '', NULL, NULL, 0, '\'411e\',\'411c\',\'411d\',\'411t\',\'411s\',\'411k\',\'411n\',\'411p\',\'411g\',\'411l\',\'411f\',\'411h\',\'411x\',\'411z\',\'411y\',\'411v\'', 0),
 ('', '', '411', 'b', 0, 0, 'Number {OBSOLETE]', 'Number {OBSOLETE]',   4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'd', 0, 0, 'Дата проведеного заходу', 'Дата проведеного заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'h', 0, 0, 'Носій', 'Носій',                           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 's', 0, 0, 'Версія', 'Версія',                         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '411', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '430', '', 1, 'Трасування посилання „див.“ — уніфікований заголовок', 'Трасування посилання „див.“ — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '430', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 4, 0, '', NULL, NULL, 0, '\'430o\',\'430m\',\'430r\',\'430s\',\'430d\',\'430k\',\'430n\',\'430p\',\'430g\',\'430l\',\'430f\',\'430h\',\'430t\',\'430x\',\'430z\',\'430y\',\'430v\'', 0),
 ('', '', '430', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'h', 0, 0, 'Носій', 'Носій',                           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 's', 0, 0, 'Версія', 'Версія',                         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '430', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '448', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL TERM', 'SEE FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '448', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'a', 0, 0, 'Chronological term', 'Chronological term', 4, 0, '', NULL, NULL, 0, '\'448y\',\'448x\',\'448z\',\'448v\'', 0),
 ('', '', '448', 'i', 0, 1, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '448', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '450', '', 1, 'Трасування посилання „див.“ — тематичний термін', 'Трасування посилання „див.“ — тематичний термін', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '450', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'a', 0, 0, 'Topical term or Географічна назва entry element', 'Topical term or Географічна назва entry element', 4, 0, '', NULL, NULL, 0, '\'450x\',\'450z\',\'450y\',\'450v\'', 0),
 ('', '', '450', 'b', 0, 0, 'Topical term following Географічна назва entry element', 'Topical term following Географічна назва entry element', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '450', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '451', '', 1, 'Трасування посилання „див.“ — георафічна назва', 'Трасування посилання „див.“ — георафічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '451', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'a', 0, 0, 'Географічна назва', 'Географічна назва',   4, 0, '', NULL, NULL, 0, '\'451z\',\'451x\',\'451y\',\'451v\'', 0),
 ('', '', '451', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '451', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '453', '', 1, 'INVALID NUMBER TRACING [CLASSIFICATION FORMAT]', 'INVALID NUMBER TRACING [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '453', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'c', 0, 1, 'Classification element--Ending number of span', 'Classification element--Ending number of span', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'h', 0, 1, 'Caption hierarchy', 'Caption hierarchy',   4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'j', 0, 0, 'Caption', 'Caption',                       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'k', 0, 1, 'Summary number span caption hierarchy', 'Summary number span caption hierarchy', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 't', 0, 0, 'Topic', 'Topic',                           4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '453', 'z', 0, 0, 'Table identification', 'Table identification', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '455', '', 1, 'SEE FROM TRACING--GENRE/FORM TERM', 'SEE FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '455', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'a', 0, 0, 'Genre/form term', 'Genre/form term',       4, 0, '', NULL, NULL, 0, '\'455v\',\'455x\',\'455z\',\'455y\'', 0),
 ('', '', '455', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '455', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '480', '', 1, 'SEE FROM TRACING--GENERAL SUBDIVISION', 'SEE FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '480', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '480', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '481', '', 1, 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '481', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '481', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '482', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '482', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '482', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '485', '', 1, 'SEE FROM TRACING--FORM SUBDIVISION', 'SEE FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '485', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '485', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '500', '', 1, 'Трасування посилання „див. також“ — ім’я особи', 'Трасування посилання „див. також“ — ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '500', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',                 5, 0, '', NULL, NULL, 0, '\'500b\',\'500c\',\'500q\',\'500d\',\'500t\',\'500o\',\'500m\',\'500r\',\'500s\',\'500k\',\'500n\',\'500p\',\'500g\',\'500l\',\'500f\',\'500h\',\'500x\',\'500z\',\'500y\',\'500v\'', 0),
 ('', '', '500', 'b', 0, 0, 'Нумерація', 'Нумерація',                   5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'h', 0, 0, 'Носій', 'Носій',                           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 's', 0, 0, 'Версія', 'Версія',                         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '500', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '510', '', 1, 'Трасування посилання „див. також“ — найменування організації', 'Трасування посилання „див. також“ — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '510', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 5, 0, '', NULL, NULL, 0, '\'510b\',\'510c\',\'510d\',\'510t\',\'510o\',\'510m\',\'510r\',\'510s\',\'510k\',\'510n\',\'510p\',\'510g\',\'510l\',\'510f\',\'510h\',\'510x\',\'510z\',\'510y\',\'510v\'', 0),
 ('', '', '510', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'h', 0, 0, 'Носій', 'Носій',                           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 's', 0, 0, 'Версія', 'Версія',                         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '510', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '511', '', 1, 'Трасування посилання „див. також“ — найменування заходу', 'Трасування посилання „див. також“ — найменування заходу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '511', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 5, 0, '', NULL, NULL, 0, '\'511e\',\'511c\',\'511d\',\'511t\',\'511s\',\'511k\',\'511n\',\'511p\',\'511g\',\'511l\',\'511f\',\'511h\',\'511x\',\'511z\',\'511y\',\'511v\'', 0),
 ('', '', '511', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'd', 0, 0, 'Дата проведеного заходу', 'Дата проведеного заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'h', 0, 0, 'Носій', 'Носій',                           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 's', 0, 0, 'Версія', 'Версія',                         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '511', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '530', '', 1, 'Трасування посилання „див. також“ — Уніфікований заголовок', 'Трасування посилання „див. також“ — Уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '530', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 5, 0, '', NULL, NULL, 0, '\'530o\',\'530m\',\'530r\',\'530s\',\'530d\',\'530k\',\'530n\',\'530p\',\'530g\',\'530l\',\'530f\',\'530h\',\'530t\',\'530x\',\'530z\',\'530y\',\'530v\'', 0),
 ('', '', '530', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'h', 0, 0, 'Носій', 'Носій',                           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 's', 0, 0, 'Версія', 'Версія',                         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '530', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '548', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '548', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'a', 0, 0, 'Chronological term', 'Chronological term', 5, 0, '', NULL, NULL, 0, '\'548y\',\'548x\',\'548z\',\'548v\'', 0),
 ('', '', '548', 'i', 0, 1, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '548', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '550', '', 1, 'Трасування посилання „див. також“ — тематичний термін', 'Трасування посилання „див. також“ — тематичний термін', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '550', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'a', 0, 0, 'Topical term or Географічна назва entry element', 'Topical term or Географічна назва entry element', 5, 0, '', NULL, NULL, 0, '\'550x\',\'550z\',\'550y\',\'550v\'', 0),
 ('', '', '550', 'b', 0, 0, 'Topical term following Географічна назва entry element', 'Topical term following Географічна назва entry element', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '550', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '551', '', 1, 'Трасування посилання „див. також“ — географічна назва', 'Трасування посилання „див. також“ — географічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '551', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'a', 0, 0, 'Географічна назва', 'Географічна назва',   5, 0, '', NULL, NULL, 0, '\'551z\',\'551x\',\'551y\',\'551v\'', 0),
 ('', '', '551', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '551', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '553', '', 1, 'VALID NUMBER TRACING [CLASSIFICATION FORMAT]', 'VALID NUMBER TRACING [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '553', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'h', 0, 1, 'Caption hierarchy', 'Caption hierarchy',   5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'j', 0, 0, 'Caption', 'Caption',                       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'k', 0, 1, 'Summary number span caption hierarchy', 'Summary number span caption hierarchy', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 't', 0, 0, 'Topic', 'Topic',                           5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '553', 'z', 0, 0, 'Table identification', 'Table identification', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '555', '', 1, 'SEE ALSO FROM TRACING--GENRE/FORM TERM', 'SEE ALSO FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '555', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'a', 0, 0, 'Genre/form term', 'Genre/form term',       5, 0, '', NULL, NULL, 0, '\'555v\',\'555x\',\'555z\',\'555y\'', 0),
 ('', '', '555', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '555', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '580', '', 1, 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '580', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '580', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '581', '', 1, 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '581', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '581', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '582', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '582', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '582', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '585', '', 1, 'SEE ALSO FROM TRACING--FORM SUBDIVISION', 'SEE ALSO FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '585', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '585', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '640', '', 1, 'Дати публікації серії та/чи позначення томів', 'Дати публікації серії та/чи позначення томів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '640', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '640', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '640', 'a', 0, 0, 'Дати публікації та/чи позначення томів', 'Дати публікації та/чи позначення томів', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '640', 'z', 0, 0, 'Джерело інформації', 'Джерело інформації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '641', '', 1, 'Особливості нумерації серії', 'Особливості нумерації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '641', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '641', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '641', 'a', 0, 0, 'Примітка про особливості нумерації', 'Примітка про особливості нумерації', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '641', 'z', 0, 0, 'Джерело інформації', 'Джерело інформації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '642', '', 1, 'Зразок нумерації серії', 'Зразок нумерації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '642', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '642', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '642', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '642', 'a', 0, 0, 'Зразок нумерації серії', 'Зразок нумерації серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '642', 'd', 0, 0, 'Тома/дати, для яких застосовується зразок нумерації серії', 'Тома/дати, для яких застосовується зразок нумерації серії', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '643', '', 1, 'Місце видання та видавництво/організація, що видає, для серії', 'Місце видання та видавництво/організація, що видає, для серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '643', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '643', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '643', 'a', 0, 1, 'Місце видання', 'Місце видання',           6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '643', 'b', 0, 1, 'Видавництво/організація, що видає', 'Видавництво/організація, що видає', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '643', 'd', 0, 0, 'Тома/дати, для яких зазначаються місце видання та видавництво/організація, що видає', 'Тома/дати, для яких зазначаються місце видання та видавництво/організація, що видає', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '644', '', 1, 'Практика аналізу серії', 'Практика аналізу серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '644', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '644', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '644', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '644', 'a', 0, 0, 'Практика аналізу серії', 'Практика аналізу серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '644', 'b', 0, 0, 'Виключення в практиці аналізу', 'Виключення в практиці аналізу', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '644', 'd', 0, 0, 'Тома/дати, для яких застосовується практика аналізу серій', 'Тома/дати, для яких застосовується практика аналізу серій', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '645', '', 1, 'Практика трасування серії', 'Практика трасування серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '645', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '645', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '645', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '645', 'a', 0, 0, 'Практика трасування серії', 'Практика трасування серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '645', 'd', 0, 0, 'Тома/дати, для яких застосовується практика трасування', 'Тома/дати, для яких застосовується практика трасування', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '646', '', 1, 'Практика систематизації серії', 'Практика систематизації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '646', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '646', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '646', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '646', 'a', 0, 0, 'Практика систематизації серії', 'Практика систематизації серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '646', 'd', 0, 0, 'Тома/дати, для яких застосовується практика систематизації', 'Тома/дати, для яких застосовується практика систематизації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '663', '', '', 'Комплексна посилання „див. також“ — ім’я/найменування', 'Комплексна посилання „див. також“ — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '663', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '663', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '663', 'a', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '663', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '663', 't', 0, 1, 'Назва, до якого робиться посилання', 'Назва, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '664', '', '', 'Комплексне посилання „див.“ — ім’я/найменування', 'Комплексне посилання „див.“ — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '664', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '664', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '664', 'a', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '664', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '664', 't', 0, 1, 'Назва, до якого робиться посилання', 'Назва, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '665', '', '', 'Історична довідка', 'Історична довідка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '665', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '665', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '665', 'a', 0, 1, 'Історичне посилання', 'Історичне посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '666', '', '', 'Загальна пояснювальна довідка — ім’я/найменування', 'Загальна пояснювальна довідка — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '666', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '666', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '666', 'a', 0, 1, 'Загальна пояснювальна довідка', 'Загальна пояснювальна довідка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '667', '', 1, 'Загальне зауваження, не призначене для користувача', 'Загальне зауваження, не призначене для користувача', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '667', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '667', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '667', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '667', 'a', 0, 0, 'Загальне зауваження, не призначене для користувача', 'Загальне зауваження, не призначене для користувача', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '668', '', 1, 'CHARACTERS IN NONROMAN ALPHABETS [OBSOLETE]', 'CHARACTERS IN NONROMAN ALPHABETS [OBSOLETE]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '668', 'a', 0, 0, 'Characters in nonroman alphabet', 'Characters in nonroman alphabet', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '670', '', 1, 'Джерело, в якому знайдені дані', 'Джерело, в якому знайдені дані', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '670', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '670', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '670', 'a', 0, 0, 'Посилання на джерело', 'Посилання на джерело', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '670', 'b', 0, 0, 'Знайдена інформація', 'Знайдена інформація', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '670', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '671', '', 1, 'NOTE--WORK CATALOGUED [OBSOLETE, CAN/MARC ONLY]', 'NOTE--WORK CATALOGUED [OBSOLETE, CAN/MARC ONLY]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '671', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '671', 'a', 0, 1, 'Citation', 'Citation',                     6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '675', '', '', 'Джерело, в якому дані не знайдені', 'Джерело, в якому дані не знайдені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '675', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '675', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '675', 'a', 0, 1, 'Посилання на джерело', 'Посилання на джерело', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '676', '', '', 'NOTE--CATALOGUING RULES (NAMES/TITLES) [OBSOLETE, CAN/MARC ONLY]', 'NOTE--CATALOGUING RULES (NAMES/TITLES) [OBSOLETE, CAN/MARC ONLY]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '676', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '676', 'a', 0, 1, 'Rule number(s) and additional information', 'Rule number(s) and additional information', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '678', '', 1, 'BIOGRAPHICAL OR HISTORICAL DATA', 'BIOGRAPHICAL OR HISTORICAL DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '678', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '678', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '678', 'a', 0, 1, 'Biographical or historical data', 'Biographical or historical data', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '678', 'b', 0, 0, 'Expansion', 'Expansion',                   6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '678', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '680', '', 1, 'Загальне зауваження, призначене для користувача', 'Загальне зауваження, призначене для користувача', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '680', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', 'a', 0, 1, 'Термін для заголовку чи підзаголовку', 'Термін для заголовку чи підзаголовку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span [CLASSIFICATION FORMAT]', 'Класифікаційний індекс--Ending number of span [CLASSIFICATION FORMAT]', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '680', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '681', '', 1, 'Примітка до прикладу трасування предметного заголовку', 'Примітка до прикладу трасування предметного заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '681', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '681', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '681', 'a', 0, 1, 'Термін предметного заголовку чи підзаголовку', 'Термін предметного заголовку чи підзаголовку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '681', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span [CLASSIFICATION FORMAT]', 'Класифікаційний індекс--Ending number of span [CLASSIFICATION FORMAT]', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '681', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '681', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '682', '', '', 'Інформація про вилуений заголовок', 'Інформація про вилуений заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '682', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '682', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '682', 'a', 0, 1, 'Заголовок, що замінює', 'Заголовок, що замінює', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '682', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '683', '', 1, 'Примітка до історії застосування', 'Примітка до історії застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '683', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'p', 0, 1, 'Corresponding classification field', 'Corresponding classification field', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '683', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '684', '', 1, 'AUXILIARY Вказівки NOTE [CLASSIFICATION FORMAT]', 'AUXILIARY Вказівки NOTE [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '684', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', 'j', 0, 0, 'Caption', 'Caption',                       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '684', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '685', '', 1, 'NOTE--SOURCE DATA FOUND (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', 'NOTE--SOURCE DATA FOUND (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '685', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '685', 'a', 0, 1, 'Source consulted and Знайдена інформація', 'Source consulted and Знайдена інформація', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '686', '', 1, 'NOTE--SOURCE DATA NOT FOUND (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', 'NOTE--SOURCE DATA NOT FOUND (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '686', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '686', 'a', 0, 1, 'Source consulted and Знайдена інформація', 'Source consulted and Знайдена інформація', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '687', '', 1, 'NOTE--USAGE (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', 'NOTE--USAGE (SUBJECTS) [OBSOLETE, CAN/MARC ONLY]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '687', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '687', 'a', 0, 1, 'Source consulted and Знайдена інформація', 'Source consulted and Знайдена інформація', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '688', '', 1, 'Примітка до історії застосування', 'Примітка до історії застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '688', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '688', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '688', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '688', 'a', 0, 0, 'Примітка до історії застосування', 'Примітка до історії застосування', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '68a', '', 1, 'HISTORY NOTE [CLASSIFICATION FORMAT]', 'HISTORY NOTE [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '68a', '2', 0, 1, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'a', 0, 1, 'New number--Single number or beginning number of span', 'New number--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'b', 0, 1, 'Previous number--Single number or beginning number of span', 'Previous number--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'c', 0, 1, 'Класифікаційний індекс-ending number of span', 'Класифікаційний індекс-ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'd', 0, 0, 'Date of implementation of authoritative agency', 'Date of implementation of authoritative agency', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'e', 0, 0, 'Local implementation date', 'Local implementation date', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'f', 0, 0, 'Title and publication date', 'Title and publication date', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 't', 0, 1, 'Topic', 'Topic',                           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68a', 'z', 0, 1, 'Table identification', 'Table identification', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '68b', '', 1, 'RELATIONSHIP TO SOURCE NOTE [CLASSIFICATION FORMAT]', 'RELATIONSHIP TO SOURCE NOTE [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '68b', '2', 0, 1, 'Номер видання', 'Номер видання',           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'a', 0, 1, 'Number in edition described in field 084--Single number or beginning number of span', 'Number in edition described in field 084--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'b', 0, 1, 'Number in primary source edition--Single number or beginning number of span', 'Number in primary source edition--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'c', 0, 1, 'Ending number of span', 'Ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'o', 0, 1, 'Number where Вказівкиs are found--Single number or beginning number of span', 'Number where Вказівкиs are found--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 't', 0, 1, 'Topic', 'Topic',                           0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '68b', 'z', 0, 1, 'Table identification', 'Table identification', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '700', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--Ім’я особи', 'ESTABLISHED HEADING LINKING ENTRY--Ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '700', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '4', 0, 1, 'Relator code', 'Relator code',             7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',                 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'b', 0, 0, 'Нумерація', 'Нумерація',                   7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'h', 0, 0, 'Носій', 'Носій',                           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'k', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 's', 0, 0, 'Версія', 'Версія',                         7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '700', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '710', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--CORPORATE NAME', 'ESTABLISHED HEADING LINKING ENTRY--CORPORATE NAME', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '710', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '4', 0, 1, 'Relator code', 'Relator code',             7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '5', 0, 1, 'Організація, яка застосовує поле [CLASSIFICATION FORMAT]', 'Організація, яка застосовує поле [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', '8', 0, 1, 'Field link and field number', 'Field link and field number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'h', 0, 0, 'Носій', 'Носій',                           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 's', 0, 0, 'Версія', 'Версія',                         7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '710', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '711', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--MEETING NAME', 'ESTABLISHED HEADING LINKING ENTRY--MEETING NAME', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '711', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '3', 0, 0, 'Область застосування даних поля', 'Область застосування даних поля', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '4', 0, 1, 'Relator code', 'Relator code',             7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '5', 0, 1, 'Організація, яка застосовує поле [CLASSIFICATION FORMAT]', 'Організація, яка застосовує поле [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'd', 0, 1, 'Дата проведеного заходу or treating signing', 'Дата проведеного заходу or treating signing', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'h', 0, 0, 'Носій', 'Носій',                           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'p', 0, 0, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 's', 0, 0, 'Версія', 'Версія',                         7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '711', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '730', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--Уніфікований заголовок', 'ESTABLISHED HEADING LINKING ENTRY--Уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '730', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'f', 0, 0, 'Дата роботи', 'Дата роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'g', 0, 0, 'Інша інформація', 'Інша інформація',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'h', 0, 0, 'Носій', 'Носій',                           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'l', 0, 0, 'Мова роботи', 'Мова роботи',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'o', 0, 1, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ',           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 's', 0, 0, 'Версія', 'Версія',                         7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '730', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '748', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--CHRONOLOGICAL TERM', 'ESTABLISHED HEADING LINKING ENTRY--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '748', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'a', 0, 0, 'Chronological term', 'Chronological term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '748', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '750', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--TOPICAL TERM', 'ESTABLISHED HEADING LINKING ENTRY--TOPICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '750', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'a', 0, 0, 'Тематичний термін чи географічне найменування як елемент вводу', 'Тематичний термін чи географічне найменування як елемент вводу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'b', 0, 0, 'Тематичний термін, що йде за географічним найменуванням, який використовується як елемент вводу', 'Тематичний термін, що йде за географічним найменуванням, який використовується як елемент вводу', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'c', 0, 0, 'Location of event', 'Location of event',   7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'd', 0, 0, 'Active date', 'Active date',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'i', 0, 1, 'Пояснювальний текст [CLASSIFICATION FORMAT]', 'Пояснювальний текст [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '750', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '751', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--Географічна назва', 'ESTABLISHED HEADING LINKING ENTRY--Географічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '751', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', '3', 0, 0, 'Область застосування даних поля [CLASSIFICATION FORMAT]', 'Область застосування даних поля [CLASSIFICATION FORMAT]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'a', 0, 0, 'Географічна назва', 'Географічна назва',   7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '751', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '753', '', 1, 'INDEX TERM--UNCONTROLLED [CLASSIFICATION FORMAT]', 'INDEX TERM--UNCONTROLLED [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '753', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'a', 0, 1, 'Index term', 'Index term',                 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'b', 0, 1, 'Index term--Succeeding level', 'Index term--Succeeding level', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'd', 0, 1, 'Index term referred from', 'Index term referred from', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'e', 0, 1, 'Example class number', 'Example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 's', 0, 0, 'See also reference term', 'See also reference term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 't', 0, 1, 'See also reference term--Succeeding level', 'See also reference term--Succeeding level', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'u', 0, 0, 'Use reference term', 'Use reference term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '753', 'v', 0, 1, 'Use reference term--Succeeding level', 'Use reference term--Succeeding level', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '754', '', 1, 'INDEX TERM--FACETED TOPICAL TERMS [CLASSIFICATION FORMAT]', 'INDEX TERM--FACETED TOPICAL TERMS [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '754', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', '3', 0, 0, 'Material specified', 'Material specified', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'a', 0, 1, 'Focus term', 'Focus term',                 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'b', 0, 1, 'Non-focus term', 'Non-focus term',         7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '754', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '755', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--GENRE/FORM TERM', 'ESTABLISHED HEADING LINKING ENTRY--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '755', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'a', 0, 0, 'Genre/form term as entry element', 'Genre/form term as entry element', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '755', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '761', '', 1, 'ADD OR DIVIDE LIKE ВказівкиS [CLASSIFICATION FORMAT]', 'ADD OR DIVIDE LIKE ВказівкиS [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '761', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'a', 0, 1, 'Number where Вказівкиs are found--Single number or beginnning number of span', 'Number where Вказівкиs are found--Single number or beginnning number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'b', 0, 0, 'Base number', 'Base number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'd', 0, 1, 'Divided like number', 'Divided like number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'e', 0, 1, 'Example class number', 'Example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'f', 0, 1, 'Facet designator', 'Facet designator',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'n', 0, 1, 'Negative example class number', 'Negative example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'r', 0, 1, 'Root number', 'Root number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'x', 0, 1, 'Other Класифікаційний індекс', 'Other Класифікаційний індекс', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '761', 'z', 0, 1, 'Table identification', 'Table identification', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '762', '', 1, 'TABLE IDENTIFICATION [CLASSIFICATION FORMAT]', 'TABLE IDENTIFICATION [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '762', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '762', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '762', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '762', 'z', 0, 0, 'Table number', 'Table number',             7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '763', '', 1, 'INTERNAL SUBARRANGEMENT OR ADD TABLE ENTRY [CLASSIFICATION FORMAT]', 'INTERNAL SUBARRANGEMENT OR ADD TABLE ENTRY [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '763', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'a', 0, 0, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'b', 0, 0, 'Base number', 'Base number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'd', 0, 1, 'Divided like number', 'Divided like number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'e', 0, 1, 'Example class number', 'Example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'h', 0, 1, 'Caption hierarchy', 'Caption hierarchy',   7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'j', 0, 0, 'Caption', 'Caption',                       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'k', 0, 1, 'Summary number span caption hierarchy', 'Summary number span caption hierarchy', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'm', 0, 0, 'Manual note', 'Manual note',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'n', 0, 1, 'Number where Вказівкиs are found', 'Number where Вказівкиs are found', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'p', 0, 1, 'Corresponding classification field', 'Corresponding classification field', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'r', 0, 1, 'Root number', 'Root number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 's', 0, 1, 'See reference', 'See reference',           7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'x', 0, 1, 'Other Класифікаційний індекс', 'Other Класифікаційний індекс', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '763', 'z', 0, 1, 'Table identification', 'Table identification', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '764', '', 1, 'RULE IDENTIFICATION [CLASSIFICATION FORMAT]', 'RULE IDENTIFICATION [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '764', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '764', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '764', 'a', 0, 0, 'Rule number', 'Rule number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '764', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '765', '', 1, 'SYNTHESIZED NUMBER COMPONENTS [CLASSIFICATION FORMAT]', 'SYNTHESIZED NUMBER COMPONENTS [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '765', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'a', 0, 1, 'Number where Вказівкиs are found--Single number or beginning number of span', 'Number where Вказівкиs are found--Single number or beginning number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'b', 0, 1, 'Base number', 'Base number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'c', 0, 1, 'Number where Вказівкиs are found--Ending number of span', 'Number where Вказівкиs are found--Ending number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'f', 0, 1, 'Facet designator', 'Facet designator',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'r', 0, 1, 'Root number', 'Root number',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 's', 0, 1, 'Digits added from Класифікаційний індекс in schedule or external table', 'Digits added from Класифікаційний індекс in schedule or external table', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 't', 0, 1, 'Digits added from internal subarrangement or add table', 'Digits added from internal subarrangement or add table', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'u', 0, 1, 'Number being analyzed', 'Number being analyzed', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'v', 0, 1, 'Number in internal subarrangement or add table where Вказівкиs are found', 'Number in internal subarrangement or add table where Вказівкиs are found', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'w', 0, 1, 'Table identification--Internal subarrangement or add table', 'Table identification--Internal subarrangement or add table', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '765', 'z', 0, 1, 'Table identification', 'Table identification', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '766', '', 1, 'SECONDARY TABLE INFORMATION [CLASSIFICATION FORMAT]', 'SECONDARY TABLE INFORMATION [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '766', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '766', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '766', 'a', 0, 0, 'Secondary table of applicability', 'Secondary table of applicability', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '766', 'y', 0, 1, 'Type of division', 'Type of division',     7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '768', '', 1, 'CITATION AND PREFERENCE ORDER ВказівкиS [CLASSIFICATION FORMAT]', 'CITATION AND PREFERENCE ORDER ВказівкиS [CLASSIFICATION FORMAT]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '768', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'e', 0, 1, 'Example class number', 'Example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'j', 0, 1, 'Caption', 'Caption',                       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'n', 0, 1, 'Negative example class number', 'Negative example class number', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 't', 0, 1, 'Topic used as example of citation and preference order Вказівки', 'Topic used as example of citation and preference order Вказівки', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'x', 0, 1, 'Exception to table of preference', 'Exception to table of preference', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '768', 'z', 0, 1, 'Table identification--Table number', 'Table identification--Table number', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '780', '', 1, 'SUBDIVISION LINKING ENTRY--GENERAL SUBDIVISION', 'SUBDIVISION LINKING ENTRY--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '780', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '780', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '781', '', 1, 'SUBDIVISION LINKING ENTRY--GEOGRAPHIC SUBDIVISION', 'SUBDIVISION LINKING ENTRY--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '781', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '781', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '782', '', 1, 'SUBDIVISION LINKING ENTRY--CHRONOLOGICAL SUBDIVISION', 'SUBDIVISION LINKING ENTRY--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '782', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '782', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '785', '', 1, 'SUBDIVISION LINKING ENTRY--FORM SUBDIVISION', 'SUBDIVISION LINKING ENTRY--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '785', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '785', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '788', '', '', 'COMPLEX LINKING ENTRY DATA', 'COMPLEX LINKING ENTRY DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '788', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '788', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '856', '', 1, 'Місцезнаходження електронного ресурсу і доступ до нього', 'Місцезнаходження електронного ресурсу і доступ до нього', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '856', '2', 0, 0, 'Спосіб доступу', 'Спосіб доступу',         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', '3', 0, 0, 'Область застосування даних поля', 'Область застосування даних поля', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'a', 0, 1, 'Ім’я сервера/домену', 'Ім’я сервера/домену', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'b', 0, 1, 'Номер для доступу', 'Номер для доступу',   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'c', 0, 1, 'Інформація про стиснення', 'Інформація про стиснення', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'd', 0, 1, 'Шлях', 'Шлях',                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'f', 0, 1, 'Електронне ім’я', 'Електронне ім’я',       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'h', 0, 0, 'Виконавець запиту', 'Виконавець запиту',   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'i', 0, 1, 'Команди', 'Команди',                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'j', 0, 0, 'Кількість бітів в секунду', 'Кількість бітів в секунду', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'k', 0, 0, 'Пароль', 'Пароль',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'l', 0, 0, 'Ім’я користувача', 'Ім’я користувача',     8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'm', 0, 1, 'Контактні дані для підтримки доступу', 'Контактні дані для підтримки доступу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'n', 0, 0, 'Місце знаходження сервера', 'Місце знаходження сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'o', 0, 0, 'Операційна система сервера', 'Операційна система сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'p', 0, 0, 'Порт', 'Порт',                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'q', 0, 0, 'Тип електронного формату', 'Тип електронного формату', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'r', 0, 0, 'Встановлення', 'Встановлення',             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 's', 0, 1, 'Розмір файлу', 'Розмір файлу',             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 't', 0, 1, 'Емуляція терміналу', 'Емуляція терміналу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'v', 0, 1, 'Години доступу за даним методом', 'Години доступу за даним методом', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'w', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'x', 0, 1, 'Службові нотатки', 'Службові нотатки',     8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'y', 0, 1, 'Довідковий текст', 'Довідковий текст',     8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '856', 'z', 0, 1, 'Загальнодоступна примітка', 'Загальнодоступна примітка', 8, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '880', '', 1, 'Альтернативне [що перемикається] подання графічних символів', 'Альтернативне [що перемикається] подання графічних символів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '880', '0', 0, 1, 0, 0,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '1', 0, 1, 1, 1,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '2', 0, 1, 2, 2,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '3', 0, 1, 3, 3,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '4', 0, 1, 4, 4,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '5', 0, 1, 5, 5,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '6', 0, 1, 6, 6,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '7', 0, 1, 7, 7,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', '8', 0, 1, 8, 8,                                       8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'a', 0, 1, 'a', 'a',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'b', 0, 1, 'b', 'b',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'c', 0, 1, 'c', 'c',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'd', 0, 1, 'd', 'd',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'e', 0, 1, 'e', 'e',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'f', 0, 1, 'f', 'f',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'g', 0, 1, 'g', 'g',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'h', 0, 1, 'h', 'h',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'i', 0, 1, 'i', 'i',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'j', 0, 1, 'j', 'j',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'k', 0, 1, 'k', 'k',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'l', 0, 1, 'l', 'l',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'm', 0, 1, 'm', 'm',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'n', 0, 1, 'n', 'n',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'o', 0, 1, 'o', 'o',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'p', 0, 1, 'p', 'p',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'q', 0, 1, 'q', 'q',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'r', 0, 1, 'r', 'r',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 's', 0, 1, 's', 's',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 't', 0, 1, 't', 't',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'u', 0, 1, 'u', 'u',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'v', 0, 1, 'v', 'v',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'w', 0, 1, 'w', 'w',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'x', 0, 1, 'x', 'x',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'y', 0, 1, 'y', 'y',                                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', '', '880', 'z', 0, 1, 'z', 'z',                                   8, 0, '', NULL, NULL, 0, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
