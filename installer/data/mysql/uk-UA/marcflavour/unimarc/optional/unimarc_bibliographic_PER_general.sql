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

DELETE FROM biblio_framework WHERE frameworkcode='PER';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('PER', 'періодика (серіальні видання)');
DELETE FROM marc_tag_structure WHERE frameworkcode='PER';
DELETE FROM marc_subfield_structure WHERE frameworkcode='PER';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',      3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '005', '', '', 'Ідентифікатор версії', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                  0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('PER', '', '010', 'b', 0, 0, 'Уточнення', '',                         -1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',        -1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                   -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '011', '', 1, 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'ISSN',                  0, NULL, 'biblioitems.issn', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '011', 'b', 0, 0, 'Уточнення', '',                         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '011', 'd', 0, 0, 'Умови придбання і/або ціна', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '011', 'y', 0, 0, 'Анульований ISSN', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '011', 'z', 0, 0, 'Помилковий ISSN', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '022', '', 1, 'Номер публікації органів державної влади', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '022', 'a', 0, 0, 'Код країни', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '022', 'b', 0, 0, 'Номер', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '022', 'z', 1, 0, 'Помилковий номер', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '040', '', 1, 'CODEN (для серіальних видань)', 'CODEN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '040', 'a', 0, 0, 'CODEN', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '040', 'z', 1, 0, 'Помилковий CODEN', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',            3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'g', 0, 0, 'Мова основної назви', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '102', 'a', 0, 0, 'Країна публікації', '',                 1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('PER', '', '102', 'b', 0, 0, 'Місце публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '106', '', '', 'Поле кодованих даних: текстові матеріали — фізичні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '106', 'a', 0, 0, 'Кодовані дані позначення фізичної форми текстових матеріалів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '110', '', '', 'Кодовані дані: серіальні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '110', 'a', 0, 0, 'Кодовані дані про серіальне видання', '', 2, 0, '', '', 'unimarc_field_110.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '200', '5', 0, 1, 'Організація – власник примірника', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'a', 1, 1, 'Основна назва', '',                     0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'd', 0, 0, 'Паралельна назва', '',                  0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'e', 0, 1, 'Підзаголовок', '',                      0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',   0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'i', 0, 0, 'Найменування частини', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'v', 0, 0, 'Позначення тому', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '205', 'a', 0, 0, 'Відомості про видання', '',             0, NULL, 'biblioitems.editionstatement', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',   0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '207', '', '', 'Область специфічних характеристик матеріалу: серіальні видання – нумерація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '207', 'a', 1, 0, 'Нумерація: Визначення дат і томів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '207', 'z', 1, 0, 'Джерело інформації про нумерацію', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('PER', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'e', 0, 0, 'Місце виробництва', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'f', 1, 0, 'Адреса виробника', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '210', 'h', 1, 0, 'Дата виробництва', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '225', 'a', 0, 0, 'Назва серії', '',                       1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('PER', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'e', 0, 0, 'Підзаголовок', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'h', 0, 0, 'Номер частини', '',                     -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'i', 0, 0, 'Найменування частини', '',              1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'v', 0, 0, 'Визначення тому', '',                   1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'x', 0, 0, 'ISSN серії', '',                        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '300', 'a', 0, 0, 'Текст примітки', '',                    1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '301', '', 1, 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '301', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '302', '', 1, 'Примітки, що відносяться до кодованої інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '302', 'a', 0, 0, 'Текст примітки', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '305', '', '', 'Примітки про видання та бібліографічну історію', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '305', 'a', 0, 0, 'Текст примітки', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '320', '', 1, 'примітка про наявність бібліографії/покажчиків', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '320', 'a', 0, 0, 'Текст примітки', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '326', '', 1, 'Примітки про періодичність (серіальні видання)', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '326', 'a', 0, 0, 'Періодичність', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '326', 'b', 0, 0, 'Дати періодичності', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '327', 'a', 0, 0, 'Текст примітки', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '333', '', 1, 'Примітка про читацьке призначення', 'Приміти про особливості користування та поширення', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '333', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '421', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '422', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '423', '', 1, 'Видано з', 'Видано з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '423', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '423', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '423', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '423', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '423', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '430', '', 1, 'Продовжується', 'Продовжується', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '430', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '430', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '430', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '430', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '430', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '432', '', 1, 'Заміщує', 'Заміщує', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '432', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '432', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '432', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '432', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '432', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '434', '', 1, 'Поглинуте', 'Поглинуте', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '434', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '434', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '434', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '434', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '434', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '436', '', 1, 'Утворене злиттям ..., ..., та ...', 'Утворене злиттям ..., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '436', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '436', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '436', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '436', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '436', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '440', '', 1, 'Продовжено як', 'Продовжено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '440', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '440', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '440', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '440', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '440', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '442', '', 1, 'Заміщене', 'Заміщене', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '442', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '442', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '442', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '442', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '442', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '444', '', 1, 'Те, що поглинуло', 'Те, що поглинуло', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '444', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '444', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '444', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '444', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '444', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '446', '', 1, 'Поділилося на .., ..., та ...', 'Поділилося на .., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '446', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '446', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '446', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '446', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '446', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '448', '', 1, 'Повернулося до попередньої назви', 'Повернулося до попередньої назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '448', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '448', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '448', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '448', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '448', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '451', '', 1, 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '451', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '451', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '451', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '451', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '451', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '452', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '453', '', 1, 'Перекладено як', 'Перекладено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '453', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '453', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '453', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '453', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '453', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '454', '', 1, 'Перекладено з…', 'Перекладено з…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '454', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '454', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', '5', 0, 0, 'Установа в якій поле застосовано', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', '@', 0, 0, 'номер ідентифікації примітки', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'a', 0, 0, 'Автор', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'c', 0, 0, 'Місце публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'd', 0, 0, 'Дата публікації', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'e', 0, 0, 'Відомості про видання', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'h', 0, 0, 'Номер розділу або частини', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'i', 0, 0, 'Назва розділу або частини', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'p', 0, 0, 'Фізичний опис', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 't', 0, 0, 'Назва', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'u', 0, 0, 'URL', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'v', 0, 0, 'Номер тому', '',                        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '454', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'a', 0, 0, 'Автор', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'c', 0, 0, 'Місце публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'd', 0, 0, 'Дата публікації', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'e', 0, 0, 'Відомості про видання', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'p', 0, 0, 'Фізичний опис', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 't', 0, 0, 'Назва', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'u', 0, 0, 'URL', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'v', 0, 0, 'Номер тому', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '461', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '462', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '488', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '510', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'a', 0, 0, 'Паралельна назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'e', 1, 0, 'Інша інформація щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'h', 1, 0, 'Номер частини', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'i', 1, 0, 'Найменування частини', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'n', 0, 0, 'Різна інформація', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '510', 'z', 0, 0, 'Мова назви', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '517', '', 1, 'Інші варіанти назви', 'Інші варіанти назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '517', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '517', 'a', 0, 0, 'Інший варіант назви', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '517', 'e', 1, 0, 'Інші відомості щодо назви', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'j', 0, 0, 'Підрозділ форми твору', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '517', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '517', 'z', 0, 0, 'Мова інших варіантів назв', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '518', '', 1, 'Назва сучасною орфографією', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '518', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'a', 0, 0, 'Основна назва, варіант назви або уніфікована форма назви сучасною орфографією, або окремі слова з них', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'e', 1, 0, 'Інша інформація щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'h', 1, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'j', 0, 0, 'Підрозділ форми твору', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'n', 0, 0, 'Змішана інформація', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '518', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '518', 'z', 0, 0, 'Мова іншої інформації щодо назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '520', '', 1, 'Попередня назва (серіальні видання)', 'Попередня назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '520', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'a', 0, 0, 'Попередня основна назва', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'e', 1, 0, 'Інші відомості щодо назви', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'h', 0, 0, 'Нумерація частини (підсерії)', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'i', 0, 0, 'Найменування частини (підсерії)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'j', 0, 0, 'Томи або дати попередньої назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'n', 0, 0, 'Текстовий коментар стосовно змісту підполів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'x', 0, 0, 'ISSN попередньої назви', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '520', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '520', 'z', 0, 0, 'Мова попередньої назви', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '530', '', 1, 'Ключова назва (серіальні видання)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '530', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '530', 'a', 0, 0, 'Ключова назва', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '530', 'b', 0, 0, 'Уточнення', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '530', 'j', 0, 0, 'Том або дата, пов’язані з ключовою назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '530', 'v', 0, 0, 'Визначення тому', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '530', 'z', 0, 0, 'Хронологічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '531', '', 1, 'Скорочена назва (серіальні видання)', 'Скорочена назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '531', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '531', 'a', 0, 0, 'Скорочена ключова назва', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '531', 'b', 0, 0, 'Уточнення', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'j', 0, 0, 'Підрозділ форми твору', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '531', 'v', 0, 0, 'Визначення тому ', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '531', 'z', 0, 0, 'Хронологічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '532', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '532', 'a', 0, 0, 'Розширена назва', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '532', 'z', 0, 0, 'Мова назви', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '600', '', 1, 'Ім`я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '600', '2', 0, 0, 'Код системи', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'd', 0, 0, 'Римські цифри', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'f', 0, 0, 'Дати', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'j', 1, 0, 'Формальний підзаголовок', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'p', 1, 0, 'Установа/адреса', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'x', 1, 0, 'Тематичний підзаголовок', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'y', 1, 0, 'Географічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '620', 'a', 0, 0, 'Країна', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '620', 'd', 0, 0, 'Місто', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '660', 'a', 0, 0, 'Код', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '675', '3', 0, 0, 'Номер класифікаційного запису', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '675', 'a', 0, 0, 'Індекс', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '675', 'v', 0, 0, 'Видання', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '675', 'z', 0, 0, 'Мова видання', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '676', 'a', 0, 0, 'Індекс', '',                            -1, NULL, 'biblioitems.dewey', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '676', 'v', 0, 0, 'Видання', '',                           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '676', 'z', 0, 0, 'Мова видання', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '680', '3', 0, 0, 'Номер класифікаційного запису', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '680', 'a', 0, 0, 'Класифікаційний індекс', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('PER', NULL, '680', 'b', 0, 0, 'Книжковий знак', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '686', '2', 0, 0, 'Код системи', '',                       1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',     -1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '686', 'a', 0, 0, 'Індекс класифікації', '',               1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '686', 'b', 0, 0, 'Книжковий знак', '',                    -1, 0, '', '', '', 0, '', '', NULL),
 ('PER', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',         -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',          2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'd', 0, 0, 'Римські цифри', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'f', 0, 0, 'Дати', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'g', 0, 0, 'Інверсований елемент', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '710', 'p', 0, 0, 'Адреса', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'g', 0, 0, 'Інверсований елемент', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '711', 'p', 0, 0, 'Адреса', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'g', 0, 0, 'Інверсований елемент', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('PER', '', '712', 'p', 0, 0, 'Адреса', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '801', 'a', 0, 1, 'Країна', '',                            -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('PER', '', '801', 'b', 1, 0, 'Установа', '',                          -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('PER', '', '801', 'c', 0, 0, 'Дата', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('PER', '', '801', 'g', 1, 0, 'Правила каталогізації', '',             -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '802', '', '', 'Центр ISSN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '802', 'a', 0, 0, 'Код центру ISSN', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('PER', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('PER', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
