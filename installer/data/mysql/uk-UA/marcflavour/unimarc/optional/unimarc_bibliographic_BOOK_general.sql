# **************************************************************************
#             UKRMARC - UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC
#           СТРУКТУРА KOHA УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# version 0.8 (5.1.2011) - reformating by script csv2marc_structures.pl, exrtact local data to separate file
# version 0.6 (29.3.2009) - виділення блоків полів з підполями (для полегшення керування та клонування)
#
# Serhij Dubyk (Сергій Дубик), serhijdubyk@gmail.com, 2009,2010,2011
#
#   SOURCE FROM:
#
# 1) UKRMARC - Ukrainian UNIMARC for bibliographic
# УкрМарк - український UniMarc для бібліографічних записів
# http://www.library.lviv.ua/e-library/library_standarts/UkrMarc/, 2010
# http://www.nbuv.gov.ua/library/ukrmarc.html, 2004
#
# 2) UNIMARC manual: bibliographic format / IFLA UNIMARC Core Activity; ed. By Alan Hopkinson.
#  3rd ed. - München: Saur, 2008. (IFLA Series in Bibliographic Control, 36).
#  ISBN 978-3-598-24284-7, 760 p.
#  http://www.ifla.org/VI/8/unimarc-concise-bibliographic-format-2008.pdf
# **************************************************************************

SET FOREIGN_KEY_CHECKS=0;

