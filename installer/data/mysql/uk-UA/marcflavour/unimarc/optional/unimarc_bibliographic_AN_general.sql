# **************************************************************************
#             UKRMARC - UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC
#           СТРУКТУРА KOHA УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# version 0.8 (5.1.2011) - reformating by script csv2marc_structures.pl, exrtact local data to separate file
# version 0.6 (29.3.2009) - виділення блоків полів з підполями (для полегшення керування та клонування)
#
# Serhij Dubyk (Сергієм Дубиком), serhijdubyk@gmail.com, 2009,2010,2011
#
#   SOURCE FROM:
#
# 1) UKRMARC - Ukrainian UNIMARC for bibliographic
# УкрМарк - український UniMarc для бібліографічних записів
# http://www.library.lviv.ua/e-library/library_standarts/UkrMarc/, 2010
# http://www.nbuv.gov.ua/library/ukrmarc.html, 2004
#
# 2) UNIMARC manual : bibliographic format 1994 / IFLA Universal
#  Bibliographic Control and International MARC Core Programme (UBCIM). -
#  "The following list represents the state of the format as at 1 March
#  2000.  It includes the changes published in Update 3." -
#  http://www.ifla.org/VI/3/p1996-1/sec-uni.htm.
#  2006-03-15 a;
#
# 3) UNIMARC manual: bibliographic format / IFLA UNIMARC Core Activity; ed. By Alan Hopkinson.
#  3rd ed. - München: Saur, 2008. (IFLA Series in Bibliographic Control, 36).
#  ISBN 978-3-598-24284-7, 760 p.
#  http://www.ifla.org/VI/8/unimarc-concise-bibliographic-format-2008.pdf
# **************************************************************************

