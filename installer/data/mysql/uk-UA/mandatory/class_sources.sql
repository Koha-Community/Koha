-- 
-- Default classification sources and filing rules
-- for Koha.
--

TRUNCATE class_sort_rules;
-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey',   'Типові правила заповнення для ДКД', 'Dewey'),
                               ('lcc',     'Типові правила заповнення для КБК', 'LCC'),
                               ('generic', 'Правила заповнення для узагальненого бібліотечного шифру', 'Generic');


TRUNCATE class_sources;
-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                            ('ddc',     'Десяткова класифікація Дьюі (ДКД)', 1, 'dewey'),
                            ('lcc',     'Класифікація Бібліотеки Конгресу (КБК)', 1, 'lcc'),
                            ('udc',     'Універсальна десяткова класифікація', 0, 'generic'),
                            ('sudocs',  'Класифікація  SuDoc (U.S. GPO)', 0, 'generic'),
                            ('anscr',   'ANSCR (звукозаписи)', 0, 'generic'),
                            ('rubbk',   'Таблиці ББК для наукових бібліотек у 30-ти томах', 0, 'generic'),
                            ('rugasnti','Рубрикатор ГАСНТІ', 0, 'generic'),
                            ('rubbkd',  'Таблиці ББК для дитячих бібліотек в 1 т.', 0, 'generic'),
                            ('rubbkm',  'Таблиці ББК для масових бібліотек в 1 т.', 0, 'generic'),
                            ('rubbko',  'Таблиці ББК для обласних бібліотек в 4-х томах', 0, 'generic'),
                            ('rubbknp', 'Перевидання таблиць ББК для наукових бібліотек у 30-ти томах', 0, 'generic'),
                            ('rubbkn',  'Таблиці ББК для наукових бібліотек у 5-ти томах', 0, 'generic'),
                            ('rubbkmv', 'Таблиці ББК для масових військових бібліотек', 0, 'generic'),
                            ('rubbkk',  'Таблиці ББК для краєзнавчих каталогів бібліотек', 0, 'generic'),                            
                            ('z',       'Інші/типові схеми класифікації', 0, 'generic');

