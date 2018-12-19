-- Default classification sources and filing rules
-- for Koha.
--
-- Джерела:
-- http://www.loc.gov/marc/sourcecode/classification/classificationsource.html
-- http://dublincore.org/usage/meetings/2001/05/marc-classification.htm
-- http://www.itsmarc.com/crsbeta/mergedProjects/relators/relators/codes_065_and_084_fields.htm


-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey',   'Типові правила заповнення для ДКД', 'Dewey'),
                               ('lcc',     'Типові правила заповнення для КБК', 'LCC'),
                               ('generic', 'Правила заповнення для узагальненого бібліотечного шифру', 'Generic');

-- splitting rules
INSERT INTO `class_split_rules` (`class_split_rule`, `description`, `split_routine`) VALUES
                               ('dewey', 'Default splitting rules for DDC', 'Dewey'),
                               ('lcc', 'Default splitting rules for LCC', 'LCC'),
                               ('generic', 'Generic call number splitting rules', 'Generic');

-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`, `class_split_rule`) VALUES
 ('ddc',     'Десяткова класифікація Дьюі та відносний показник (ДКД)',          1, 'dewey', 'dewey'),
 ('lcc',     'Класифікація Бібліотеки Конгресу (КБК)',                           1, 'lcc', 'lcc'),
 ('udc',     'Універсальна десяткова класифікація (УДК)',                        1, 'generic', 'generic'),
 ('rubbk',   'Таблиці ББК для наукових бібліотек у 30-ти томах',                 1, 'generic', 'generic'),
 ('rugasnti','Рубрики ГАСНТІ',                                                   1, 'generic', 'generic'),
 ('rubbkd',  'Таблиці ББК для дитячих бібліотек в 1 т.',                         1, 'generic', 'generic'),
 ('rubbks',  'Середні таблиці ББК',                                              1, 'generic', 'generic'),
 ('rubbkm',  'Таблиці ББК для масових бібліотек в 1 т.',                         1, 'generic', 'generic'),
 ('rubbko',  'Таблиці ББК для обласних бібліотек в 4-х томах',                   1, 'generic', 'generic'),
 ('rubbknp', 'Перевидання таблиць ББК для наукових бібліотек у 30-ти томах',     1, 'generic', 'generic'),
 ('rubbkn',  'Таблиці ББК для наукових бібліотек у 5-ти томах',                  1, 'generic', 'generic'),
 ('rubbkmv', 'Таблиці ББК для масових військових бібліотек',                     1, 'generic', 'generic'),
 ('rubbkk',  'Таблиці ББК для краєзнавчих каталогів бібліотек',                  1, 'generic', 'generic'),
 ('rutbkm',  'Таблиці бібліотечної класифікації для масових бібліотек/Під ред. З.М. Амбарцумяна/Пер. з 3-го рос. вид. з доп. для мас. б-к УРСР. – Х., 1975. – 239 с.',                                                        1, 'generic', 'generic'),
 ('rutbko',  'Таблиці бібліотечної класифікації для обласних бібліотек / Під ред. 3. Н. Амбарцумяна/Пер. з рос. вид. з доп. для обл. б-к УРСР. — 1961',                                                                       0, 'generic', 'generic'),
 ('rutbkd',  'Таблицы библиотечной классификации для детских библиотек. — М.: Гос. б-ка СССР им. В. И. Ленина, 1960. — 88 с; То же / Гос. б-ка СССР им. В. И. Ленина. — 3-е изд., испр. и доп. — М.: Книга — 1974. — 140 с.', 0, 'generic', 'generic'),
 ('rueskl',  'Єдина схема класифікації літератури для книго-видавництва в СРСР', 1, 'generic', 'generic'),
 ('sudocs',  'Класифікація  SuDoc (U.S. GPO)',                                   0, 'generic', 'generic'),
 ('anscr',   'Символьно-числова система ANSCR для класифікації звукозаписів',    0, 'generic', 'generic'),
 ('farl',    'Frick: класифікаційна схема Art Reference Library book',           0, 'generic', 'generic'),
 ('fcps',    '«Class FC»: класифікація з історії Канади та «Class PS8000»: класифікація з канадської літератури',  0, 'generic', 'generic'),
 ('fiaf',    'Класифікаційна схема для літератури про фільми та телебачення',    0, 'generic', 'generic'),
 ('flarch',  'Florida State Archives arrangement and description procedures manual', 0, 'generic', 'generic'),
 ('gfdc',    'Глобальна система лісової класифікації (GFDC)',                    0, 'generic', 'generic'),
 ('gadocs',  'Офіційні видання штату Джорджія',                                  0, 'generic', 'generic'),
 ('inspec',  'Класифікація INSPEC (Едісон, Нью-Джерсі: корпорація INSPEC)',      0, 'generic', 'generic'),
 ('ipc',     'Міжнародна патентна класифікація (http://www.wipo.int/classifications/ipc/en/)', 0, 'generic', 'generic'),
 ('kktb',    'Класифікація Національної парламентської бібліотеки (Токіо)',      0, 'generic', 'generic'),
 ('kssb',    'Класифікаційна система шведських бібліотек',                       0, 'generic', 'generic'),
 ('laclaw',  'Los Angeles County Law Library, class K-Law',                      0, 'generic', 'generic'),
 ('loovs',   'Класифікаційна система Løøvs (Саамі)',                             0, 'generic', 'generic'),
 ('accs',    'Annehurst: система класифікації навчальних планів',                0, 'generic', 'generic'),
 ('acmccs',  'ACM: комп’ютерна класифікаційна система',                          0, 'generic', 'generic'),
 ('agricola','AGRICOLA: коди тематичних категорій',                              0, 'generic', 'generic'),
 ('agrissc', 'AGRIS: тематичні категорії',                                       0, 'generic', 'generic'),
 ('bcl',     'Голландські основні класифікаційні коди',                          0, 'generic', 'generic'),
 ('bcmc',    'Британський каталог музичної класифікації',                        0, 'generic', 'generic'),
 ('bliss',   'Бібліографічна класифікація Блісса',                               0, 'generic', 'generic'),
 ('blsrissc','Британська бібліотека — тематична класифікація для довідково-інформаційного сервісу з науки', 0, 'generic', 'generic'),
 ('cacodoc', 'CODOC — класифікаційна схема канадських федеральних та провінційних урядових організацій', 0, 'generic', 'generic'),
 ('ccpgq',   'Cadre de classement des publication gouvernementales',             0, 'generic', 'generic'),
 ('clc',     'Китайська система бібліотечної класифікації',                      0, 'generic', 'generic'),
 ('clutscny','Класифікація бібліотеки об’єднананої богословської семінарії міста Нью-Йорк', 0, 'generic', 'generic'),
 ('cstud',   'Класифікаційна система бібліотеки Технічного університету Делфт (Нідерланди)', 0, 'generic', 'generic'),
 ('mmlcc',   'Manual of map library classification and cataloguing',             0, 'generic', 'generic'),
 ('cutterec','Експансивна класифікація C.A. Cutter',                             0, 'generic', 'generic'),
 ('sab',     'Класифікаційна система шведських публічних бібліотек',             0, 'generic', 'generic'),
 ('usgslcs', 'Бібліотечна класифікація Американської Геологорозвідки',           0, 'generic', 'generic'),
 ('usnal',   'Національна Сільськогосподарська Бібліотека',                      0, 'generic', 'generic'),
 ('usnlm',   'Класифікація Національної Бібліотеки Медицини',                    0, 'generic', 'generic'),
 ('vsiso',   'Vlaamse SISO [Schema voor de Indeling van de Systematische Catalogus in Open', 0, 'generic', 'generic'),
 ('ykl',     'Система класифікації фінських публічних бібліотек',                0, 'generic', 'generic'),
 ('moys',    'Moys classification and thesaurus for legal materials',            0, 'generic', 'generic'),
 ('msc',     'Математична тематична класифікація',                               0, 'generic', 'generic'),
 ('naics',   'North American industry classification system',                    0, 'generic', 'generic'),
 ('nasasscg','NASA scope and subject category guide',                            0, 'generic', 'generic'),
 ('ncsclt',  'Нова схема класифікації для китайських бібліотек',                 0, 'generic', 'generic'),
 ('nhcp',    'NH classification for photography',                                0, 'generic', 'generic'),
 ('nicem',   'NICEM subject headings and classification system',                 0, 'generic', 'generic'),
 ('njb',     'Японська десяткова класифікація',                                  0, 'generic', 'generic'),
 ('nlm',     'Класифікація національної бібліотеки медицини',                    0, 'generic', 'generic'),
 ('rswk',    'Regeln für den Schlagwortkatalog',                                 0, 'generic', 'generic'),
 ('z',       'Інші/типові схеми класифікації',                                   0, 'generic', 'generic');

