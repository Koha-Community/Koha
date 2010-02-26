-- 
-- Default classification sources and filing rules
-- for Koha.
--
-- Джерела:
-- http://www.loc.gov/marc/sourcecode/classification/classificationsource.html
-- http://dublincore.org/usage/meetings/2001/05/marc-classification.htm
-- http://www.itsmarc.com/crsbeta/mergedProjects/relators/relators/codes_065_and_084_fields.htm

-- TRUNCATE class_sort_rules;
-- class sorting (filing) rules
/*
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey',   'Типові правила заповнення для ДКД', 'Dewey'),
                               ('lcc',     'Типові правила заповнення для КБК', 'LCC'),
                               ('generic', 'Правила заповнення для узагальненого бібліотечного шифру', 'Generic');
*/


INSERT INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES 
('dewey',                           'Типові правила заповнення для ДКД',             'Dewey')
ON DUPLICATE KEY UPDATE description='Типові правила заповнення для ДКД',sort_routine='Dewey';

INSERT INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES 
('lcc',                             'Типові правила заповнення для КБК',             'LCC')
ON DUPLICATE KEY UPDATE description='Типові правила заповнення для КБК',sort_routine='LCC';

INSERT INTO class_sort_rules (class_sort_rule, description, sort_routine) VALUES 
('generic',                         'Правила заповнення для узагальненого бібліотечного шифру',             'Generic')
ON DUPLICATE KEY UPDATE description='Правила заповнення для узагальненого бібліотечного шифру',sort_routine='Generic';


