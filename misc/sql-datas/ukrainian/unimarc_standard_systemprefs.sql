TRUNCATE systempreferences;
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('dateformat', 'metric', 'Формат дати (ММ/ДД/РРРР у США, ДД/ММ/РРРР у метричній системі,  РРРР/ММ/ДД за ISO)', 'metric|us|iso', 'Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('insecure', 'no', 'Якщо ТАК, то авторизація взагалі непотрібна. Будь-уважні, якщо хочете встановити цю змінну у ТАК!', NULL, 'YesNo');

INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('acquisitions', 'normal', 'Звичайні (normal) придбання на основі бюджету або ж прості (simple) надходження бібліографічних даних', 'simple|normal', 'Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('gist', '0', 'Ставка ПДВ. НЕ в процентах (%), а в числовій формі (0,055 означатиме 5,5%)', NULL, 'free');

INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('AuthDisplayHierarchy', '0', 'Показувати ієрархії у деталізації для авторитетних джерел', NULL, NULL);
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('authoritysep', '--', 'Роздільник для авторитетних джерел/тезаурусу. Зазвичай --', '10', 'free');

INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('IntranetNav','<a class="menu" href="http://www.library.lviv.ua">Домівка бібліотеки</a>','Використовуйте HTML-закладки для додавання посилань до лівостороньої навігаційної смужки у внутрішньобібліотечному інтерфейсі','70|10','Textarea');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('TemplateEncoding', 'utf-8', 'Зазначення кодування шаблонів', 'iso-8859-1|utf-8', 'Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('intranetcolorstylesheet','colors.npl.css','Введіть назву таблиці стилів кольорів для внутрішньобібліотечного інтерфейсу','|colors.npl.css|colors.css','Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('intranetstylesheet','','Назва альтернативної таблиці стилів для компонування сторінок внутрішньобібліотечного інтерфейсу','|intranet.liblime.css|intranet.css','Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('template', 'default', 'Вибір варіанту шаблону для внутрішньобібліотечного інтерфейсу', NULL, 'Themes');

INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('ISBD', '#910|<code><b>|{910e/}{910f }|</b></code><br/>#900|<code><b>|{900a }|</b></code><br/>#700|<i>|{700a }{ 700g, }{701a }{ 701g, }{702a }{ 702g, }|; </i>#200||<b>{200a}</b>{ [200b] }{. 200c}{: 200e}{. 200h}{. 200i}{ / 200f}{; 200g}|#230||{; 230a}|#205||{; 205a}{, 205b}{ = 205d}{ / 205f}{; 205g}|#210|<br/>|{; 210a}{ (210b) }{: 210c}{, 210d}|. - #210|(|{ 210e}{(210f)}{: 210g}{, 210h}|)#215|<quantitative>|{; 215a}{: 215c}{; 215d}{ + 215e}|</quantitative>#225|<br/><description>(|{ 225a}{ = 225d}{: 225e}{. 225h}{. 225i}{ / 225f}{, I225x}{; 225v}|)</description>#010|<br/>&nbsp;&nbsp;&nbsp;<ISBN>ISBN |{010a}{: 010d}|</ISBN>#606|<br/>&nbsp;&nbsp;&nbsp;<thematic>|{- 606a }|</thematic>#995|<br><block995>|{\\n995b}{ - 995j}{/995k}|</block995>#686|<div align="right">BBK |{686a   }|</div>#910|<div align="right"><code>&nbsp;&nbsp;&nbsp;|{910a }{ /910d/ }|</code></div>', 'Структура міжнародного стандарту бібліографічного опису ISBD', NULL, 'Textarea');
INSERT into systempreferences(variable, value, explanation, options, type) values ('IntranetBiblioDefaultView','marc','Визначення варіанту перегляду за умовчанням бібліотечного запису у внутрішньобібліотечному інтерфейс. Може бути normal, marc чи isbd','normal|marc|isbd','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('LabelMARCView','standard','Зазначається, як відображати МАРК-запис','standard|economical','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('MARCOrgCode','0','Ваш МАРК-код організації, - див. http://www.loc.gov/marc/organizations/orgshome.htm',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('advancedMARCeditor','0','Якщо встановлено, то МАРК-редактор не показуватиме описи ознак/підполів',NULL,'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('autoBarcode', '0', 'Чи автоматично призначати штрих-коди', NULL, 'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('hide_marc','0','Приховувати специфічні марк-дані типу кодів підполів та індикаторів для  бібліотеки',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('itemcallnumber','676a','МАРК-поле/підполе, що використовується для обрахунку шифру для замовлення бібліотечної одиниці (у UNIMARC)',NULL,'free');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('marc', 'ON', 'Задіяння підтримки МАРК-стандарту (ON чи OFF)', NULL, 'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('marcflavour', 'UNIMARC', 'Ваш МАРК-стандарт (MARC21 чи UNIMARC/Укрмарк)', 'MARC21|UNIMARC', 'Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('serialsadditems','0','При встановленні, нова одиниця автоматично додаватиметься при отриманні випуску',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('sortbynonfiling','no','Сортувати результати пошуку за необліковуваними МАРК-символами',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('z3950AuthorAuthFields','701,702,700','Містить МАРК-ознаки бібліотечного запису з авторитетних джерел персони для заповнення biblio.author при імпорті бібліотечних записів',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('z3950NormalizeAuthor','0','Якщо встановлено, то авторитетні значення персони замінюватимуть авторів у biblio.author',NULL,'YesNo');

INSERT into systempreferences(variable, value, explanation, options, type) values ('ReturnBeforeExpiry','0','Якщо встановлено, то дата повернення при видачі не може бути після закінчення дії квитка позичальника',NULL,'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('maxoutstanding', '5', 'Максимальна сума заборгованих витрат до заборони резервувань', NULL, 'Integer');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('maxreserves', '5', 'Максимальна кількість резервувань, що позичальник може зробити', NULL, 'Integer');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('noissuescharge', '5', 'Максимальна сума заборгованих витрат до заборони видачі', NULL, 'Integer');
INSERT into systempreferences(variable, value, explanation, options, type) values ('patronimages','jpg','Включення/виключення відображення зображень відвідувачів в Інтернеті та зазначення розширення файлу для зображень',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('printcirculationslips','0','Якщо рівне 1, то видруковуватимуться обігові картки. Якщо 0, то ні',NULL,'free');

INSERT into systempreferences(variable, value, explanation, options, type) values ('NotifyBorrowerDeparture','10','За скільки днів до завершення дії квитка подавати повідомлення при видачах',NULL,'Integer');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('autoMemberNum', '0', 'Чи автоматично призначати номер квитка відвідувача', NULL, 'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('checkdigit', 'none', 'Перевірка достовірності картки відвідувача: немає перевірки або "Katipo"-перевірка', 'none|katipo', 'Choice');

INSERT into systempreferences(variable, value, explanation, options, type) values ('AmazonAssocTag','','гляньте на http://associates.amazon.com/gp/flex/associates/apply-login.html',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('AmazonContent','0','Задіяти дані з Amazon - Ви ПОВИННІ встановити AmazonDevKey та AmazonAssocTag якщо маєте їх',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('AmazonDevKey','','гляньте на http://aws-portal.amazon.com/gp/aws/developer/registration/index.html',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('AnonSuggestions','0','Вкажіть номер_анонімного_позичальника для дозволу анонімних пропозицій',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('BiblioDefaultView','normal','Вигляд по умовчанню для бібліотечного запису. Може приймати значення normal, marc чи isbd','normal|marc|isbd','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('Disable_Dictionary','0','Блокує кнопки словника, якщо встановлено у Так',NULL,'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('LibraryName', 'Електронічний каталог бібліотеки', 'Ім\'я бібліотеки або повідомлення, яке буде показане на головній сторінці електронічнго каталогу', NULL, '');
INSERT into systempreferences(variable, value, explanation, options, type) values ('OpacNav','<a class="menu" href="http://www.library.lviv.ua">Домівка бібліотеки</a>','Використовуйте HTML-закладки для додавання посилань до лівостороньої навігаційної смужки у електронічному каталозі','70|10','Textarea');
INSERT into systempreferences(variable, value, explanation, options, type) values ('OpacPasswordChange','1','Дозволити/заблокувати зміну паролю у ЕК (заблокуйте, якщо використовуйте LDAP-авторизацію)',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('SubscriptionHistory','simplified','Рівень інформативності для хронології періодичних видань у електронічному каталозі','simplified|full','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('hidelostitems','No','Показувати чи приховувати \"втрачені\" одиниці у ЕК.',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacbookbag','1','Включити чи заблокувати відображення бібліотечного замовлення (полички замовлень)',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opaccolorstylesheet','/opac-tmpl/npl/uk_UA/includes/opac-colors.npl.css','Введіть найменування таблиці стилів кольорів для електронічного каталогу','|/opac-tmpl/npl/uk_UA/includes/opac-colors.npl.css','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opaccredits','','Зазначте будь-які вдячності/заслуги у HTML для низу сторінки ЕК','70|10','Textarea');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacheader','','Користувацький HTML-заголовок для ЕК','30|10','Textarea');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('opaclanguages', 'uk_UA', 'Встановлення Вашої привілейованої мови. Мова зверху списку пробуватиметься спочатку.', NULL, 'Languages');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opaclanguagesdisplay','1','Включення/виключення можливості зміни мови у ЕК',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opaclargeimage','','URL-посилання зображення на основній сторінці, що буде замість Koha',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opaclayoutstylesheet','','URL-посилання таблиці стилів для компонування сторінок для електронічного каталогу',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacreadinghistory','1','Включення/виключення відображення історії читання відвідувача у ЕК',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacsmallimage','','URL-посилання зображення, що розміщується зверху/зліва замість логотипу Koha',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacstylesheet','','URL-посилання альтернативної таблиці стилів для електронічного каталогу','|/opac-tmpl/npl/uk_UA/includes/opac-layout.liblime.css','Choice');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('opacthemes', 'css', 'Встановлення переважного порядку для тем. Спочатку пробуватиметься вища тема.', NULL, 'Themes');
INSERT into systempreferences(variable, value, explanation, options, type) values ('opacuserlogin','1','Включити/заблокувати відображення можливості реєстрації користувача',NULL,'YesNo');
INSERT into systempreferences(variable, value, explanation, options, type) values ('suggestion','1','Якщо рівне 1, то пропозиції будуть активовані у ЕК',NULL,'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('virtualshelves','1','Встановіть управління віртуальними полицями у ON чи OFF',NULL,'YesNo');

INSERT into systempreferences(variable, value, explanation, options, type) values ('delimiter',';','Символ-роздільник по умовчанню, що використовувтиметься при експорті звітів у файли',';|tabulation|,|/|\\|#','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('IndependantBranches','0','Включити незалежне управління підрозділами у On чи Off',NULL,'YesNo');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('KohaAdminEmailAddress', 'vasha.poshta@otut.ua', 'Адреса електронної пошти, на яку приходять запити відвідувачів щодо модифікації їх записів', NULL, 'free');
INSERT into systempreferences(variable, value, explanation, options, type) values ('MIME','OPENOFFICE.ORG','Програма за умовчанням для експорту звітів у файли','EXCEL|OPENOFFICE.ORG','Choice');
INSERT into systempreferences(variable, value, explanation, options, type) values ('ReceiveBackIssues','5','Скільки попередніх періодичних видань відображати при отриманні періодичних видань',NULL,'free');
INSERT INTO systempreferences (variable, value, explanation, options, type) VALUES ('timeout', '120000000', 'Період проміжку часу бездіяльності (у секундах)', NULL, 'Integer');
