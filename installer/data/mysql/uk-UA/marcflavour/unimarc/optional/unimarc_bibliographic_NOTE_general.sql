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

DELETE FROM biblio_framework WHERE frameworkcode='NOTE';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('NOTE', 'нотні видання');
DELETE FROM marc_tag_structure WHERE frameworkcode='NOTE';
DELETE FROM marc_subfield_structure WHERE frameworkcode='NOTE';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',     3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '005', '', '', 'Ідентифікатор версії', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                 0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('NOTE', '', '010', 'b', 0, 0, 'Уточнення', '',                        -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                  -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '011', '', 1, 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'ISSN',                 0, NULL, 'biblioitems.issn', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '011', 'b', 0, 0, 'Уточнення', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '011', 'd', 0, 0, 'Умови придбання і/або ціна', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '011', 'y', 0, 0, 'Анульований ISSN', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '011', 'z', 0, 0, 'Помилковий ISSN', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '013', '', 1, 'Міжнародний стандартний номер нотного видання (ISMN)', 'ISMN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '013', 'a', 0, 0, 'Код ISMN', 'ISMN',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '013', 'b', 0, 0, 'Характеристики', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '013', 'd', 0, 0, 'Умови придбання та/або ціна', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '013', 'z', 1, 0, 'Помилковий ISMN', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '016', '', 1, 'Міжнародний стандартний код звуко-/відео-/аудіовізу­ального запису (ISRC)', 'ISRC', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '016', 'a', 0, 0, 'Код ISRC', 'ISRC',                     0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '016', 'b', 0, 0, 'Характеристики', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '016', 'd', 0, 0, 'Сфера доступності та/або ціна', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '016', 'z', 1, 0, 'Помилковий ISRC', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '020', '', 1, 'Номер документа в національній бібліографії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '020', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '020', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '020', 'z', 1, 0, 'Помилковий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '071', '', 1, 'Видавничі номери (для музичних матеріалів)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '071', 'a', 0, 0, 'Видавничий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '071', 'b', 0, 0, 'Джерело', '',                        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',           3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'g', 0, 0, 'Мова основної назви', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '102', 'a', 0, 0, 'Країна публікації', '',                1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '102', 'b', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '105', '', '', 'Поле кодованих даних: текстові матеріали (монографічні)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '105', 'a', 0, 0, 'Кодовані дані про монографію', '',     3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '106', '', '', 'Поле кодованих даних: текстові матеріали — фізичні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '106', 'a', 0, 0, 'Кодовані дані позначення фізичної форми текстових матеріалів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '115', '', 1, 'Поле кодованих даних: візуально-проекційні матеріали, відеозаписи та кінофільми', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '115', 'a', 0, 0, 'Кодовані дані — загальні', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '115', 'b', 0, 0, 'Кодовані дані архівних кінофільмів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '122', '', '', 'Поле кодованих даних: період часу, охоплюваний змістом документа', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '122', 'a', 1, 0, 'Період часу від 9999 до н.е. до теперішнього часу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '125', '', '', 'Поле кодованих даних: немузичні звукозаписи та нотні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '125', 'a', 0, 0, 'Формат нотного видання', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '125', 'b', 0, 0, 'Визначник літературного тексту для немузичних звукозаписів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '126', '', 1, 'Поле кодованих даних: звукозаписи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '126', 'a', 1, 0, 'Кодовані дані: загальні', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '126', 'b', 0, 0, 'Кодовані дані: спеціальні', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '127', '', '', 'Поле кодованих даних: тривалість звукозаписів і музичного виконання (для нотних видань)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '127', 'a', 1, 0, 'Тривалість', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '128', '', 1, 'Поле кодованих даних: жанр і форма музичної композиції,засоби виконання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '128', 'a', 1, 0, 'Жанр і форма твору (музичне відтворення або партитура)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '128', 'b', 1, 0, 'Інструменти або голоси для ансамблів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '128', 'c', 1, 0, 'Інструменти або голоси для солістів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '130', '', 1, 'Поле кодованих данных: мікроформи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '130', 'a', 1, 0, 'Мікроформа кодовані дані — фізичні характеристики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '140', '', '', 'Поле кодованих даних: монографічні стародруки — загальні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '140', 'a', 1, 0, 'Кодовані дані: загальні', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '141', '', 1, 'Поле кодованих даних: монографічні стародруки — специфічні характеристики примірника', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '141', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '141', 'a', 1, 0, 'Кодовані дані монографічного стародруку: специфічні характеристики примірника', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '200', '5', 0, 1, 'Організація – власник примірника', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'a', 1, 1, 'Основна назва', '',                    0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'd', 0, 0, 'Паралельна назва', '',                 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'e', 0, 1, 'Підзаголовок', '',                     0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',  0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'i', 0, 0, 'Найменування частини', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'v', 0, 0, 'Позначення тому', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '205', 'a', 0, 0, 'Відомості про видання', '',            0, NULL, 'biblioitems.editionstatement', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',  0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '208', '', '', 'Область специфічних характеристик матеріалу: відомості про printed music specific statement', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '208', 'a', 0, 0, 'Специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '208', 'd', 1, 0, 'Паралельні специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'e', 0, 0, 'Місце виробництва', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'f', 1, 0, 'Адреса виробника', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '210', 'h', 1, 0, 'Дата виробництва', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '211', '', '', 'Запланована дата публікації', 'Запланована дата публікації', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '211', 'a', 0, 0, 'Дата', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '215', '', 1, 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '215', 'a', 0, 0, 'Специфічне визначення матеріалу та обсяг документа', '', 1, NULL, 'biblioitems.pages', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '215', 'c', 0, 0, 'Інші уточнення фізичних характеристик', '', -1, NULL, 'biblioitems.illus', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '215', 'd', 0, 0, 'Розміри', '',                          1, NULL, 'biblioitems.size', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '215', 'e', 0, 0, 'Супроводжувальний матеріал', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '225', 'a', 0, 0, 'Назва серії', '',                      1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'e', 0, 0, 'Підзаголовок', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'h', 0, 0, 'Номер частини', '',                    -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'i', 0, 0, 'Найменування частини', '',             1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'v', 0, 0, 'Визначення тому', '',                  1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'x', 0, 0, 'ISSN серії', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '300', 'a', 0, 0, 'Текст примітки', '',                   1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '301', '', 1, 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '301', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '302', '', 1, 'Примітки, що відносяться до кодованої інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '302', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '304', '', 1, 'Примітки, що відносяться  до назви і відомостей про відповідальність', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '304', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '305', '', '', 'Примітки про видання та бібліографічну історію', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '305', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '307', '', 1, 'Примітки щодо кількісної/фізичної характеристики', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '307', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '310', '', 1, 'Примітки щодо оправи та умов придбання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '310', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '315', '', 1, 'Примітки щодо специфічних характеристик матеріалу або типу публікації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '315', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '316', '', 1, 'Примітки щодо каталогізованого примірника', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '316', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '316', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '317', '', 1, 'Примітки щодо походження', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '317', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '317', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '318', '', 1, 'Примітки щодо поводження з примірником', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '318', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'a', 0, 0, 'Поводження', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'b', 1, 0, 'Ідентифікація поводження', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'c', 1, 0, 'Час поводження', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'd', 1, 0, 'Інтервал поводження', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'e', 1, 0, 'Робота з непередбачуваними обставинами', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'f', 1, 0, 'Авторизація', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'h', 1, 0, 'Повноваження', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'i', 1, 0, 'Метод роботи', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'j', 1, 0, 'Місце роботи', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'k', 1, 0, 'Виконавець роботи', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'l', 1, 0, 'Статус', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'n', 1, 0, 'Межі роботи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'o', 1, 0, 'Тип одиниці', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'p', 1, 0, 'Примітка, не призначена для друку', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '318', 'r', 1, 0, 'Примітка, призначена для друку', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '320', '', 1, 'примітка про наявність бібліографії/покажчиків', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '320', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '321', '', 1, 'Примітка про видані окремо покажчики, реферати, посилання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '321', 'a', 0, 0, 'Примітка про покажчики, реферати, посилання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '321', 'b', 0, 0, 'Дати обсягу', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '321', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '322', '', '', 'Примітки щодо переліку учасників підготовки матеріалу до випуску (проекційні та відеоматеріали і звукозаписи)', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '322', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '323', '', 1, 'Примітки щодо складу виконавців (проекційні та відеоматеріали і звукозаписи)', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '323', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '327', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '330', '', 1, 'Короткий звіт або резюме', 'Короткий зміст', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '330', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '333', '', 1, 'Примітка про читацьке призначення', 'Приміти про особливості користування та поширення', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '333', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '410', '', 1, 'Серії (поле зв’язку)', 'Серії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '410', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '410', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', '@', 0, 0, 'номер ідентифікації примітки', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 't', 0, 0, 'Назва', '',                            1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '410', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '421', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '422', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '423', '', 1, 'Видано з', 'Видано з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '423', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '423', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '423', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '423', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '423', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '451', '', 1, 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '451', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '451', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '451', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '451', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '451', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '452', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '453', '', 1, 'Перекладено як', 'Перекладено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '453', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '453', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '453', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '453', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '453', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '454', '', 1, 'Перекладено з…', 'Перекладено з…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '454', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '454', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', '@', 0, 0, 'номер ідентифікації примітки', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '454', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '455', '', 1, 'Відтворено з…', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '455', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '455', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '455', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '455', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '455', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '456', '', 1, 'Відтворено як', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '456', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '456', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '456', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '456', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '456', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '461', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '462', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '463', '', 1, 'Окрема фізична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '463', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '463', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '463', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '463', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '463', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '464', '', 1, 'Аналітична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '464', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '464', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '464', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '464', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '464', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '481', '', 1, 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '481', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '481', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '481', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '481', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '481', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '482', '', 1, 'Переплетено з', 'Переплетено з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '482', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '482', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '482', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '482', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '482', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '488', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '500', '', 1, 'Уніфікована форма назви', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '500', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'a', 0, 0, 'Уніфікована форма назви', 'Назва',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '500', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '501', '', 1, 'Загальна уніфікована назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '501', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'a', 0, 0, 'Типова назва', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'b', 1, 0, 'Загальне визначення матеріалу', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'e', 0, 0, 'Типова підназва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '501', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '501', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'j', 0, 0, 'Підрозділ форми', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'm', 0, 0, 'Мова (якщо є частиною заголовку)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'r', 1, 0, 'Засоби виконання музичних творів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 's', 1, 0, 'Порядкове визначення  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'u', 0, 0, 'Ключ  музичного твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'w', 0, 0, 'Відомості про аранжування  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'x', 1, 0, 'Тематичний підрозділ', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'y', 1, 0, 'Географічний підрозділ', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '501', 'z', 1, 0, 'Хронологічний підрозділ', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '503', '', 1, 'Уніфікований обумовлений заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '503', 'a', 0, 0, 'Основний уніфікований умовний заголовок', 'Заголовок', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'b', 0, 0, 'Підзаголовок уніфікованого умовного заголовку', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'd', 0, 0, 'Місяць і день', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'e', 0, 0, 'Прізвище особи', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'f', 0, 0, 'Ім’я особи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'h', 0, 0, 'Визначник персонального імені', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'i', 0, 0, 'Назва частини', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'j', 0, 0, 'Рік', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'k', 0, 0, 'Нумерація (арабська)', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'l', 0, 0, 'Нумерація (римська)', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'm', 0, 0, 'Місцевість', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '503', 'n', 0, 0, 'Установа у місцевості', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '510', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'a', 0, 0, 'Паралельна назва', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'n', 0, 0, 'Різна інформація', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '510', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '512', '', 1, 'Назва обкладинки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '512', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'a', 0, 0, 'Назва обкладинки', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'e', 1, 0, 'Інші відомості щодо назви обкладинки', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '512', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '512', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '513', '', 1, 'Назва на додатковому титульному аркуші', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '513', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'a', 0, 0, 'Назва додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'e', 1, 0, 'Інші відомості щодо назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '513', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '513', 'z', 0, 0, 'Мова назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '514', '', 1, 'Назва на першій сторінці тексту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '514', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'a', 0, 0, 'Назва перед текстом', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '514', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '514', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '515', '', 1, 'Назва на колонтитулі', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '515', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'a', 0, 0, 'Назва колонтитулу', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '515', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '515', 'z', 0, 0, 'Мова назви колонтитулу', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '516', '', 1, 'Назва на корінці', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '516', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'a', 0, 0, 'Назва на спинці', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '516', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '516', 'z', 0, 0, 'Мова назви на спинці', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '517', '', 1, 'Інші варіанти назви', 'Інші варіанти назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '517', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '517', 'a', 0, 0, 'Інший варіант назви', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '517', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '517', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '517', 'z', 0, 0, 'Мова інших варіантів назв', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '518', '', 1, 'Назва сучасною орфографією', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '518', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'a', 0, 0, 'Основна назва, варіант назви або уніфікована форма назви сучасною орфографією, або окремі слова з них', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '518', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '518', 'z', 0, 0, 'Мова іншої інформації щодо назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '532', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '532', 'a', 0, 0, 'Розширена назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '532', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '540', '', 1, 'Додаткова назва застосована каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '540', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '540', 'a', 0, 0, 'Додаткова назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '540', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '541', '', 1, 'Перекладена назва складена каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '541', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '541', 'a', 0, 0, 'Перекладена назва', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '541', 'e', 0, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '541', 'h', 0, 0, 'Нумерація частини', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '541', 'i', 0, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '541', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '541', 'z', 0, 0, 'Мова перекладеної назви', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '600', '', 1, 'Ім`я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '600', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'd', 0, 0, 'Римські цифри', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'p', 1, 0, 'Установа/адреса', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '601', '', 1, 'Найменування колективу як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '601', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'b', 1, 0, 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'c', 1, 0, 'Доповнення до найменування або уточнення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'd', 0, 0, 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'e', 0, 0, 'Місце знаходження тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'f', 0, 0, 'Дати існування тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'g', 0, 0, 'Інверсований елемент', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'h', 0, 0, 'Частина найменування, що відрізняється від початкового елемента заголовку рубрики й інверсованого елемента', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'j', 1, 0, 'Формальна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'x', 1, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '601', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '602', '', 1, 'Родове ім`я як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '602', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'j', 1, 0, 'Формальна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'x', 1, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '602', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '604', '', 1, 'Автор і назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '604', '1', 1, 0, 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '605', '', 1, 'Назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '605', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'i', 1, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'j', 0, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'm', 0, 0, 'Мова (як частина предметної рубрики)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'n', 1, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'q', 0, 0, 'Версія (або дата версії)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'r', 1, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 's', 1, 0, 'Числове визначення (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'u', 1, 0, 'Ключ (для музичних творів)', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'w', 1, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '605', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '606', '', 1, 'Найменування теми як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '606', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', 'a', 0, 1, 'Заголовок рубрики', 'Предмет',         1, NULL, 'bibliosubject.subject', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '606', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '607', '', 1, 'Географічна назіва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '607', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '607', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '608', '', 1, 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '608', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', '5', 0, 0, 'Організація, до якої застосовується поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', 'a', 0, 0, 'Початковий елемент заголовку', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '608', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '610', '', 1, 'Неконтрольовані предметні терміни', 'Ключові слова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '610', 'a', 0, 1, 'Предметний термін', 'Предмет',         1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '615', '', 1, 'Предметна категорія (попереднє)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '615', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '615', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '615', 'a', 1, 0, 'Текст елемента предметної категорій', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '615', 'm', 1, 0, 'Код підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '615', 'n', 1, 0, 'Код предметної категорій', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '615', 'x', 1, 0, 'Текст підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '620', 'a', 0, 0, 'Країна', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '620', 'd', 0, 0, 'Місто', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '660', 'a', 0, 0, 'Код', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '661', '', 1, 'Код періоду часу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '661', 'a', 0, 0, 'Код періоду часу', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '675', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '675', 'a', 0, 0, 'Індекс', '',                           -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '675', 'v', 0, 0, 'Видання', '',                          -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '675', 'z', 0, 0, 'Мова видання', '',                     -1, 0, '', '', NULL, 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '676', 'a', 0, 0, 'Індекс', '',                           -1, 0, 'biblioitems.dewey', '', '', 0, '', '', NULL),
 ('NOTE', '', '676', 'v', 0, 0, 'Видання', '',                          -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '676', 'z', 0, 0, 'Мова видання', '',                     -1, 0, '', '', NULL, 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '680', '3', 0, 0, 'Номер класифікаційного запису', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '680', 'a', 0, 0, 'Класифікаційний індекс', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '680', 'b', 0, 0, 'Книжковий знак', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '686', '2', 0, 0, 'Код системи', '',                      1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '686', 'a', 0, 0, 'Індекс класифікації', '',              1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '686', 'b', 0, 0, 'Книжковий знак', '',                   -1, 0, '', '', '', 0, '', '', NULL),
 ('NOTE', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',        -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '700', '', '', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',    2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',         2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',         2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '710', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '711', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('NOTE', '', '712', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '720', '', '', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '720', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '720', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '721', '', 1, 'Родове ім’я — альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '721', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '721', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '722', '', 1, 'Родове ім’я — вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '722', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '722', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '722', '5', 1, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '722', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '722', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '801', 'a', 0, 1, 'Країна', '',                           -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('NOTE', '', '801', 'b', 1, 0, 'Установа', '',                         -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '801', 'c', 0, 0, 'Дата', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('NOTE', '', '801', 'g', 1, 0, 'Правила каталогізації', '',            -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('NOTE', '856', '', 1, 'Електронна адреса та доступ', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('NOTE', NULL, '856', 'a', 1, 0, 'Ім’я сервера (Host name)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'b', 1, 0, 'Номер доступу (Access number)', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'c', 1, 0, 'Відомості про стиснення (Compression information)', 'стиснення', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'd', 1, 0, 'Шлях (Path)', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'e', 1, 0, 'Дата і час останнього доступу (Date and Hour of Consultation and Access)', 'Час останнього доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'f', 1, 0, 'Електронне ім’я (electronic name)', 'електронне ім’я', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'g', 1, 0, 'Унікальне ім’я ресурсу (URN - Uniform Resource Name)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'h', 0, 0, 'Виконавець запиту (Processor of request)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'i', 1, 0, 'Команди (Instruction)', 'Команди',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'j', 0, 0, 'Швидкість передачі даних (BPS - bits per second)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'k', 0, 0, 'Пароль (Password)', 'Пароль',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'l', 0, 0, 'Ім’я користувача (Logon/login) ', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'm', 1, 0, 'Контактні дані для підтримки доступу (Contact for access assistance)', 'Контактні дані', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'n', 0, 0, 'Місце знаходження серверу, що позначений у підполі $a (Name of location of host)', 'адреса', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'o', 0, 0, 'Операційна система (Operating system)', 'Операційна система', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'p', 0, 0, 'Порт (Port)', 'Порт',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'q', 0, 0, 'Тип електронного формату (Electronic Format Type)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'r', 0, 0, 'Установки (Settings)', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 's', 1, 0, 'Розмір файлу (File size)', 'Розмір файлу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 't', 1, 0, 'Емуляція терміналу (Terminal emulation)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'u', 1, 0, 'Універсальна адреса ресурсу (URL - Uniform Resource Locator)', 'URL (універсальна адреса ресурсу)', -1, NULL, 'biblioitems.url', NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'v', 1, 0, 'Термін доступу за даним методом (Hours access method available)', 'Термін доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'w', 1, 0, 'Контрольний номер запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'x', 1, 0, 'Службові нотатки (Nonpublic note)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('NOTE', NULL, '856', 'z', 1, 0, 'Не службові нотатки (Public note)', 'нотатки', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
