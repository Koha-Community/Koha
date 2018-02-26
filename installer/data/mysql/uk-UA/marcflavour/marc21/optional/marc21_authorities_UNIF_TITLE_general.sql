-- На основі MARC21-структури англійською „UNIF_TITLE“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

DELETE FROM auth_types WHERE authtypecode='UNIF_TITLE';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES (130, 'UNIF_TITLE', 'Уніфікований заголовок', 'Уніфікований, умовний, узагальнюючий заголовок як предметна пошукова ознака');
DELETE FROM auth_tag_structure WHERE authtypecode='UNIF_TITLE';
DELETE FROM auth_subfield_structure WHERE authtypecode='UNIF_TITLE';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '000', 1, '', 'Маркер', 'Маркер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '000', '@', 1, 0, 'Контрольне поле фіксованої довжини', 'Контрольне поле фіксованої довжини', 0, 0, '', NULL, 'marc21_leader_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '001', 1, '', 'Контрольний номер', 'Контрольний номер', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '001', '@', 0, 0, 'Контрольний номер', 'Контрольний номер', 0, 0, 'auth_header.authid', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '003', 1, '', 'Ідентифікатор контрольного номера', 'Ідентифікатор контрольного номера', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '003', '@', 1, 0, 'Контрольне поле', 'Контрольне поле', 0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '005', 1, '', 'Дата і час останньої транзакції', 'Дата і час останньої транзакції', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '005', '@', 1, 0, 'Контрольне поле', 'Контрольне поле', 0, 0, '', NULL, 'marc21_field_005.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '008', 1, '', 'Елементи даних фіксованої довжини', 'Елементи даних фіксованої довжини', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '008', '@', 1, 0, 'Контрольне поле фіксованої довжини', 'Контрольне поле фіксованої довжини', 0, 0, '', NULL, 'marc21_field_008_authorities.pl', 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '010', '', '', 'Контрольний номер Бібліотеки Конгресу', 'Контрольний номер Бібліотеки Конгресу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '010', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '010', 'a', 0, 0, 'Контрольний номер БК', 'Контрольний номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '010', 'z', 0, 1, 'Анульований/недіючий контрольний номер БК', 'Анульований/недіючий контрольний номер БК', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '014', '', 1, 'Зв’язок з бібліографічним записом на серіальну чи багатотомну одиницю', 'Зв’язок з бібліографічним записом на серіальну чи багатотомну одиницю', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '014', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '014', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '014', 'a', 0, 0, 'Контрольний номер взаємозалежного бібліографічного запису', 'Контрольний номер взаємозалежного бібліографічного запису', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '016', '', 1, 'Контрольний номер національної бібліографічної агенції', 'Контрольний номер національної бібліографічної агенції', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '016', '2', 0, 0, 'Джерело', 'Джерело',             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '016', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '016', 'a', 0, 0, 'Контрольний номер запису', 'Контрольний номер запису', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '016', 'z', 0, 1, 'Анульований/недіючий контрольний номер запису', 'Анульований/недіючий контрольний номер запису', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '020', '', 1, 'Міжнародний стандартний книжковий номер ISBN', 'Міжнародний стандартний книжковий номер ISBN', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '020', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '020', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '020', 'a', 0, 0, 'ISBN', 'ISBN',                   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '020', 'c', 0, 0, 'Умови придбання', 'Умови придбання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '020', 'z', 0, 1, 'Анульований/недіючий ISBN', 'Анульований/недіючий ISBN', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '022', '', 1, 'Міжнародний стандартний номер серіального видання ISSN', 'Міжнародний стандартний номер серіального видання ISSN', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '022', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '022', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '022', 'a', 0, 0, 'ISSN', 'ISSN',                   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '022', 'y', 0, 1, 'Помилковий ISSN', 'Помилковий ISSN', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '022', 'z', 0, 1, 'Анульованій ISSN', 'Анульованій ISSN', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '024', '', 1, 'Інший стандартний ідентифікатор', 'Інший стандартний ідентифікатор', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '024', '2', 0, 0, 'Джерело номера чи коду', 'Джерело номера чи коду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', 'a', 0, 0, 'Стандартний номер чи код', 'Стандартний номер чи код', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', 'c', 0, 0, 'Умови доступності', 'Умови доступності', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', 'd', 0, 0, 'Додаткові коди, що йдуть за стандартним номером або кодом', 'Додаткові коди, що йдуть за стандартним номером або кодом', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '024', 'z', 0, 1, 'Анульований/недіючий стандартний номер чи код', 'Анульований/недіючий стандартний номер чи код', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '031', '', 1, 'MUSICAL INCIPITS INFORMATION', 'MUSICAL INCIPITS INFORMATION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '031', '2', 0, 0, 'System code', 'System code',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'a', 0, 0, 'Number of work', 'Number of work', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'b', 0, 0, 'Number of movement', 'Number of movement', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'c', 0, 0, 'Number of excerpt', 'Number of excerpt', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'd', 0, 1, 'Caption or heading', 'Caption or heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'e', 0, 0, 'Role', 'Role',                   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'g', 0, 0, 'Clef', 'Clef',                   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'm', 0, 0, 'Voice/instrument', 'Voice/instrument', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'n', 0, 0, 'Key signature', 'Key signature', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'o', 0, 0, 'Time signature', 'Time signature', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'p', 0, 0, 'Musical notation', 'Musical notation', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'q', 0, 1, 'General note', 'General note',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'r', 0, 0, 'Key or mode', 'Key or mode',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 's', 0, 1, 'Coded validity note', 'Coded validity note', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 't', 0, 1, 'Text incipit', 'Text incipit',   0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '031', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '034', '', 1, 'CODED CARTOGRAPHIC MATHEMATICAL DATA', 'CODED CARTOGRAPHIC MATHEMATICAL DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '034', '2', 0, 0, 'Джерело', 'Джерело',             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'd', 0, 0, 'Coordinates--westernmost longitude', 'Coordinates--westernmost longitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'e', 0, 0, 'Coordinates--easternmost longitude', 'Coordinates--easternmost longitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'f', 0, 0, 'Coordinates--northernmost latitude', 'Coordinates--northernmost latitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'g', 0, 0, 'Coordinates--southernmost latitude', 'Coordinates--southernmost latitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'j', 0, 0, 'Declination--northern limit', 'Declination--northern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'k', 0, 0, 'Declination--southern limit', 'Declination--southern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'm', 0, 0, 'Right ascension--eastern limit', 'Right ascension--eastern limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'n', 0, 0, 'Right ascension--western limit', 'Right ascension--western limit', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'p', 0, 0, 'Equinox', 'Equinox',             0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'r', 0, 1, 'Distance from earth', 'Distance from earth', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 's', 0, 1, 'G-ring latitude', 'G-ring latitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 't', 0, 1, 'G-ring longitude', 'G-ring longitude', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'x', 0, 0, 'Beginning date', 'Beginning date', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'y', 0, 0, 'Ending date', 'Ending date',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '034', 'z', 0, 0, 'Name of extraterrestrial body', 'Name of extraterrestrial body', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '035', '', 1, 'Контрольний номер системи', 'Контрольний номер системи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '035', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '035', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '035', 'a', 0, 0, 'Контрольний номер системи', 'Контрольний номер системи', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '035', 'z', 0, 1, 'Анульований/недіючий контрольний номер', 'Анульований/недіючий контрольний номер', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '040', 1, '', 'Джерело каталогізації', 'Джерело каталогізації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '040', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'a', 1, 0, 'Служба первинної каталогізації', 'Служба первинної каталогізації', 0, 0, '', NULL, 'marc21_orgcode.pl', 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'b', 0, 0, 'Мова каталогізації', 'Мова каталогізації', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'c', 0, 0, 'Управління перезапису або перетворення', 'Управління перезапису або перетворення', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'd', 0, 1, 'Служба змін', 'Служба змін',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'e', 0, 0, 'Description conventions', 'Description conventions', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '040', 'f', 0, 0, 'Правила складання предметних рубрик/тезаурусу', 'Правила складання предметних рубрик/тезаурусу', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '042', '', '', 'Код справжності [автентичності]', 'Код справжності [автентичності]', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '042', 'a', 0, 1, 'Код справжності [автентичності]', 'Код справжності [автентичності]', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '043', '', '', 'Код географічного регіону', 'Код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '043', '2', 0, 1, 'Source of local code', 'Source of local code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '043', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '043', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '043', 'a', 0, 1, 'Код географічного регіону', 'Код географічного регіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '043', 'b', 0, 1, 'Local GAC code', 'Local GAC code', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '043', 'c', 0, 1, 'ISO code', 'ISO code',           0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '045', '', '', 'Хронологічний період, що відноситься до заголовку', 'Хронологічний період, що відноситься до заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '045', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '045', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '045', 'a', 0, 1, 'Код хронологічного періоду', 'Код хронологічного періоду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '045', 'b', 0, 0, 'Форматований хронологічний період від 9999 р. до Різдва Христового і нашої ери', 'Форматований хронологічний період від 9999 р. до Різдва Христового і нашої ери', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '045', 'c', 0, 1, 'Форматований хронологічний період раніше 9999 до Різдва Христового', 'Форматований хронологічний період раніше 9999 до Різдва Христового', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '050', '', 1, 'Расстановочний шифр Бібліотеки Конгресу', 'Расстановочний шифр Бібліотеки Конгресу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '050', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '050', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '050', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '050', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '050', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '050', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '052', '', 1, 'Класифікаційний код географічного регіону', 'Класифікаційний код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '052', '2', 0, 0, 'Код джерела', 'Код джерела',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '052', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '052', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '052', 'a', 0, 0, 'Класифікаційний код географічного регіону', 'Класифікаційний код географічного регіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '052', 'b', 0, 1, 'Класифікаційний код географічного підрегіону', 'Класифікаційний код географічного підрегіону', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '053', '', 1, 'Класифікаційний індекс БК', 'Класифікаційний індекс БК', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '053', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '053', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '053', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '053', 'a', 0, 0, 'Класифікаційний індекс — окремий індекс О або початковий індекс у ряду', 'Класифікаційний індекс — окремий індекс О або початковий індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '053', 'b', 0, 1, 'Класифікаційний індекс - останній індекс у ряду', 'Класифікаційний індекс - останній індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '053', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '055', '', 1, 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', 'NATIONAL LIBRARY AND ARCHIVE OF CANADA CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '055', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '055', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '055', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '055', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '055', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '055', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '060', '', 1, 'Розстановочний шифр Національної медичної бібліотеки', 'Розстановочний шифр Національної медичної бібліотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '060', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '060', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '060', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '060', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '060', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '060', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '065', '', 1, 'OTHER Класифікаційний індекс', 'OTHER Класифікаційний індекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '065', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning of span', 'Класифікаційний індекс element--single number or beginning of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '065', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '066', '', '', 'Використовувані набори символів', 'Використовувані набори символів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '066', 'a', 0, 0, 'Позначення набору символів, який не є за умовчанням набором ASCII G0', 'Позначення набору символів, який не є за умовчанням набором ASCII G0', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '066', 'b', 0, 0, 'Позначення набору символів, який не є за умовчанням набором ASCII G1', 'Позначення набору символів, який не є за умовчанням набором ASCII G1', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '066', 'c', 0, 1, 'Ідентифікація альтернативного [що перемикається] до G0 і G1 набору графічних символів', 'Ідентифікація альтернативного [що перемикається] до G0 і G1 набору графічних символів', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '070', '', 1, 'Розстановочний шифр Національної сільськогосподарської бібліотеки', 'Розстановочний шифр Національної сільськогосподарської бібліотеки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '070', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '070', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '070', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '070', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '070', 'd', 0, 0, 'Тома/дати, для яких застосовується розстановочний шифр', 'Тома/дати, для яких застосовується розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '072', '', 1, 'Код тематичної категорії', 'Код тематичної категорії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '072', '2', 0, 0, 'Код джерела', 'Код джерела',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '072', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '072', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '072', 'a', 0, 0, 'Код тематичної категорії', 'Код тематичної категорії', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '072', 'x', 0, 1, 'Код підрозбиття тематичної категорії', 'Код підрозбиття тематичної категорії', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '073', '', '', 'Використання підзаголовку', 'Використання підзаголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '073', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '073', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '073', 'a', 0, 1, 'Використання підзаголовку', 'Використання підзаголовку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '073', 'z', 0, 0, 'Код джерела', 'Код джерела',     0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '082', '', 1, 'Розстановочний шифр за Десятковою класифікацією Дьюї', 'Розстановочний шифр за Десятковою класифікацією Дьюї', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '082', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '082', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '083', '', 1, 'Класифікаційний індекс Десяткової класифікації Дьюї', 'Класифікаційний індекс Десяткової класифікації Дьюї', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '083', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', 'a', 0, 0, 'Класифікаційний індекс — окремий індекс або початковий індекс у ряду', 'Класифікаційний індекс — окремий індекс або початковий індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', 'b', 0, 0, 'Класифікаційний індекс — останній індекс у ряду', 'Класифікаційний індекс — останній індекс у ряду', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '083', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '086', '', 1, 'GOVERNMENT DOCUMENT CALL NUMBER', 'GOVERNMENT DOCUMENT CALL NUMBER', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '086', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', 'a', 0, 0, 'Call number', 'Call number',     0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '086', 'z', 0, 1, 'Cancelled/invalid call number', 'Cancelled/invalid call number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '087', '', 1, 'GOVERNMENT DOCUMENT Класифікаційний індекс', 'GOVERNMENT DOCUMENT Класифікаційний індекс', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '087', '2', 0, 0, 'Number source', 'Number source', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '087', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '087', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '087', 'a', 0, 0, 'Класифікаційний індекс element--Single number or beginning number of span', 'Класифікаційний індекс element--Single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '087', 'b', 0, 0, 'Класифікаційний індекс element--Ending number of span', 'Класифікаційний індекс element--Ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '087', 'c', 0, 0, 'Explanatory information', 'Explanatory information', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '091', '', '', 'LOCALLY ASSIGNED LC-TYPE Класифікаційний індекс (OCLC); LOCAL Класифікаційний індекс (RLIN)', 'LOCALLY ASSIGNED LC-TYPE Класифікаційний індекс (OCLC); LOCAL Класифікаційний індекс (RLIN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '091', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '091', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '092', '', 1, 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '092', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '093', '', 1, 'LOCALLY ASSIGNED DEWEY Класифікаційний індекс (OCLC)', 'LOCALLY ASSIGNED DEWEY Класифікаційний індекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '093', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '093', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '096', '', 1, 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE CALL NUMBER (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '096', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', 'a', 0, 0, 'Класифікаційний індекс', 'Класифікаційний індекс', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '097', '', 1, 'LOCALLY ASSIGNED NLM-TYPE Класифікаційний індекс (OCLC)', 'LOCALLY ASSIGNED NLM-TYPE Класифікаційний індекс (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '097', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', 'a', 0, 0, 'Класифікаційний індекс element--single number or beginning number of span', 'Класифікаційний індекс element--single number or beginning number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', 'b', 0, 0, 'Класифікаційний індекс element--ending number of span', 'Класифікаційний індекс element--ending number of span', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', 'c', 0, 0, 'Пояснюючий термін', 'Пояснюючий термін', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '097', 'z', 0, 0, 'Table identification--table number', 'Table identification--table number', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '098', '', 1, 'OTHER CLASSIFICATION SCHEMES (OCLC)', 'OTHER CLASSIFICATION SCHEMES (OCLC)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '098', '2', 0, 0, 'Номер видання', 'Номер видання', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', 'b', 0, 0, 'Номер одиниці', 'Номер одиниці', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', 'd', 0, 0, 'Тома/дати, до яких відноситься розстановочний шифр', 'Тома/дати, до яких відноситься розстановочний шифр', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', 'e', 0, 0, 'Feature heading', 'Feature heading', 0, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix', 0, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '130', '', '', 'Заголовок — уніфікований заголовок', 'Заголовок — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '130', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 1, 0, '', NULL, NULL, 0, '\'130o\',\'130m\',\'130r\',\'130s\',\'130d\',\'130k\',\'130n\',\'130p\',\'130g\',\'130l\',\'130f\',\'130h\',\'130t\',\'130x\',\'130z\',\'130y\',\'130v\'', 0),
 ('', 'UNIF_TITLE', '130', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'h', 0, 0, 'Носій', 'Носій',                 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 's', 0, 0, 'Версія', 'Версія',               1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '130', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 1, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '260', '', 1, 'Комплексне посилання „див.“ — предмет', 'Комплексне посилання „див.“ — предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '260', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '260', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '260', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 2, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '260', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 2, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '360', '', 1, 'Комплексне посилання „див. також“ — предмет', 'Комплексне посилання „див. також“ — предмет', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '360', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '360', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '360', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 3, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '360', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 3, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '400', '', 1, 'Трасування посилання „див.“ — ім’я особи', 'Трасування посилання „див.“ — ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '400', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',       4, 0, '', NULL, NULL, 0, '\'400b\',\'400c\',\'400q\',\'400d\',\'400t\',\'400o\',\'400m\',\'400r\',\'400s\',\'400k\',\'400n\',\'400p\',\'400g\',\'400l\',\'400f\',\'400h\',\'400x\',\'400z\',\'400y\',\'400v\'', 0),
 ('', 'UNIF_TITLE', '400', 'b', 0, 0, 'Нумерація', 'Нумерація',         4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'h', 0, 0, 'Носій', 'Носій',                 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 's', 0, 0, 'Версія', 'Версія',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '400', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '410', '', 1, 'Трасування посилання „див.“ — назва організації', 'Трасування посилання „див.“ — назва організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '410', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 4, 0, '', NULL, NULL, 0, '\'410b\',\'410c\',\'410d\',\'410t\',\'410o\',\'410m\',\'410r\',\'410s\',\'410k\',\'410n\',\'410p\',\'410g\',\'410l\',\'410f\',\'410h\',\'410x\',\'410z\',\'410y\',\'410v\'', 0),
 ('', 'UNIF_TITLE', '410', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'h', 0, 0, 'Носій', 'Носій',                 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 's', 0, 0, 'Версія', 'Версія',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '410', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '411', '', 1, 'Трасування посилання „див.“ — назва заходу', 'Трасування посилання „див.“ — назва заходу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '411', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 4, 0, '', NULL, NULL, 0, '\'411e\',\'411c\',\'411d\',\'411t\',\'411s\',\'411k\',\'411n\',\'411p\',\'411g\',\'411l\',\'411f\',\'411h\',\'411x\',\'411z\',\'411y\',\'411v\'', 0),
 ('', 'UNIF_TITLE', '411', 'b', 0, 0, 'Number {OBSOLETE]', 'Number {OBSOLETE]', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'd', 0, 0, 'Дата проведеного заходу', 'Дата проведеного заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'h', 0, 0, 'Носій', 'Носій',                 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 's', 0, 0, 'Версія', 'Версія',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '411', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '430', '', 1, 'Трасування посилання „див.“ — уніфікований заголовок', 'Трасування посилання „див.“ — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '430', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 4, 0, '', NULL, NULL, 0, '\'430o\',\'430m\',\'430r\',\'430s\',\'430d\',\'430k\',\'430n\',\'430p\',\'430g\',\'430l\',\'430f\',\'430h\',\'430t\',\'430x\',\'430z\',\'430y\',\'430v\'', 0),
 ('', 'UNIF_TITLE', '430', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'h', 0, 0, 'Носій', 'Носій',                 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 's', 0, 0, 'Версія', 'Версія',               4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '430', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '448', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL TERM', 'SEE FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '448', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'a', 0, 0, 'Chronological term', 'Chronological term', 4, 0, '', NULL, NULL, 0, '\'448y\',\'448x\',\'448z\',\'448v\'', 0),
 ('', 'UNIF_TITLE', '448', 'i', 0, 1, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '448', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '450', '', 1, 'Трасування посилання „див.“ — тематичний термін', 'Трасування посилання „див.“ — тематичний термін', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '450', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'a', 0, 0, 'Topical term or Географічна назва entry element', 'Topical term or Географічна назва entry element', 4, 0, '', NULL, NULL, 0, '\'450x\',\'450z\',\'450y\',\'450v\'', 0),
 ('', 'UNIF_TITLE', '450', 'b', 0, 0, 'Topical term following Географічна назва entry element', 'Topical term following Географічна назва entry element', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '450', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '451', '', 1, 'Трасування посилання „див.“ — георафічна назва', 'Трасування посилання „див.“ — георафічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '451', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'a', 0, 0, 'Географічна назва', 'Географічна назва', 4, 0, '', NULL, NULL, 0, '\'451z\',\'451x\',\'451y\',\'451v\'', 0),
 ('', 'UNIF_TITLE', '451', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '451', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '455', '', 1, 'SEE FROM TRACING--GENRE/FORM TERM', 'SEE FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '455', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'a', 0, 0, 'Genre/form term', 'Genre/form term', 4, 0, '', NULL, NULL, 0, '\'455v\',\'455x\',\'455z\',\'455y\'', 0),
 ('', 'UNIF_TITLE', '455', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '455', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '480', '', 1, 'SEE FROM TRACING--GENERAL SUBDIVISION', 'SEE FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '480', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '480', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '481', '', 1, 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '481', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '481', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '482', '', 1, 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '482', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '482', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '485', '', 1, 'SEE FROM TRACING--FORM SUBDIVISION', 'SEE FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '485', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '485', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 4, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '500', '', 1, 'Трасування посилання „див. також“ — ім’я особи', 'Трасування посилання „див. також“ — ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '500', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'a', 0, 0, 'Ім’я особи', 'Ім’я особи',       5, 0, '', NULL, NULL, 0, '\'500b\',\'500c\',\'500q\',\'500d\',\'500t\',\'500o\',\'500m\',\'500r\',\'500s\',\'500k\',\'500n\',\'500p\',\'500g\',\'500l\',\'500f\',\'500h\',\'500x\',\'500z\',\'500y\',\'500v\'', 0),
 ('', 'UNIF_TITLE', '500', 'b', 0, 0, 'Нумерація', 'Нумерація',         5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'c', 0, 1, 'Титули (звання) та інші слова, які асоціюються з іменем', 'Титули (звання) та інші слова, які асоціюються з іменем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'd', 0, 0, 'Дати, асоційовані з іменем', 'Дати, асоційовані з іменем', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'h', 0, 0, 'Носій', 'Носій',                 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'q', 0, 0, 'Найбільш повна форма імені', 'Найбільш повна форма імені', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 's', 0, 0, 'Версія', 'Версія',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '500', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '510', '', 1, 'Трасування посилання „див. також“ — найменування організації', 'Трасування посилання „див. також“ — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '510', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'a', 0, 0, 'Найменування організації чи найменування юрисдикції як елемент вводу', 'Найменування організації чи найменування юрисдикції як елемент вводу', 5, 0, '', NULL, NULL, 0, '\'510b\',\'510c\',\'510d\',\'510t\',\'510o\',\'510m\',\'510r\',\'510s\',\'510k\',\'510n\',\'510p\',\'510g\',\'510l\',\'510f\',\'510h\',\'510x\',\'510z\',\'510y\',\'510v\'', 0),
 ('', 'UNIF_TITLE', '510', 'b', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'd', 0, 1, 'Дата проведення заходу чи підписання контракту', 'Дата проведення заходу чи підписання контракту', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'e', 0, 1, 'Термін авторського відношення', 'Термін авторського відношення', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'h', 0, 0, 'Носій', 'Носій',                 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 's', 0, 0, 'Версія', 'Версія',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '510', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '511', '', 1, 'Трасування посилання „див. також“ — найменування заходу', 'Трасування посилання „див. також“ — найменування заходу', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '511', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'a', 0, 0, 'Найменування заходу чи найменування юрисдикції як елементу вводу', 'Найменування заходу чи найменування юрисдикції як елементу вводу', 5, 0, '', NULL, NULL, 0, '\'511e\',\'511c\',\'511d\',\'511t\',\'511s\',\'511k\',\'511n\',\'511p\',\'511g\',\'511l\',\'511f\',\'511h\',\'511x\',\'511z\',\'511y\',\'511v\'', 0),
 ('', 'UNIF_TITLE', '511', 'c', 0, 0, 'Місце проведення заходу', 'Місце проведення заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'd', 0, 0, 'Дата проведеного заходу', 'Дата проведеного заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'e', 0, 1, 'Співпідпорядкована одиниця', 'Співпідпорядкована одиниця', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'h', 0, 0, 'Носій', 'Носій',                 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'n', 0, 1, 'Номер частини/розділу/заходу', 'Номер частини/розділу/заходу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'q', 0, 0, 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 'Найменування заходу, що йде за найменуванням юрисдикції, яка є елементом вводу', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 's', 0, 0, 'Версія', 'Версія',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '511', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '530', '', 1, 'Трасування посилання „див. також“ — Уніфікований заголовок', 'Трасування посилання „див. також“ — Уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '530', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 5, 0, '', NULL, NULL, 0, '\'530o\',\'530m\',\'530r\',\'530s\',\'530d\',\'530k\',\'530n\',\'530p\',\'530g\',\'530l\',\'530f\',\'530h\',\'530t\',\'530x\',\'530z\',\'530y\',\'530v\'', 0),
 ('', 'UNIF_TITLE', '530', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'h', 0, 0, 'Носій', 'Носій',                 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'o', 0, 0, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 's', 0, 0, 'Версія', 'Версія',               5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '530', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '548', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', 'SEE ALSO FROM TRACING--CHRONOLOGICAL TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '548', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'a', 0, 0, 'Chronological term', 'Chronological term', 5, 0, '', NULL, NULL, 0, '\'548y\',\'548x\',\'548z\',\'548v\'', 0),
 ('', 'UNIF_TITLE', '548', 'i', 0, 1, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '548', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '550', '', 1, 'Трасування посилання „див. також“ — тематичний термін', 'Трасування посилання „див. також“ — тематичний термін', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '550', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'a', 0, 0, 'Topical term or Географічна назва entry element', 'Topical term or Географічна назва entry element', 5, 0, '', NULL, NULL, 0, '\'550x\',\'550z\',\'550y\',\'550v\'', 0),
 ('', 'UNIF_TITLE', '550', 'b', 0, 0, 'Topical term following Географічна назва entry element', 'Topical term following Географічна назва entry element', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '550', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '551', '', 1, 'Трасування посилання „див. також“ — географічна назва', 'Трасування посилання „див. також“ — географічна назва', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '551', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'a', 0, 0, 'Географічна назва', 'Географічна назва', 5, 0, '', NULL, NULL, 0, '\'551z\',\'551x\',\'551y\',\'551v\'', 0),
 ('', 'UNIF_TITLE', '551', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '551', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '555', '', 1, 'SEE ALSO FROM TRACING--GENRE/FORM TERM', 'SEE ALSO FROM TRACING--GENRE/FORM TERM', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '555', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'a', 0, 0, 'Genre/form term', 'Genre/form term', 5, 0, '', NULL, NULL, 0, '\'555v\',\'555x\',\'555z\',\'555y\'', 0),
 ('', 'UNIF_TITLE', '555', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '555', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '580', '', 1, 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', 'SEE ALSO FROM TRACING--GENERAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '580', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '580', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '581', '', 1, 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', 'SEE ALSO FROM TRACING--GEOGRAPHIC SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '581', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '581', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '582', '', 1, 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', 'SEE ALSO FROM TRACING--CHRONOLOGICAL SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '582', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '582', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '585', '', 1, 'SEE ALSO FROM TRACING--FORM SUBDIVISION', 'SEE ALSO FROM TRACING--FORM SUBDIVISION', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '585', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'i', 0, 0, 'Інструктивний текст посилання', 'Інструктивний текст посилання', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '585', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 5, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '640', '', 1, 'Дати публікації серії та/чи позначення томів', 'Дати публікації серії та/чи позначення томів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '640', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '640', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '640', 'a', 0, 0, 'Дати публікації та/чи позначення томів', 'Дати публікації та/чи позначення томів', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '640', 'z', 0, 0, 'Джерело інформації', 'Джерело інформації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '641', '', 1, 'Особливості нумерації серії', 'Особливості нумерації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '641', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '641', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '641', 'a', 0, 0, 'Примітка про особливості нумерації', 'Примітка про особливості нумерації', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '641', 'z', 0, 0, 'Джерело інформації', 'Джерело інформації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '642', '', 1, 'Зразок нумерації серії', 'Зразок нумерації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '642', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '642', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '642', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '642', 'a', 0, 0, 'Зразок нумерації серії', 'Зразок нумерації серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '642', 'd', 0, 0, 'Тома/дати, для яких застосовується зразок нумерації серії', 'Тома/дати, для яких застосовується зразок нумерації серії', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '643', '', 1, 'Місце видання та видавництво/організація, що видає, для серії', 'Місце видання та видавництво/організація, що видає, для серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '643', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '643', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '643', 'a', 0, 1, 'Місце видання', 'Місце видання', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '643', 'b', 0, 1, 'Видавництво/організація, що видає', 'Видавництво/організація, що видає', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '643', 'd', 0, 0, 'Тома/дати, для яких зазначаються місце видання та видавництво/організація, що видає', 'Тома/дати, для яких зазначаються місце видання та видавництво/організація, що видає', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '644', '', 1, 'Практика аналізу серії', 'Практика аналізу серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '644', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '644', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '644', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '644', 'a', 0, 0, 'Практика аналізу серії', 'Практика аналізу серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '644', 'b', 0, 0, 'Виключення в практиці аналізу', 'Виключення в практиці аналізу', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '644', 'd', 0, 0, 'Тома/дати, для яких застосовується практика аналізу серій', 'Тома/дати, для яких застосовується практика аналізу серій', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '645', '', 1, 'Практика трасування серії', 'Практика трасування серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '645', '5', 0, 1, 'Організація/екземпляр, для яких застосовується поле', 'Організація/екземпляр, для яких застосовується поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '645', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '645', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '645', 'a', 0, 0, 'Практика трасування серії', 'Практика трасування серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '645', 'd', 0, 0, 'Тома/дати, для яких застосовується практика трасування', 'Тома/дати, для яких застосовується практика трасування', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '646', '', 1, 'Практика систематизації серії', 'Практика систематизації серії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '646', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '646', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '646', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '646', 'a', 0, 0, 'Практика систематизації серії', 'Практика систематизації серії', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '646', 'd', 0, 0, 'Тома/дати, для яких застосовується практика систематизації', 'Тома/дати, для яких застосовується практика систематизації', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '663', '', '', 'Комплексна посилання „див. також“ — ім’я/найменування', 'Комплексна посилання „див. також“ — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '663', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '663', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '663', 'a', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '663', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '663', 't', 0, 1, 'Назва, до якого робиться посилання', 'Назва, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '664', '', '', 'Комплексне посилання „див.“ — ім’я/найменування', 'Комплексне посилання „див.“ — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '664', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '664', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '664', 'a', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '664', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '664', 't', 0, 1, 'Назва, до якого робиться посилання', 'Назва, до якого робиться посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '665', '', '', 'Історична довідка', 'Історична довідка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '665', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '665', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '665', 'a', 0, 1, 'Історичне посилання', 'Історичне посилання', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '666', '', '', 'Загальна пояснювальна довідка — ім’я/найменування', 'Загальна пояснювальна довідка — ім’я/найменування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '666', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '666', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '666', 'a', 0, 1, 'Загальна пояснювальна довідка', 'Загальна пояснювальна довідка', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '667', '', 1, 'Загальне зауваження, не призначене для користувача', 'Загальне зауваження, не призначене для користувача', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '667', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '667', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '667', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '667', 'a', 0, 0, 'Загальне зауваження, не призначене для користувача', 'Загальне зауваження, не призначене для користувача', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '670', '', 1, 'Джерело, в якому знайдені дані', 'Джерело, в якому знайдені дані', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '670', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '670', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '670', 'a', 0, 0, 'Посилання на джерело', 'Посилання на джерело', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '670', 'b', 0, 0, 'Знайдена інформація', 'Знайдена інформація', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '670', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '675', '', '', 'Джерело, в якому дані не знайдені', 'Джерело, в якому дані не знайдені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '675', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '675', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '675', 'a', 0, 1, 'Посилання на джерело', 'Посилання на джерело', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '678', '', 1, 'BIOGRAPHICAL OR HISTORICAL DATA', 'BIOGRAPHICAL OR HISTORICAL DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '678', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '678', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '678', 'a', 0, 1, 'Biographical or historical data', 'Biographical or historical data', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '678', 'b', 0, 0, 'Expansion', 'Expansion',         6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '678', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '680', '', 1, 'Загальне зауваження, призначене для користувача', 'Загальне зауваження, призначене для користувача', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '680', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '680', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '680', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '680', 'a', 0, 1, 'Термін для заголовку чи підзаголовку', 'Термін для заголовку чи підзаголовку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '680', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '680', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '681', '', 1, 'Примітка до прикладу трасування предметного заголовку', 'Примітка до прикладу трасування предметного заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '681', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '681', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '681', 'a', 0, 1, 'Термін предметного заголовку чи підзаголовку', 'Термін предметного заголовку чи підзаголовку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '681', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '681', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '682', '', '', 'Інформація про вилуений заголовок', 'Інформація про вилуений заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '682', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '682', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '682', 'a', 0, 1, 'Заголовок, що замінює', 'Заголовок, що замінює', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '682', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '683', '', 1, 'Примітка до історії застосування', 'Примітка до історії застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '683', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', '8', 0, 0, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'a', 0, 1, 'Класифікаційний індекс--Single number or beginning number of span', 'Класифікаційний індекс--Single number or beginning number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'c', 0, 1, 'Класифікаційний індекс--Ending number of span', 'Класифікаційний індекс--Ending number of span', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'p', 0, 1, 'Corresponding classification field', 'Corresponding classification field', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'y', 0, 0, 'Table identification--Schedule [OBSOLETE]', 'Table identification--Schedule [OBSOLETE]', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '683', 'z', 0, 1, 'Table identification', 'Table identification', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '688', '', 1, 'Примітка до історії застосування', 'Примітка до історії застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '688', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '688', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '688', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 6, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '688', 'a', 0, 0, 'Примітка до історії застосування', 'Примітка до історії застосування', 6, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '730', '', 1, 'ESTABLISHED HEADING LINKING ENTRY--Уніфікований заголовок', 'ESTABLISHED HEADING LINKING ENTRY--Уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '730', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'a', 0, 0, 'Уніфікований заголовок', 'Уніфікований заголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'd', 0, 1, 'Дата підписання договору', 'Дата підписання договору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'f', 0, 0, 'Дата роботи', 'Дата роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'g', 0, 0, 'Інша інформація', 'Інша інформація', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'h', 0, 0, 'Носій', 'Носій',                 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'k', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'l', 0, 0, 'Мова роботи', 'Мова роботи',     7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'm', 0, 1, 'Засіб для виконання музичного твору', 'Засіб для виконання музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'n', 0, 1, 'Номер частини/розділу роботи', 'Номер частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'o', 0, 1, 'Відомості про аранжування музичного твору', 'Відомості про аранжування музичного твору', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'p', 0, 1, 'Найменування частини/розділу роботи', 'Найменування частини/розділу роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'r', 0, 0, 'Музичний ключ', 'Музичний ключ', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 's', 0, 0, 'Версія', 'Версія',               7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 't', 0, 0, 'Заголовок роботи', 'Заголовок роботи', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'v', 0, 1, 'Form subdivision', 'Form subdivision', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'w', 0, 0, 'Контрольне підполе', 'Контрольне підполе', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'x', 0, 1, 'Загальний підзаголовок', 'Загальний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'y', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '730', 'z', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '788', '', '', 'COMPLEX LINKING ENTRY DATA', 'COMPLEX LINKING ENTRY DATA', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '788', '0', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', '5', 0, 1, 'Організація, яка застосовує поле', 'Організація, яка застосовує поле', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', 'a', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 7, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '788', 'i', 0, 1, 'Пояснювальний текст', 'Пояснювальний текст', 7, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '856', '', 1, 'Місцезнаходження електронного ресурсу і доступ до нього', 'Місцезнаходження електронного ресурсу і доступ до нього', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '856', '2', 0, 0, 'Спосіб доступу', 'Спосіб доступу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', '3', 0, 0, 'Область застосування даних поля', 'Область застосування даних поля', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', '8', 0, 1, 'Номер зв’язку та порядковий номер', 'Номер зв’язку та порядковий номер', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'a', 0, 1, 'Ім’я сервера/домену', 'Ім’я сервера/домену', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'b', 0, 1, 'Номер для доступу', 'Номер для доступу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'c', 0, 1, 'Інформація про стиснення', 'Інформація про стиснення', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'd', 0, 1, 'Шлях', 'Шлях',                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'f', 0, 1, 'Електронне ім’я', 'Електронне ім’я', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'h', 0, 0, 'Виконавець запиту', 'Виконавець запиту', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'i', 0, 1, 'Команди', 'Команди',             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'j', 0, 0, 'Кількість бітів в секунду', 'Кількість бітів в секунду', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'k', 0, 0, 'Пароль', 'Пароль',               8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'l', 0, 0, 'Ім’я користувача', 'Ім’я користувача', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'm', 0, 1, 'Контактні дані для підтримки доступу', 'Контактні дані для підтримки доступу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'n', 0, 0, 'Місце знаходження сервера', 'Місце знаходження сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'o', 0, 0, 'Операційна система сервера', 'Операційна система сервера', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'p', 0, 0, 'Порт', 'Порт',                   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'q', 0, 0, 'Тип електронного формату', 'Тип електронного формату', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'r', 0, 0, 'Встановлення', 'Встановлення',   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 's', 0, 1, 'Розмір файлу', 'Розмір файлу',   8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 't', 0, 1, 'Емуляція терміналу', 'Емуляція терміналу', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', 'Уніфікований визначник ресурсу (URI)', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'v', 0, 1, 'Години доступу за даним методом', 'Години доступу за даним методом', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'w', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'x', 0, 1, 'Службові нотатки', 'Службові нотатки', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'y', 0, 1, 'Довідковий текст', 'Довідковий текст', 8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '856', 'z', 0, 1, 'Загальнодоступна примітка', 'Загальнодоступна примітка', 8, 0, '', NULL, NULL, 0, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('UNIF_TITLE', '880', '', 1, 'Альтернативне [що перемикається] подання графічних символів', 'Альтернативне [що перемикається] подання графічних символів', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'UNIF_TITLE', '880', '0', 0, 1, 0, 0,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '1', 0, 1, 1, 1,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '2', 0, 1, 2, 2,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '3', 0, 1, 3, 3,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '4', 0, 1, 4, 4,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '5', 0, 1, 5, 5,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '6', 0, 1, 6, 6,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '7', 0, 1, 7, 7,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', '8', 0, 1, 8, 8,                             8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'a', 0, 1, 'a', 'a',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'b', 0, 1, 'b', 'b',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'c', 0, 1, 'c', 'c',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'd', 0, 1, 'd', 'd',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'e', 0, 1, 'e', 'e',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'f', 0, 1, 'f', 'f',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'g', 0, 1, 'g', 'g',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'h', 0, 1, 'h', 'h',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'i', 0, 1, 'i', 'i',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'j', 0, 1, 'j', 'j',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'k', 0, 1, 'k', 'k',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'l', 0, 1, 'l', 'l',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'm', 0, 1, 'm', 'm',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'n', 0, 1, 'n', 'n',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'o', 0, 1, 'o', 'o',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'p', 0, 1, 'p', 'p',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'q', 0, 1, 'q', 'q',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'r', 0, 1, 'r', 'r',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 's', 0, 1, 's', 's',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 't', 0, 1, 't', 't',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'u', 0, 1, 'u', 'u',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'v', 0, 1, 'v', 'v',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'w', 0, 1, 'w', 'w',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'x', 0, 1, 'x', 'x',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'y', 0, 1, 'y', 'y',                         8, 0, '', NULL, NULL, 0, NULL, 0),
 ('', 'UNIF_TITLE', '880', 'z', 0, 1, 'z', 'z',                         8, 0, '', NULL, NULL, 0, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
