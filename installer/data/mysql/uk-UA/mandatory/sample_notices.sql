-- Sample Notices.

INSERT INTO `letter` (module, code, name, title, content, message_transport_type) VALUES

('circulation','ODUE','повідомлення про прострочення', 'Одиниця прострочена',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Згідно нашим поточним записам, у Вас є прострочені примірники. Наша бібліотека не стягує штрафи за запізнення, але, будь ласка, поверніть и продовжіть їх як можна швидше.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>>\n<<branches.branchaddress3>>\n Телефон: <<branches.branchphone>>\n Факс: <<branches.branchfax>>\n Електронічна пошта: <<branches.branchemail>>\n\nЯкщо Ви зареєстрували пароль у бібліотеці і маєте доступні продовження, то можете продовжити онлайн. Якщо примірник має прострочення більше 30-ти днів, Ви не зможете використовувати Ваш читацький квиток доки не повернете примірник. Наступн(ий/і) примірник(и) на даний час є простроченим(и):\n\n<item>"<<biblio.title>>" / <<biblio.author>>, <<items.itemcallnumber>>, Штрихкод: <<items.barcode>> Пеня: <<items.fine>></item>\n\n Спасибі Вам за невідкладну увагу до цього питання.\n\nБібліотекар\n<<branches.branchname>>\n',
 'email'),

('claimacquisition','ACQCLAIM','претензія щодо надходження', 'Примірник не отримано',
 '<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Номер замовлення <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> замовлено) (<<aqorders.listprice>> кожний) отримано не було.</order>',
 'email'),

('orderacquisition','ACQORDER','замовлення надходжень','Замовлення',
 '<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n Будь ласка, замовляйте для бібліотеки:\r\n\r\n<order>Номер замовлення <<aqorders.ordernumber>> (<<biblio.title>>) (кількість: <<aqorders.quantity>>) ($<<aqorders.listprice>> кожний).</order>\r\n\r\n Спасибі,\n\n<<branches.branchname>>',
 'email'),

('serial','SERIAL_ALERT','список скерування', 'Серіальне видання вже доступне',
 '<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nНаступний випуск вже доступний:\r\n\r\n<<biblio.title>> / <<biblio.author>> (<<items.barcode>>)\r\n\r\n Прохання забрати його в будь-який зручний для Вас час.',
 'email'),

('members','ACCTDETAILS','шаблон даних облікового запису (типово)', 'Дані Вашого нового облікового запису в Koha',
 'Привіт <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\n Дані Вашого нового облікового запису в Koha такі:\r\n\r\n Користувач:  <<borrowers.userid>>\r\n Пароль: <<borrowers.password>>\r\n\r\n Якщо у Вас виникли проблеми чи питання з приводу Вашого облікового запису, будь ласка, звяжіться з адміністратором Koha\r\n\r\n Спасибі,\r\n адміністратор Koha\r\n kohaadmin@yoursite.org',
 'email'),

('circulation','DUE','нагадування про повернення примірника', 'Нагадування про повернення примірника',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\n Наступний примірник тепер потрібно повернути:\r\n\r\n„<<biblio.title>>“, <<biblio.author>> (<<items.barcode>>)',
 'email'),

('circulation','DUEDGST','нагадування про повернення примірників (збірка)', 'Нагадування про повернення примірників',
 'Вам необхідно повернути <<count>> примірників(а/ів)',
 'email'),

('circulation','PREDUE','завчасне повідомлення про поверенення примірника', 'Завчасне повідомлення про поверенення примірника',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\n Наступний примірник незабаром потрібно буде повернути:\r\n\r\n„<<biblio.title>>“, <<biblio.author>> (<<items.barcode>>)',
 'email'),

('circulation','PREDUEDGST','завчасне повідомлення про поверенення примірників (збірка)', 'Завчасне повідомлення про поверенення примірників',
 'Незабаром Вам потрібно повернути <<count>> примірник(а/ів)',
 'email'),

('circulation','RENEWAL','продовження примірників', 'Продовження примірників',
 'Наступні примірники продовжено:\r\n----\r\n„<<biblio.title>>“\r\n----\r\n Дякуємо Вам за відвідування! <<branches.branchname>>.',
 'email'),

('reserves', 'HOLD', 'резервування, що очікує на отримання', 'Резервування, що очікує на отримання у бібліотеці – „<<branches.branchname>>“',
 'Шановн(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\n у Вас є резервування, що очікує на отримання до <<reserves.waitingdate>>:\r\n\r\n Заголовок: „<<biblio.title>>“\r\n Автор: <<biblio.author>>\r\n Номер примірника: <<items.copynumber>>\r\n Розташування: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>',
 'email'),

