TRUNCATE userflags;

INSERT INTO `userflags` VALUES(0, 'superlibrarian',  'Доступ ко всем библиотечным функциям',0);
INSERT INTO `userflags` VALUES(1, 'circulate',       'Оборот книг',0);
INSERT INTO `userflags` VALUES(2, 'catalogue',       'Просмотр каталога (интерфейс библиотекаря)',0);
INSERT INTO `userflags` VALUES(3, 'parameters',      'Установка системных настроек Koha',0);
INSERT INTO `userflags` VALUES(4, 'borrowers',       'Внесение и изменение посетителей',0);
INSERT INTO `userflags` VALUES(5, 'permissions',     'Установка привилегий пользователя',0);
INSERT INTO `userflags` VALUES(6, 'reserveforothers','Резервирование книжек для посетителей',0);
INSERT INTO `userflags` VALUES(7, 'borrow',          'Заем книг',1);
INSERT INTO `userflags` VALUES(9, 'editcatalogue',   'Изменение каталога (изменение библиографических/локальных данных)',0);
INSERT INTO `userflags` VALUES(10,'updatecharges',   'Обновление оплат пользователей',0);
INSERT INTO `userflags` VALUES(11,'acquisition',     'Управление поступлениями и/или предложениями',0);
INSERT INTO `userflags` VALUES(12,'management',      'Установка параметров управления библиотекой',0);
INSERT INTO `userflags` VALUES(13,'tools',           'Использование инструментов (экспорт, импорт, штрих-коды)',0);
INSERT INTO `userflags` VALUES(14,'editauthorities', 'Разрешение на изменение авторитетных источников',0);
INSERT INTO `userflags` VALUES(15,'serials',         'Разрешение на управление подпиской периодических изданий',0);
INSERT INTO `userflags` VALUES(16,'reports',         'Разрешение на доступ к модулю отчетов',0);
INSERT INTO `userflags` VALUES(17,'staffaccess',     'Смена имени(логина)/привилегий для работников библиотеки',0);