DELETE FROM biblio_framework WHERE frameworkcode='AN';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('AN', 'аналітичний опис');
DELETE FROM marc_tag_structure WHERE frameworkcode='AN';
DELETE FROM marc_subfield_structure WHERE frameworkcode='AN';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '000', '@', 0, 0, 'Контрольне поле фіксованої довжини', '', 0, 1, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',       3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '005', '', '', 'Ідентифікатор версії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '005', '@', 0, 0, 'Контрольне поле', '',                    0, 1, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '014', '', 1, 'Ідентифікатор статті', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '014', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '014', 'a', 0, 0, 'Ідентифікатор статті', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '014', 'z', 1, 0, 'Помилковий ідентифікатор статті', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',             3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'g', 0, 0, 'Мова основної назви', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '102', 'a', 0, 0, 'Країна публікації', '',                  1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('AN', '', '102', 'b', 0, 0, 'Місце публікації', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '105', '', '', 'Поле кодованих даних: текстові матеріали (монографічні)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '105', 'a', 0, 0, 'Кодовані дані про монографію', '',       3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '110', '', '', 'Кодовані дані: серіальні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '110', 'a', 0, 0, 'Кодовані дані про серіальне видання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '200', '5', 0, 1, 'Організація – власник примірника', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'a', 1, 1, 'Основна назва', '',                      0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'd', 0, 0, 'Паралельна назва', '',                   0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'e', 0, 1, 'Підзаголовок', '',                       0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',    0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'i', 0, 0, 'Найменування частини', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'v', 0, 0, 'Позначення тому', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('AN', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'e', 0, 0, 'Місце виробництва', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'f', 1, 0, 'Адреса виробника', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '210', 'h', 1, 0, 'Дата виробництва', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '225', 'a', 0, 0, 'Назва серії', '',                        1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('AN', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'e', 0, 0, 'Підзаголовок', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'h', 0, 0, 'Номер частини', '',                      -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'i', 0, 0, 'Найменування частини', '',               1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'v', 0, 0, 'Визначення тому', '',                    1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'x', 0, 0, 'ISSN серії', '',                         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '300', 'a', 0, 0, 'Текст примітки', '',                     1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '301', '', 1, 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '301', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '302', '', 1, 'Примітки, що відносяться до кодованої інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '302', 'a', 0, 0, 'Текст примітки', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '320', '', 1, 'примітка про наявність бібліографії/покажчиків', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '320', 'a', 0, 0, 'Текст примітки', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '321', '', 1, 'Примітка про видані окремо покажчики, реферати, посилання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '321', 'a', 0, 0, 'Примітка про покажчики, реферати, посилання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '321', 'b', 0, 0, 'Дати обсягу', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '321', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '327', 'a', 0, 0, 'Текст примітки', '',                     1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '330', '', 1, 'Короткий звіт або резюме', 'Короткий зміст', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '330', 'a', 0, 0, 'Текст примітки', '',                     1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '410', '', 1, 'Серії (поле зв’язку)', 'Серії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '410', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '410', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', '5', 0, 0, 'Установа в якій поле застосовано', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', '@', 0, 0, 'номер ідентифікації примітки', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'a', 0, 0, 'Автор', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'c', 0, 0, 'Місце публікації', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'd', 0, 0, 'Дата публікації', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'e', 0, 0, 'Відомості про видання', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'h', 0, 0, 'Номер розділу або частини', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'i', 0, 0, 'Назва розділу або частини', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'p', 0, 0, 'Фізичний опис', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 't', 0, 0, 'Назва', '',                              1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'u', 0, 0, 'URL', '',                                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'v', 0, 0, 'Номер тому', '',                         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '410', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '411', '', 1, 'Підсерії', 'Підсерії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '411', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '411', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '411', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '411', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '411', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '421', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '422', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '423', '', 1, 'Видано з', 'Видано з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '423', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '423', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '423', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '423', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '423', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '430', '', 1, 'Продовжується', 'Продовжується', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '430', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '430', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '430', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '430', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '430', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '431', '', 1, 'Продовжується в частково', 'Продовжується в частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '431', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '431', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '431', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '431', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '431', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '432', '', 1, 'Заміщує', 'Заміщує', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '432', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '432', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '432', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '432', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '432', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '433', '', 1, 'Заміщує в частково', 'Заміщує в частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '433', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '433', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '433', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '433', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '433', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '434', '', 1, 'Поглинуте', 'Поглинуте', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '434', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '434', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '434', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '434', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '434', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '435', '', 1, 'Поглинене частково', 'Поглинене частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '435', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '435', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '435', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '435', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '435', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '436', '', 1, 'Утворене злиттям ..., ..., та ...', 'Утворене злиттям ..., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '436', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '436', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '436', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '436', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '436', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '437', '', 1, 'Відокремилось від…', 'Відокремилось від…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '437', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '437', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '437', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '437', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '437', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '440', '', 1, 'Продовжено як', 'Продовжено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '440', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '440', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '440', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '440', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '440', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '441', '', 1, 'Продовжено частково', 'Продовжено частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '441', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '441', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '441', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '441', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '441', 'z', 0, 0, 'CODEN+', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '442', '', 1, 'Заміщене', 'Заміщене', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '442', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '442', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '442', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '442', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '442', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '443', '', 1, 'Заміщено частково', 'Заміщено частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '443', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '443', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '443', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '443', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '443', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '444', '', 1, 'Те, що поглинуло', 'Те, що поглинуло', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '444', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '444', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '444', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '444', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '444', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '445', '', 1, 'Те, що поглинуло частково', 'Те, що поглинуло частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '445', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '445', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '445', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '445', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '445', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '446', '', 1, 'Поділилося на .., ..., та ...', 'Поділилося на .., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '446', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '446', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '446', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '446', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '446', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '447', '', 1, 'Злито з ... та ... щоб утворити ...', 'Злито з ... та ... щоб утворити ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '447', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '447', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '447', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '447', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '447', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '448', '', 1, 'Повернулося до попередньої назви', 'Повернулося до попередньої назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '448', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '448', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '448', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '448', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '448', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '451', '', 1, 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '451', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '451', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '451', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '451', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '451', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '452', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '453', '', 1, 'Перекладено як', 'Перекладено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '453', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '453', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '453', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '453', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '453', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '454', '', 1, 'Перекладено з…', 'Перекладено з…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '454', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '454', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', '5', 0, 0, 'Установа в якій поле застосовано', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', '@', 0, 0, 'номер ідентифікації примітки', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'a', 0, 0, 'Автор', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'c', 0, 0, 'Місце публікації', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'd', 0, 0, 'Дата публікації', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'e', 0, 0, 'Відомості про видання', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'h', 0, 0, 'Номер розділу або частини', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'i', 0, 0, 'Назва розділу або частини', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'p', 0, 0, 'Фізичний опис', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 't', 0, 0, 'Назва', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'u', 0, 0, 'URL', '',                                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'v', 0, 0, 'Номер тому', '',                         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '454', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '455', '', 1, 'Відтворено з…', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '455', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '455', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '455', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '455', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '455', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '456', '', 1, 'Відтворено як', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '456', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '456', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '456', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '456', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '456', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '',   -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'a', 0, 0, 'Автор', '',                              1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'c', 0, 0, 'Місце публікації', '',                   1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'd', 0, 0, 'Дата публікації', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'e', 0, 0, 'Відомості про видання', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'p', 0, 0, 'Фізичний опис', '',                      -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 't', 0, 0, 'Назва', '',                              1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'u', 0, 0, 'URL', '',                                -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '461', 'v', 0, 0, 'Номер тому', '',                         1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', 1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '461', 'z', 0, 0, 'CODEN', '',                              -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '462', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '463', '', 1, 'Окрема фізична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '463', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', '5', 0, 0, 'Установа в якій поле застосовано', '',   -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'a', 0, 0, 'Автор', '',                              1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'c', 0, 0, 'Місце публікації', '',                   1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'd', 0, 0, 'Дата публікації', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'e', 0, 0, 'Відомості про видання', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'h', 0, 0, 'Номер розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'i', 0, 0, 'Назва розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'p', 0, 0, 'Фізичний опис', '',                      -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 't', 0, 0, 'Назва', '',                              1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'u', 0, 0, 'URL', '',                                -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '463', 'v', 0, 0, 'Номер тому', '',                         1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', 1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 1, 0, '', '', 'unimarc_field_4XX.pl', 0, NULL, '', ''),
 ('AN', '', '463', 'z', 0, 0, 'CODEN', '',                              -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '464', '', 1, 'Аналітична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '464', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '464', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '464', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '464', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '464', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '470', '', 1, 'Документ, що є предметом огляду/рецензії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '470', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '470', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '470', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '470', 'y', 0, 0, 'IМіжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '470', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '481', '', 1, 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '481', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '481', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '481', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '481', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '481', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '482', '', 1, 'Переплетено з', 'Переплетено з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '482', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '482', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '482', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '482', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '482', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', '', '488', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '510', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'a', 0, 0, 'Паралельна назва', '',                   0, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'e', 1, 0, 'Інша інформація щодо назви', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'h', 1, 0, 'Номер частини', '',                      -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'i', 1, 0, 'Найменування частини', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'n', 0, 0, 'Різна інформація', '',                   -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'v', 0, 0, 'Визначення тому', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '510', 'z', 0, 0, 'Мова назви', '',                         0, 0, '', 'LANG', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '532', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'a', 0, 0, 'Розширена назва', '',                    0, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'n', 0, 0, 'Змішана інформація', '',                 -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'v', 0, 0, 'Визначення тому', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '532', 'z', 0, 0, 'Мова назви', '',                         0, 0, '', 'LANG', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '541', '', 1, 'Перекладена назва складена каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '541', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'a', 0, 0, 'Перекладена назва', '',                  0, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'e', 0, 0, 'Інші відомості щодо назви', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'h', 0, 0, 'Нумерація частини', '',                  -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'i', 0, 0, 'Найменування частини', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'n', 0, 0, 'Змішана інформація', '',                 -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'v', 0, 0, 'Визначення тому', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'y', 0, 0, 'Географічний підрозділ', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '541', 'z', 0, 0, 'Мова перекладеної назви', '',            0, 0, '', 'LANG', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '545', '', 1, 'Назва розділу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '545', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'a', 0, 0, 'Назва розділу', '',                      0, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     0, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'n', 0, 0, 'Змішана інформація', '',                 -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'v', 0, 0, 'Визначення тому', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'y', 0, 0, 'Географічний підрозділ', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '545', 'z', 0, 0, 'Хронологічний підрозділ', '',            -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '600', '', 1, 'Ім’я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '600', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', 1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '',     -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'd', 0, 0, 'Римські цифри', '',                      -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'f', 0, 0, 'Дати', '',                               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'j', 1, 0, 'Формальний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'p', 1, 0, 'Установа/адреса', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'x', 1, 0, 'Тематичний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'y', 1, 0, 'Географічний підзаголовок', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',         -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '601', '', 1, 'Найменування колективу як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '601', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', 1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'b', 1, 0, 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'c', 1, 0, 'Доповнення до найменування або уточнення', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'd', 0, 0, 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'e', 0, 0, 'Місце знаходження тимчасового колективу', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'f', 0, 0, 'Дати існування тимчасового колективу', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'g', 0, 0, 'Інверсований елемент', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'h', 0, 0, 'Частина найменування, що відрізняється від початкового елемента заголовку рубрики й інверсованого елемента', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'j', 1, 0, 'Формальна підрубрика', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'x', 1, 0, 'Тематична підрубрика', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'y', 0, 0, 'Географічна підрубрика', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '601', 'z', 0, 0, 'Хронологічна підрубрика', '',            -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '602', '', 1, 'Родове ім’я як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '602', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', 1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'f', 0, 0, 'Дати', '',                               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'j', 1, 0, 'Формальна підрубрика', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'x', 1, 0, 'Тематична підрубрика', '',               -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'y', 0, 0, 'Географічна підрубрика', '',             -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '602', 'z', 0, 0, 'Хронологічна підрубрика', '',            -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '604', '', 1, 'Автор і назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '604', '1', 1, 0, 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', 1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '605', '', 1, 'Назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '605', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',           1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'h', 1, 0, 'Номер розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'i', 1, 0, 'Назва розділу або частини', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'j', 0, 0, 'Формальний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'k', 0, 0, 'Дата публікації', '',                    -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'm', 0, 0, 'Мова (як частина предметної рубрики)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'n', 1, 0, 'Змішана інформація', '',                 -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'r', 1, 0, 'Засоби виконання (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 's', 1, 0, 'Числове визначення (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'u', 1, 0, 'Ключ (для музичних творів)', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'w', 1, 0, 'Відомості про аранжування (для музичних творів)', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'x', 1, 0, 'Тематичний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'y', 1, 0, 'Географічний підзаголовок', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '605', 'z', 1, 0, 'Хронологічний підзаголовок', '',         -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '606', '', 1, 'Найменування теми як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '606', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', 'a', 0, 1, 'Заголовок рубрики', 'Предмет',           1, NULL, 'bibliosubject.subject', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', 'j', 1, 0, 'Формальний підзаголовок', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', 'x', 1, 0, 'Тематичний підзаголовок', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', 'y', 1, 0, 'Географічний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '606', 'z', 1, 0, 'Хронологічний підзаголовок', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '607', '', 1, 'Географічна назіва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '607', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',           1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', 'j', 1, 0, 'Формальний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', 'x', 1, 0, 'Тематичний підзаголовок', '',            -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', 'y', 1, 0, 'Географічний підзаголовок', '',          -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '607', 'z', 1, 0, 'Хронологічний підзаголовок', '',         -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '608', '', 1, 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '608', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', '5', 0, 0, 'Організація, до якої застосовується поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', 'a', 0, 0, 'Початковий елемент заголовку', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '608', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '610', '', 1, 'Неконтрольовані предметні терміни', 'Ключові слова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '610', 'a', 0, 1, 'Предметний термін', 'Предмет',           1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '615', '', 1, 'Предметна категорія (попереднє)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '615', '2', 0, 0, 'Код системи', '',                        -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '615', '3', 0, 0, 'Номер авторитетного запису', '',         -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '615', 'a', 0, 0, 'Текст елемента предметної категорій', 'Предмет', 1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '615', 'm', 1, 0, 'Код підрозділу предметної категорії', '', -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '615', 'n', 1, 0, 'Код предметної категорій', '',           -1, 0, '', '', '', 0, NULL, '', ''),
 ('AN', '', '615', 'x', 1, 0, 'Текст підрозділу предметної категорії', '', -1, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '620', 'a', 0, 0, 'Країна', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '620', 'd', 0, 0, 'Місто', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '660', 'a', 0, 0, 'Код', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '661', '', 1, 'Код періоду часу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '661', 'a', 0, 0, 'Код періоду часу', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '675', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '675', 'a', 0, 0, 'Індекс', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '675', 'v', 0, 0, 'Видання', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '675', 'z', 0, 0, 'Мова видання', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '676', 'a', 0, 0, 'Індекс', '',                             -1, NULL, 'biblioitems.dewey', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '676', 'v', 0, 0, 'Видання', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '676', 'z', 0, 0, 'Мова видання', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '680', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '680', 'a', 0, 0, 'Класифікаційний індекс', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('AN', NULL, '680', 'b', 0, 0, 'Книжковий знак', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '686', '2', 0, 0, 'Код системи', '',                        1, 0, '', '', '', 0, '', '', NULL),
 ('AN', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',      -1, 0, '', '', '', 0, '', '', NULL),
 ('AN', '', '686', 'a', 0, 0, 'Індекс класифікації', '',                1, 0, '', '', '', 0, '', '', NULL),
 ('AN', '', '686', 'b', 0, 0, 'Книжковий знак', '',                     -1, 0, '', '', '', 0, '', '', NULL),
 ('AN', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',          -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '700', '', '', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',      7, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',           7, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',           7, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '710', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '711', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('AN', '', '712', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '720', '', '', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '720', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '720', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '721', '', 1, 'Родове ім’я - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '721', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '721', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '722', '', 1, 'Родове ім’я - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '722', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '722', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '722', '5', 1, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '722', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '722', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '801', 'a', 0, 1, 'Країна', '',                             -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('AN', '', '801', 'b', 1, 0, 'Установа', '',                           -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('AN', '', '801', 'c', 0, 0, 'Дата', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('AN', '', '801', 'g', 1, 0, 'Правила каталогізації', '',              -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('AN', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('AN', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
