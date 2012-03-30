-- На основе MARC21-структуры на английском «Fast Add Frameworks»
-- Перевод/адаптация: Сергей Дубик, Ольга Баркова (2011)

DELETE FROM biblio_framework WHERE frameworkcode='FA';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('FA', 'Структура быстрого добавления');
DELETE FROM marc_tag_structure WHERE frameworkcode='FA';
DELETE FROM marc_subfield_structure WHERE frameworkcode='FA';


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '000', 1, '', 'Маркер записи', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '000', '@', 1, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, 0, '', '', 'marc21_leader.pl', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '008', 1, '', 'Кодируемые данные', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '008', '@', 1, 0, 'Контрольное поле постоянной длины', 'Контрольное поле постоянной длины', 0, 0, '', '', 'marc21_field_008.pl', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '010', '', '', 'Контрольный номер записи в Библиотеке Конгресса США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '010', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'a', 0, 0, 'Контрольный номер записи БК', '',        0, 0, 'biblioitems.lccn', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'b', 0, 1, 'Контрольный номер записи NUCMC (Национальный объединенный каталог рукописных собраний)', '', 0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '010', 'z', 0, 1, 'Отменённый/ошибочный контрольный номер БК', '', 0, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '020', '', 1, 'Индекс  ISBN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '020', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'a', 0, 0, 'ISBN', '',                               0, 0, 'biblioitems.isbn', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'c', 0, 0, 'Цена, тираж', '',                        0, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '020', 'z', 0, 1, 'Отмененный/ошибочный  ISBN', '',         0, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '022', '', 1, 'Индекс  ISSN', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '050', '', 1, 'Расстановочный код библ. Конгресса', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '050', 'a', 0, 1, 'Классификационный индекс', '',           0, 0, '', '', '', 0, '', '', NULL),
 ('FA', '', '050', 'b', 0, 0, 'Номер единицы', '',                      0, 0, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '082', '2', 0, 0, 'Номер издания', '',                      0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', '6', 0, 0, 'Элемент связи', 'Элемент связи',         0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', 'a', 0, 1, 'Индекс Дьюи', '',                        0, 0, '', '', '', NULL, '', NULL, NULL),
 ('FA', '', '082', 'b', 0, 0, 'Номер единицы', '',                      0, 0, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('CF', '084', '', 1, 'Индекс другой классификации/Индекс ББК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('CF', NULL, '084', '2', 0, 0, 'Источник индекса', '',                 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', '6', 0, 0, 'Элемент связи', 'Элемент связи',       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', '8', 0, 1, 'Связь поля и ее порядковый номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', 'a', 0, 1, 'Индекс другой классификации/Индекс ББК', '', 0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('CF', NULL, '084', 'b', 0, 0, 'Номер единицы', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '100', '', '', 'Автор', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '100', '4', 0, 1, 'Код отношения', '',                      1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', '6', 0, 0, 'Связь', '',                              1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', '8', 0, 1, 'Связь поля и её порядковый номер', '',   1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', 'PERSO_NAME', '100', 'a', 0, 0, 'Автор', '',                    1, 0, 'biblio.author', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'b', 0, 0, 'Династ. номер', '',                      1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'c', 0, 0, 'Титул (звания)', '',                     1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'd', 0, 0, 'Дата', '',                               1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'e', 0, 1, 'Роль лиц', '',                           1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'f', 0, 0, 'Дата публикации', '',                    1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'g', 0, 0, 'Прочие сведения', '',                    1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'j', 0, 1, 'Принадлежность неизвестного автора к последователям, ученикам, сторонникам, школе и т. д.', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'k', 0, 1, 'Подзаголовок формы', '',                 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'l', 0, 0, 'Язык работы', '',                        1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'n', 0, 1, 'Обозначение и номер части/раздела произведения', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'p', 0, 1, 'Заглавие части/раздела произведения', '', 1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'q', 0, 0, 'Полное имя', '',                         1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 't', 0, 0, 'Заглавие работы', '',                    1, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '100', 'u', 0, 0, 'Дополнение', '',                         1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '245', 1, '', 'Заглавие', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '245', '6', 0, 0, 'Элемент связи', '',                      2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'a', 0, 0, 'Заглавие', '',                           2, 0, 'biblio.title', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'b', 0, 0, 'Продолж. заглавия', '',                  2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'c', 0, 0, 'Ответственность', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'd', 0, 0, 'Designation of section/part/series (SE) (устаревшее)', 'Designation of section section/part/series: (SE) (устаревшее)', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'e', 0, 0, 'Name of part/section/series (SE) (устаревшее)', 'Name of part/section/series (SE) (устаревшее)', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'f', 0, 0, 'Даты создания произведения', '',         2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'g', 0, 0, 'Даты создания осн. части произв.', '',   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'h', 0, 0, 'Физичисский носитель', '',               2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'k', 0, 1, 'Форма, вид, жанр', '',                   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'n', 0, 1, 'Номер части/раздела', '',                2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 'p', 0, 1, 'Название части/раздела', '',             2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '245', 's', 0, 0, 'Версия', '',                             2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '250', '', '', 'Сведения об издании', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '250', '6', 0, 0, 'Элемент связи', '',                      2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '250', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '250', 'a', 0, 0, 'Основные сведения об издании', '',       2, 0, 'biblioitems.editionstatement', '', '', 0, NULL, '', ''),
 ('FA', '', '250', 'b', 0, 0, 'Дополнительные сведения об издании', '', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '260', '', 1, 'Выходные данные', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '260', '6', 0, 0, 'Элемент связи', '',                      2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', '8', 0, 1, 'Связь поля и ее порядковый номер', '',   2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'a', 0, 1, 'Место издания', '',                      2, 0, 'biblioitems.place', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'b', 0, 1, 'Издательство', '',                       2, 0, 'biblioitems.publishercode', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'c', 0, 1, 'Дата издания', '',                       2, 0, 'biblio.copyrightdate', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'd', 0, 0, 'Plate or publishers number for music (Pre-AACR 2) (устаревшее, CAN/MARC), (локальное, США)', '', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'e', 0, 0, 'Место печатания', '',                    2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'f', 0, 0, 'Типография', '',                         2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'g', 0, 0, 'Дата печатания', '',                     2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'k', 0, 0, 'Identification/manufacturer number (устаревшее, CAN/MARC]', 'Identification/manufacturer number (устаревшее, CAN/MARC]', 2, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '260', 'l', 0, 0, 'Matrix and/or take number (устаревшее, CAN/MARC]', 'Matrix and/or take number (устаревшее, CAN/MARC]', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '300', '', 1, 'Физическое описание', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('FA', '500', '', 1, 'Примечания', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('FA', '', '500', '3', 0, 0, 'Область применения данных поля', '',     5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '5', 0, 0, 'Принадлежность поля организации', '',    5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '6', 0, 0, 'Элемент связи', '',                      5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', '8', 0, 1, 'Связь полей и номер последовательности', '', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'a', 0, 0, 'Примечание', '',                         5, 0, 'biblio.notes', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'l', 0, 0, 'Library of Congress call number (SE) (устаревшее)', 'Library of Congress call number (SE) (устаревшее)', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'n', 0, 0, 'n (RLIN) (устаревшее)', 'n (RLIN) (устаревшее)', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'x', 0, 0, 'International Standard Serial Number (SE) (устаревшее)', 'International Standard Serial Number (SE) (устаревшее)', 5, 0, '', '', '', 0, NULL, '', ''),
 ('FA', '', '500', 'z', 0, 0, 'Source of note information (AM SE) (устаревшее)', 'Source of note information (AM SE) (устаревшее)', 5, 0, '', '', '', 0, NULL, '', '');
