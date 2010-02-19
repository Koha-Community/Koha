INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('circulation','ODUE','Overdue Notice','Item Overdue',"Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nAccording to our current records, you have items that are overdue.Your library does not charge late fines, but please return or renew them at the branch below as soon as possible.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nPhone: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nEmail: <<branches.branchemail>>\n\nIf you have registered a password with the library, and you have a renewal available, you may renew online. If an item becomes more than 30 days overdue, you will be unable to use your library card until the item is returned.\n\nThe following item(s) is/are currently overdue:\n\n<item>"<<biblio.title>>" by <<biblio.author>>, <<items.itemcallnumber>>, Barcode: <<items.barcode>> Fine: <fine>GBP</fine></item>\n\nThank-you for your prompt attention to this matter.\n\n<<branches.branchname>> Staff\n"),
-- ('circulation','ODUE','Повідомлення про прострочення','Одиниця прострочена','Добродію <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nПо нашим нинішнім записам, у Вас є прострочені екземпляри. Ваша бібліотека не стягує штрафи за запізнення, але, будь ласка, поверніть або оновіть їх як можна швидше.\r\n\r\n<<branches.branchname>><<branches.branchaddress1>><<branches.branchaddress2>><<branches.branchaddress3>><<branches.branchphone>><<branches.branchfax>><<branches.branchemail>>Якщо Ви зареєстрували пароль у бібліотеці, ви можете використовувати його з Вашим номером бібліотечного квитка для продовження онлайн. Якщо примірник має прострочення більш ніж на 30 днів, Ви не зможете використовувати Ваш читацький квиток доки не повернете примірник. Наступний примірник в даний час є простроченим:\r\n\r\n<<items.content>>'),

('claimacquisition','ACQCLAIM','Вимога придбання','Примірник не отримано','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nНомер замовлення <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> замовлено) (<<aqorders.listprice>> кожний) отримано не було.'),

('serial','RLIST','Список направления','Серіальне видання вже доступне','<<borrowers.firstname>> <<borrowers.title>>,\r\n\r\nНаступний випуск вже доступний:\r\n\r\n<<items.content>>\r\n\r\nПрохання забрати його в будь-який зручний для Вас час.'),

('members','ACCTDETAILS','Шаблон даних облікового рахунку - ТИПОВО','Дані Вашого нового облікового рахунку в Коха.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nДані Вашого нового облікового рахунку в Коха такі:\r\n\r\nКористувач:  <<borrowers.userid>>\r\nПароль: <<borrowers.password>>\r\n\r\nЯкщо у Вас виникли проблеми чи питання з приводу Вашого облікового запису, будь ласка, звяжіться з адміністратором Коха.\r\n\r\nСпасибі,\r\nадміністратор Koha\r\nkohaadmin@yoursite.org'),

('circulation','DUE','Нагадування про повернення одиниці','Нагадування про повернення одиниці','Добродій <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nнаступну одиницю тепер потрібно повернути:\r\n\r\n<<items.content>>'),

('circulation','DUEDGST','Нагадування про повернення одиниці (збірка)','Нагадування про повернення одиниці','Ви заборгували <<count>> одиниць'),

('circulation','PREDUE','	
Попереднє повідомлення про заборгованість одиниці','Попереднє повідомлення про заборгованість одиниці','Добродій <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nнаступну одиницю скоро потрібно повернути:\r\n\r\n<<items.content>>'),

('circulation','PREDUEDGST','Попереднє повідомлення про заборгованість одиниці (збірка)','Попереднє повідомлення про заборгованість одиниці','В найближчому часі Вам потрібно повернути <<count>> одиниць'),

('circulation','EVENT','Майбутня бібліотечна подія','Майбутня бібліотечна подія','Добродій <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nЦе нагадування про майбутню бібліотечну подію, до якої Ви проявили інтерес.'),
('reserves', 'HOLDPLACED', 'Hold Placed on Item', 'Hold Placed on Item','A hold has been placed on the following item : <<title>> (<<biblionumber>>) by the user <<firstname>> <<surname>> (<<cardnumber>>).');
