-- На основе MARC21-структуры на английском «DEFAULT»
-- Перевод/адаптация: Сергей Дубик, Ольга Баркова (2011)

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '090', '', 1, 'Шифры', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '090', 'a', 0, 0, 'Полочный индекс', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'b', 0, 0, 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 'Local cutter number (OCLC) ; Book number/undivided call number, CALL (RLIN)', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'c', 0, 0, 'Каталожный индекс', '',                    0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '090', 'e', 0, 1, 'Инвентарный номер', '',                    0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'f', 0, 1, 'Сигла хранения', '',                       0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'h', 0, 1, 'Формат', '',                               0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'i', 0, 0, 'Output transaction instruction, INS (RLIN)', 'Output transaction instruction, INS (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'l', 0, 0, 'Extra card control statement, EXT (RLIN)', 'Extra card control statement, EXT (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'n', 0, 0, 'Additional local notes, ANT (RLIN)', 'Additional local notes, ANT (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'p', 0, 0, 'Pathfinder code, PTH (RLIN)', 'Pathfinder code, PTH (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 't', 0, 0, 'Field suppresion, FSP (RLIN)', 'Field suppresion, FSP (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'v', 0, 0, 'Volumes, VOL (RLIN)', 'Volumes, VOL (RLIN)', 0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'w', 0, 1, 'Номер фонда', '',                          0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '090', 'x', 0, 0, 'Авторский знак', '',                       0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '090', 'y', 0, 0, 'Date, VOL (RLIN)', 'Date, VOL (RLIN)',     0, 5, '', '', '', 0, '', '', NULL),
 ('', '', '090', 'z', 0, 0, 'Retention, VOL (RLIN)', 'Retention, VOL (RLIN)', 0, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '099', '', 1, 'Периодические издания', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '099', 'a', 0, 0, 'Индекс', '',                               0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '099', 'b', 0, 0, 'Название', '',                             0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'c', 0, 1, 'Адрес организации', '',                    0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'd', 0, 0, 'Название организации', '',                 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'e', 0, 0, 'Год', '',                                  0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '099', 'f', 0, 0, 'Количество комплектов', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '099', 'h', 0, 0, 'Цена', '',                                 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'x', 0, 1, 'Сигла хранения', '',                       0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'y', 0, 0, 'Количество месяцев', '',                   0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '099', 'z', 0, 1, 'Отметка о получении', '',                  0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '100', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     1, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '110', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     1, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '111', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     1, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '130', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     1, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '240', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     2, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '243', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     2, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '400', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     4, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '410', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     4, -6, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '411', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     4, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '440', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     4, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '610', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '611', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '630', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '648', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '650', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '651', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '654', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '655', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '656', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '657', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '658', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '662', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '690', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '691', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '696', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '697', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '698', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '699', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     6, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '710', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '711', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '730', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '789', '9', 0, 0, 9, 9,                                       7, -6, '', '', '', NULL, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '796', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '797', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '798', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '799', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '800', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '810', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '811', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '830', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '880', '9', 0, 1, 9, 9,                                       8, -6, '', '', '', NULL, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '886', '9', 0, 1, 9, 9,                                       8, -6, '', '', '', NULL, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '896', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '897', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '898', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '899', '9', 0, 0, '9 (RLIN)', '9 (RLIN)',                     8, -5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '900', '', 1, 'Макрообъекты', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '900', '4', 0, 1, 'Relator code', 'Relator code',             9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'a', 0, 0, 'Имя макрообъекта', '',                     9, 5, '', '', '', 0, '\'110a\', \'700a\', \'710a\'', '', NULL),
 ('', '', '900', 'b', 0, 0, 'Доступ к макрообъекту', '',                9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'e', 0, 1, 'Relator term', 'Relator term',             9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 't', 0, 0, 'Title of a work', 'Title of a work',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '900', 'u', 0, 0, 'Affiliation', 'Affiliation',               9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '901', '', 1, 'Тип документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '901', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 't', 0, 0, 'Тип документа', '',                        9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '901', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '902', '', 1, 'Элемент локальных данных B', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '902', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '902', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '903', '', 1, 'Элемент локальных данных C', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '903', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '903', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '904', '', 1, 'Элемент локальных данных D', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '904', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '904', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '905', '', 1, 'Элемент локальных данных E', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '905', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '905', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '906', '', 1, 'Элемент локальных данных F', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '906', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '906', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '907', '', 1, 'Элемент локальных данных G', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '907', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '907', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '908', '', '', 'Параметр входа данных', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '908', 'a', 0, 0, 'Параметр входа данных', '',                9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '910', '', '', 'Еквівалент або перехресне посилання — наймення організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '910', 'a', 0, 0, 'Еквівалент або перехресне посилання — наймення організації', '', 9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '911', '', 1, 'Журнальная рубрика', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '911', '4', 0, 1, 'Relator code', 'Relator code',           9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', '6', 0, 0, 'Linkage', 'Linkage',                     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'a', 0, 0, 'Журнальная рубрика', '',                 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'f', 0, 0, 'Date of a work', 'Date of a work',       9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'k', 0, 1, 'Form subheading', 'Form subheading',     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 't', 0, 0, 'Title of a work', 'Title of a work',     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '911', 'u', 0, 0, 'Affiliation', 'Affiliation',             9, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '930', '', 1, 'Эквивалент или перекрестная ссылка — унифицированный заголовок (локальное, Канада)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '930', '6', 0, 0, 'Linkage', 'Linkage',                     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'a', 0, 0, 'Uniform title', 'Uniform title',         9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'd', 0, 1, 'Date of treaty signing', 'Date of treaty signing', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'f', 0, 0, 'Date of a work', 'Date of a work',       9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'h', 0, 0, 'Medium', 'Medium',                       9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'k', 0, 1, 'Form subheading', 'Form subheading',     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 'r', 0, 0, 'Key for music', 'Key for music',         9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 's', 0, 0, 'Version', 'Version',                     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '930', 't', 0, 0, 'Title of a work', 'Title of a work',     9, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '936', '', '', 'OCLC-данные; часть, используемая для каталогизации', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '936', 'a', 0, 1, 'OCLC-данные; часть, используемая для каталогизации', '', 9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '940', '', 1, 'Эквивалент или перекрестная ссылка — унифицированное название (устаревшее) (только CAN/MARC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '940', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'a', 0, 0, 'Uniform title', 'Uniform title',           9, -6, '', '', '', 1, '', '', NULL),
 ('', '', '940', 'd', 0, 1, 'Date of treaty signing', 'Date of treaty signing', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'h', 0, 0, 'Medium', 'Medium',                         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 'r', 0, 0, 'Key for music', 'Key for music',           9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '940', 's', 0, 0, 'Version', 'Version',                       9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '941', '', 1, 'Эквивалент или перекрестная ссылка — лицензированное название (устаревшее) (только CAN/MARC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '941', 'a', 0, 0, 'Romanized title', 'Romanized title',     9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '941', 'h', 0, 0, 'Medium', 'Medium',                       9, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '942', '', '', 'Дополнительные данные (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '942', '0', 0, 0, 'Количество выдач для всех экземпляров', '', 9, -5, 'biblioitems.totalissues', '', '', NULL, '', '', NULL),
 ('', '', '942', '2', 0, 0, 'Код системы классификации для розстановки фонда', '', 9, 0, 'biblioitems.cn_source', 'cn_source', '', NULL, '', '', NULL),
 ('', '', '942', '6', 0, 0, 'Нормализованная классификация Коха для сортировки', '', -1, 7, 'biblioitems.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '942', 'a', 0, 0, 'Institution code (устаревшее)', '',        9, -5, '', '', '', NULL, '', '', NULL),
 ('', '', '942', 'c', 1, 0, 'Тип единицы (уровень записи)', '',         9, 0, 'biblioitems.itemtype', 'itemtypes', '', NULL, '', '', NULL),
 ('', '', '942', 'e', 0, 0, 'Издание /часть шифра/', '',                9, 0, NULL, '', '', NULL, '', '', NULL),
 ('', '', '942', 'h', 0, 0, 'Классификационная часть шифра хранения', '', 9, 0, 'biblioitems.cn_class', '', '', NULL, '', '', NULL),
 ('', '', '942', 'i', 0, 1, 'Экземплярная часть шифра хранения', '',    9, 0, 'biblioitems.cn_item', '', '', NULL, '', '', NULL),
 ('', '', '942', 'k', 0, 0, 'Префикс шифра хранения', '',               9, 0, 'biblioitems.cn_prefix', '', '', NULL, '', '', NULL),
 ('', '', '942', 'm', 0, 0, 'Суффикс шифра хранения', '',               9, 0, 'biblioitems.cn_suffix', '', '', 0, '', '', NULL),
 ('', '', '942', 'n', 0, 0, 'Статус сокрытия в ЭК', '',                 9, 0, NULL, '', '', 0, '', '', NULL),
 ('', '', '942', 's', 0, 0, 'Отметка о записи сериального издания', 'Запись сериального издания', 9, -5, 'biblio.serial', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '943', '', 1, 'Эквивалент или перекрестная ссылка — название коллектива (устаревшее) (только CAN/MARC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '943', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'a', 0, 0, 'Uniform title', 'Unifor title',            9, 5, '', '', '', 1, '', 130, NULL),
 ('', '', '943', 'd', 0, 1, 'Date of treaty signing', 'Date of treaty signing', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'h', 0, 0, 'Medium', 'Medium',                         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 'r', 0, 0, 'Key for music', 'Key for music',           9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '943', 's', 0, 0, 'Version', 'Version',                       9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '945', '', 1, 'Локальное — информация об обработке', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '945', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '945', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '946', '', 1, 'Локальное — информация об обработке', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '946', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '946', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '947', '', 1, 'Локальное — информация об обработке', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '947', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '947', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '948', '', 1, 'Локальное — информация об обработке; обозначение части серии', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '948', '0', 0, 1, '0 (OCLC)', '0 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '1', 0, 1, '1 (OCLC)', '1 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '2', 0, 1, '2 (OCLC)', '2 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '3', 0, 1, '3 (OCLC)', '3 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '4', 0, 1, '4 (OCLC)', '4 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '5', 0, 1, '5 (OCLC)', '5 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '6', 0, 1, '6 (OCLC)', '6 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '7', 0, 1, '7 (OCLC)', '7 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '8', 0, 1, '8 (OCLC)', '8 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', '9', 0, 1, '9 (OCLC)', '9 (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'a', 0, 0, 'Series part designator, SPT (RLIN)', 'Series part designator, SPT (RLIN)', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '948', 'b', 0, 1, 'b (OCLC)', 'b (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'c', 0, 1, 'c (OCLC)', 'c (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'd', 0, 1, 'd (OCLC)', 'd (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'e', 0, 1, 'e (OCLC)', 'e (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'f', 0, 1, 'f (OCLC)', 'f (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'g', 0, 1, 'g (OCLC)', 'g (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'h', 0, 1, 'h (OCLC)', 'h (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'i', 0, 1, 'i (OCLC)', 'i (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'j', 0, 1, 'j (OCLC)', 'j (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'k', 0, 1, 'k (OCLC)', 'k (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'l', 0, 1, 'l (OCLC)', 'l (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'm', 0, 1, 'm (OCLC)', 'm (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'n', 0, 1, 'n (OCLC)', 'n (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'o', 0, 1, 'o (OCLC)', 'o (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'p', 0, 1, 'p (OCLC)', 'p (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'q', 0, 1, 'q (OCLC)', 'q (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'r', 0, 1, 'r (OCLC)', 'r (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 's', 0, 1, 's (OCLC)', 's (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 't', 0, 1, 't (OCLC)', 't (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'u', 0, 1, 'u (OCLC)', 'u (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'v', 0, 1, 'v (OCLC)', 'v (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'w', 0, 1, 'w (OCLC)', 'w (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'x', 0, 1, 'x (OCLC)', 'x (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'y', 0, 1, 'y (OCLC)', 'y (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '948', 'z', 0, 1, 'z (OCLC)', 'z (OCLC)',                     9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '949', '', 1, 'Локальное — информация об обработке', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '949', '0', 0, 1, 0, 0,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '1', 0, 1, 1, 1,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '2', 0, 1, 2, 2,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '3', 0, 1, 3, 3,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '4', 0, 1, 4, 4,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '5', 0, 1, 5, 5,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '6', 0, 1, 6, 6,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '7', 0, 1, 7, 7,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '8', 0, 1, 8, 8,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', '9', 0, 1, 9, 9,                                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'a', 0, 1, 'a', 'a',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'b', 0, 1, 'b', 'b',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'c', 0, 1, 'c', 'c',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'd', 0, 1, 'd', 'd',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'e', 0, 1, 'e', 'e',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'f', 0, 1, 'f', 'f',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'g', 0, 1, 'g', 'g',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'h', 0, 1, 'h', 'h',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'i', 0, 1, 'i', 'i',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'j', 0, 1, 'j', 'j',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'k', 0, 1, 'k', 'k',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'l', 0, 1, 'l', 'l',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'm', 0, 1, 'm', 'm',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'n', 0, 1, 'n', 'n',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'o', 0, 1, 'o', 'o',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'p', 0, 1, 'p', 'p',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'q', 0, 1, 'q', 'q',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'r', 0, 1, 'r', 'r',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 's', 0, 1, 's', 's',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 't', 0, 1, 't', 't',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'u', 0, 1, 'u', 'u',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'v', 0, 1, 'v', 'v',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'w', 0, 1, 'w', 'w',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'x', 0, 1, 'x', 'x',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'y', 0, 1, 'y', 'y',                                   9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '949', 'z', 0, 1, 'z', 'z',                                   9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '950', '', 1, 'Локальное хранение', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '950', 'a', 0, 0, 'Classification number, LCAL (RLIN)', 'Classification number, LCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'b', 0, 0, 'Book number/undivided call number, LCAL (RLIN)', 'Book number/undivided call number, LCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'd', 0, 1, 'Additional free-text stamp above the call number, LCAL (RLIN)', 'Additional free-text stamp above the call number, LCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'e', 0, 1, 'Additional free-text or profiled stamp below the call number, LCAL (RLIN)', 'Additional free-text or profiled stamp below the call number, LCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'f', 0, 0, 'Location-level footnote, LFNT (RLIN)', 'Location-level footnote, LFNT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'h', 0, 0, 'Location-level output transaction history, LHST (RLIN)', 'Location-level output transaction history, LHST (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'i', 0, 0, 'Location-level extra card request, LEXT (RLIN)', 'Location-level extra card request, LEXT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'l', 0, 0, 'Permanent shelving location, LOC (RLIN)', 'Permanent shelving location, LOC (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'n', 0, 1, 'Location-level additional note, LANT (RLIN)', 'Location-level additional note, LANT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'p', 0, 0, 'Location-level pathfinder, LPTH (RLIN)', 'Location-level pathfinder, LPTH (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 't', 0, 0, 'Location-level field suppression, LFSP (RLIN)', 'Location-level field suppression, LFSP (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'u', 0, 1, 'Non-printing notes, LANT (RLIN)', 'Non-printing notes, LANT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'v', 0, 0, 'Volumes, LVOL (RLIN)', 'Volumes, LVOL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'w', 0, 0, 'Subscription status code, LANT (RLIN)', 'Subscription status code, LANT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'y', 0, 0, 'Date, LVOL (RLIN)', 'Date, LVOL (RLIN)',   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '950', 'z', 0, 0, 'Retention, LVOL (RLIN)', 'Retention, LVOL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '951', '', 1, 'Эквивалент или перекрестная ссылка — географическое название / название области (устаревшее) (только CAN/MARC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '951', '2', 0, 0, 'Source of heading or term', 'Source of heading or term', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', '3', 0, 0, 'Materials specified', 'Materials specified', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', '6', 0, 0, 'Linkage', 'Linkage',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'a', 0, 0, 'Geographic name', 'Geographic name',       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'b', 0, 1, 'Geographic name following place entry element [OBSOLETE]', 'Geographic name following place entry element [OBSOLETE]', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'v', 0, 1, 'Form subdivision', 'Form subdivision',     6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'x', 0, 1, 'General subdivision', 'General subdivision', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'y', 0, 1, 'Chronological subdivision', 'Chronological subdivision', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '951', 'z', 0, 1, 'Geographic subdivision', 'Geographic subdivision', 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '952', '', 1, 'Данные о экземплярах и расположение (Koha)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '952', '0', 0, 0, 'Статус изъятия', '',                       10, 0, 'items.withdrawn', 'WITHDRAWN', '', 0, '', '', NULL),
 ('', '', '952', '1', 0, 0, 'Статус потери/отсутствия', '',             10, 0, 'items.itemlost', 'LOST', '', 0, '', '', NULL),
 ('', '', '952', '2', 0, 0, 'Источник классификации или схема полочного расположения', '', 10, 0, 'items.cn_source', 'cn_source', '', NULL, '', '', NULL),
 ('', '', '952', '3', 0, 0, 'Нумерация (объединенный том или иная часть)', '', 10, -1, 'items.materials', '', '', NULL, '', '', NULL),
 ('', '', '952', '4', 0, 0, 'Статус повреждения', '',                   10, 0, 'items.damaged', 'DAMAGED', '', NULL, '', '', NULL),
 ('', '', '952', '5', 0, 0, 'Статус ограничения доступа', '',           10, 0, 'items.restricted', 'RESTRICTED', '', 0, '', '', NULL),
 ('', '', '952', '6', 0, 0, 'Нормализованная классификация Коха для сортировки', '', -1, 7, 'items.cn_sort', '', '', 0, '', '', NULL),
 ('', '', '952', '7', 0, 0, 'Тип оборота (не для выдачи)', '',          10, 0, 'items.notforloan', 'NOT_LOAN', '', 0, '', '', NULL),
 ('', '', '952', '8', 0, 0, 'Вид собрания', '',                         10, 0, 'items.ccode', 'CCODE', '', 0, '', '', NULL),
 ('', '', '952', '9', 0, 0, 'Внутренний № экземпляра в Koha (items.itemnumber)', 'Внутренний № экземпляра в Koha', -1, 7, 'items.itemnumber', '', '', 0, '', '', NULL),
 ('', '', '952', 'a', 0, 1, 'Исходное место хранения экземпляра (домашнее подразделение)', '', 10, 0, 'items.homebranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'b', 0, 1, 'Место временного хранения или выдачи (подразделение хранения)', '', 10, 0, 'items.holdingbranch', 'branches', '', 0, '', '', NULL),
 ('', '', '952', 'c', 0, 0, 'Полочное расположение', '',                10, 0, 'items.location', 'LOC', '', 0, '', '', NULL),
 ('', '', '952', 'd', 0, 0, 'Дата поступления', '',                     10, 0, 'items.dateaccessioned', '', 'dateaccessioned.pl', 0, '', '', NULL),
 ('', '', '952', 'e', 0, 0, 'Источник поступления (поставщик)', '',     10, 0, 'items.booksellerid', '', '', 0, '', '', NULL),
 ('', '', '952', 'f', 0, 0, 'Кодированный определитель местоположения', '', 10, 0, 'items.coded_location_qualifier', '', '', NULL, '', '', NULL),
 ('', '', '952', 'g', 0, 0, 'Стоимость, обычная закупочная цена', '',   10, 0, 'items.price', '', '', 0, '', '', NULL),
 ('', '', '952', 'h', 0, 0, 'Нумерация/хронология сериальных изданий', '', 10, 0, 'items.enumchron', '', '', 0, '', '', NULL),
 ('', '', '952', 'i', 0, 0, 'Инвентарный номер', '',                    10, 0, 'items.stocknumber', '', '', NULL, '', '', NULL),
 ('', '', '952', 'j', 0, 0, 'Полочный контрольный номер', '',           10, -1, 'items.stack', 'STACK', '', NULL, '', '', NULL),
 ('', '', '952', 'l', 0, 0, 'Выдач в целом', '',                        10, -5, 'items.issues', '', '', NULL, '', '', NULL),
 ('', '', '952', 'm', 0, 0, 'Продлено в целом', '',                     10, -5, 'items.renewals', '', '', NULL, '', '', NULL),
 ('', '', '952', 'n', 0, 0, 'Всего резервирований', '',                 10, -5, 'items.reserves', '', '', NULL, '', '', NULL),
 ('', '', '952', 'o', 0, 0, 'Полный (экземплярный) шифр хранения', '',  10, 0, 'items.itemcallnumber', '', NULL, 0, '', '', NULL),
 ('', '', '952', 'p', 0, 0, 'Штрих-код', '',                            10, 0, 'items.barcode', '', 'barcode.pl', 0, '', '', NULL),
 ('', '', '952', 'q', 0, 0, 'Дата окончания срока выдачи', '',          10, -5, 'items.onloan', '', '', NULL, '', '', NULL),
 ('', '', '952', 'r', 0, 0, 'Дата, когда последний раз видели экземпляр', '', 10, -5, 'items.datelastseen', '', '', NULL, '', '', NULL),
 ('', '', '952', 's', 0, 0, 'Дата последней выдачи или возвращения', '', 10, -5, 'items.datelastborrowed', '', '', NULL, '', '', NULL),
 ('', '', '952', 't', 0, 0, 'Порядковый номер комплекта/экземпляра', '', 10, 0, 'items.copynumber', '', '', NULL, '', '', NULL),
 ('', '', '952', 'u', 0, 0, 'Унифицированный идентификатор ресурсов', '', 10, 0, 'items.uri', '', '', 1, '', '', NULL),
 ('', '', '952', 'v', 0, 0, 'Стоимость, цена замены', '',               10, 0, 'items.replacementprice', '', '', 0, '', '', NULL),
 ('', '', '952', 'w', 0, 0, 'Дата, для которой действительна цена замены', '', 10, 0, 'items.replacementpricedate', '', '', 0, '', '', NULL),
 ('', '', '952', 'x', 0, 0, 'Служебное (необщедоступное) примечание', '', 10, 1, 'items.itemnotes_nonpublic', '', '', NULL, '', '', NULL),
 ('', '', '952', 'y', 0, 0, 'Тип единицы (уровень экземпляра)', '',     10, 0, 'items.itype', 'itemtypes', '', NULL, '', '', NULL),
 ('', '', '952', 'z', 0, 0, 'Общедоступное примечание о экземпляре', '', 10, 0, 'items.itemnotes', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '955', '', 1, 'Информация уровня копии', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '955', 'a', 0, 0, 'Classification number, CCAL (RLIN)', 'Classification number, CCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'b', 0, 0, 'Book number/undivided call number, CCAL (RLIN)', 'Book number/undivided call number, CCAL (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'c', 0, 0, 'Copy information and material description, CCAL + MDES (RLIN)', 'Copy information and material description, CCAL + MDES (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'h', 0, 0, 'Copy status--for earlier dates, CST (RLIN)', 'Copy status--for earlier dates, CST (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'i', 0, 0, 'Copy status, CST (RLIN)', 'Copy status, CST (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'l', 0, 0, 'Permanent shelving location, LOC (RLIN)', 'Permanent shelving location, LOC (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'q', 0, 1, 'Aquisitions control number, HNT (RLIN)', 'Aquisitions control number, HNT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 'r', 0, 0, 'Circulation control number, HNT (RLIN)', 'Circulation control number, HNT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '955', 's', 0, 1, 'Shelflist note, HNT (RLIN)', 'Shelflist note, HNT (RLIN)', 9, 5, '', '', '', 1, '', '', NULL),
 ('', '', '955', 'u', 0, 1, 'Non-printing notes, HNT (RLIN)', 'Non-printing notes, HNT (RLIN)', 9, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '956', '', 1, 'Локальное — электронное местонахождение и доступ', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '956', '2', 0, 0, 'Access method', 'Access method',           9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', '3', 0, 0, 'Materials specified', 'Materials specified', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'a', 0, 1, 'Host name', 'Host name',                   9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'b', 0, 1, 'Access number', 'Access number',           9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'c', 0, 1, 'Compression information', 'Compression information', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'd', 0, 1, 'Path', 'Path',                             9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'f', 0, 1, 'Electronic name', 'Electronic name',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'h', 0, 0, 'Processor of request', 'Processor of request', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'i', 0, 1, 'Instruction', 'Instruction',               9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'j', 0, 0, 'Bits per second', 'Bits per second',       9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'k', 0, 0, 'Password', 'Password',                     9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'l', 0, 0, 'Logon', 'Logon',                           9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'm', 0, 1, 'Contact for access assistance', 'Contact for access assistance', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'n', 0, 0, 'Name of location of host in subfield', 'Name of location of host in subfield', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'o', 0, 0, 'Operating system', 'Operating system',     9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'p', 0, 0, 'Port', 'Port',                             9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'q', 0, 0, 'Electronic format type', 'Electronic format type', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'r', 0, 0, 'Settings', 'Settings',                     9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 's', 0, 1, 'File size', 'File size',                   9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 't', 0, 1, 'Terminal emulation', 'Terminal emulation', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'u', 0, 1, 'Uniform Resource Identifier', 'Uniform Resource Identifier', 9, -6, '', '', '', 1, '', '', NULL),
 ('', '', '956', 'v', 0, 1, 'Hours access method available', 'Hours access method available', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'w', 0, 1, 'Record control number', 'Record control number', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'x', 0, 1, 'Nonpublic note', 'Nonpublic note',         9, 6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'y', 0, 1, 'Link text', 'Link text',                   9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '956', 'z', 0, 1, 'Public note', 'Public note',               9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '960', '', 1, 'Физическое местонахождение', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '960', '3', 0, 0, 'Materials specified, MATL', 'Materials specified, MATL', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '960', 'a', 0, 0, 'Физическое местонахождение', '',           9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '967', '', 1, 'Дополнительные ESTC-коды', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '967', 'a', 0, 0, 'GNR (RLIN)', 'GNR (RLIN)',                 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '967', 'c', 0, 0, 'PSI (RLIN)', 'PSI (RLIN)',                 9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '980', '', 1, 'Эквивалент или перекрестная ссылка — сведения о серии — индивидуальное имя/название (локальное, Канада)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '980', '4', 0, 1, 'Relator code', 'Relator code',             9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'a', 0, 0, 'Personal name', 'Personal name',           9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'b', 0, 0, 'Numeration', 'Numeration',                 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'e', 0, 1, 'Relator term', 'Relator term',             9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'h', 0, 0, 'Medium', 'Medium',                         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'r', 0, 0, 'Key for music', 'Key for music',           9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 's', 0, 0, 'Version', 'Version',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 't', 0, 0, 'Title of a work', 'Title of a work',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'u', 0, 0, 'Affiliation', 'Affiliation',               9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '980', 'v', 0, 0, 'Volume/sequential designation', 'Volume/sequential designation', 9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '981', '', 1, 'Эквивалент или перекрестная ссылка — сведения о серии — название организации / название (локальное, Канада)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '981', '4', 0, 1, 'Relator code', 'Relator code',             9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'e', 0, 1, 'Relator term', 'Relator term',             9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'h', 0, 0, 'Medium', 'Medium',                         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'r', 0, 0, 'Key for music', 'Key for music',           9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 's', 0, 0, 'Version', 'Version',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 't', 0, 0, 'Title of a work', 'Title of a work',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'u', 0, 0, 'Affiliation', 'Affiliation',               9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '981', 'v', 0, 0, 'Volume/sequential designation', 'Volume/sequential designation', 9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '982', '', 1, 'Эквивалент или перекрестная ссылка — сведения о серии — название конференции или мероприятия/название (локальное, Канада)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '982', '4', 0, 1, 'Relator code', 'Relator code',           8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', '6', 0, 0, 'Linkage', 'Linkage',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', '8', 0, 1, 'Field link and sequence number ', 'Field link and sequence number ', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'f', 0, 0, 'Date of a work', 'Date of a work',       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'h', 0, 0, 'Medium', 'Medium',                       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'k', 0, 1, 'Form subheading', 'Form subheading',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'l', 0, 0, 'Language of a work', 'Language of a work', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 's', 0, 0, 'Version', 'Version',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 't', 0, 0, 'Title of a work', 'Title of a work',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'u', 0, 0, 'Affiliation', 'Affiliation',             8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '982', 'v', 0, 0, 'Volume/sequential designation', 'Volume/sequential designation', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '983', '', 1, 'Эквивалент или перекрестная ссылка — сведения о серии — название / унифицированное название (локальное, Канада)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '983', '6', 0, 0, 'Linkage', 'Linkage',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'a', 0, 0, 'Uniform title', 'Uniform title',           9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'd', 0, 1, 'Date of treaty signing', 'Date of treaty signing', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'f', 0, 0, 'Date of a work', 'Date of a work',         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'g', 0, 0, 'Miscellaneous information', 'Miscellaneous information', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'h', 0, 0, 'Medium', 'Medium',                         9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'k', 0, 1, 'Form subheading', 'Form subheading',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'l', 0, 0, 'Language of a work', 'Language of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'm', 0, 1, 'Medium of performance for music', 'Medium of performance for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'n', 0, 1, 'Number of part/section of a work', 'Number of part/section of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'o', 0, 0, 'Arranged statement for music', 'Arranged statement for music', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'p', 0, 1, 'Name of part/section of a work', 'Name of part/section of a work', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'r', 0, 0, 'Key for music', 'Key for music',           9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 's', 0, 0, 'Version', 'Version',                       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 't', 0, 0, 'Title of a work', 'Title of a work',       9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '983', 'v', 0, 0, 'Volume number/sequential designation', 'Volume number/sequential designation', 9, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '984', '', 1, 'Автоматическая ведомость хранения', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '984', 'a', 0, 0, 'Holding library identification number', 'Holding library identification number', 9, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '984', 'b', 0, 1, 'Physical description codes', 'Physical description codes', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'c', 0, 0, 'Call number', 'Call number',               9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'd', 0, 0, 'Volume or other numbering', 'Volume or other numbering', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'e', 0, 0, 'Dates', 'Dates',                           9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'f', 0, 0, 'Completeness note', 'Completeness note',   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'g', 0, 0, 'Referral note', 'Referral note',           9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '984', 'h', 0, 0, 'Retention note', 'Retention note',         9, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '987', '', 1, 'Локальное — исторя лицензирования/конверсии', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '987', 'a', 0, 0, 'Romanization/conversion identifier', 'Romanization/conversion identifier', 9, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '987', 'b', 0, 1, 'Agency that converted, created or reviewed', 'Agency that converted, created or reviewed', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '987', 'c', 0, 0, 'Date of conversion or review', 'Date of conversion or review', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '987', 'd', 0, 0, 'Status code', 'Status code ',              9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '987', 'e', 0, 0, 'Version of conversion program used', 'Version of conversion program used', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '987', 'f', 0, 0, 'Note', 'Note',                             9, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '990', '', 1, 'Данные о заказе', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '990', 'a', 0, 1, 'Автор заказа', '',                         9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '990', 'b', 0, 1, 'Заказано', '',                             9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '990', 'c', 0, 1, 'Приоритет заказа', '',                     9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'd', 0, 1, 'Дата исполнения', '',                      9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'e', 0, 1, 'Получено на ИУ', '',                       9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'f', 0, 1, 'Даты поступлений', '',                     9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'g', 0, 1, 'Размещение заказа', '',                    9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'h', 0, 1, '№ записи в КСУ для Б/У', '',               9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'j', 0, 1, 'Количество экземпляров', '',               9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'k', 0, 1, 'Состоит на УК', '',                        9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'n', 0, 1, 'Номер УК', '',                             9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 't', 0, 1, '№ записи в КСУ для И/У', '',               9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'v', 0, 1, 'Состоит на ИУ', '',                        9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'w', 0, 1, 'Получено на УК', '',                       9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '990', 'z', 0, 1, 'Выбыло', '',                               9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '995', '', 1, 'Рекомендация 995 (локальное, UNIMARC Франция и др.)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '995', '0', 0, 0, 'Withdrawn status [LOCAL, KOHA]', 'Withdrawn status [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', '1', 0, 0, 'Lost status [LOCAL, KOHA]', 'Lost status [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', '2', 0, 0, 'System code (specific classification or other scheme and edition) [LOCAL, KOHA]', 'System code (specific classification or other scheme and edition) [LOCAL, KOHA]', 9, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '995', '3', 0, 0, 'Use restrictions [LOCAL, KOHA]', 'Use restrictions [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', '4', 0, 0, 'Koha normalized classification for sorting [LOCAL, KOHA]', 'Koha normalized classification for sorting [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', '5', 0, 1, 'Coded location qualifier [LOCAL, KOHA]', 'Coded location qualifier [LOCAL, KOHA]', 9, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '995', '6', 0, 0, 'Copy number [LOCAL, KOHA]', 'Copy number [LOCAL, KOHA]', 9, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '995', '7', 0, 1, 'Uniform Resource Identifier [LOCAL, KOHA]', 'Uniform Resource Identifier [LOCAL, KOHA]', 9, 5, '', '', '', 1, '', '', NULL),
 ('', '', '995', '8', 0, 0, 'Koha collection [LOCAL, KOHA]', 'Koha collection [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', '9', 0, 0, 'Internal item number (Koha itemnumber, autogenerated) [LOCAL, KOHA]', 'Internal itemnumber (Koha itemnumber) [LOCAL, KOHA]', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'a', 0, 0, 'Origin of the item (home branch) (free text)', 'Origin of item (home branch) (free text)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'b', 0, 0, 'Origin of item (home branch) (coded)', 'Origin of item (home branch (coded)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'c', 0, 0, 'Lending or holding organisation (holding branch) (free text)', 'Lending or holding organisation (holding branch) (free text)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'd', 0, 0, 'Lending or holding organisation (holding branch) code', 'Lending or holding organisation (holding branch) code', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'e', 0, 0, 'Genre detail', 'Genre',                    9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'f', 0, 0, 'Штрих-код', '',                            9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'g', 0, 0, 'Barcode prefix', 'Barcode prefix',         9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'h', 0, 0, 'Barcode incrementation', 'Barcode incrementation', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'i', 0, 0, 'Barcode suffix', 'Barcode suffix',         9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'j', 0, 0, 'Section', 'Section',                       9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'k', 0, 0, 'Call number (full call number)', 'Call number (full call number)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'l', 0, 0, 'Numbering (volume or other part)', 'Numbering (bound volume or other part)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'm', 0, 0, 'Date of loan or deposit', 'Date of loan or deposit', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'n', 0, 0, 'Expiration of loan date', 'Expiration of loan date', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'o', 0, 1, 'Circulation type (not for loan)', 'Circulation type (not for loan)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'p', 0, 0, 'Serial', 'Serial',                         9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'q', 0, 0, 'Intended audience (age level)', 'Intended audience (age level)', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'r', 0, 0, 'Type of item and material', 'Type of item and material', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 's', 0, 0, 'Acquisition mode', 'Acquisition mode',     9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 't', 0, 0, 'Genre', 'Genre',                           9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'u', 0, 0, 'Copy note', 'Copy note',                   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'v', 0, 0, 'Periodical number', 'Periodical number',   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'w', 0, 0, 'Recipient organisation code', 'Recipient organisation code', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'x', 0, 0, 'Recipient organisation, free text', 'Recipient organisation, free text', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'y', 0, 0, 'Recipient parent organisation code', 'Recipient parent organisation code', 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '995', 'z', 0, 0, 'Recipient parent organisation, free text', 'Recipient parent organisation, free text', 9, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '998', '', 1, 'Персоналии', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '998', 'a', 0, 0, 'Персоналии', '',                           9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '998', 'b', 0, 0, 'Operators initials, OID (RLIN)', 'Operators initials, OID (RLIN)', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'c', 0, 0, 'Catalogers initials, CIN (RLIN)', 'Catalogers initials, CIN (RLIN)', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'd', 0, 0, 'First date, FD (RLIN)', 'First Date, FD (RLIN)', 9, -6, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'i', 0, 0, 'RINS (RLIN)', 'RINS (RLIN)',               9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'l', 0, 0, 'LI (RLIN)', 'LI (RLIN)',                   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'n', 0, 0, 'NUC (RLIN)', 'NUC (RLIN)',                 9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'p', 0, 0, 'PROC (RLIN)', 'PROC (RLIN)',               9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 's', 0, 0, 'CC (RLIN)', 'CC (RLIN)',                   9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 't', 0, 0, 'RTYP (RLIN)', 'RTYP (RLIN)',               9, 5, '', '', '', 0, '', '', NULL),
 ('', '', '998', 'w', 0, 0, 'PLINK (RLIN)', 'PLINK (RLIN)',             9, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '999', '', 1, 'Системные контрольные номера (Коха)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '999', 'a', 0, 0, 'Тип единицы хранения (устаревшее)', '',  -1, -5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '999', 'b', 0, 0, 'Подклас Дьюи (Коха, устаревшее)', '',    0, -5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '999', 'c', 0, 0, '«biblionumber» (Коха)', '',              -1, -5, 'biblio.biblionumber', NULL, '', NULL, '', '', NULL),
 ('', NULL, '999', 'd', 0, 0, '«biblioitemnumber» (Коха)', '',          -1, -5, 'biblioitems.biblioitemnumber', NULL, '', NULL, '', '', NULL);
