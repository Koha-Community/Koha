INSERT INTO `letter`
(module, code, name, title, content)
VALUES
('circulation','ODUE','Уведомление о просрочке','Единица прострочена','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nПо нашим нынешним записям, у Вас есть простроченные экземпляры. Ваша библиотека не взимает штрафы за опоздание, но, пожалуйста, поверните или обновите их как можно скорее.\r\n\r\n<<branches.branchname>><<branches.branchaddress1>><<branches.branchaddress2>><<branches.branchaddress3>><<branches.branchphone>><<branches.branchfax>><<branches.branchemail>>Если Вы зарегистрировали пароль в библиотеке, вы можете использовать его с вашим номером библиотечного билета для продолжения онлайн. Если экземпляр имеет просрочки более чем на 30 дней, Вы не сможете использовать Ваш читательский билет пока не вернете экземпляр. Следующий экземпляр в настоящее время является просроченным:\r\n\r\n<<items.content>>'),

('claimacquisition','ACQCLAIM','Требование приобретения','	
Экземпляр не получено','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\nНомер заказа <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> каждый) получено не было.'),

('serial','RLIST','Список скерування','Сериальные издания уже доступное','<<borrowers.firstname>> <<borrowers.title>>,\r\n\r\nСледующий выпуск уже доступен:\r\n\r\n<<items.content>>\r\n\r\nПросьба забрать его в любое удобное для Вас время.'),

('members','ACCTDETAILS','Шаблон данных учетной записи - типовые','Данные Вашего нового учетного счета в Коха.','Hello <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nДанные Вашего нового учетного счета в Коха такие:\r\n\r\nПользователь:  <<borrowers.userid>>\r\nПароль: <<borrowers.password>>\r\n\r\nЕсли у Вас возникли проблемы или вопросы по поводу Вашей учетной записи, пожалуйста, свяжитесь с администратором Коха.\r\n\r\nСпасибо,\r\nадминистратор Koha\r\nkohaadmin@yoursite.org'),

('circulation','DUE','Напоминание про возвращение единицы','Напоминание про возвращение единицы','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nследующую единицу теперь нужно возвратить:\r\n\r\n<<items.content>>'),

('circulation','DUEDGST','Напоминие про возвращение единицы (сборник)','Напоминие про возвращение единицы','Вы задолжали <<count>> единиц'),

('circulation','PREDUE','	
Предварительное уведомление о задолженности единицы','Предварительное уведомление о задолженности единицы','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nследующую единицу скоро нужно возвратить:\r\n\r\n<<items.content>>'),

('circulation','PREDUEDGST','Предварительное уведомление о задолженности единицы (сборник)','Предварительное уведомление о задолженности единицы','В ближайшем времени Вам нужно возвратить <<count>> единиц'),

('circulation','EVENT','Предстоящее библиотечное событие','Предстоящее библиотечное событие','Любезный <<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nЭто напоминание о предстоящем библиотечном событии, в котором Вы проявили интерес.');