('reserves', 'HOLD', 'резервування, що очікує на отримання', 'Резервування, що очікує на отримання у бібліотеці (повідомлення для друку)',
'<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\n Звернення про зміну стану обслуговування\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\n У Вас є зарезервований примірник, що вже доступний щоб забрати до <<reserves.waitingdate>>:\r\n\r\n Заголовок: „<<biblio.title>>“\r\n Автор: <<biblio.author>>\r\n Номер примірника: <<items.copynumber>>\r\n',
 'print'),
('reserves', 'CANCEL_HOLD_ON_LOST', 'Hold has been cancelled', "Hold has been cancelled", "Dear [% borrower.firstname %] [% borrower.surname %],\n\nWe regret to inform you, that the following item can not be provided due to it being missing. Your hold was cancelled.\n\nTitle: [% biblio.title %]\nAuthor: [% biblio.author %]\nCopy: [% item.copynumber %]\nLocation: [% branch.branchname %]", 'email'),

('circulation','CHECKIN','повернення примірників (збірка)', 'Повернення',
 'Наступні примірники були повернуті:\r\n----\r\n„[% biblio.title %]“\r\n----\r\n Спасибі.',
 'email'),

('circulation','CHECKOUT','видача примірників (збірка)', 'Видача',
 'Наступні примірники були видані:\r\n----\r\n„[% biblio.title %]“\r\n----\r\n Спасибі, що відвідали бібліотеку – „[% branches.branchname %]“.',
 'email'),

('reserves', 'HOLDPLACED', 'на примірник встановлено резервування', 'На примірник встановлено резервування',
 'Встановлено резервування на наступний примірник: „<<biblio.title>>“ (<<biblio.biblionumber>>) відвідувачем: <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).',
 'email'),

('suggestions','ACCEPTED','пропозиція прийнята', 'Пропозицію на придбання прийнято',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Ви запропонували бібліотеці отримати надходження зі заголовком „<<suggestions.title>>“, автор „<<suggestions.author>>“.\n\n Бібліотека розглянула сьогодні Вашу пропозицію. Примірник буде замовлений як можна швидше. Ви будете повідомлені поштою, коли замовлення завершено, і знову, коли примірник надійде до бібліотеки. \n\n Якщо у Вас є які-небудь питання, будь ласка, напишіть нам за адресою <<branches.branchemail>>.\n\n Спасибі,\n\n<<branches.branchname>>',
 'email'),

('suggestions','AVAILABLE','пропозиція доступна', 'Пропозиція на придбання доступна',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Ви запропонували бібліотеці отримати надходження зі заголовком „<<suggestions.title>>“, автор „<<suggestions.author>>“.\n\n Ми раді повідомити Вам, що примірник, який Ви запитували, зараз є частиною фондів бібліотеки. \n\n Якщо у Вас є які-небудь питання, будь ласка, напишіть нам за адресою <<branches.branchemail>>.\n\n Спасибі,\n\n<<branches.branchname>>',
 'email'),

('suggestions','ORDERED','пропозицію замовлено', 'Запропонований примірник замовлено',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Ви запропонували бібліотеці отримати надходження зі заголовком „<<suggestions.title>>“, автор „<<suggestions.author>>“.\n\n Ми раді повідомити Вам, що примірник, який Ви запитували, тепер замовлений. Він повинен прибути найближчим часом, і деякий час буде опрацьоуватися для додавання у фонди бібліотеки. \n\n Ви будете повідомлені ще раз, коли книга стане доступна.\n\n Якщо у Вас є які-небудь питання, будь ласка, напишіть нам за адресою <<branches.branchemail>>\n\n Спасибі,\n\n<<branches.branchname>>',
 'email'),

('suggestions','REJECTED','пропозицію відхилено', 'Пропозицію на придбання відхилено',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Ви запропонували бібліотеці отримати надходження зі заголовком „<<suggestions.title>>“, автор „<<suggestions.author>>“.\n\n Бібліотека розглянула сьогодні Ваш запит, і вирішила на даний момент не приймати пропозицію.\n\n Причиною є: <<suggestions.reason>>\n\n Якщо у Вас є які-небудь питання, будь ласка, напишіть нам за адресою <<branches.branchemail>>.\n\n Спасибі,\n\n<<branches.branchname>>',
 'email'),

('suggestions','TO_PROCESS','Увідомлення фондотримача', 'Пропозиція готова то обробки',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n нова пропозиція гоотова до обробки: „<<suggestions.title>>“ / <<suggestions.author>>.\n\n Спасибі,\n\n<<branches.branchname>>',
 'email')
