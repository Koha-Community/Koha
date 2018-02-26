DELETE FROM auth_types WHERE authtypecode='SAUTTIT';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES (240, 'SAUTTIT', 'Auteur titre', '[240a][, 240b][ 240d][ ; 240c][ (240f)][. 240t]\n');
DELETE FROM auth_tag_structure WHERE authtypecode='SAUTTIT';
DELETE FROM auth_subfield_structure WHERE authtypecode='SAUTTIT';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '001', '', '', 'Ідентифікатор запису', 'Ідентифікатор запису', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '001', '@', 0, 0, 'tag 001', 'tag 001',                -1, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '005', '', '', 'Ідентифікатор версії', 'Ідентифікатор версії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '005', '@', 0, 0, 'tag 005', 'tag 005',                -1, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '015', '', '', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '015', '@', 0, 0, 'tag 015', 'tag 015',                -1, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '035', '', '', 'Інші системні контрольні номери', 'Інші системні контрольні номери', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '035', 'a', 0, 0, 'Системний контрольний номер', 'Системний контрольний номер', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '035', 'z', 0, 1, 'Скасований або недійсний контрольний номер', 'Скасований або недійсний контрольний номер', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '100', 1, '', 'Дані загальної обробки', 'Дані загальної обробки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '100', 'a', 0, 0, 'Дані загальної обробки', 'Дані загальної обробки', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '101', '', '', 'Мова об’єкту', 'Мова об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '101', 'a', 1, 0, 'Мова, використовувана об’єктом', 'Мова, використовувана об’єктом', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '102', 1, '', 'Національність об’єкту', 'Національність об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '102', 'a', 0, 1, 'Країна національності', 'Країна національності', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '102', 'b', 0, 1, 'Місцеположення', 'Місцеположення',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '106', '', '', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '106', 'a', 1, 0, 'Один символьний код', 'Один символьний код', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '120', '', '', 'Поле кодованих даних для особистого імені', 'Поле кодованих даних для особистого імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '120', 'a', 1, 0, 'Кодовані дані: особисті імена', 'Кодовані дані: особисті імена', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '123', '', 1, 'Поле кодованих даних для територіального або географічного імені', 'Поле кодованих даних для територіального або географічного імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '123', 'd', 0, 0, 'Координати — найзахідніша довгота', 'Координати — найзахідніша довгота', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '123', 'e', 0, 0, 'Координати — найбільш східна довгота', 'Координати — найбільш східна довгота', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '123', 'f', 0, 0, 'Координати — найбільш північна широта', 'Координати — найбільш північна широта', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '123', 'g', 0, 0, 'Координати — найбільш південна широта', 'Координати — найбільш південна широта', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '150', '', '', 'Поле кодованих даних для найменувань організацій', 'Поле кодованих даних для найменувань організацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '150', 'a', 1, 0, 'Найменування оброблюваних даних', 'Найменування оброблюваних даних', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '152', '', '', 'Коди правил каталогізації і системи предметизації', 'Коди правил каталогізації і системи предметизації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '152', 'a', 0, 0, 'Правила каталогізації', 'Правила каталогізації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '152', 'b', 0, 0, 'Система предметизації', 'Система предметизації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '154', '', '', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '154', 'a', 1, 0, 'Дані обробки заголовка', 'Дані обробки заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '160', '', '', 'Код географічного регіону', 'Код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '160', 'a', 1, 1, 'Код географічного регіону', 'Код географічного регіону', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '240', '', 1, 'Заголовок — ім’я/заголовок', 'Заголовок — ім’я/заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '240', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', '8', 0, 0, 'Мова каталогізації і мова базового заголовка', 'Мова каталогізації і мова базового заголовка', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'a', 1, 0, 'Елемент входження', 'Елемент входження', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'b', 0, 0, 'Prénom', '',                        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'c', 0, 0, 'Qualificatifs', '',                 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'f', 0, 0, 'Dates', '',                         0, 0, NULL, '', NULL, NULL, '', 0),
 ('', 'SAUTTIT', '240', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 't', 1, 0, 'Заголовок', 'Заголовок',            0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '240', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', -1, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '300', '', 1, 'Довідкова примітка', 'Довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '300', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '300', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '300', 'a', 1, 0, 'Текст довідки', 'Текст довідки',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '305', '', 1, 'Посилальна примітка „див. також“', 'Посилальна примітка „див. також“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '305', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '305', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '305', 'a', 1, 1, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '305', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '310', '', 1, 'Посилальна примітка „див.“', 'Посилальна примітка „див.“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '310', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '310', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '310', 'a', 0, 0, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '310', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '320', '', 1, 'Загальна довідкова примітка', 'Загальна довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '320', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '320', 'a', 1, 1, 'Текст примітка', 'Текст примітка',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '330', '', 1, 'Примітка про область застосування', 'Примітка про область застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '330', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '330', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '330', 'a', 1, 0, 'Примітка про область застосування', 'Примітка про область застосування', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '340', '', 1, 'Біографія та примітка про діяльність', 'Біографія та примітка про діяльність', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '340', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '340', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '340', 'a', 1, 0, 'Примітка біографічна чи про діяльність', 'Примітка біографічна чи про діяльність', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '356', 1, '', 'Географічні примітки', 'Географічні примітки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '356', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '356', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '356', 'a', 0, 0, 'Географічна примітка', 'Географічна примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '440', '', 1, 'Формування посилання „див.“ — ім’я / заголовок', 'Формування посилання „див.“ — ім’я / заголовок', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '440', '0', 0, 0, 'Командна фраза', 'Командна фраза',  -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '3', 0, 0, 'Номер запису', 'Номер запису',      -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',  -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'a', 0, 0, 'Елемент входження', 'Елемент входження', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'b', 0, 0, 'Prénom', '',                        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'c', 0, 0, 'qualificatif', '',                  0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'd', 0, 0, 'numérotation (chiffres romains)', '', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'f', 0, 0, 'Dates', '',                         0, 0, NULL, '', NULL, NULL, '', 0),
 ('', 'SAUTTIT', '440', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 't', 0, 0, 'Заголовок', 'Заголовок',            0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '440', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', -1, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '540', '', 1, 'Формування посилання „див. також“ — ім’я/заголовок', 'Формування посилання „див. також“ — ім’я/заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '540', '0', 0, 0, 'Текст пояснення', 'Текст пояснення', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '3', 0, 0, 'Номер запису', 'Номер запису',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 'a', 0, 0, 'Елемент входження', 'Елемент входження', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 't', 0, 0, 'Заголовок', 'Заголовок',            -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '540', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '675', '', 1, 'Універсальна десяткова класифікація (УДК)', 'Універсальна десяткова класифікація (УДК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '675', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '675', 'a', 0, 0, 'Індекс УДК, окремий або початковий в ряду', 'Індекс УДК, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '675', 'b', 1, 0, 'Індекси УДК, останній в ряду', 'Індекси УДК, останній в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '675', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '675', 'v', 0, 0, 'Відомості про видання УДК', 'Відомості про видання УДК', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '675', 'z', 0, 0, 'Мова видання', 'Мова видання',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '676', '', 1, 'Десяткова класифікація Дьюї (ДК Дьюї)', 'Десяткова класифікація Дьюї (ДК Дьюї)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '676', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '676', 'a', 0, 0, 'Індекс ДК Дьюї, окремий або початковий в ряду', 'Індекс ДК Дьюї, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '676', 'b', 1, 0, 'Індекс ДК Дьюї, кінцевий в ряду', 'Індекс ДК Дьюї, кінцевий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '676', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '676', 'v', 0, 0, 'Зведення про видання Десяткової класифікації Дьюї', 'Зведення про видання Десяткової класифікації Дьюї', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '676', 'z', 0, 0, 'Мова видання', 'Мова видання',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '680', '', 1, 'Класифікація Бібліотеки Конгресу (КБК)', 'Класифікація Бібліотеки Конгресу (КБК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '680', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '680', 'a', 0, 0, 'Індекс КБК, окремий або початковий в ряду', 'Індекс КБК, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '680', 'b', 1, 0, 'Індекси КБК, останній в ряду', 'Індекси КБК, останній в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '680', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '686', '', 1, 'Індекси інших класифікацій', 'Індекси інших класифікацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '686', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '686', 'a', 0, 0, 'Індекс, окремий або початковий в ряду', 'Індекс, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '686', 'b', 1, 0, 'Індекс, кінцевий в послідовності', 'Індекс, кінцевий в послідовності', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '686', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '740', '', 1, 'Зв’язаний заголовок — ім’я/заголовок', 'Зв’язаний заголовок — ім’я/заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '740', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', '3', 0, 0, 'Номер запису', 'Номер запису',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', '7', 0, 0, 'Графіка', 'Графіка',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 'a', 0, 0, 'Елемент входження', 'Елемент входження', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 't', 0, 0, 'Заголовок', 'Заголовок',            -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '740', 'z', 1, 0, 'Хронологічний підрозділ', 'Хронологічний підрозділ', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '801', 1, '', 'Джерело запису', 'Джерело запису', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '801', 'a', 0, 0, 'Країна', 'Країна',                  0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '801', 'b', 0, 0, 'Організація', 'Організація',        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SAUTTIT', '801', 'c', 0, 0, 'Дата введення або останнього редагування запису', 'Дата введення або останнього редагування запису', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '810', '', 1, 'Джерело, в якому виявлена інформація про заголовок', 'Джерело, в якому виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '810', 'a', 0, 0, 'Назва джерела', 'Назва джерела',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '810', 'b', 0, 0, 'Знайдена інформація', 'Знайдена інформація', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '815', '', '', 'Джерело, в якому не виявлена інформація про заголовок', 'Джерело, в якому не виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '815', 'a', 1, 1, 'Назва джерела', 'Назва джерела',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '820', '', 1, 'Інформація про використання заголовка в полі 2--', 'Інформація про використання заголовка в полі 2--', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '820', 'a', 1, 1, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '825', '', 1, 'Приклад, приведений в примітці', 'Приклад, приведений в примітці', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '825', 'a', 1, 0, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '830', '', 1, 'Загальна примітка каталогізатора', 'Загальна примітка каталогізатора', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '830', 'a', 0, 1, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '835', '', 1, 'Інформація про виключений заголовок', 'Інформація про виключений заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '835', 'a', 0, 1, 'Текст примітки', 'Текст примітки',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '835', 'b', 1, 0, 'Заголовок, на який замінений виключений', 'Заголовок, на який замінений виключений', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '835', 'd', 1, 0, 'Дата транзакції', 'Дата транзакції', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '836', '', 1, 'Замінена інформація заголовку', 'Замінена інформація заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '836', 'b', 0, 0, 'Замінено заголовок', 'Замінено заголовок', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '836', 'd', 0, 0, 'Дата транзакції', 'Дата транзакції', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '856', '', 1, 'Електронічне розташування та доступ', 'Електронічне розташування та доступ', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '856', 'a', 0, 1, 'Ім’я сервера', 'Ім’я сервера',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'b', 0, 1, 'Номер доступу', 'Номер доступу',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'c', 0, 1, 'Інформація про компресію', 'Інформація про компресію', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'd', 0, 1, 'Шлях', 'Шлях',                      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'e', 0, 0, 'Дата і година консультацій та доступу', 'Дата і година консультацій та доступу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'f', 0, 1, 'Електронічне ім’я', 'Електронічне ім’я', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'g', 1, 0, 'Загальноприйняте ім’я ресурсу (URN)', 'Загальноприйняте ім’я ресурсу (URN)', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'h', 0, 0, 'Процесор запиту', 'Процесор запиту', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'i', 0, 1, 'Команда', 'Команда',                -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'j', 0, 0, 'Біт на секунду', 'Біт на секунду',  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'k', 0, 0, 'Пароль', 'Пароль',                  -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'l', 0, 0, 'Вхід/логін сеансу', 'Вхід/логін сеансу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'm', 0, 1, 'Контакт для допомоги доступу', 'Контакт для допомоги доступу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'n', 0, 0, 'Ім’я розташування вузла в підполі $a', 'Ім’я розташування вузла в підполі $a', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'o', 0, 0, 'Операційна система', 'Операційна система', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'p', 0, 0, 'Порт', 'Порт',                      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'q', 0, 0, 'Електронічний тип формату', 'Електронічний тип формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'r', 0, 0, 'Налаштування', 'Налаштування',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 's', 0, 1, 'Розмір файлу', 'Розмір файлу',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 't', 0, 1, 'Емуляція терміналу', 'Емуляція терміналу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'u', 0, 0, 'Загальноприйняте розміщення ресурсу (URL)', 'Загальноприйняте розміщення ресурсу (URL)', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'v', 0, 1, 'Години доступності електронічного ресурсу', 'Години доступності електронічного ресурсу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'w', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'x', 1, 0, 'Непублікована примітка', 'Непублікована примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '856', 'z', 0, 1, 'Загальна примітка', 'Загальна примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SAUTTIT', '886', '', 1, 'Дані, не конвертовані з початкового Формату', 'Дані, не конвертовані з початкового Формату', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SAUTTIT', '886', '2', 0, 0, 'Системний код', 'Системний код',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '886', 'a', 0, 1, 'Тег поля початкового формату', 'Тег поля початкового формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SAUTTIT', '886', 'b', 0, 1, 'Індикатори та підполя поля початкового формату', 'Індикатори та підполя поля початкового формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
