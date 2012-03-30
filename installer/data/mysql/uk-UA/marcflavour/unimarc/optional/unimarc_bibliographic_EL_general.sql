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

DELETE FROM biblio_framework WHERE frameworkcode='EL';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('EL', 'електронні видання');
DELETE FROM marc_tag_structure WHERE frameworkcode='EL';
DELETE FROM marc_subfield_structure WHERE frameworkcode='EL';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '000', 1, '', 'Маркер запису', '', '');
 INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',       3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '005', '', '', 'Ідентифікатор версії', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                   0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('EL', '', '010', 'b', 0, 0, 'Уточнення', '',                          -1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',         -1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                    -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '011', '', 1, 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'ISSN',                   0, NULL, 'biblioitems.issn', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '011', 'b', 0, 0, 'Уточнення', '',                          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '011', 'd', 0, 0, 'Умови придбання і/або ціна', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '011', 'y', 0, 0, 'Анульований ISSN', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '011', 'z', 0, 0, 'Помилковий ISSN', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',             3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'g', 0, 0, 'Мова основної назви', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '102', 'a', 0, 0, 'Країна публікації', '',                  1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('EL', '', '102', 'b', 0, 0, 'Місце публікації', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '135', '', 1, 'Поле кодованих данных: електронні ресурси', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '135', 'a', 0, 0, 'Кодовані дані для електронних ресурсів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '200', '5', 0, 1, 'Організація – власник примірника', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'a', 1, 1, 'Основна назва', '',                      0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'd', 0, 0, 'Паралельна назва', '',                   0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'e', 0, 1, 'Підзаголовок', '',                       0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',    0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'i', 0, 0, 'Найменування частини', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'v', 0, 0, 'Позначення тому', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '205', 'a', 0, 0, 'Відомості про видання', '',              0, NULL, 'biblioitems.editionstatement', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',    0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('EL', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'e', 0, 0, 'Місце виробництва', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'f', 1, 0, 'Адреса виробника', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '210', 'h', 1, 0, 'Дата виробництва', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '215', '', 1, 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '215', 'a', 0, 0, 'Специфічне визначення матеріалу та обсяг документа', '', 1, NULL, 'biblioitems.pages', '', '', NULL, '', NULL, NULL),
 ('EL', '', '215', 'c', 0, 0, 'Інші уточнення фізичних характеристик', '', -1, NULL, 'biblioitems.illus', '', '', NULL, '', NULL, NULL),
 ('EL', '', '215', 'd', 0, 0, 'Розміри', '',                            1, NULL, 'biblioitems.size', '', '', NULL, '', NULL, NULL),
 ('EL', '', '215', 'e', 0, 0, 'Супроводжувальний матеріал', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '225', 'a', 0, 0, 'Назва серії', '',                        1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('EL', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'e', 0, 0, 'Підзаголовок', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'h', 0, 0, 'Номер частини', '',                      -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'i', 0, 0, 'Найменування частини', '',               1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'v', 0, 0, 'Визначення тому', '',                    1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'x', 0, 0, 'ISSN серії', '',                         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '230', '', 1, 'Область специфіки матеріалу: характеристики електронного ресурсу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '230', 'a', 0, 0, 'Визначення типу та розміру електронного ресурсу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '300', 'a', 0, 0, 'Текст примітки', '',                     1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '327', 'a', 0, 0, 'Текст примітки', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '330', '', 1, 'Короткий звіт або резюме', 'Короткий зміст', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '330', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '336', '', 1, 'Примітки про тип електронного ресурсу', 'Примітки про тип електронного ресурсу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '336', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '337', '', 1, 'Примітки про системні вимоги (електронні ресурси)', 'Системні вимоги', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '337', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '421', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '422', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '452', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'a', 0, 0, 'Автор', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'c', 0, 0, 'Місце публікації', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'd', 0, 0, 'Дата публікації', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'e', 0, 0, 'Відомості про видання', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'p', 0, 0, 'Фізичний опис', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 't', 0, 0, 'Назва', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'u', 0, 0, 'URL', '',                                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'v', 0, 0, 'Номер тому', '',                         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '461', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '462', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '463', '', 1, 'Окрема фізична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '463', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '463', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '463', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '463', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '463', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '464', '', 1, 'Аналітична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '464', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '464', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '464', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '464', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '464', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'a', 0, 0, 'Автор', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 't', 0, 0, 'Назва', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'u', 0, 0, 'URL', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '488', 'z', 0, 0, 'CODEN', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '500', '', 1, 'Уніфікована форма назви', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '500', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'a', 0, 0, 'Уніфікована форма назви', 'Назва',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '500', 'z', 0, 0, 'Хронологічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '503', '', 1, 'Уніфікований обумовлений заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '503', 'a', 0, 0, 'Основний уніфікований умовний заголовок', 'Заголовок', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'b', 0, 0, 'Підзаголовок уніфікованого умовного заголовку', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'd', 0, 0, 'Місяць і день', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'e', 0, 0, 'Прізвище особи', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'f', 0, 0, 'Ім’я особи', '',                         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'h', 0, 0, 'Визначник персонального імені', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'i', 0, 0, 'Назва частини', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'j', 0, 0, 'Рік', '',                                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'k', 0, 0, 'Нумерація (арабська)', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'l', 0, 0, 'Нумерація (римська)', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'm', 0, 0, 'Місцевість', '',                         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '503', 'n', 0, 0, 'Установа у місцевості', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '510', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'a', 0, 0, 'Паралельна назва', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'e', 1, 0, 'Інша інформація щодо назви', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'h', 1, 0, 'Номер частини', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'i', 1, 0, 'Найменування частини', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'n', 0, 0, 'Різна інформація', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '510', 'z', 0, 0, 'Мова назви', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '517', '', 1, 'Інші варіанти назви', 'Інші варіанти назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '517', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '517', 'a', 0, 0, 'Інший варіант назви', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '517', 'e', 1, 0, 'Інші відомості щодо назви', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '517', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '517', 'z', 0, 0, 'Мова інших варіантів назв', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '532', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '532', 'a', 0, 0, 'Розширена назва', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '532', 'z', 0, 0, 'Мова назви', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '540', '', 1, 'Додаткова назва застосована каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '540', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '540', 'a', 0, 0, 'Додаткова назва', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '540', 'z', 0, 0, 'Хронологічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '541', '', 1, 'Перекладена назва складена каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '541', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '541', 'a', 0, 0, 'Перекладена назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '541', 'e', 0, 0, 'Інші відомості щодо назви', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '541', 'h', 0, 0, 'Нумерація частини', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '541', 'i', 0, 0, 'Найменування частини', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '541', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '541', 'z', 0, 0, 'Мова перекладеної назви', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '545', '', 1, 'Назва розділу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '545', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '545', 'a', 0, 0, 'Назва розділу', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'h', 0, 0, 'Номер розділу або частини', 'Номер',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'i', 0, 0, 'Найменування розділу або частини', '',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'j', 0, 0, 'Підрозділ форми твору', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'k', 0, 0, 'Дата публікації', 'Опубліковано',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'n', 0, 0, 'Змішана інформація', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'q', 0, 0, 'Версія (або дата версії)', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'u', 0, 0, 'Ключ  музичних творів', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'v', 0, 0, 'Визначення тому', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'y', 0, 0, 'Географічний підрозділ', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '545', 'z', 0, 0, 'Хронологічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '600', '', 1, 'Ім`я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '600', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'f', 0, 0, 'Дати', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'p', 1, 0, 'Установа/адреса', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '601', '', 1, 'Найменування колективу як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '601', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'b', 1, 0, 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'c', 1, 0, 'Доповнення до найменування або уточнення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'd', 0, 0, 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'e', 0, 0, 'Місце знаходження тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'f', 0, 0, 'Дати існування тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'h', 0, 0, 'Частина найменування, що відрізняється від початкового елемента заголовку рубрики й інверсованого елемента', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'j', 1, 0, 'Формальна підрубрика', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'x', 1, 0, 'Тематична підрубрика', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'y', 0, 0, 'Географічна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '601', 'z', 0, 0, 'Хронологічна підрубрика', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '602', '', 1, 'Родове ім`я як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '602', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'f', 0, 0, 'Дати', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'j', 1, 0, 'Формальна підрубрика', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'x', 1, 0, 'Тематична підрубрика', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'y', 0, 0, 'Географічна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '602', 'z', 0, 0, 'Хронологічна підрубрика', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '604', '', 1, 'Автор і назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '604', '1', 1, 0, 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '605', '', 1, 'Назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '605', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'h', 1, 0, 'Номер розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'i', 1, 0, 'Назва розділу або частини', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'j', 0, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'k', 0, 0, 'Дата публікації', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'm', 0, 0, 'Мова (як частина предметної рубрики)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'n', 1, 0, 'Змішана інформація', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'r', 1, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 's', 1, 0, 'Числове визначення (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'u', 1, 0, 'Ключ (для музичних творів)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'w', 1, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '605', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '606', '', 1, 'Найменування теми як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '606', '2', 0, 0, 'Код системи', '',                        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', 'a', 0, 1, 'Заголовок рубрики', 'Предмет',           1, NULL, 'bibliosubject.subject', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', 'j', 1, 0, 'Формальний підзаголовок', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', 'x', 1, 0, 'Тематичний підзаголовок', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', 'y', 1, 0, 'Географічний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '606', 'z', 1, 0, 'Хронологічний підзаголовок', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '607', '', 1, 'Географічна назіва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '607', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '607', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '608', '', 1, 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '608', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', '5', 0, 0, 'Організація, до якої застосовується поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', 'a', 0, 0, 'Початковий елемент заголовку', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '608', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '610', '', 1, 'Неконтрольовані предметні терміни', 'Ключові слова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '610', 'a', 0, 1, 'Предметний термін', 'Предмет',           1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '615', '', 1, 'Предметна категорія (попереднє)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '615', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '615', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '615', 'a', 1, 0, 'Текст елемента предметної категорій', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '615', 'm', 1, 0, 'Код підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '615', 'n', 1, 0, 'Код предметної категорій', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '615', 'x', 1, 0, 'Текст підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '616', '', 1, 'Товарний знак як предметна рубрика', 'Товарний знак', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '616', '2', 0, 0, 'Код системи', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'a', 0, 0, 'Початковий елемент заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'c', 0, 0, 'Характеристики', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'f', 0, 0, 'Дати', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'j', 0, 0, 'Формальний підзаголовок', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'x', 0, 0, 'Тематична підрубрика', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'y', 0, 0, 'Географічна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '616', 'z', 0, 0, 'Хронологічна підрубрика', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '620', 'a', 0, 0, 'Країна', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '620', 'd', 0, 0, 'Місто', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '626', '', 1, 'Технічні характеристики як точка доступу: електронні ресурси', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '626', 'a', 0, 0, 'Марка та модель комп’ютера', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '626', 'b', 0, 0, 'Мова програмування', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '626', 'c', 0, 0, 'Операційна система', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '629', '', 1, 'Шифр наукової спеціальності як точка доступу', 'Шифр наукової спеціальності', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '629', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '629', 'a', 0, 0, 'Шифр/найменування наукової спеціальності', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '629', 'b', 0, 0, 'Учений ступінь', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '629', 'c', 0, 0, 'Назва країни, де було подано дисертацію на здобуття вченого ступеню', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '660', 'a', 0, 0, 'Код', '',                              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '661', '', 1, 'Код періоду часу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '661', 'a', 0, 0, 'Код періоду часу', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '670', '', 1, 'PRECIS', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '670', 'b', 0, 0, 'Номер індикатора предмета', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '670', 'c', 0, 0, 'Рядок', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '670', 'e', 1, 0, 'Код індикатора посилання', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '670', 'z', 0, 0, 'Мова терміна', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '675', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '675', 'a', 0, 0, 'Індекс', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '675', 'v', 0, 0, 'Видання', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '675', 'z', 0, 0, 'Мова видання', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '676', 'a', 0, 0, 'Індекс', '',                             -1, NULL, 'biblioitems.dewey', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '676', 'v', 0, 0, 'Видання', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '676', 'z', 0, 0, 'Мова видання', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '680', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '680', 'a', 0, 0, 'Класифікаційний індекс', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '680', 'b', 0, 0, 'Книжковий знак', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '686', '2', 0, 0, 'Код системи', '',                        1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',      -1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '686', 'a', 0, 0, 'Індекс класифікації', '',                1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '686', 'b', 0, 0, 'Книжковий знак', '',                     -1, 0, '', '', '', 0, '', '', NULL),
 ('EL', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',          -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '700', '', '', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',           2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',           2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'd', 0, 0, 'Римські цифри', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '710', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '711', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',       2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'g', 0, 0, 'Інверсований елемент', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('EL', '', '712', 'p', 0, 0, 'Адреса', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '716', '', 1, 'Торгова марка', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '716', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '716', '4', 0, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '716', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '716', 'c', 0, 0, 'Характеристики', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '716', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '720', '', '', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '720', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '720', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '721', '', 1, 'Родове ім’я - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '721', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '721', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '722', '', 1, 'Родове ім’я - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '722', '3', 0, 0, 'Номер авторитетного запису', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '722', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '722', '5', 1, 0, 'Установа-утримувач примірника', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '722', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '722', 'f', 0, 0, 'Дати', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '730', '', 1, 'Ім’я/найменування - інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '730', '4', 1, 0, 'Код відношення', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '730', 'a', 1, 0, 'Ім’я/найменування', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '801', 'a', 0, 1, 'Країна', '',                             -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('EL', '', '801', 'b', 1, 0, 'Установа', '',                           -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('EL', '', '801', 'c', 0, 0, 'Дата', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('EL', '', '801', 'g', 1, 0, 'Правила каталогізації', '',              -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('EL', '856', '', 1, 'Електронна адреса та доступ', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('EL', NULL, '856', 'a', 1, 0, 'Ім’я сервера (Host name)', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'b', 1, 0, 'Номер доступу (Access number)', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'c', 1, 0, 'Відомості про стиснення (Compression information)', 'стиснення', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'd', 1, 0, 'Шлях (Path)', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'e', 1, 0, 'Дата і час останнього доступу (Date and Hour of Consultation and Access)', 'Час останнього доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'f', 1, 0, 'Електронне ім’я (electronic name)', 'електронне ім’я', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'g', 1, 0, 'Унікальне ім’я ресурсу (URN - Uniform Resource Name)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'h', 0, 0, 'Виконавець запиту (Processor of request)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'i', 1, 0, 'Команди (Instruction)', 'Команди',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'j', 0, 0, 'Швидкість передачі даних (BPS - bits per second)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'k', 0, 0, 'Пароль (Password)', 'Пароль',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'l', 0, 0, 'Ім’я користувача (Logon/login) ', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'm', 1, 0, 'Контактні дані для підтримки доступу (Contact for access assistance)', 'Контактні дані', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'n', 0, 0, 'Місце знаходження серверу, що позначений у підполі $a (Name of location of host)', 'адреса', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'o', 0, 0, 'Операційна система (Operating system)', 'Операційна система', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'p', 0, 0, 'Порт (Port)', 'Порт',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'q', 0, 0, 'Тип електронного формату (Electronic Format Type)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'r', 0, 0, 'Установки (Settings)', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 's', 1, 0, 'Розмір файлу (File size)', 'Розмір файлу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 't', 1, 0, 'Емуляція терміналу (Terminal emulation)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'u', 1, 0, 'Універсальна адреса ресурсу (URL - Uniform Resource Locator)', 'URL (універсальна адреса ресурсу)', -1, NULL, 'biblioitems.url', NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'v', 1, 0, 'Термін доступу за даним методом (Hours access method available)', 'Термін доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'w', 1, 0, 'Контрольний номер запису', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'x', 1, 0, 'Службові нотатки (Nonpublic note)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('EL', NULL, '856', 'z', 1, 0, 'Не службові нотатки (Public note)', 'нотатки', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