;


INSERT INTO `letter` (module, code, name, title, content, is_html, message_transport_type) VALUES
('members', 'DISCHARGE', 'підтвердження на розрахування',
'Розрахування для відвідувача — <<borrowers.firstname>> <<borrowers.surname>>', '
<<today>>
<h1>Підтвердження на розрахування</h1>
<p><<branches.branchname>> засвідчує, що наступний відвідувач:<br>
<<borrowers.firstname>> <<borrowers.surname>> (читацький квиток: <<borrowers.cardnumber>>)<br>
повернув усі примірники.</p>',
 1, 'email');


INSERT INTO `letter` (module, code, name, title, content, is_html) VALUES

('circulation','ISSUESLIP','листок про видачу','Листок про видачу',
 '<h3><<branches.branchname>></h3>
Видача відвідувачу: <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(№ <<borrowers.cardnumber>>) <br />
<<today>><br />
<h4>Видано</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Штрихкод: <<items.barcode>><br />
Дата очікування: <<issues.date_due>><br />
</p>
</checkedout>
<h4>Прострочення</h4>
<overdue>
<p>
<<biblio.title>> <br />
Штрихкод: <<items.barcode>><br />
Дата очікування: <<issues.date_due>><br />
</p>
</overdue>
<hr>
<h4 style="text-align: center; font-style:italic;">Новини</h4>
<news>
<div class="newsitem">
<h5 style="margin-bottom: 1px; margin-top: 1px"><b><<opac_news.title>></b></h5>
<p style="margin-bottom: 1px; margin-top: 1px"><<opac_news.content>></p>
<p class="newsfooter" style="font-size: 8pt; font-style:italic; margin-bottom: 1px; margin-top: 1px">Вивішено <<opac_news.timestamp>></p>
<hr />
</div>
</news>',
 1),

('circulation','ISSUEQSLIP','швидкий листок про видачу','Швидкий листок про видачу',
'<h3><<branches.branchname>></h3>
Видача відвідувачу: <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(№ <<borrowers.cardnumber>>) <br />
<<today>><br />
<h4>Видано сьогодні</h4>
<checkedout>
<p>
<<biblio.title>> <br />
Штрихкод: <<items.barcode>><br />
Дата очікування: <<issues.date_due>><br />
</p>
</checkedout>',
 1),

('circulation','HOLD_SLIP','листок про резервування','Листок про резервування',
'<h5> Дата: <<today>></h5>
<h3> Переміщення у підрозділ / Резервування у підрозділі: <<branches.branchname>></h3>
<h3><<borrowers.surname>>, <<borrowers.firstname>></h3>
<ul>
    <li><<borrowers.cardnumber>></li>
    <li><<borrowers.phone>></li>
    <li> <<borrowers.address>><br />
         <<borrowers.address2>><br />
         <<borrowers.city>>  <<borrowers.zipcode>>
    </li>
    <li><<borrowers.email>></li>
</ul>
<br />
<h3>ПРИМІРНИК ЗАРЕЗЕРВОВАНИЙ</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
   <li><<reserves.waitingdate>></li>
</ul>
<p>Примітка:
<pre><<reserves.reservenotes>></pre>
</p>',
 1),

('circulation','TRANSFERSLIP','листок про переміщення','Листок про переміщення',
'<h5>Дата: <<today>></h5>
<h3>Переміщення у підрозділ: <<branches.branchname>></h3>
<h3>ПРИМІРНИК</h3>
<h4><<biblio.title>></h4>
<h5><<biblio.author>></h5>
<ul>
   <li><<items.barcode>></li>
   <li><<items.itemcallnumber>></li>
</ul>',
 1);


