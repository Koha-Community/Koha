truncate letter;

INSERT INTO `letter`
(module, code, name, title, content, message_transport_type)
VALUES
('circulation','ODUE','Повідомлення про прострочення','Одиниця прострочена','Добродію <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nПо нашим нинішнім записам, у Вас є прострочені екземпляри. Ваша бібліотека не стягує штрафи за запізнення, але, будь ласка, поверніть або оновіть їх як можна швидше.\r\n\r\n<<branches.branchname>><<branches.branchaddress1>><<branches.branchaddress2>><<branches.branchaddress3>><<branches.branchphone>><<branches.branchfax>><<branches.branchemail>>Якщо Ви зареєстрували пароль у бібліотеці, ви можете використовувати його з Вашим номером бібліотечного квитка для продовження онлайн. Якщо примірник має прострочення більш ніж на 30 днів, Ви не зможете використовувати Ваш читацький квиток доки не повернете примірник. Наступний примірник в даний час є простроченим:\r\n\r\n<<items.content>>', 'email'),

('claimacquisition','ACQCLAIM','Вимога придбання','Примірник не отримано','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Номер замовлення <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> замовлено) (<<aqorders.listprice>> кожний) отримано не було.</order>', 'email'),

('serial','RLIST','Список направления','Серіальне видання вже доступне','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nНаступний випуск вже доступний:\r\n\r\n<<items.content>>\r\n\r\nПрохання забрати його в будь-який зручний для Вас час.', 'email'),

('members','ACCTDETAILS','Шаблон даних облікового рахунку - ТИПОВО','Дані Вашого нового облікового рахунку в Коха.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nДані Вашого нового облікового рахунку в Коха такі:\r\n\r\nКористувач:  <<borrowers.userid>>\r\nПароль: <<borrowers.password>>\r\n\r\nЯкщо у Вас виникли проблеми чи питання з приводу Вашого облікового запису, будь ласка, звяжіться з адміністратором Коха.\r\n\r\nСпасибі,\r\nадміністратор Koha\r\nkohaadmin@yoursite.org', 'email'),

('circulation','DUE','Нагадування про повернення одиниці','Нагадування про повернення одиниці','Добродій <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nнаступну одиницю тепер потрібно повернути:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),

('circulation','DUEDGST','Нагадування про повернення одиниці (збірка)','Нагадування про повернення одиниці','Ви заборгували <<count>> одиниць', 'email'),

('circulation','PREDUE','Попереднє повідомлення про заборгованість одиниці','Попереднє повідомлення про заборгованість одиниці','Добродій <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nнаступну одиницю скоро потрібно повернути:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),

('circulation','PREDUEDGST','Попереднє повідомлення про заборгованість одиниці (збірка)','Попереднє повідомлення про заборгованість одиниці','В найближчому часі Вам потрібно повернути <<count>> одиниць', 'email'),

('reserves', 'HOLD', 'Hold Available for Pickup', 'Hold Available for Pickup at <<branches.branchname>>', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\nLocation: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>', 'email'),

('circulation','CHECKIN','Item Check-in (Digest)','Check-ins','The following items have been checked in:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you.', 'email'),

('circulation','CHECKOUT','Item Check-out (Digest)','Checkouts','The following items have been checked out:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.', 'email'),

('suggestions','ACCEPTED','Suggestion accepted', 'Purchase suggestion accepted','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your suggestion today. The item will be ordered as soon as possible. You will be notified by mail when the order is completed, and again when the item arrives at the library.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','AVAILABLE','Suggestion available', 'Suggested purchase available','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested is now part of the collection.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','ORDERED','Suggestion ordered', 'Suggested item ordered','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested has now been ordered. It should arrive soon, at which time it will be processed for addition into the collection.\n\nYou will be notified again when the book is available.\n\nIf you have any questions, please email us at <<branches.branchemail>>\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','REJECTED','Suggestion rejected', 'Purchase suggestion declined','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your request today, and has decided not to accept the suggestion at this time.\n\nThe reason given is: <<suggestions.reason>>\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','TO_PROCESS','Notify fund owner', 'A suggestion is ready to be processed','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nA new suggestion is ready to be processed: <<suggestions.title>> by <<suggestions.author>>.\n\nThank you,\n\n<<branches.branchname>>', 'email')

;
