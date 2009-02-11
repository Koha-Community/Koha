TRUNCATE userflags;

INSERT INTO `userflags` VALUES(0, 'superlibrarian',  'Доступ до усіх бібліотечних функцій',0);
INSERT INTO `userflags` VALUES(1, 'circulate',       'Обіг книжок',0);
INSERT INTO `userflags` VALUES(2, 'catalogue',       'Перегляд каталогу (інтерфейс бібліотекаря)',0);
INSERT INTO `userflags` VALUES(3, 'parameters',      'Встановлення системних налаштувань Koha',0);
INSERT INTO `userflags` VALUES(4, 'borrowers',       'Внесення та зміна відвідувачів',0);
INSERT INTO `userflags` VALUES(5, 'permissions',     'Встановлення привілеїв користувача',0);
INSERT INTO `userflags` VALUES(6, 'reserveforothers','Резервування книжок для відвідувачів',0);
INSERT INTO `userflags` VALUES(7, 'borrow',          'Випозичання книжок',1);
INSERT INTO `userflags` VALUES(9, 'editcatalogue',   'Редагування каталогу (зміна бібліографічних/локальних даних)',0);
INSERT INTO `userflags` VALUES(10,'updatecharges',   'Оновлення сплат користувачів',0);
INSERT INTO `userflags` VALUES(11,'acquisition',     'Управління надходженнями і/чи пропозиціями',0);
INSERT INTO `userflags` VALUES(12,'management',      'Встановлення параметрів керування бібліотекою',0);
INSERT INTO `userflags` VALUES(13,'tools',           'Використання інструментів (експорт, імпорт, штрих-коди)',0);
INSERT INTO `userflags` VALUES(14,'editauthorities', 'Дозвіл на редагування авторитетних джерел',0);
INSERT INTO `userflags` VALUES(15,'serials',         'Дозвіл на керування підпискою періодичних видань',0);
INSERT INTO `userflags` VALUES(16,'reports',         'Дозвіл на доступ до модуля звітів',0);
INSERT INTO `userflags` VALUES(17,'staffaccess',     'Зміна імені(логіна)/привілеїв для працівників бібліотеки',0);
