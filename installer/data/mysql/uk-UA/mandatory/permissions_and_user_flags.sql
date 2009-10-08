TRUNCATE userflags;

INSERT INTO userflags (bit, flag, flagdesc, defaulton) VALUES
   (0, 'superlibrarian',  'Доступ до усіх бібліотечних функцій',0),
   (1, 'circulate',       'Обіг книжок',0),
   (2, 'catalogue',       'Перегляд каталогу (інтерфейс бібліотекаря)',0),
   (3, 'parameters',      'Встановлення системних налаштувань Koha',0),
   (4, 'borrowers',       'Внесення та зміна відвідувачів',0),
   (5, 'permissions',     'Встановлення привілеїв користувача',0),
   (6, 'reserveforothers','Резервування книжок для відвідувачів',0),
   (7, 'borrow',          'Випозичання книжок',1),
   (9, 'editcatalogue',   'Редагування каталогу (зміна бібліографічних/локальних даних)',0),
   (10,'updatecharges',   'Оновлення сплат користувачів',0),
   (11,'acquisition',     'Управління надходженнями і/чи пропозиціями',0),
   (12,'management',      'Встановлення параметрів керування бібліотекою',0),
   (13,'tools',           'Використання інструментів (експорт, імпорт, штрих-коди)',0),
   (14,'editauthorities', 'Дозвіл на редагування авторитетних джерел',0),
   (15,'serials',         'Дозвіл на керування підпискою періодичних видань',0),
   (16,'reports',         'Дозвіл на доступ до модуля звітів',0),
   (17,'staffaccess',     'Зміна імені(логіну)/привілеїв для працівників бібліотеки',0)
;

TRUNCATE permissions;

INSERT INTO permissions (module_bit, code, description) VALUES
   ( 1, 'circulate_remaining_permissions', 'Remaining circulation permissions'),
   ( 1, 'override_renewals', 'Override blocked renewals'),
   (13, 'edit_news',                   'Написання новин для електронного каталогу та інтерфейсу бібліотекарів'),
   (13, 'label_creator',               'Створення друкованих наклейок і штрих-кодів з каталогу та з даними про користувачів'),
   (13, 'edit_calendar',               'Визначення днів, коли бібліотека закрита'),
   (13, 'moderate_comments',           'Регулювання коментарів від відвідувачів'),
   (13, 'edit_notices',                'Визначення повідомлень'),
   (13, 'edit_notice_status_triggers', 'Встановлення тригерів повідомлень/статусів для прострочених примірників'),
   (13, 'view_system_logs',            'Перегляд протоколів системи'),
   (13, 'inventory',                   'Проведення інвентаризації(аналізу) Вашого каталогу'),
   (13, 'stage_marc_import',           'Заготівля МАРК-записів у сховище'),
   (13, 'manage_staged_marc',          'Керування заготовленими МАРК-записами, в тому числі доповнення та зворотній імпорт'),
   (13, 'export_catalog',              'Експортування бібліографічної інформації та даних про одиниці зберігання'),
   (13, 'import_patrons',              'Імпортування даних про відвідувачів'),
   (13, 'delete_anonymize_patrons',    'Вилучення користувачів з протермінованим періодом реєстрації та анонімізація історії обігу (вилучення історія читання користувачів)'),
   (13, 'batch_upload_patron_images',  'Завантаження зображень відвідувачів партіями чи усіх за раз'),
   (13, 'schedule_tasks',              'Планування задач до виконання'),
   (15, 'check_expiration', 'Check the expiration of a serial'),
   (15, 'claim_serials', 'Claim missing serials'),
   (15, 'create_subscription', 'Create a new subscription'),
   (15, 'delete_subscription', 'Delete an existing subscription'),
   (15, 'edit_subscription', 'Edit an existing subscription'),
   (15, 'receive_serials', 'Serials receiving'),
   (15, 'renew_subscription', 'Renew a subscription'),
   (15, 'routing', 'Routing')
;

