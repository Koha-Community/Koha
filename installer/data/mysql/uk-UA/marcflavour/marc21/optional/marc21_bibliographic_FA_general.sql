-- На основі MARC21-структури англійською „Fast Add Framework“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

DELETE FROM biblio_framework WHERE frameworkcode='FA';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('FA', 'Структура швидкого додавання');
DELETE FROM marc_tag_structure WHERE frameworkcode='FA';
DELETE FROM marc_subfield_structure WHERE frameworkcode='FA';


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '000', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_leader.pl', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '008', 1, '', 'Кодовані дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '008', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_field_008.pl', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '010', '', '', 'Контрольний номер запису в Бібліотеці Конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '010', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'a', 0, 0, 'Контрольний номер запису БК', '',        0, 0, 'biblioitems.lccn', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'b', 0, 1, 'Контрольний номер запису NUCMC (Національний об’єднаний каталог рукописних зібрань)', '', 0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'z', 0, 1, 'Скасований/помилковий контрольний номер БК', '', 0, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '020', '', 1, 'Індекс ISBN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '020', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'a', 0, 0, 'ISBN', '',                               0, 0, 'biblioitems.isbn', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'c', 0, 0, 'Ціна, тираж', '',                        0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'z', 0, 1, 'Скасований/помилковий ISBN', '',         0, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '022', '', 1, 'Індекс ISSN', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '050', '', 1, 'Розстановочний код бібл. Конгресу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '050', 'a', 0, 1, 'Класифікаційний індекс', '',             0, 0, '', '', '', 0, '', '', NULL),
 ('FA', '', '050', 'b', 0, 0, 'Номер одиниці', '',                      0, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '082', '2', 0, 0, 'Номер видання', '',                      0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', 'a', 0, 1, 'Індекс Дьюї', '',                        0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', 'b', 0, 0, 'Номер одиниці', '',                      0, 0, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('CF', '084', '', 1, 'Індекс ББК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('CF', NULL, '084', '2', 0, 0, 'Джерело індексу', '',                  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', '6', 0, 0, 'Елемент зв’язку', '',   0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', 'a', 0, 1, 'Індекс ББК / індекс іншої класифікації', '',                       0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', 'b', 0, 0, 'Номер одиниці', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '100', '', '', 'Автор', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '100', '4', 0, 0, 'Код відношення', '',                     1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', '6', 0, 0, 'Зв’язок', '',                            1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', 'PERSO_NAME', '100', 'a', 0, 0, 'Автор', '',                    1, 0, 'biblio.author', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'b', 0, 0, 'Династ. номер', '',                      1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'c', 0, 0, 'Титул (звання)', '',                     1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'd', 0, 0, 'Дата', '',                               1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'e', 0, 0, 'Роль осіб', '',                          1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'f', 0, 0, 'Дата публікації', '',                    1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'g', 0, 0, 'Інші відомості', '',                     1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'j', 0, 1, 'Приналежність невідомого автора до послідовників, учнів, прихильників, школі і т. ін.', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'k', 0, 1, 'Підзаголовок форми', '',                 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'l', 0, 0, 'Мова роботи', '',                        1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'q', 0, 0, 'Повне ім’я', '',                         1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 't', 0, 0, 'Назва роботи', '',                       1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'u', 0, 0, 'Доповнення', '',                         1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '245', 1, '', 'Назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '245', '6', 0, 0, 'Елемент зв’язку', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'a', 0, 0, 'Назва', '',                              2, 0, 'biblio.title', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'b', 0, 0, 'Продовж. назви', '',                     2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'c', 0, 0, 'Відповідальність', '',                   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'd', 0, 0, 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series: (SE) [OBSOLETE]', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'e', 0, 0, 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'f', 0, 0, 'Дати створення твору', '',               2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'g', 0, 0, 'Дати створення осн. частини твору', '',  2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'h', 0, 0, 'Фізичний носій', '',                     2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'k', 0, 1, 'Форма, вид, жанр', '',                   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'n', 0, 1, 'Номер частини/розділу', '',              2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'p', 0, 1, 'Назва частини/розділу', '',              2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 's', 0, 0, 'Версія', '',                             2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '250', '', '', 'Відомості про видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '250', '6', 0, 0, 'Елемент зв’язку', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '250', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '250', 'a', 0, 0, 'Основні відомості про видання', '',      2, 0, 'biblioitems.editionstatement', '', '', 0, NULL, '', ''),
 ('FA', '', '250', 'b', 0, 0, 'Додаткові відомості про видання', '',    2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '260', '', 1, 'Вихідні дані', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '260', '6', 0, 0, 'Елемент зв’язку', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'a', 0, 1, 'Місце видання', '',                      2, 0, 'biblioitems.place', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'b', 0, 1, 'Видавництво', '',                        2, 0, 'biblioitems.publishercode', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'c', 0, 1, 'Дата видання', '',                       2, 0, 'biblio.copyrightdate', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'd', 0, 0, 'Plate or publishers number for music (Pre-AACR 2) (застаріле, CAN/MARC), (локальне, США)', '', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'e', 0, 0, 'Місце друкування', '',                   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'f', 0, 0, 'Друкарня', '',                           2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'g', 0, 0, 'Дата друкування', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'k', 0, 0, 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'l', 0, 0, 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '300', '', 1, 'Фізичний опис', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '500', '', 1, 'Примітка', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '500', '3', 0, 0, 'Область застосування даних поля', '',    5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '5', 0, 0, 'Приналежність поля організації', '',     5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '6', 0, 0, 'Елемент зв’язку', '',                    5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'a', 0, 0, 'Примітка', '',                           5, 0, 'biblio.notes', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'l', 0, 0, 'Library of Congress call number (SE) (застаріле)', 'Library of Congress call number (SE) [OBSOLETE]', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'n', 0, 0, 'n (RLIN) (застаріле)', 'n (RLIN) [OBSOLETE]', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'x', 0, 0, 'International Standard Serial Number (SE) (застаріле)', 'International Standard Serial Number (SE) [OBSOLETE]', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'z', 0, 0, 'Source of note information (AM SE) (застаріле)', 'Source of note information (AM SE) [OBSOLETE]', 5, 0, '', '', '', 0, NULL, '', '');
