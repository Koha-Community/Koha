DELETE FROM auth_types WHERE authtypecode='';
INSERT INTO auth_types (auth_tag_to_report, authtypecode, authtypetext, summary) VALUES ('', '', 'За умовчанням', '');
DELETE FROM auth_tag_structure WHERE authtypecode='';
DELETE FROM auth_subfield_structure WHERE authtypecode='';


INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '001', '', '', 'Ідентифікатор запису', 'Ідентифікатор запису', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '001', '@', 0, 0, 'tag 001', 'tag 001',                       0, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '005', '', '', 'Ідентифікатор версії', 'Ідентифікатор версії', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '005', '@', 0, 0, 'tag 005', 'tag 005',                       0, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '015', '', '', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', 'Міжнародний стандартний номер авторитетних / нормативних даних (ISADN)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '015', '@', 0, 0, 'tag 015', 'tag 015',                       0, 0, NULL, '', '', NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '035', '', '', 'Інші системні контрольні номери', 'Інші системні контрольні номери', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '035', 'a', 0, 0, 'Системний контрольний номер', 'Системний контрольний номер', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '035', 'z', 0, 1, 'Скасований або недійсний контрольний номер', 'Скасований або недійсний контрольний номер', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '100', 1, '', 'Дані загальної обробки', 'Дані загальної обробки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '100', 'a', 0, 0, 'Дані загальної обробки', 'Дані загальної обробки', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '101', '', '', 'Мова об’єкту', 'Мова об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '101', 'a', 1, 0, 'Мова, використовувана об’єктом', 'Мова, використовувана об’єктом', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '102', 1, '', 'Національність об’єкту', 'Національність об’єкту', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '102', 'a', 0, 1, 'Країна національності', 'Країна національності', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '102', 'b', 0, 1, 'Місцеположення', 'Місцеположення',         0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '106', '', '', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', 'Поле кодованих даних для персонального/корпоративного/родового імені / торгової марки використано як тематичний заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '106', 'a', 1, 0, 'Один символьний код', 'Один символьний код', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '120', '', '', 'Поле кодованих даних для особистого імені', 'Поле кодованих даних для особистого імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '120', 'a', 1, 0, 'Кодовані дані: особисті імена', 'Кодовані дані: особисті імена', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '123', '', 1, 'Поле кодованих даних для територіального або географічного імені', 'Поле кодованих даних для територіального або географічного імені', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '123', 'd', 0, 0, 'Координати — найзахідніша довгота', 'Координати — найзахідніша довгота', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '123', 'e', 0, 0, 'Координати — найбільш східна довгота', 'Координати — найбільш східна довгота', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '123', 'f', 0, 0, 'Координати — найбільш північна широта', 'Координати — найбільш північна широта', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '123', 'g', 0, 0, 'Координати — найбільш південна широта', 'Координати — найбільш південна широта', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '150', '', '', 'Поле кодованих даних для найменувань організацій', 'Поле кодованих даних для найменувань організацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '150', 'a', 1, 0, 'Найменування оброблюваних даних', 'Найменування оброблюваних даних', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '152', '', '', 'Коди правил каталогізації і системи предметизації', 'Коди правил каталогізації і системи предметизації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '152', 'a', 0, 0, 'Правила каталогізації', 'Правила каталогізації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '152', 'b', 0, 0, 'Система предметизації', 'Система предметизації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '154', '', '', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', 'Поле кодованих даних для уніфікованих заголовків (попереднє)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '154', 'a', 1, 0, 'Дані обробки заголовка', 'Дані обробки заголовка', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '160', '', '', 'Код географічного регіону', 'Код географічного регіону', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '160', 'a', 1, 1, 'Код географічного регіону', 'Код географічного регіону', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '200', '', 1, 'Заголовок — ім’я особи', 'Заголовок — ім’я особи', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '200', '4', 0, 1, 'Код відносин', 'Код відносин',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', '8', 0, 0, 'Мова заголовка', 'Мова заголовка',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'a', 1, 0, 'Початковий елемент введення', 'Початковий елемент введення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'b', 0, 0, 'Частина імені, окрім початкового елементу введення', 'Частина імені, окрім початкового елементу введення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'c', 0, 0, 'Ідентифікуючі ознаки (окрім дат)', 'Ідентифікуючі ознаки (окрім дат)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'd', 0, 0, 'Римські цифри', 'Римські цифри',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'f', 0, 0, 'Дати', 'Дати',                             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'g', 0, 0, 'Розкриття ініціалів імені особи', 'Розкриття ініціалів імені особи', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'j', 0, 1, 'Підзаголовок форми', 'Підзаголовок форми', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'x', 0, 1, 'Тематичний підзаголовок', 'Тематичний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'y', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '200', 'z', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '210', '', 1, 'Заголовок — найменування організації', 'Заголовок — найменування організації', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '210', '4', 0, 1, 'Код відносин', 'Код відносин',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', '7', 0, 0, 'Графіка заголовка', 'Графіка заголовка',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', '8', 0, 0, 'Мова заголовка', 'Мова заголовка',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'a', 1, 0, 'Початковий елемент введення', 'Початковий елемент введення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'b', 0, 1, 'Структурний підрозділ', 'Структурний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'c', 0, 1, 'Ідентифікуюча ознака', 'Ідентифікуюча ознака', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'd', 0, 0, 'Номер тимчасової організації (заходи) і/або номер її частини', 'Номер тимчасової організації (заходи) і/або номер її частини', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'e', 0, 0, 'Місце проведення тимчасової організації (заходи)', 'Місце проведення тимчасової організації (заходи)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'f', 0, 0, 'Дата проведення тимчасової організації (заходи)', 'Дата проведення тимчасової організації (заходи)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'g', 0, 0, 'Інверсований елемент', 'Інверсований елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'h', 0, 0, 'Частина найменування, відмінна від початкового елементу введення та інверсованого елементу', 'Частина найменування, відмінна від початкового елементу введення та інверсованого елементу', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'x', 0, 1, 'Тематичний підзаголовок', 'Тематичний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'y', 0, 1, 'Географічний підзаголовок', 'Географічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '210', 'z', 0, 1, 'Хронологічний підзаголовок', 'Хронологічний підзаголовок', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '215', '', 1, 'Заголовок — географічна назва', 'Заголовок — географічна назва', '');

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '230', '', 1, 'Заголовок — уніфікований заголовок', 'Заголовок — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '230', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', '8', 0, 0, 'Мова каталогізації і мова базового заголовка', 'Мова каталогізації і мова базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'a', 1, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'b', 0, 1, 'Загальне матеріальне позначення', 'Загальне матеріальне позначення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'h', 0, 1, 'Число секцій або частин', 'Число секцій або частин', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'i', 0, 1, 'Ім’я секції або частини', 'Ім’я секції або частини', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'k', 0, 0, 'Дата публікації', 'Дата публікації',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'l', 0, 0, 'Форма підзаголовка', 'Форма підзаголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'm', 0, 0, 'Мова (коли частина заголовка)', 'Мова (коли частина заголовка)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'q', 0, 0, 'Версія (або дата версії)', 'Версія (або дата версії)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'r', 0, 1, 'Засіб роботи (для музики)', 'Засіб роботи (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 's', 0, 1, 'Числове позначення (для музики)', 'Числове позначення (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'u', 0, 0, 'Клавіша (для музики)', 'Клавіша (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'w', 0, 0, 'Впорядкована інструкція (для музики)', 'Впорядкована інструкція (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '230', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '240', '', 1, 'Заголовок — ім’я/заголовок', 'Заголовок — ім’я/заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '240', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', '8', 0, 0, 'Мова каталогізації і мова базового заголовка', 'Мова каталогізації і мова базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'a', 1, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'b', 0, 0, 'Prénom', '',                               0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'c', 0, 0, 'Qualificatifs', '',                        0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'f', 0, 0, 'Dates', '',                                0, 0, NULL, '', NULL, NULL, '', 0),
 ('', '', '240', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 't', 1, 0, 'Заголовок', 'Заголовок',                   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '240', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '250', '', 1, 'Заголовок — тематична наочна рубрика', 'Заголовок — тематична наочна рубрика', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '250', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', '8', 0, 0, 'Мова каталогізації і мова базового заголовка', 'Мова каталогізації і мова базового заголовка', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', 'a', 1, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', 'b', 0, 0, 'Statut', '',                               0, 0, NULL, 'CAND', '', NULL, '', 0),
 ('', '', '250', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '250', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '300', '', 1, 'Довідкова примітка', 'Довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '300', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '300', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '300', 'a', 1, 0, 'Текст довідки', 'Текст довідки',           0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '305', '', 1, 'Посилальна примітка „див. також“', 'Посилальна примітка „див. також“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '305', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '305', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '305', 'a', 1, 1, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '305', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '310', '', 1, 'Посилальна примітка „див.“', 'Посилальна примітка „див.“', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '310', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '310', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '310', 'a', 0, 0, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '310', 'b', 0, 1, 'Заголовок, до якого робиться посилання', 'Заголовок, до якого робиться посилання', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '320', '', 1, 'Загальна довідкова примітка', 'Загальна довідкова примітка', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '320', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '320', 'a', 1, 1, 'Текст примітка', 'Текст примітка',         0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '330', '', 1, 'Примітка про область застосування', 'Примітка про область застосування', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '330', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '330', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '330', 'a', 1, 0, 'Примітка про область застосування', 'Примітка про область застосування', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '340', '', 1, 'Біографія та примітка про діяльність', 'Біографія та примітка про діяльність', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '340', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '340', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '340', 'a', 1, 0, 'Примітка біографічна чи про діяльність', 'Примітка біографічна чи про діяльність', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '356', 1, '', 'Географічні примітки', 'Географічні примітки', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '356', '6', 0, 0, 'Міжполе, що зв’язує дані', 'Міжполе, що зв’язує дані', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '356', '7', 0, 0, 'Сценарій каталогізації і сценарій базового заголовка', 'Сценарій каталогізації і сценарій базового заголовка', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '356', 'a', 0, 0, 'Географічна примітка', 'Географічна примітка', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '400', '', 1, 'Формування посилання „див.“ — ім’я особи', 'Формування посилання „див.“ — ім’я особи', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '400', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'b', 0, 0, 'Частина імені окрім елементу входу', 'Частина імені окрім елементу входу', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'c', 0, 0, 'Додавання іменам окрім дат', 'Додавання іменам окрім дат', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'd', 0, 0, 'Римські цифри', 'Римські цифри',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'f', 0, 0, 'Дати', 'Дати',                             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'g', 0, 0, 'Розширення ініціалів імені', 'Розширення ініціалів імені', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '400', 'z', 0, 0, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '410', '', 1, 'Формування посилання „див.“ — найменування організації', 'Формування посилання „див.“ — найменування організації', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '410', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'd', 0, 0, 'Число зустрічей і/або число частини зустрічей', 'Число зустрічей і/або число частини зустрічей', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '410', 'z', 0, 0, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '415', '', 1, 'Формування посилання „див.“ — географічна назва', 'Формування посилання „див.“ — географічна назва', '');

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '430', '', 1, 'Формування посилання „див.“ — уніфікований заголовок', 'Формування посилання „див.“ — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '430', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'b', 0, 1, 'Загальне матеріальне позначення', 'Загальне матеріальне позначення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'h', 0, 1, 'Число секцій або частин', 'Число секцій або частин', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'i', 0, 1, 'Ім’я секції або частини', 'Ім’я секції або частини', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'k', 0, 0, 'Дата публікації', 'Дата публікації',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'l', 0, 0, 'Підзаголовок форми', 'Підзаголовок форми', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'm', 0, 0, 'Мова (коли частина заголовка)', 'Мова (коли частина заголовка)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'n', 0, 1, 'Змішана інформація', 'Змішана інформація', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'q', 0, 0, 'Версія (або дата версії)', 'Версія (або дата версії)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'r', 0, 1, 'Засіб роботи (для музики)', 'Засіб роботи (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 's', 0, 1, 'Числове позначення (для музики)', 'Числове позначення (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'u', 0, 0, 'Клавіша (для музики)', 'Клавіша (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'w', 0, 0, 'Впорядкована інструкція (для музики)', 'Впорядкована інструкція (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '430', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '440', '0', 0, 0, 'Командна фраза', 'Командна фраза',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'b', 0, 0, 'Prénom', '',                               0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'c', 0, 0, 'qualificatif', '',                         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'd', 0, 0, 'numérotation (chiffres romains)', '',      0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'f', 0, 0, 'Dates', '',                                0, 0, NULL, '', NULL, NULL, '', 0),
 ('', '', '440', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 't', 0, 0, 'Заголовок', 'Заголовок',                   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '440', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '450', '', 1, 'Формування посилання „див.“ — тематична наочна рубрика', 'Формування посилання „див.“ — тематична наочна рубрика', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '450', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '450', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '500', '', 1, 'Формування посилання „див. також“ — ім’я особи', 'Формування посилання „див. також“ — ім’я особи', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '500', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'b', 0, 0, 'Частина імені окрім елементу входу', 'Частина імені окрім елементу входу', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'c', 0, 1, 'Додавання іменам окрім дат', 'Додавання іменам окрім дат', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'd', 0, 0, 'Римські цифри', 'Римські цифри',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'f', 0, 0, 'Дати', 'Дати',                             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'g', 0, 0, 'Розширення ініціалів імені', 'Розширення ініціалів імені', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '500', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '510', '', 1, 'Формування посилання „див. також“ — найменування організації', 'Формування посилання „див. також“ — найменування організації', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '510', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'd', 0, 0, 'Число зустрічі і/або число частини зустрічі', 'Число зустрічі і/або число частини зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '510', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '515', '', 1, 'Формування посилання „див. також“ — географічна назва', 'Формування посилання „див. також“ — географічна назва', NULL);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '530', '', 1, 'Формування посилання „див. також“ — уніфікований заголовок', 'Формування посилання „див. також“ — уніфікований заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '530', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'b', 0, 1, 'Загальне матеріальне позначення', 'Загальне матеріальне позначення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'h', 0, 1, 'Число секцій або частин', 'Число секцій або частин', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'i', 0, 1, 'Ім’я секції або частини', 'Ім’я секції або частини', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'k', 0, 0, 'Дата публікації', 'Дата публікації',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'l', 0, 0, 'Підзаголовок форми', 'Підзаголовок форми', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'm', 0, 0, 'Мова (коли частина заголовка)', 'Мова (коли частина заголовка)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'n', 0, 1, 'Змішана інформація', 'Змішана інформація', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'q', 0, 0, 'Версія (або дата версії)', 'Версія (або дата версії)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'r', 0, 1, 'Засіб роботи (для музики)', 'Засіб роботи (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 's', 0, 1, 'Числове позначення (для музики)', 'Числове позначення (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'u', 0, 0, 'Клавіша (для музики)', 'Клавіша (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'w', 0, 0, 'Впорядкована інструкція (для музики)', 'Впорядкована інструкція (для музики)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '530', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '540', '', 1, 'Формування посилання „див. також“ — ім’я/заголовок', 'Формування посилання „див. також“ — ім’я/заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '540', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 't', 0, 0, 'Заголовок', 'Заголовок',                   0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '540', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '550', '', 1, 'Формування посилання „див. також“ — тематична наочна рубрика', 'Формування посилання „див. також“ — тематична наочна рубрика', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '550', '0', 0, 0, 'Текст пояснення', 'Текст пояснення',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '5', 0, 0, 'Управління формуванням посилань (контроль трасування)', 'Управління формуванням посилань (контроль трасування)', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '6', 0, 0, 'Дані для зв’язку полів', 'Дані для зв’язку полів', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '550', 'z', 0, 1, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '675', '', 1, 'Універсальна десяткова класифікація (УДК)', 'Універсальна десяткова класифікація (УДК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '675', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '675', 'a', 0, 0, 'Індекс УДК, окремий або початковий в ряду', 'Індекс УДК, окремий або початковий в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '675', 'b', 1, 0, 'Індекси УДК, останній в ряду', 'Індекси УДК, останній в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '675', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '675', 'v', 0, 0, 'Відомості про видання УДК', 'Відомості про видання УДК', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '675', 'z', 0, 0, 'Мова видання', 'Мова видання',             0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '676', '', 1, 'Десяткова класифікація Дьюї (ДК Дьюї)', 'Десяткова класифікація Дьюї (ДК Дьюї)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '676', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '676', 'a', 0, 0, 'Індекс ДК Дьюї, окремий або початковий в ряду', 'Індекс ДК Дьюї, окремий або початковий в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '676', 'b', 1, 0, 'Індекс ДК Дьюї, кінцевий в ряду', 'Індекс ДК Дьюї, кінцевий в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '676', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '676', 'v', 0, 0, 'Зведення про видання Десяткової класифікації Дьюї', 'Зведення про видання Десяткової класифікації Дьюї', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '676', 'z', 0, 0, 'Мова видання', 'Мова видання',             0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '680', '', 1, 'Класифікація Бібліотеки Конгресу (КБК)', 'Класифікація Бібліотеки Конгресу (КБК)', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '680', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '680', 'a', 0, 0, 'Індекс КБК, окремий або початковий в ряду', 'Індекс КБК, окремий або початковий в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '680', 'b', 1, 0, 'Індекси КБК, останній в ряду', 'Індекси КБК, останній в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '680', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',       0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '686', '', 1, 'Індекси інших класифікацій', 'Індекси інших класифікацій', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '686', '3', 0, 0, 'Зв’язок з форматом класифікації', 'Зв’язок з форматом класифікації', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '686', 'a', 0, 0, 'Індекс, окремий або початковий в ряду', 'Індекс, окремий або початковий в ряду', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '686', 'b', 1, 0, 'Індекс, кінцевий в послідовності', 'Індекс, кінцевий в послідовності', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '686', 'c', 1, 0, 'Пояснюючі слова', 'Пояснюючі слова',       0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '710', '', 1, 'Зв’язаний заголовок — найменування організації', 'Зв’язаний заголовок — найменування організації', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '710', '2', 0, 0, 'Код системи предметизації', 'Код системи предметизації', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', '3', 0, 0, 'Номер запису', 'Номер запису',             0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', '4', 0, 1, 'Код знаку відношення', 'Код знаку відношення', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', '7', 0, 0, 'Графіка', 'Графіка',                       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', '8', 0, 0, 'Мова заголовку', 'Мова заголовку',         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'a', 0, 0, 'Елемент входження', 'Елемент входження',   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'b', 0, 1, 'Підрозділ', 'Підрозділ',                   0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'c', 0, 1, 'Додавання імені або визначникові', 'Додавання імені або визначникові', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'd', 0, 0, 'Число зустрічі і/або число частини зустрічі', 'Число зустрічі і/або число частини зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'e', 0, 0, 'Розташування зустрічі', 'Розташування зустрічі', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'f', 0, 0, 'Дата зустрічі', 'Дата зустрічі',           0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'g', 0, 0, 'Перевернутий елемент', 'Перевернутий елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'h', 0, 0, 'Частина імені окрім елементу входу і перевернув елемент', 'Частина імені окрім елементу входу і перевернув елемент', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'j', 0, 1, 'Підрозділ форми', 'Підрозділ форми',       0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'x', 0, 1, 'Актуальний підрозділ', 'Актуальний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'y', 0, 1, 'Географічний підрозділ', 'Географічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '710', 'z', 0, 0, 'Хронологічний підрозділ', 'Хронологічний підрозділ', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '801', 1, 1, 'Джерело запису', 'Джерело запису', '');
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '801', 'a', 0, 0, 'Країна', 'Країна',                         0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '801', 'b', 0, 0, 'Організація', 'Організація',               0, 0, NULL, '', '', NULL, '', 0),
 ('', '', '801', 'c', 0, 0, 'Дата введення або останнього редагування запису', 'Дата введення або останнього редагування запису', 0, 0, NULL, '', '', NULL, '', 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '810', '', 1, 'Джерело, в якому виявлена інформація про заголовок', 'Джерело, в якому виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '810', 'a', 0, 0, 'Назва джерела', 'Назва джерела',           0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '810', 'b', 0, 0, 'Знайдена інформація', 'Знайдена інформація', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '815', '', '', 'Джерело, в якому не виявлена інформація про заголовок', 'Джерело, в якому не виявлена інформація про заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '815', 'a', 1, 1, 'Назва джерела', 'Назва джерела',           0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '820', '', 1, 'Інформація про використання заголовка в полі 2--', 'Інформація про використання заголовка в полі 2--', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '820', 'a', 1, 1, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '825', '', 1, 'Приклад, приведений в примітці', 'Приклад, приведений в примітці', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '825', 'a', 1, 0, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '830', '', 1, 'Загальна примітка каталогізатора', 'Загальна примітка каталогізатора', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '830', 'a', 0, 1, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '835', '', 1, 'Інформація про виключений заголовок', 'Інформація про виключений заголовок', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '835', 'a', 0, 1, 'Текст примітки', 'Текст примітки',         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '835', 'b', 1, 0, 'Заголовок, на який замінений виключений', 'Заголовок, на який замінений виключений', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '835', 'd', 1, 0, 'Дата транзакції', 'Дата транзакції',       0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '836', '', 1, 'Замінена інформація заголовку', 'Замінена інформація заголовку', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '836', 'b', 0, 0, 'Замінено заголовок', 'Замінено заголовок', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '836', 'd', 0, 0, 'Дата транзакції', 'Дата транзакції',       0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '856', '', 1, 'Електронічне розташування та доступ', 'Електронічне розташування та доступ', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '856', 'a', 0, 1, 'Ім’я сервера', 'Ім’я сервера',             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'b', 0, 1, 'Номер доступу', 'Номер доступу',           0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'c', 0, 1, 'Інформація про компресію', 'Інформація про компресію', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'd', 0, 1, 'Шлях', 'Шлях',                             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'e', 0, 0, 'Дата і година консультацій та доступу', 'Дата і година консультацій та доступу', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'f', 0, 1, 'Електронічне ім’я', 'Електронічне ім’я',   0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'g', 1, 0, 'Загальноприйняте ім’я ресурсу (URN)', 'Загальноприйняте ім’я ресурсу (URN)', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'h', 0, 0, 'Процесор запиту', 'Процесор запиту',       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'i', 0, 1, 'Команда', 'Команда',                       0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'j', 0, 0, 'Біт на секунду', 'Біт на секунду',         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'k', 0, 0, 'Пароль', 'Пароль',                         0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'l', 0, 0, 'Вхід/логін сеансу', 'Вхід/логін сеансу',   0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'm', 0, 1, 'Контакт для допомоги доступу', 'Контакт для допомоги доступу', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'n', 0, 0, 'Ім’я розташування вузла в підполі $a', 'Ім’я розташування вузла в підполі $a', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'o', 0, 0, 'Операційна система', 'Операційна система', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'p', 0, 0, 'Порт', 'Порт',                             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'q', 0, 0, 'Електронічний тип формату', 'Електронічний тип формату', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'r', 0, 0, 'Налаштування', 'Налаштування',             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 's', 0, 1, 'Розмір файлу', 'Розмір файлу',             0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 't', 0, 1, 'Емуляція терміналу', 'Емуляція терміналу', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'u', 0, 0, 'Загальноприйняте розміщення ресурсу (URL)', 'Загальноприйняте розміщення ресурсу (URL)', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'v', 0, 1, 'Години доступності електронічного ресурсу', 'Години доступності електронічного ресурсу', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'w', 0, 1, 'Контрольний номер запису', 'Контрольний номер запису', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'x', 1, 0, 'Непублікована примітка', 'Непублікована примітка', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',           0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '856', 'z', 0, 1, 'Загальна примітка', 'Загальна примітка',   0, 0, NULL, NULL, NULL, NULL, NULL, 0);

INSERT INTO auth_tag_structure  (authtypecode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '886', '', 1, 'Дані, не конвертовані з початкового Формату', 'Дані, не конвертовані з початкового Формату', NULL);
INSERT INTO  auth_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, linkid) VALUES
 ('', '', '886', '2', 0, 0, 'Системний код', 'Системний код',           0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '886', 'a', 0, 1, 'Тег поля початкового формату', 'Тег поля початкового формату', 0, 0, NULL, NULL, NULL, NULL, NULL, 0),
 ('', '', '886', 'b', 0, 1, 'Індикатори та підполя поля початкового формату', 'Індикатори та підполя поля початкового формату', 0, 0, NULL, NULL, NULL, NULL, NULL, 0);

-- Replace nonzero hidden values like -5, 1 or 8 by 1
UPDATE auth_subfield_structure SET hidden=1 WHERE hidden<>0
