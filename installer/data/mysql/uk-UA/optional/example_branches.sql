TRUNCATE branches;
TRUNCATE branchcategories;
TRUNCATE branchrelations;

INSERT INTO `branches` (`branchcode`, `branchname`, `branchaddress1`, `branchaddress2`, `branchaddress3`, `branchphone`, `branchfax`, `branchemail`, `issuing`, `branchip`, `branchprinter`) VALUES
('AB',   'Абонемент', 
             'Україна', 'м. Тернопіль', 'кабінет 53 (2-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('ABH',  'Абонемент художньої літератури', 
             'Україна', 'м. Тернопіль', 'кабінет 53 (2-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('CHZ',  'Читальний зал', 
             'Україна', 'м. Тернопіль', 'кабінет 58 (3-ій поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('CHZP', 'Читальний зал періодики, каталог', 
             'Україна', 'м. Тернопіль', 'кабінет 2 (1-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('ECHZ', 'Електронний читальний зал', 
             'Україна', 'м. Тернопіль', 'кабінет 54 (2-ий поверх)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('LNSL', 'Львівська національна наукова бібліотека ім. В. Стефаника НАНУ', 
             'Україна', 'м. Львів', 'вул. Стефаника 2', '8 (032) 272-45-36', '', 'library@library.lviv.ua', NULL, '', NULL),
('STL',  'Науково-технічна бібліотека Тернопільського національного технічного університету ім. Ів. Пулюя', 
             'Україна', 'м. Тернопіль', 'вул. Руська 56, кабінет 5 (другий корпус)', '8 (0352) 52-53-45', '', 'lib@tu.edu.te.ua', NULL, '', NULL),
('NPLU', 'Національна парламентська бібліотека України', 
             'Україна', 'м. Київ', 'вул. Грушевського, 1', '38 (044) 278-85-12', '38 (044) 278-85-12', 'office@nplu.org', NULL, '192.168.1.*', NULL);

INSERT INTO `branchcategories` (`categorycode`, `categoryname`, `codedescription`, `categorytype`) VALUES
('HOME',   'Домівка',                    'Може встановлюватися як домашня бібліотека',   'properties'),
('ISSUE',  'Книговидача',                'Може видавати книги',                          'properties'),
('NATIOS', 'Національна бібліотека',     'Пошукова область національних бібліотек',      'searchdomain'),
('PUBLS',  'Публічні бібліотеки',        'Пошукова область публічних бібліотек',         'searchdomain'),
('UNIVS',  'Університетські бібліотеки', 'Пошукова область університетських бібліотек',  'searchdomain');

INSERT INTO `branchrelations` (`branchcode`, `categorycode`) VALUES
('AB',   'ISSUE'),
('ABH',  'ISSUE'),
('LNSL', 'HOME'),
('LNSL', 'NATIOS'),
('NPLU', 'HOME'),
('NPLU', 'NATIOS'),
('STL',  'HOME'),
('STL',  'UNIVS');

