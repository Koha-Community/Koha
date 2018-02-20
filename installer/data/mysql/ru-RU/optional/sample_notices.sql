truncate letter;

INSERT INTO `letter`
(module, code, name, title, content, message_transport_type)
VALUES
('circulation','ODUE','Уведомление о просрочке','Единица прострочена','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nПо нашим нынешним записям, у Вас есть простроченные экземпляры. Ваша библиотека не взимает штрафы за опоздание, но, пожалуйста, поверните или обновите их как можно скорее.\r\n\r\n<<branches.branchname>><<branches.branchaddress1>><<branches.branchaddress2>><<branches.branchaddress3>><<branches.branchphone>><<branches.branchfax>><<branches.branchemail>>Если Вы зарегистрировали пароль в библиотеке, вы можете использовать его с вашим номером библиотечного билета для продолжения онлайн. Если экземпляр имеет просрочки более чем на 30 дней, Вы не сможете использовать Ваш читательский билет пока не вернете экземпляр. Следующий экземпляр в настоящее время является просроченным:\r\n\r\n<<items.content>>', 'email'),

('claimacquisition','ACQCLAIM','Требование приобретения','Экземпляр не получено','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Номер заказа <<aqorders.ordernumber>> (<<biblio.title>>) (<<aqorders.quantity>> каждый) получено не было.</order>', 'email'),

('serial','SERIAL_ALERT','Список скерування','Сериальные издания уже доступное','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nСледующий выпуск уже доступен:\r\n\r\n<<items.content>>\r\n\r\nПросьба забрать его в любое удобное для Вас время.', 'email'),

('members','ACCTDETAILS','Шаблон данных учетной записи - типовые','Данные Вашего нового учетного счета в Коха.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nДанные Вашего нового учетного счета в Коха такие:\r\n\r\nПользователь:  <<borrowers.userid>>\r\nПароль: <<borrowers.password>>\r\n\r\nЕсли у Вас возникли проблемы или вопросы по поводу Вашей учетной записи, пожалуйста, свяжитесь с администратором Коха.\r\n\r\nСпасибо,\r\nадминистратор Koha\r\nkohaadmin@yoursite.org', 'email'),

('circulation','DUE','Напоминание про возвращение единицы','Напоминание про возвращение единицы','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nследующую единицу теперь нужно возвратить:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),

('circulation','DUEDGST','Напоминие про возвращение единицы (сборник)','Напоминие про возвращение единицы','Вы задолжали <<count>> единиц', 'email'),

('circulation','PREDUE','Предварительное уведомление о задолженности единицы','Предварительное уведомление о задолженности единицы','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nследующую единицу скоро нужно возвратить:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)', 'email'),

('circulation','PREDUEDGST','Предварительное уведомление о задолженности единицы (сборник)','Предварительное уведомление о задолженности единицы','В ближайшем времени Вам нужно возвратить <<count>> единиц', 'email'),

('reserves', 'HOLD', 'Hold Available for Pickup', 'Hold Available for Pickup at <<branches.branchname>>', 'Dear <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nYou have a hold available for pickup as of <<reserves.waitingdate>>:\r\n\r\nTitle: <<biblio.title>>\r\nAuthor: <<biblio.author>>\r\nCopy: <<items.copynumber>>\r\nLocation: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>', 'email'),

('circulation','CHECKIN','Item Check-in (Digest)','Check-ins','The following items have been checked in:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you.', 'email'),

('circulation','CHECKOUT','Item Check-out (Digest)','Checkouts','The following items have been checked out:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.', 'email'),

('reserves', 'HOLDPLACED', 'Hold Placed on Item', 'Hold Placed on Item','A hold has been placed on the following item : <<biblio.title>> (<<biblio.biblionumber>>) by the user <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).', 'email'),

('suggestions','ACCEPTED','Suggestion accepted', 'Purchase suggestion accepted','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your suggestion today. The item will be ordered as soon as possible. You will be notified by mail when the order is completed, and again when the item arrives at the library.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','AVAILABLE','Suggestion available', 'Suggested purchase available','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested is now part of the collection.\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','ORDERED','Suggestion ordered', 'Suggested item ordered','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nWe are pleased to inform you that the item you requested has now been ordered. It should arrive soon, at which time it will be processed for addition into the collection.\n\nYou will be notified again when the book is available.\n\nIf you have any questions, please email us at <<branches.branchemail>>\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','REJECTED','Suggestion rejected', 'Purchase suggestion declined','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nYou have suggested that the library acquire <<suggestions.title>> by <<suggestions.author>>.\n\nThe library has reviewed your request today, and has decided not to accept the suggestion at this time.\n\nThe reason given is: <<suggestions.reason>>\n\nIf you have any questions, please email us at <<branches.branchemail>>.\n\nThank you,\n\n<<branches.branchname>>', 'email'),

('suggestions','TO_PROCESS','Notify fund owner', 'A suggestion is ready to be processed','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nA new suggestion is ready to be processed: <<suggestions.title>> by <<suggestions.author>>.\n\nThank you,\n\n<<branches.branchname>>', 'email')

;