INSERT INTO `letter` (`module`,`code`,`branchcode`,`name`,`is_html`,`title`,`content`) VALUES
('members',  'OPAC_REG_VERIFY',  '',  'електронний лист перевірки самостійної реєстрації через електронний каталог',  '1',
 'Підтвердіть Ваш обліковий запис',  'Привіт!
 Було створено обліковий запис у Вашій бібліотеці. Для завершення процесу реєстрації, будь ласка, підтвердіть свою адресу електронної пошти, натиснувши на це посилання:
 <<OPACBaseURL>>/cgi-bin/koha/opac-registration-verify.pl?token=<<borrower_modifications.verification_token>>
 Якщо Ви не ініціювали цей запит, можете спокійно ігнорувати це одноразове повідомлення. Запит стане недійсним найближчим часом.');


-- INSERT INTO `letter` (module, code, name, title, content) VALUES
-- ('circulation','RENEWAL','продовження примірників','Продовження',
-- 'Наступні примірники продовжено:\r\n----\r\n<<biblio.title>>\r\n----\r\nДякуємо Вам за відвідування! <<branches.branchname>>.');


INSERT INTO  letter (module, code, branchcode, name, is_html, title, content) VALUES
('members', 'SHARE_INVITE', '', 'запрошення для спільного використання списку', '0', 'Спільне використання списку „<<listname>>“',
 'Дорог(ий/а) відвідувач(ка),
 один з наших відвідувачів, <<borrowers.firstname>> <<borrowers.surname>>, запрошує Вас до спільного використання списку „<<listname>>“ у нашому бібліотечному каталозі.
 Для доступу до цього спільного списку, будь ласка, натисніть на наступне посилання або ж скопіюйте і вставте його в адресний рядок браузера.
 <<shareurl>>
 У разі, якщо Ви не є відвідувач(ем/кою) нашої бібліотеки або не хочете приймати це запрошення, будь ласка, не звертайте уваги на цей лист. Відзначимо також, що це запрошення стане недісним протягом двох тижнів.
 Дякуємо!
 Ваша бібліотека.');


INSERT INTO  letter (module, code, branchcode, name, is_html, title, content) VALUES
('members', 'SHARE_ACCEPT', '', 'сповіщення про згоду на спільне використання', '0', 'Спільне використання списку „<<listname>>“ прийнято',
 'Дорог(ий/а) відвідувач(ка),
 Ми хочемо повідомити Вам, що <<borrowers.firstname>> <<borrowers.surname>> прийняв Ваше запрошення щодо спільного використання Вашого списку „<<listname>>“ у нашому бібліотечному каталозі.
 Дякуємо!
 Ваша бібліотека.');


INSERT INTO letter(module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('acquisition', 'ACQ_NOTIF_ON_RECEIV', '', 'повідомлення про отримання', '0', 'Замовлення отримано',
 'Дорог(ий/а) <<borrowers.firstname>> <<borrowers.surname>>,\n\n Замовлення „<<aqorders.ordernumber>>“ (<<biblio.title>>) Отримано.\n\nВаша бібліотека.',
 'email'),

('members','MEMBERSHIP_EXPIRY','','закінчення терміну дії облікового запису', '0', 'Термін дії облікового запису завершується',
 'Дорог(ий/а) <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\n Термін чинності Вашого бібліотечного квитка незабаром завершиться, а саме:\r\n\r\n<<borrowers.dateexpiry>>\r\n\r\nСпасибі,\r\n\r\nбібліотекар\r\n\r\n<<branches.branchname>>',
 'email');


INSERT INTO letter ( module, code, branchcode, name, is_html, title, content, message_transport_type ) VALUES
('circulation', 'OVERDUES_SLIP', '', 'квитанція про прострочення', '0', 'OVERDUES_SLIP',
 'Наступн(ий/і) примірник(и) на даний час вже прострочені:
 <item>"<<biblio.title>>" / <<biblio.author>>, <<items.itemcallnumber>>, Штрихкод: <<items.barcode>> Пеня: <<items.fine>></item>',
 'print' );


INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
('members','PASSWORD_RESET','','онлайн-скидання пароля',1,'Відновлення пароля Koha',
 '<html>\r\n<p>Це повідомлення було відправлено у відповідь на Ваш запит про відновлення пароля для облікового запису <strong><<user>></strong>.\r\n</p>\r\n<p>\r\n Тепер Ви можете створити новий пароль, використовуючи наступне посилання:\r\n<br/><a href=\"<<passwordreseturl>>\"><<passwordreseturl>></a>\r\n</p>\r\n<p>Це посилання буде чинним протягом 2-х днів з моменту приходу цього листа. Пізніш Вам необхідно буде повторити дію, якщо Ви не зміните свій пароль.</p>\r\n<p>Списибі.</p>\r\n</html>\r\n',
 'email');


INSERT INTO `letter` (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
 ('circulation', 'AR_CANCELED', '', 'запит статті - скасовано', 0, 'Запит статті скасовано',
 '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\n Ваш запит на статтю зі  „<<biblio.title>>“ (<<items.barcode>>) був скасований з наступної причини:\r\n\r\n<<article_requests.notes>>\r\n\r\n Запитувана стаття:\r\n Заголовок: <<article_requests.title>>\r\n Автор: <<article_requests.author>>\r\n Том: <<article_requests.volume>>\r\n Випуск: <<article_requests.issue>>\r\n Дата: <<article_requests.date>>\r\n Сторінки: <<article_requests.pages>>\r\n Розділи: <<article_requests.chapters>>\r\n Примітки: <<article_requests.patron_notes>>\r\n',
 'email'),

 ('circulation', 'AR_COMPLETED', '', 'запит статті - завершено', 0, 'Запит статті завершено',
 '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\n Ми виконали Ваш запит на статтю зі  „<<biblio.title>>“ (<<items.barcode>>).\r\n\r\n Запитувана стаття:\r\n Заголовок: <<article_requests.title>>\r\n Автор: <<article_requests.author>>\r\n Том: <<article_requests.volume>>\r\n Випуск: <<article_requests.issue>>\r\n Дата: <<article_requests.date>>\r\n Сторінки: <<article_requests.pages>>\r\n Розділи: <<article_requests.chapters>>\r\n Примітки: <<article_requests.patron_notes>>\r\n\r\n Ви можете забрати статтю у підрозділі „<<branches.branchname>>“.\r\n\r\n Спасибі!',
 'email'),

 ('circulation', 'AR_PENDING', '', 'запит статті - відкрито', 0, 'Надійшов запит статті',
 '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\n Ми отритмали Ваш запит на статтю зі „<<biblio.title>>“ (<<items.barcode>>).\r\n\r\n Запитувана стаття:\r\n Заголовок: <<article_requests.title>>\r\n Автор: <<article_requests.author>>\r\n Том: <<article_requests.volume>>\r\n Випуск: <<article_requests.issue>>\r\n Дата: <<article_requests.date>>\r\n Сторінки: <<article_requests.pages>>\r\n Розділи: <<article_requests.chapters>>\r\n Примітки: <<article_requests.patron_notes>>\r\n\r\n\r\n Спасибі!',
 'email'),

 ('circulation', 'AR_SLIP', '', 'запит статті - роздрук квитанції', 0, 'Тест', 'Запитувана стаття:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\n Заголовок: <<biblio.title>>\r\n Штрих-код: <<items.barcode>>\r\n\r\n Запитувана стаття:\r\n Заголовок: <<article_requests.title>>\r\n Автор: <<article_requests.author>>\r\n Том: <<article_requests.volume>>\r\n Випуск: <<article_requests.issue>>\r\n Дата: <<article_requests.date>>\r\n Сторінки: <<article_requests.pages>>\r\n Розділи: <<article_requests.chapters>>\r\n Примітки: <<article_requests.patron_notes>>\r\n',
 'print'),

 ('circulation', 'AR_PROCESSING', '', 'запит статті - обробка', 0, 'Обробка запиту статті', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\n Ми зараз обробляємо Ваш запит на статтю зі „<<biblio.title>>“ (<<items.barcode>>).\r\n\r\n Запитувана стаття:\r\n Заголовок: <<article_requests.title>>\r\n Автор: <<article_requests.author>>\r\n Том: <<article_requests.volume>>\r\n Випуск: <<article_requests.issue>>\r\n Дата: <<article_requests.date>>\r\n Сторінки: <<article_requests.pages>>\r\n Розділи: <<article_requests.chapters>>\r\n Примітки: <<article_requests.patron_notes>>\r\n\r\n Спасибі!',
 'email'),

('circulation', 'CHECKOUT_NOTE', '', 'Checkout note on item set by patron', '0', 'Checkout note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`)
    VALUES
        ('circulation', 'ACCOUNT_PAYMENT', '', 'Account payment', 0, 'Account payment', '[%- USE Price -%]\r\nA payment of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis payment affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
            ('circulation', 'ACCOUNT_WRITEOFF', '', 'Account writeoff', 0, 'Account writeoff', '[%- USE Price -%]\r\nAn account writeoff of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis writeoff affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');
INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'SR_SLIP', '', 'Stock Rotation Slip', 0, 'Stockrotation Report', 'Stockrotation report for [% branch.name %]:\r\n\r\n[% IF branch.items.size %][% branch.items.size %] items to be processed for this branch.\r\n[% ELSE %]No items to be processed for this branch\r\n[% END %][% FOREACH item IN branch.items %][% IF item.reason ne \'in-demand\' %]Title: [% item.title %]\r\nAuthor: [% item.author %]\r\nCallnumber: [% item.callnumber %]\r\nLocation: [% item.location %]\r\nBarcode: [% item.barcode %]\r\nOn loan?: [% item.onloan %]\r\nStatus: [% item.reason %]\r\nCurrent Library: [% item.branch.branchname %] [% item.branch.branchcode %]\r\n\r\n[% END %][% END %]', 'email');