DELETE FROM biblio_framework WHERE frameworkcode='BOOK';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('BOOK', 'книги (монографічні видання)');
DELETE FROM marc_tag_structure WHERE frameworkcode='BOOK';
DELETE FROM marc_subfield_structure WHERE frameworkcode='BOOK';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '000', 1, '', 'Маркер запису', '', '');
 INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue, maxlength) VALUES
 ('BOOK', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL, 24);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '001', '@', 0, 0, 'Ідентифікатор запису', '',     -1, 1, 'biblio.biblionumber', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '005', '', '', 'Ідентифікатор версії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '005', '@', 0, 0, 'Ідентифікатор версії', '',             0, 1, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                 3, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('BOOK', '', '010', 'b', 0, 0, 'Уточнення', '',                        -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',       3, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                  -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '020', '', 1, 'Номер документа в національній бібліографії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '020', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '020', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '020', 'z', 1, 0, 'Помилковий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '021', '', 1, 'Номер державної реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '021', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '021', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '021', 'z', 1, 0, 'Помилковий номер державної реєстрації', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '022', '', 1, 'Номер публікації органів державної влади', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '022', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '022', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '022', 'z', 1, 0, 'Помилковий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue, maxlength) VALUES
 ('BOOK', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',           3, -1, '', '', 'unimarc_field_100.pl', 0, '', '', NULL, 36);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'g', 0, 0, 'Мова основної назви', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '102', 'a', 0, 0, 'Країна публікації', '',                1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '102', 'b', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '105', '', '', 'Поле кодованих даних: текстові матеріали (монографічні)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '105', 'a', 0, 0, 'Кодовані дані про монографію', '',     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '106', '', '', 'Поле кодованих даних: текстові матеріали — фізичні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '106', 'a', 0, 0, 'Кодовані дані позначення фізичної форми текстових матеріалів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '122', '', 1, 'Поле кодованих даних: період часу, охоплюваний змістом документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '122', 'a', 1, 0, 'Період часу від 9999 до н.е. до теперішнього часу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '130', '', 1, 'Поле кодованих данных: мікроформи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '130', 'a', 1, 0, 'Мікроформа кодовані дані — фізичні характеристики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '200', '5', 0, 0, 'Організація – власник примірника', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'a', 1, 1, 'Основна назва', '',                    0, 0, 'biblio.title', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'b', 0, 1, 'Загальне визначення матеріалу носія інформації', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'c', 0, 1, 'Основна назва твору іншого автора', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'd', 0, 1, 'Паралельна назва', '',                 -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'e', 0, 1, 'Підзаголовок', '',                     0, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'f', 0, 1, 'Перші відомості про відповідальність', '', 0, 0, 'biblio.author', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'g', 0, 1, 'Наступні відомості про відповідальність', '', 0, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'h', 0, 1, 'Позначення та/або номер частини', '',  0, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'i', 0, 1, 'Найменування частини', '',             0, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'v', 0, 1, 'Позначення тому', '',                  0, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '200', 'z', 0, 1, 'Мова паралельної основної назви', '',  -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '205', 'a', 0, 0, 'Відомості про видання', '',            0, 0, 'biblioitems.editionstatement', '', '', 0, '', '', NULL),
 ('BOOK', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',  -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'e', 0, 0, 'Місце виробництва', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'f', 1, 0, 'Адреса виробника', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '210', 'h', 1, 0, 'Дата виробництва', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '215', '', 1, 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '215', 'a', 0, 1, 'Специфічне визначення матеріалу та обсяг документа', '', 1, 0, 'biblioitems.pages', '', '', 0, '', '', NULL),
 ('BOOK', '', '215', 'c', 0, 0, 'Інші уточнення фізичних характеристик', '', 1, 0, 'biblioitems.illus', '', '', 0, '', '', NULL),
 ('BOOK', '', '215', 'd', 0, 1, 'Розміри', '',                          -1, 0, 'biblioitems.size', '', '', 0, '', '', NULL),
 ('BOOK', '', '215', 'e', 0, 1, 'Супроводжувальний матеріал', '',       1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '225', 'a', 0, 0, 'Назва серії', '',                      1, 0, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', 0, '', '', NULL),
 ('BOOK', '', '225', 'd', 0, 1, 'Паралельна назва серії', '',           -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'e', 0, 1, 'Підзаголовок', '',                     -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'f', 0, 1, 'Відомості про відповідальність', '',   -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'h', 0, 1, 'Номер частини', '',                    -1, 0, 'biblioitems.number', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'i', 0, 1, 'Найменування частини', '',             1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'v', 0, 1, 'Визначення тому', '',                  1, 0, 'biblioitems.volume', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'x', 0, 1, 'ISSN серії', '',                       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '225', 'z', 0, 1, 'Мова паралельної назви', '',           -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '300', 'a', 0, 0, 'Текст примітки', '',                   1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '301', '', 1, 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '301', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '302', '', 1, 'Примітки, що відносяться до кодованої інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '302', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '320', '', 1, 'примітка про наявність бібліографії/покажчиків', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '320', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '321', '', 1, 'Примітка про видані окремо покажчики, реферати, посилання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '321', 'a', 0, 0, 'Примітка про покажчики, реферати, посилання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '321', 'b', 0, 0, 'Дати обсягу', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '321', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '324', '', '', 'Примітка про версію оригіналу (факсіміле)', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '324', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '327', 'a', 0, 1, 'Текст примітки', '',                   1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '330', '', 1, 'Короткий звіт або резюме', 'Короткий зміст', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '330', 'a', 0, 0, 'Текст примітки', '',                       1, 0, 'biblio.abstract', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '333', '', 1, 'Примітка про читацьке призначення', 'Приміти про особливості користування та поширення', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '333', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '345', '', '', 'Примітка про відомості щодо комплектування', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '345', 'a', 0, 0, 'Адреса та джерело комплектування/передплати', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '345', 'b', 1, 0, 'Реєстраційний номер документа', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '345', 'c', 1, 0, 'Фізичний носій', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '345', 'd', 1, 0, 'Умови придбання. Ціна документа.', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '421', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '422', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '423', '', 1, 'Видано з', 'Видано з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '423', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '423', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '423', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '423', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '423', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '451', '', 1, 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '451', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '451', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '451', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '451', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '451', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '452', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '453', '', 1, 'Перекладено як', 'Перекладено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '453', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '453', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '453', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '453', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '453', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '454', '', 1, 'Перекладено з…', 'Перекладено з…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '454', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '454', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', '@', 0, 0, 'номер ідентифікації примітки', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '454', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '455', '', 1, 'Відтворено з…', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '455', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '455', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '455', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '455', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '455', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '456', '', 1, 'Відтворено як', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '456', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '456', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '456', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '456', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '456', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '461', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '462', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '464', '', 1, 'Аналітична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '464', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '464', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '464', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '464', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '464', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '481', '', 1, 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '481', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '481', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '481', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '481', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '481', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '482', '', 1, 'Переплетено з', 'Переплетено з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '482', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '482', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '482', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '482', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '482', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '488', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '500', '', 1, 'Уніфікована форма назви', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '500', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'a', 0, 0, 'Уніфікована форма назви', 'Назва',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '500', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '501', '', 1, 'Загальна уніфікована назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '501', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'a', 0, 0, 'Типова назва', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'b', 1, 0, 'Загальне визначення матеріалу', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'e', 0, 0, 'Типова підназва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '501', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '501', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'j', 0, 0, 'Підрозділ форми', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'm', 0, 0, 'Мова (якщо є частиною заголовку)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'r', 1, 0, 'Засоби виконання музичних творів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 's', 1, 0, 'Порядкове визначення  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'u', 0, 0, 'Ключ  музичного твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'w', 0, 0, 'Відомості про аранжування  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'x', 1, 0, 'Тематичний підрозділ', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'y', 1, 0, 'Географічний підрозділ', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '501', 'z', 1, 0, 'Хронологічний підрозділ', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '510', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'a', 0, 0, 'Паралельна назва', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'n', 0, 0, 'Різна інформація', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '510', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '512', '', 1, 'Назва обкладинки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '512', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'a', 0, 0, 'Назва обкладинки', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'e', 1, 0, 'Інші відомості щодо назви обкладинки', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '512', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '512', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '513', '', 1, 'Назва на додатковому титульному аркуші', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '513', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'a', 0, 0, 'Назва додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'e', 1, 0, 'Інші відомості щодо назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '513', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '513', 'z', 0, 0, 'Мова назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '514', '', 1, 'Назва на першій сторінці тексту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '514', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'a', 0, 0, 'Назва перед текстом', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '514', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '514', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '515', '', 1, 'Назва на колонтитулі', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '515', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'a', 0, 0, 'Назва колонтитулу', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '515', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '515', 'z', 0, 0, 'Мова назви колонтитулу', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '516', '', 1, 'Назва на корінці', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '516', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'a', 0, 0, 'Назва на спинці', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '516', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '516', 'z', 0, 0, 'Мова назви на спинці', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '517', '', 1, 'Інші варіанти назви', 'Інші варіанти назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '517', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '517', 'a', 0, 0, 'Інший варіант назви', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '517', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '517', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '517', 'z', 0, 0, 'Мова інших варіантів назв', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '518', '', 1, 'Назва сучасною орфографією', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '518', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'a', 0, 0, 'Основна назва, варіант назви або уніфікована форма назви сучасною орфографією, або окремі слова з них', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '518', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '518', 'z', 0, 0, 'Мова іншої інформації щодо назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '532', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '532', 'a', 0, 0, 'Розширена назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '532', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '540', '', 1, 'Додаткова назва застосована каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '540', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '540', 'a', 0, 0, 'Додаткова назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '540', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '541', '', 1, 'Перекладена назва складена каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '541', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '541', 'a', 0, 0, 'Перекладена назва', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '541', 'e', 0, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '541', 'h', 0, 0, 'Нумерація частини', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '541', 'i', 0, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '541', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '541', 'z', 0, 0, 'Мова перекладеної назви', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '600', '', 1, 'Ім`я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '600', '2', 0, 0, 'Код системи', '',                      -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', 1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', 1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '',   -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'd', 0, 0, 'Римські цифри', '',                    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'f', 0, 0, 'Дати', '',                             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'p', 1, 0, 'Установа/адреса', '',                  -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '601', '', 1, 'Найменування колективу як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '601', '2', 0, 0, 'Код системи', '',                      -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', 1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'b', 1, 0, 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'c', 1, 0, 'Доповнення до найменування або уточнення', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'd', 0, 0, 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'e', 0, 0, 'Місце знаходження тимчасового колективу', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'f', 0, 0, 'Дати існування тимчасового колективу', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'g', 0, 0, 'Інверсований елемент', '',             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'h', 0, 0, 'Частина найменування, що відрізняється від початкового елемента заголовку рубрик', '', -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'j', 1, 0, 'Формальна підрубрика', '',             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'x', 1, 0, 'Тематична підрубрика', '',             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'y', 0, 0, 'Географічна підрубрика', '',           -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '601', 'z', 0, 0, 'Хронологічна підрубрика', '',          -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '602', '', 1, 'Родове ім`я як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '602', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'j', 1, 0, 'Формальна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'x', 1, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '602', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '604', '', 1, 'Автор і назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '604', '1', 0, 1, 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '605', '', 1, 'Назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '605', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'i', 1, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'j', 0, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'm', 0, 0, 'Мова (як частина предметної рубрики)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'n', 1, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'q', 0, 0, 'Версія (або дата версії)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'r', 1, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 's', 1, 0, 'Числове визначення (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'u', 1, 0, 'Ключ (для музичних творів)', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'w', 1, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '605', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '606', '', 1, 'Найменування теми як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '606', '2', 0, 0, 'Код системи', '',                      -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',         1, 0, 'bibliosubject.subject', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '606', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '607', '', 1, 'Географічна назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '607', '2', 0, 0, 'Код системи', '',                      -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',         1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '607', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '608', '', 1, 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '608', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', '5', 0, 0, 'Організація, до якої застосовується поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', 'a', 0, 0, 'Початковий елемент заголовку', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '608', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '610', '', 1, 'Неконтрольовані предметні терміни', 'Ключові слова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '610', 'a', 0, 1, 'Предметний термін', 'Предмет',         1, 0, '', '', '', 0, '', '610a', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '615', '', 1, 'Предметна категорія (попереднє)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '615', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '615', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '615', 'a', 1, 0, 'Текст елемента предметної категорій', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '615', 'm', 1, 0, 'Код підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '615', 'n', 1, 0, 'Код предметної категорій', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '615', 'x', 1, 0, 'Текст підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '620', 'a', 0, 0, 'Країна', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('BOOK', NULL, '620', 'd', 0, 0, 'Місто', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '660', 'a', 0, 0, 'Код', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '661', '', 1, 'Код періоду часу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '661', 'a', 0, 0, 'Код періоду часу', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '675', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '675', 'a', 0, 0, 'Індекс', '',                           1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '675', 'v', 0, 0, 'Видання', '',                          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '675', 'z', 0, 0, 'Мова видання', '',                     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '676', 'a', 0, 0, 'Індекс', '',                           1, 0, 'biblioitems.dewey', '', '', 0, '', '', NULL),
 ('BOOK', '', '676', 'v', 0, 0, 'Видання', '',                          -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '676', 'z', 0, 0, 'Мова видання', '',                     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '680', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '680', 'a', 0, 0, 'Класифікаційний індекс', '',           1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '680', 'b', 0, 0, 'Книжковий знак', '',                   -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '686', '2', 0, 0, 'Код системи', '',                      1, 1, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '686', 'a', 0, 0, 'Індекс класифікації', '',              1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '686', 'b', 0, 0, 'Книжковий знак', '',                   -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',        -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '700', '', '', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', '4', 0, 0, 'Код відношення', '',                   -1, 0, '', '', 'QUALIF', 0, '', '', NULL),
 ('BOOK', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',    2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'd', 0, 0, 'Римські цифри', '',                    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'f', 0, 0, 'Дати', '',                             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', '4', 0, 0, 'Код відношення', '',                   -1, 0, '', '', 'QUALIF', 0, '', '', NULL),
 ('BOOK', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',         2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'd', 0, 0, 'Римські цифри', '',                    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'f', 0, 0, 'Дати', '',                             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', '4', 0, 0, 'Код відношення', '',                   -1, 0, '', '', 'QUALIF', 0, '', '', NULL),
 ('BOOK', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',         2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'd', 0, 0, 'Римські цифри', '',                    -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'f', 0, 0, 'Дати', '',                             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', 2, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',     -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '710', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '711', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, '', NULL, NULL),
 ('BOOK', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('BOOK', '', '712', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '720', '', '', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '720', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, NULL, NULL, NULL),
 ('BOOK', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '720', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '721', '', 1, 'Родове ім’я - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '721', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, NULL, NULL, NULL),
 ('BOOK', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '721', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '722', '', 1, 'Родове ім’я - вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '722', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '722', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', 'QUALIF', NULL, NULL, NULL, NULL),
 ('BOOK', '', '722', '5', 1, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '722', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('BOOK', '', '722', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',     -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '801', 'a', 0, 0, 'Країна', '',                           3, 0, '', 'COUNTRY', '', 0, '', '', 'UA'),
 ('BOOK', '', '801', 'b', 0, 0, 'Установа', '',                         3, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '801', 'c', 0, 0, 'Дата', '',                             -1, 0, '', '', '', 0, '', '', NULL),
 ('BOOK', '', '801', 'g', 0, 0, 'Правила каталогізації', '',            -1, 0, '', '', '', 0, '', '', 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BOOK', '852', '', 1, 'Місцезнаходження та шифр зберігання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden,
                                      kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BOOK', '', '852', '2', 0, 0, 'Код системи класифікації для розстановки фонду', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'a', 0, 0, 'Ідентифікатор організації', '',            8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'b', 0, 1, 'Найменування підрозділу, фонду чи колекції', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'c', 0, 0, 'Адреса', '',                               8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'd', 0, 0, 'Визначник місцезнаходження (в кодований формі)', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'e', 0, 0, 'Визначник місцезнаходження (не в кодований формі)', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'g', 0, 0, 'Префікс шифру зберігання', '',             8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'j', 0, 0, 'Шифр зберігання', 'Шифр замовлення',       8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'k', 0, 0, 'Форма заголовку/імені автора, що використовуються для організації фонду', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'l', 0, 0, 'Суфікс шифру зберігання', '',              8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'm', 0, 0, 'Ідентифікатор одиниці', '',                8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'n', 0, 0, 'Ідентифікатор екземпляра', '',             8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'p', 0, 0, 'Код країни основного місцезнаходження', '', 8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 't', 0, 0, 'Номер примірника', '',                     8, 0, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'x', 0, 0, 'Службова примітка', '',                    8, 4, '', '', '', 0, NULL, '', ''),
 ('BOOK', '', '852', 'y', 0, 0, 'Загальнодоступна примітка', 'Нотатки',     8, 0, '', '', '', 0, NULL, '', '');

SET FOREIGN_KEY_CHECKS=1;
