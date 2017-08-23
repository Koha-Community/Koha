-- TRUNCATE opac_news;

--  idnew           -- unique identifier for the news article
--  branchcode      -- branch code users to create branch specific news, NULL is every branch.
--  title           -- title of the news article
--  new             -- the body of your news article
--  lang            -- location for the article (koha is the staff client, slip is the circulation receipt and language codes are for the opac)
--  timestamp       -- pulibcation date and time
--  expirationdate  -- date the article is set to expire or no longer be visible
--  number          -- the order in which this article appears in that specific location
--  borrowernumber  -- The user who created the news article

-- Бібліотечний інтерфейс
INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Ласкаво просимо до Коха','Ласкаво просимо до Коха. Коха є повнофункціональною АБІС з відкритими джерельними текстами. Розроблена спочатку в Новій Зеландії компанією Katipo Communications Ltd і вперше випущена у січні 2000 року для бібліотечного консорціуму Хороунеа. Коха на даний час підтримується групою постачальників програмного забезпечення та фахівцями з бібліотечних технологій зі всієї земної кулі.',
'koha',NOW(),'2099-01-10',1);
-- DATE_SUB(NOW(), INTERVAL 1 DAY)

INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Що далі?','Тепер, коли Ви встановили Коха, що ж далі? Ось деякі пропозиції:\r\n<ul>\r\n<li><a href=\"http://koha-community.org/documentation/\">Читайте документацію про Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org\">Читайте/пишіть на Коха Wiki</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Читайте і беріть участь в обговореннях</a></li>\r\n<li><a href=\"http://bugs.koha-community.org\">Рапортуйте про недоліки Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org/wiki/Version_Control_Using_Git\"> Подавайте латки для Коха, використовуючи Git (система контролю версій)</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Чат користувачів та розробників Коха</a></li>\r\n</ul>',
'koha',NOW(),'2099-01-10',2);

-- Електронний каталог / укр
INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Ласкаво просимо до Коха','Ласкаво просимо до Коха. Коха є повнофункціональною АБІС з відкритими джерельними текстами. Розроблена спочатку в Новій Зеландії компанією Katipo Communications Ltd і вперше випущена у січні 2000 року для бібліотечного консорціуму Хороунеа. Коха на даний час підтримується групою постачальників програмного забезпечення та фахівцями з бібліотечних технологій зі всієї земної кулі.',
'uk-UA',NOW(),'2099-01-10',1);

INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Що далі?','Тепер, коли Ви встановили Коха, що ж далі? Ось деякі пропозиції:\r\n<ul>\r\n<li><a href=\"http://koha-community.org/documentation/\">Читайте документацію про Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org\">Читайте/пишіть на Коха Wiki</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Читайте і беріть участь в обговореннях</a></li>\r\n<li><a href=\"http://bugs.koha-community.org\">Рапортуйте про недоліки Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org/wiki/Version_Control_Using_Git\"> Подавайте латки для Коха, використовуючи Git (система контролю версій)</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Чат користувачів та розробників Коха</a></li>\r\n</ul>',
'uk-UA',NOW(),'2099-01-10',2);

-- Електронний каталог / рос
INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Добро пожаловать в Коха','Добро пожаловать в Коха. Коха является полнофункциональной АБИС с открытыми исходниками. Разработана первоначально в Новой Зеландии компанией Katipo Communications Ltd и впервые выпущена в январе 2000 года для библиотечного консорциума Хороунеа. Коха в настоящее время поддерживается группой поставщиков программного обеспечения и специалистами по библиотечным технологиям со всего земного шара.',
'ru-RU',NOW(),'2099-01-10',1);

INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Что дальше?','Теперь, когда Вы установили Коха, что же дальше? Вот некоторые предложения:\r\n<ul>\r\n<li><a href=\"http://koha-community.org/documentation/\">Читайте документацию про Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org\">Читайте/пишите на Коха Wiki</a></li>\r\n<li><a href=\"http://koha-community.org/support/\"> Читайте и принимайте участие в обсуждениях</a></li>\r\n<li><a href=\"http://bugs.koha-community.org\">Отчитывайтесь про недочеты Коха</a></li>\r\n<li><a href=\"http://wiki.koha-community.org/wiki/Version_Control_Using_Git\"> Подавайте патчи для Коха, используя Git (система контроля версий)</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Чат пользователей и разработчиков Коха</a></li>\r\n</ul>',
'ru-RU',NOW(),'2099-01-10',2);

-- Електронний каталог / англ
INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('Welcome to Koha','Welcome to Koha. Koha is a full-featured open-source ILS. Developed initially in New Zealand by Katipo Communications Ltd and first deployed in January of 2000 for Horowhenua Library Trust, Koha is currently maintained by a team of software providers and library technology staff from around the globe.',
'en',NOW(),'2099-01-10',1);

INSERT INTO opac_news (title, content, lang, timestamp, expirationdate, number) VALUES
('What\'s Next?','Now that you\'ve installed Koha, what\'s next? Here are some suggestions:\r\n<ul>\r\n<li><a href=\"http://koha-community.org/documentation/\">Read Koha Documentation</a></li>\r\n<li><a href=\"http://wiki.koha-community.org\">Read/Write to the Koha Wiki</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Read and Contribute to Discussions</a></li>\r\n<li><a href=\"http://bugs.koha-community.org\">Report Koha Bugs</a></li>\r\n<li><a href=\"http://wiki.koha-community.org/wiki/Version_Control_Using_Git\">Submit Patches to Koha using Git (Version Control System)</a></li>\r\n<li><a href=\"http://koha-community.org/support/\">Chat with Koha users and developers</a></li>\r\n</ul>\r\n',
'en',NOW(),'2099-01-10',2);

