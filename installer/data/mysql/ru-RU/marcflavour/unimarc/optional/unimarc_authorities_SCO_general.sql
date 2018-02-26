DELETE FROM auth_types WHERE authtypecode='SCO';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES (210, 'SCO', 'Sujet (collectivité)', '[210a ][ (210c)][. 210b][ -- 210d][ ; 210e][ ; 210f][ -- 210x][ -- 210z][ -- 210y]');
DELETE FROM auth_tag_structure WHERE authtypecode='SCO';
DELETE FROM auth_subfield_structure WHERE authtypecode='SCO';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '001', '', '', 'Ідентифікатор запису', 'Ідентифікатор запису', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '001', '@', 0, 0, 'tag 001', 'tag 001',                    -1, 0, NULL, '', NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '005', '', '', 'Ідентифікатор версії', 'Ідентифікатор версії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '005', '@', 0, 0, 'tag 005', 'tag 005',                    -1, 0, NULL, '', NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '015', '', '', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '015', '@', 0, 0, 'tag 015', 'tag 015',                    -1, 0, NULL, '', NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '035', '', '', 'Інші системні контрольні номери', 'Інші системні контрольні номери', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '035', 'a', 0, 0, 'Системний контрольний номер', 'Системний контрольний номер', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '035', 'z', 0, 1, 'Скасований або недійсний контрольний номер', 'Скасований або недійсний контрольний номер', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '100', 1, '', 'Дані загальної обробки', 'Дані загальної обробки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '100', 'a', 0, 0, 'Дані загальної обробки', 'Дані загальної обробки', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '101', '', '', 'Мова об’єкту', 'Мова об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '101', 'a', 1, 0, 'Мова, використовувана об’єктом', 'Мова, використовувана об’єктом', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '102', 1, '', 'Національність об’єкту', 'Національність об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '102', 'a', 0, 1, 'Країна національності', 'Країна національності', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '102', 'b', 0, 1, 'Місцеположення', 'Місцеположення',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '106', '', '', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '106', 'a', 1, 0, 'Один символьний код', 'Один символьний код', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '120', '', '', 'Поле кодованих даних для особистого імені', 'Поле кодованих даних для особистого імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '120', 'a', 1, 0, 'Кодовані дані: особисті імена', 'Кодовані дані: особисті імена', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '123', '', 1, 'Поле кодованих даних для територіального або географічного імені', 'Поле кодованих даних для територіального або географічного імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '123', 'd', 0, 0, 'Координати — найзахідніша довгота', 'Координати — найзахідніша довгота', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '123', 'e', 0, 0, 'Координати — найбільш східна довгота', 'Координати — найбільш східна довгота', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '123', 'f', 0, 0, 'Координати — найбільш північна широта', 'Координати — найбільш північна широта', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '123', 'g', 0, 0, 'Координати — найбільш південна широта', 'Координати — найбільш південна широта', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '150', '', '', 'Поле кодованих даних для найменувань організацій', 'Поле кодованих даних для найменувань організацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '150', 'a', 1, 0, 'Найменування оброблюваних даних', 'Найменування оброблюваних даних', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '152', '', '', 'Коди правил каталогізації і системи предметизації', 'Коди правил каталогізації і системи предметизації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '152', 'a', 0, 0, 'Правила каталогізації', 'Правила каталогізації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '152', 'b', 0, 0, 'Система предметизації', 'Система предметизації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '154', '', '', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '154', 'a', 1, 0, 'Дані обробки заголовка', 'Дані обробки заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '160', '', '', 'Код географічного регіону', 'Код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '160', 'a', 1, 1, 'Код географічного регіону', 'Код географічного регіону', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '210', '', 1, 'Заголовок — найменування організації', 'Заголовок — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '210', '7', 0, 0, 'Графіка заголовка', 'Графіка заголовка', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', '8', 0, 0, 'Мова заголовка', 'Мова заголовка',      -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'a', 1, 0, 'Початковий елемент введення', 'Початковий елемент введення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'b', 0, 1, 'Структурний підрозділ', 'Структурний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'c', 0, 1, 'Ідентифікуюча ознака', 'Ідентифікуюча ознака', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'd', 0, 0, 'Номер тимчасової організації (заходи) і/або номер її частини', 'Номер тимчасової організації (заходи) і/або номер її частини', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'e', 0, 0, 'Місце проведення тимчасової організації (заходи)', 'Місце проведення тимчасової організації (заходи)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'f', 0, 0, 'Дата проведення тимчасової організації (заходи)', 'Дата проведення тимчасової організації (заходи)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'g', 0, 0, 'Інверсований елемент', 'Інверсований елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'h', 0, 0, 'Частина найменування, відмінна від початкового елементу введення та інверсованого елементу', 'Частина найменування, відмінна від початкового елементу введення та інверсованого елементу', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'x', 0, 1, 'Тематичний підзаголовок', 'Тематичний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'y', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '210', 'z', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '300', '', 1, 'Довідкова примітка', 'Довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '300', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '300', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '300', 'a', 1, 0, 'Текст довідки', 'Текст довідки',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '305', '', 1, 'Посилальна примітка „див. також“', 'Посилальна примітка „див. також“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '305', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '305', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '305', 'a', 1, 1, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '305', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '310', '', 1, 'Посилальна примітка „див.“', 'Посилальна примітка „див.“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '310', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '310', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '310', 'a', 0, 0, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '310', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '320', '', 1, 'Загальна довідкова примітка', 'Загальна довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '320', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '320', 'a', 1, 1, 'Текст примітка', 'Текст примітка',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '330', '', 1, 'Примітка про область застосування', 'Примітка про область застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '330', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '330', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '330', 'a', 1, 0, 'Примітка про область застосування', 'Примітка про область застосування', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '340', '', 1, 'Біографія та примітка про діяльність', 'Біографія та примітка про діяльність', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '340', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '340', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '340', 'a', 1, 0, 'Примітка біографічна чи про діяльність', 'Примітка біографічна чи про діяльність', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '356', 1, '', 'Географічні примітки', 'Географічні примітки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '356', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '356', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '356', 'a', 0, 0, 'Географічна примітка', 'Географічна примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '410', '', 1, 'Формування посилання „див.“ — найменування організації', 'Формування посилання „див.“ — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '410', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '3', 0, 0, 'Номер запису', 'Номер запису',          -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',      -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'a', 0, 0, 'Елемент входження', 'Елемент входження', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'd', 0, 0, 'Число зустрічей і/або число частини зустрічей', 'Число зустрічей і/або число частини зустрічей', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '410', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', -1, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '510', '', 1, 'Формування посилання „див. також“ — найменування організації', 'Формування посилання „див. також“ — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '510', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '3', 0, 0, 'Номер запису', 'Номер запису',          -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',      -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'a', 0, 0, 'Елемент входження', 'Елемент входження', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'd', 0, 0, 'Число зустрічі і/або число частини зустрічі', 'Число зустрічі і/або число частини зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '510', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '675', '', 1, 'Універсальна десяткова класифікація (УДК)', 'Універсальна десяткова класифікація (УДК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '675', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '675', 'a', 0, 0, 'Індекс УДК, окремий або початковий в ряду', 'Індекс УДК, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '675', 'b', 1, 0, 'Індекси УДК, останній в ряду', 'Індекси УДК, останній в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '675', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '675', 'v', 0, 0, 'Відомості про видання УДК', 'Відомості про видання УДК', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '675', 'z', 0, 0, 'Мова видання', 'Мова видання',          -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '676', '', 1, 'Десяткова класифікація Дьюї (ДК Дьюї)', 'Десяткова класифікація Дьюї (ДК Дьюї)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '676', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '676', 'a', 0, 0, 'Індекс ДК Дьюї, окремий або початковий в ряду', 'Індекс ДК Дьюї, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '676', 'b', 1, 0, 'Індекс ДК Дьюї, кінцевий в ряду', 'Індекс ДК Дьюї, кінцевий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '676', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '676', 'v', 0, 0, 'Зведення про видання Десяткової класифікації Дьюї', 'Зведення про видання Десяткової класифікації Дьюї', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '676', 'z', 0, 0, 'Мова видання', 'Мова видання',          -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '680', '', 1, 'Класифікація Бібліотеки Конгресу (КБК)', 'Класифікація Бібліотеки Конгресу (КБК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '680', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '680', 'a', 0, 0, 'Індекс КБК, окремий або початковий в ряду', 'Індекс КБК, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '680', 'b', 1, 0, 'Індекси КБК, останній в ряду', 'Індекси КБК, останній в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '680', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '686', '', 1, 'Індекси інших класифікацій', 'Індекси інших класифікацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '686', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '686', 'a', 0, 0, 'Індекс, окремий або початковий в ряду', 'Індекс, окремий або початковий в ряду', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '686', 'b', 1, 0, 'Індекс, кінцевий в послідовності', 'Індекс, кінцевий в послідовності', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '686', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '710', '', 1, 'Зв’язаний заголовок — найменування організації', 'Зв’язаний заголовок — найменування організації', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '710', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', '3', 0, 0, 'Номер запису', 'Номер запису',          -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', '7', 0, 0, 'Графіка', 'Графіка',                    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',      -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'a', 0, 0, 'Елемент входження', 'Елемент входження', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'd', 0, 0, 'Число зустрічі і/або число частини зустрічі', 'Число зустрічі і/або число частини зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',        0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',    -1, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '710', 'z', 0, 0, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '801', 1, '', 'Джерело запису', 'Джерело запису', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '801', 'a', 0, 0, 'Країна', 'Країна',                      0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '801', 'b', 0, 0, 'Організація', 'Організація',            0, 0, NULL, '', '', NULL, '', 0),
 ('', 'SCO', '801', 'c', 0, 0, 'Дата введення або останнього редагування запису', 'Дата введення або останнього редагування запису', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '810', '', 1, 'Джерело, в якому виявлена інформація про заголовок', 'Джерело, в якому виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '810', 'a', 0, 0, 'Назва джерела', 'Назва джерела',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '810', 'b', 0, 0, 'Знайдена інформація', 'Знайдена інформація', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '815', '', '', 'Джерело, в якому не виявлена інформація про заголовок', 'Джерело, в якому не виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '815', 'a', 1, 1, 'Назва джерела', 'Назва джерела',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '820', '', 1, 'Інформація про використання заголовка в полі 2--', 'Інформація про використання заголовка в полі 2--', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '820', 'a', 1, 1, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '825', '', 1, 'Приклад, приведений в примітці', 'Приклад, приведений в примітці', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '825', 'a', 1, 0, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '830', '', 1, 'Загальна примітка каталогізатора', 'Загальна примітка каталогізатора', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '830', 'a', 0, 1, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '835', '', 1, 'Інформація про виключений заголовок', 'Інформація про виключений заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '835', 'a', 0, 1, 'Текст примітки', 'Текст примітки',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '835', 'b', 1, 0, 'Заголовок, на який замінений виключений', 'Заголовок, на який замінений виключений', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '835', 'd', 1, 0, 'Дата транзакції', 'Дата транзакції',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '836', '', 1, 'Замінена інформація заголовку', 'Замінена інформація заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '836', 'b', 0, 0, 'Замінено заголовок', 'Замінено заголовок', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '836', 'd', 0, 0, 'Дата транзакції', 'Дата транзакції',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '856', '', 1, 'Електронічне розташування та доступ', 'Електронічне розташування та доступ', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '856', 'a', 0, 1, 'Ім’я сервера', 'Ім’я сервера',          -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'b', 0, 1, 'Номер доступу', 'Номер доступу',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'c', 0, 1, 'Інформація про компресію', 'Інформація про компресію', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'd', 0, 1, 'Шлях', 'Шлях',                          -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'e', 0, 0, 'Дата і година консультацій та доступу', 'Дата і година консультацій та доступу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'f', 0, 1, 'Електронічне ім’я', 'Електронічне ім’я', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'g', 1, 0, 'Загальноприйняте ім’я ресурсу (URN)', 'Загальноприйняте ім’я ресурсу (URN)', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'h', 0, 0, 'Процесор запиту', 'Процесор запиту',    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'i', 0, 1, 'Команда', 'Команда',                    -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'j', 0, 0, 'Біт на секунду', 'Біт на секунду',      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'k', 0, 0, 'Пароль', 'Пароль',                      -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'l', 0, 0, 'Вхід/логін сеансу', 'Вхід/логін сеансу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'm', 0, 1, 'Контакт для допомоги доступу', 'Контакт для допомоги доступу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'n', 0, 0, 'Ім’я розташування вузла в підполі $a', 'Ім’я розташування вузла в підполі $a', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'o', 0, 0, 'Операційна система', 'Операційна система', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'p', 0, 0, 'Порт', 'Порт',                          -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'q', 0, 0, 'Електронічний тип формату', 'Електронічний тип формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'r', 0, 0, 'Налаштування', 'Налаштування',          -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 's', 0, 1, 'Розмір файлу', 'Розмір файлу',          -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 't', 0, 1, 'Емуляція терміналу', 'Емуляція терміналу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'u', 0, 0, 'Загальноприйняте розміщення ресурсу (URL)', 'Загальноприйняте розміщення ресурсу (URL)', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'v', 0, 1, 'Години доступності електронічного ресурсу', 'Години доступності електронічного ресурсу', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'w', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'x', 1, 0, 'Непублікована примітка', 'Непублікована примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '856', 'z', 0, 1, 'Загальна примітка', 'Загальна примітка', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('SCO', '886', '', 1, 'Дані, не конвертовані з початкового Формату', 'Дані, не конвертовані з початкового Формату', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', 'SCO', '886', '2', 0, 0, 'Системний код', 'Системний код',        -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '886', 'a', 0, 1, 'Тег поля початкового формату', 'Тег поля початкового формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', 'SCO', '886', 'b', 0, 1, 'Індикатори та підполя поля початкового формату', 'Індикатори та підполя поля початкового формату', -1, 0, NULL, NULL, NULL, NULL, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
