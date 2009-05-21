-- 
-- Default classification sources and filing rules
-- for Koha.
--

TRUNCATE class_sort_rules;
-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey',   'Типовые правила заполнения для ДКД', 'Dewey'),
                               ('lcc',     'Типовые правила заполнения для КБК', 'LCC'),
                               ('generic', 'Правила заполнения для обобщённого библиотечного шифра', 'Generic');


TRUNCATE class_sources;
-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                            ('ddc',     'Десятичная классификация Дьюи (ДКД)', 1, 'dewey'),
                            ('lcc',     'Классификация Библиотеки Конгресса (КБК)', 1, 'lcc'),
                            ('udc',     'Универсальная десятичная классификация', 0, 'generic'),
                            ('sudocs',  'Классификация SuDoc (U.S. GPO)', 0, 'generic'),
                            ('anscr',   'ANSCR (звукозаписи)', 0, 'generic'),
                            ('rubbk',   'Таблицы ББК для научных библиотек в 30-ти томах', 0, 'generic'),
                            ('rugasnti','Рубрикатор ГАСНТИ', 0, 'generic'),
                            ('rubbkd',  'Таблицы ББК для детских библиотек в 1 т.', 0, 'generic'),
                            ('rubbkm',  'Таблицы ББК для массовых библиотек в 1 т.', 0, 'generic'),
                            ('rubbko',  'Таблицы ББК для областных библиотек в 4-х томах', 0, 'generic'),
                            ('rubbknp', 'Переиздания таблиц ББК для научных библиотек в 30-ти томах', 0, 'generic'),
                            ('rubbkn',  'Таблицы ББК для научных библиотек в 5-ти томах', 0, 'generic'),
                            ('rubbkmv', 'Таблицы ББК для массовых военных библиотек', 0, 'generic'),
                            ('rubbkk',  'Таблицы ББК для краеведческих каталогов библиотек', 0, 'generic'),                            
                            ('z',       'Другие/типовые схемы классификации', 0, 'generic');

