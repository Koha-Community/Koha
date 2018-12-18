-- 
-- Default classification sources and filing rules
-- for Koha.
--


-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey',   'Типовые правила заполнения для ДКД', 'Dewey'),
                               ('lcc',     'Типовые правила заполнения для КБК', 'LCC'),
                               ('generic', 'Правила заполнения для обобщённого библиотечного шифра', 'Generic');

-- splitting rules
INSERT INTO `class_split_rules` (`class_split_rule`, `description`, `split_routine`) VALUES
                               ('dewey', 'Default splitting rules for DDC', 'Dewey'),
                               ('lcc', 'Default splitting rules for LCC', 'LCC'),
                               ('generic', 'Generic call number splitting rules', 'Generic');

-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`, `class_split_rule`) VALUES
                            ('ddc',     'Десятичная классификация Дьюи (ДКД)', 1, 'dewey', 'dewey'),
                            ('lcc',     'Классификация Библиотеки Конгресса (КБК)', 1, 'lcc', 'lcc'),
                            ('udc',     'Универсальная десятичная классификация', 0, 'generic', 'generic'),
                            ('sudocs',  'Классификация SuDoc (U.S. GPO)', 0, 'generic', 'generic'),
                            ('anscr',   'ANSCR (звукозаписи)', 0, 'generic', 'generic'),
                            ('rubbk',   'Таблицы ББК для научных библиотек в 30-ти томах', 0, 'generic', 'generic'),
                            ('rugasnti','Рубрикатор ГАСНТИ', 0, 'generic', 'generic'),
                            ('rubbkd',  'Таблицы ББК для детских библиотек в 1 т.', 0, 'generic', 'generic'),
                            ('rubbkm',  'Таблицы ББК для массовых библиотек в 1 т.', 0, 'generic', 'generic'),
                            ('rubbko',  'Таблицы ББК для областных библиотек в 4-х томах', 0, 'generic', 'generic'),
                            ('rubbknp', 'Переиздания таблиц ББК для научных библиотек в 30-ти томах', 0, 'generic', 'generic'),
                            ('rubbkn',  'Таблицы ББК для научных библиотек в 5-ти томах', 0, 'generic', 'generic'),
                            ('rubbkmv', 'Таблицы ББК для массовых военных библиотек', 0, 'generic', 'generic'),
                            ('rubbkk',  'Таблицы ББК для краеведческих каталогов библиотек', 0, 'generic', 'generic'),
                            ('z',       'Другие/типовые схемы классификации', 0, 'generic', 'generic');