TRUNCATE class_sources;
-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                      ('ddc',     'Десяткова класифікація Дьюі та відносний показник (ДКД)',          1, 'dewey'  ),
                      ('lcc',     'Класифікація Бібліотеки Конгресу (КБК)',                           1, 'lcc'    ),
                      ('udc',     'Універсальна десяткова класифікація (УДК)',                        1, 'generic'),
                      ('rubbk',   'Таблиці ББК для наукових бібліотек у 30-ти томах',                 1, 'generic'),
                      ('rugasnti','Рубрики ГАСНТІ',                                                   1, 'generic'),
                      ('rubbkd',  'Таблиці ББК для дитячих бібліотек в 1 т.',                         1, 'generic'),
                      ('rubbks',  'Середні таблиці ББК',                                              1, 'generic'),
                      ('rubbkm',  'Таблиці ББК для масових бібліотек в 1 т.',                         1, 'generic'),
                      ('rubbko',  'Таблиці ББК для обласних бібліотек в 4-х томах',                   1, 'generic'),
                      ('rubbknp', 'Перевидання таблиць ББК для наукових бібліотек у 30-ти томах',     1, 'generic'),
                      ('rubbkn',  'Таблиці ББК для наукових бібліотек у 5-ти томах',                  1, 'generic'),
                      ('rubbkmv', 'Таблиці ББК для масових військових бібліотек',                     1, 'generic'),
                      ('rubbkk',  'Таблиці ББК для краєзнавчих каталогів бібліотек',                  1, 'generic'), 
                      ('rueskl',  'Єдина схема класифікації літератури для книго-видавництва в СРСР', 1, 'generic'),
                      ('sudocs',  'Класифікація  SuDoc (U.S. GPO)',                                0, 'generic'),
                      ('anscr',   'Символьно-числова система ANSCR для класифікації звукозаписів', 0, 'generic'),  
                      ('farl',    'Frick: класифікаційна схема Art Reference Library book',                                0, 'generic'),
                      ('fcps',    '«Class FC»: класифікація з історії Канади та «Class PS8000»: класифікація з канадської літератури',0,'generic'),
                           ('fiaf',    'Класифікаційна схема для літератури про фільми та телебачення',    0, 'generic'),
                           ('flarch',  'Florida State Archives arrangement and description procedures manual',   0, 'generic'),
                           ('gfdc',    'Глобальна система лісової класифікації (GFDC)',                                0, 'generic'),
                           ('gadocs',  'Офіційні видання штату Джорджія',                                0, 'generic'),
                           ('inspec',  'Класифікація INSPEC (Едісон, Нью-Джерсі: корпорація INSPEC)',   0, 'generic'),
                           ('ipc',     'Міжнародна патентна класифікація (http://www.wipo.int/classifications/ipc/en/)',    0, 'generic'),
                           ('kktb',    'Класифікація Національної парламентської бібліотеки (Токіо)',    0, 'generic'),
                           ('kssb',    'Класифікаційна система шведських бібліотек',                                0, 'generic'),
                           ('laclaw',  'Los Angeles County Law Library, class K-Law',                                0, 'generic'),
                           ('loovs',   'Класифікаційна система Løøvs (Саамі)',                                0, 'generic'),
                           ('accs',    'Annehurst: система класифікації навчальних планів',                                0, 'generic'),
                           ('acmccs',  'ACM: комп’ютерна класифікаційна система',                                0, 'generic'),
                           ('agricola','AGRICOLA: коди тематичних категорій',                                0, 'generic'),
                           ('agrissc', 'AGRIS: тематичні категорії',                                0, 'generic'),
                           ('bcl',     'Голландські основні класифікаційні коди',                                0, 'generic'),
                           ('bcmc',    'Британський каталог музичної класифікації',                                0, 'generic'),
                           ('bliss',   'Bliss bibliographic classification',                                0, 'generic'),
                           ('blsrissc','Британська бібліотека — тематична класифікація для довідково-інформаційного сервісу з науки',0,'generic'),
                           ('cacodoc', 'CODOC — класифікаційна схема канадських федеральних та провінційних урядових організацій',  0, 'generic'),
                           ('ccpgq',   'Cadre de classement des publication gouvernementales',                                0, 'generic'),
                           ('clc',     'Zhongguo tu shu guan fen lei fa',                                0, 'generic'),
                           ('clutscny','Класифікація бібліотеки об’єднананої богословської семінарії міста Нью-Йорк', 0, 'generic'),
                           ('cstud',   'Класифікаційна система бібліотеки Технічного університету Делфт (Нідерланди)', 0, 'generic'),
                           ('mmlcc',   'Manual of map library classification and cataloguing',                                0, 'generic'),
                           ('cutterec','Експансивна класифікація C.A. Cutter',                                0, 'generic'),
                           ('sab',     'Класифікаційна система шведських публічних бібліотек',                                0, 'generic'),
                           ('usgslcs', 'Бібліотечна класифікація Американської Геологорозвідки',                                0, 'generic'),
                           ('usnal',   'Національна Сільськогосподарська Бібліотека',                                0, 'generic'),
                           ('usnlm',   'Класифікація Національної Бібліотеки Медицини',                                0, 'generic'),
                           ('vsiso',   'Vlaamse SISO [Schema voor de Indeling van de Systematische Catalogus in Open',     0, 'generic'),
                           ('ykl',     'Система класифікації фінських публічних бібліотек',                                0, 'generic'),
                           ('moys',    'Moys classification and thesaurus for legal materials',                                0, 'generic'),
                           ('msc',     'Математична тематична класифікація',                                0, 'generic'),
                           ('naics',   'North American industry classification system',                                0, 'generic'),
                           ('nasasscg','NASA scope and subject category guide',                                0, 'generic'),
                           ('ncsclt',  'Нова схема класифікації для китайських бібліотек',                                0, 'generic'),
                           ('nhcp',    'NH classification for photography',                                0, 'generic'),
                           ('nicem',   'NICEM subject headings and classification system',                                0, 'generic'),
                           ('njb',     'Десяткова класифікація Nippon',                                0, 'generic'),
                           ('nlm',     'Класифікація національної бібліотеки медицини',                                0, 'generic'),
                           ('rswk',    'Regeln für den Schlagwortkatalog',                                0, 'generic'),
                           ('z',       'Інші/типові схеми класифікації',                                0, 'generic');

