# **************************************************************************
#             UKRMARC - UKRAINIAN UNIMARC FOR BIBLIOGRAPHIC
#           СТРУКТУРА KOHA УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ
#
# version 0.8.1 (13.12.2011) - for 801^a added authorised_value='COUNTRY' and defaultvalue='UA'
#                              for 801^g added defaultvalue='psbo'
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

DELETE FROM biblio_framework WHERE frameworkcode='TECH';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('TECH', 'нормативно-технічні та неопубліковані матеріали');
DELETE FROM marc_tag_structure WHERE frameworkcode='TECH';
DELETE FROM marc_subfield_structure WHERE frameworkcode='TECH';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',     3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '005', '', '', 'Ідентифікатор версії', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                 0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('TECH', '', '010', 'b', 0, 0, 'Уточнення', '',                        -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                  -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '011', '', 1, 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'ISSN',                 0, NULL, 'biblioitems.issn', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '011', 'b', 0, 0, 'Уточнення', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '011', 'd', 0, 0, 'Умови придбання і/або ціна', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '011', 'y', 0, 0, 'Анульований ISSN', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '011', 'z', 0, 0, 'Помилковий ISSN', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '012', '', 1, 'Ідентифікатор фінгерпринту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '012', '2', 0, 0, 'Код системи утворення фінгерпринту', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '012', '5', 0, 1, 'Організація, якої стосується поле ідентифікатора фінгерпринту', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '012', 'a', 0, 0, 'Фінгерпринт', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '013', '', 1, 'Міжнародний стандартний номер нотного видання (ISMN)', 'ISMN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '013', 'a', 0, 0, 'Код ISMN', 'ISMN',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '013', 'b', 0, 0, 'Характеристики', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '013', 'd', 0, 0, 'Умови придбання та/або ціна', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '013', 'z', 1, 0, 'Помилковий ISMN', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '014', '', 1, 'Ідентифікатор статті', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '014', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '014', 'a', 0, 0, 'Ідентифікатор статті', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '014', 'z', 1, 0, 'Помилковий ідентифікатор статті', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '015', '', 1, 'Міжнародний стандартний номер технічного звіту (ISRN)', 'ISRN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '015', 'a', 0, 0, 'Код ISRN', 'ISRN',                     0, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '015', 'b', 0, 0, 'Характеристики', '',                   -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '015', 'd', 0, 0, 'Умови придбання і/або ціна', '',       -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '015', 'z', 0, 1, 'Скасований/недійсний/помилковий ISRN', '', -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '016', '', 1, 'Міжнародний стандартний код звуко-/відео-/аудіовізу­ального запису (ISRC)', 'ISRC', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '016', 'a', 0, 0, 'Код ISRC', 'ISRC',                     0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '016', 'b', 0, 0, 'Характеристики', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '016', 'd', 0, 0, 'Сфера доступності та/або ціна', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '016', 'z', 1, 0, 'Помилковий ISRC', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '020', '', 1, 'Номер документа в національній бібліографії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '020', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '020', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '020', 'z', 1, 0, 'Помилковий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '021', '', 1, 'Номер державної реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '021', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '021', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '021', 'z', 1, 0, 'Помилковий номер державної реєстрації', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '022', '', 1, 'Номер публікації органів державної влади', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '022', 'a', 0, 0, 'Код країни', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '022', 'b', 0, 0, 'Номер', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '022', 'z', 1, 0, 'Помилковий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '035', '', 1, 'Інші системні номери', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '035', 'a', 0, 0, 'Ідентифікатор запису+', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '035', 'z', 1, 0, 'Скасований чи помилковий ідентифікатор запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '040', '', 1, 'CODEN (для серіальних видань)', 'CODEN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '040', 'a', 0, 0, 'CODEN', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '040', 'z', 1, 0, 'Помилковий CODEN', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '071', '', 1, 'Видавничі номери (для музичних матеріалів)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '071', 'a', 0, 0, 'Видавничий номер', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '071', 'b', 0, 0, 'Джерело', '',                        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',           3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'g', 0, 0, 'Мова основної назви', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '102', 'a', 0, 0, 'Країна публікації', '',                1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '102', 'b', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '105', '', '', 'Поле кодованих даних: текстові матеріали (монографічні)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '105', 'a', 0, 0, 'Кодовані дані про монографію', '',     3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '106', '', '', 'Поле кодованих даних: текстові матеріали — фізичні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '106', 'a', 0, 0, 'Кодовані дані позначення фізичної форми текстових матеріалів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '110', '', '', 'Кодовані дані: серіальні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '110', 'a', 0, 0, 'Кодовані дані про серіальне видання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '115', '', 1, 'Поле кодованих даних: візуально-проекційні матеріали, відеозаписи та кінофільми', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '115', 'a', 0, 0, 'Кодовані дані — загальні', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '115', 'b', 0, 0, 'Кодовані дані архівних кінофільмів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '116', '', 1, 'Поле кодованих даних: двовимірні зображувальні об’єкти', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '116', 'a', 1, 0, 'Кодовані дані для двовимірних зображувальних об’єктів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '117', '', 1, 'Поле кодованих даних: тривимірні  штучні та природні об’єкти', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '117', 'a', 0, 0, 'Кодовані дані для тривимірних штучних та природних об’єктів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '120', '', '', 'Поле кодованих даних: картографічні матеріали — загальне', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '120', 'a', 0, 0, 'Кодовані дані картографічних матеріалів (загальні)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '121', '', '', 'Поле кодованих даних: картографічні матеріали: фізичні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '121', 'a', 0, 0, 'Кодовані дані картографічних матеріалів: фізичні характеристики (загальні)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '121', 'b', 1, 0, 'Кодовані дані аерофотографічної та космічної зйомки: Фізичні характеристики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '122', '', 1, 'Поле кодованих даних: період часу, охоплюваний змістом документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '122', 'a', 1, 0, 'Період часу від 9999 до н.е. до теперішнього часу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '123', '', 1, 'Поле кодованих даних: картографічні матеріали — масштаб та координати', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '123', 'a', 0, 1, 'Тип масштабу', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'b', 1, 0, 'Постійне відношення лінійного горизонтального масштабу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'c', 1, 0, 'Постійне відношення лінійного вертикального масштабу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'd', 0, 0, 'Координати — Західна довгота', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'e', 0, 0, 'Координати — Східна довгота', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'f', 0, 0, 'Координати — Північна широта', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'g', 0, 0, 'Координати — Південна широта', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'h', 1, 0, 'Кутовий масштаб', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'i', 0, 0, 'Схилення – Північна межа', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'j', 0, 0, 'Схилення – Південна межа', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'k', 0, 0, 'Пряме піднесення — Східна межа', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'm', 0, 0, 'Пряме піднесення — Західна межа', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'n', 0, 0, 'Рівнодення', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '123', 'o', 0, 0, 'Епоха', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '124', '', '', 'Поле кодованих даних: картографічні матеріали — специфічні характеристики матеріалу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '124', 'a', 0, 0, 'Характеристика зображення', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'b', 1, 0, 'Форма картографічного документу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'c', 1, 0, 'Техніка подання фотографічних або нефотографічних зображень', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'd', 1, 0, 'Позиція платформи фотографування або дистанційного датчика', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'e', 1, 0, 'Категорія супутника для одержання дистанційного зображення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'f', 1, 0, 'Найменування супутника для дистанційного зображення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '124', 'g', 1, 0, 'Техніка запису для одержання дистанційного зображення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '125', '', '', 'Поле кодованих даних: немузичні звукозаписи та нотні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '125', 'a', 0, 0, 'Формат нотного видання', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '125', 'b', 0, 0, 'Визначник літературного тексту для немузичних звукозаписів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '126', '', 1, 'Поле кодованих даних: звукозаписи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '126', 'a', 1, 0, 'Кодовані дані: загальні', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '126', 'b', 0, 0, 'Кодовані дані: спеціальні', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '127', '', '', 'Поле кодованих даних: тривалість звукозаписів і музичного виконання (для нотних видань)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '127', 'a', 1, 0, 'Тривалість', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '128', '', 1, 'Поле кодованих даних: жанр і форма музичної композиції,засоби виконання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '128', 'a', 1, 0, 'Жанр і форма твору (музичне відтворення або партитура)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '128', 'b', 1, 0, 'Інструменти або голоси для ансамблів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '128', 'c', 1, 0, 'Інструменти або голоси для солістів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '130', '', 1, 'Поле кодованих данных: мікроформи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '130', 'a', 1, 0, 'Мікроформа кодовані дані — фізичні характеристики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '131', '', '', 'Поле кодованих даних: картографічні матеріали — геодезичні та координатні сітки та система вимірів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '131', 'a', 1, 0, 'Сфероїд', '',                        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'b', 1, 0, 'Горизонтальна основа системи координат', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'c', 1, 0, 'Сітка координат', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'd', 1, 0, 'Накладені сітки', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'e', 1, 0, 'Додаткова сітка', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'f', 1, 0, 'Початок відліку висот', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'g', 1, 0, 'Одиниці виміру висот', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'h', 1, 0, 'Переріз рельєфу', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'i', 1, 0, 'Допоміжний переріз рельєфу', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'j', 1, 0, 'Одиниці батиметричного виміру глибин', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'k', 1, 0, 'Батиметричні інтервали (шкала глибин)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '131', 'l', 1, 0, 'Додаткові ізобати (додатковий батиметричний інтервал)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '135', '', 1, 'Поле кодованих данных: електронні ресурси', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '135', 'a', 0, 0, 'Кодовані дані для електронних ресурсів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '140', '', '', 'Поле кодованих даних: монографічні стародруки — загальні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '140', 'a', 1, 0, 'Кодовані дані: загальні', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '141', '', 1, 'Поле кодованих даних: монографічні стародруки — специфічні характеристики примірника', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '141', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '141', 'a', 1, 0, 'Кодовані дані монографічного стародруку: специфічні характеристики примірника', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '200', '5', 0, 1, 'Організація – власник примірника', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'a', 1, 1, 'Основна назва', '',                    0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'd', 0, 0, 'Паралельна назва', '',                 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'e', 0, 1, 'Підзаголовок', '',                     0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',  0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'i', 0, 0, 'Найменування частини', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'v', 0, 0, 'Позначення тому', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '205', 'a', 0, 0, 'Відомості про видання', '',            0, NULL, 'biblioitems.editionstatement', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',  0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '206', '', 1, 'Область специфічних характеристик матеріалу: картографічні матеріали – математичні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '206', 'a', 0, 0, 'Відомості про математичні дані', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '207', '', '', 'Область специфічних характеристик матеріалу: серіальні видання – нумерація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '207', 'a', 1, 0, 'Нумерація: Визначення дат і томів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '207', 'z', 1, 0, 'Джерело інформації про нумерацію', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '208', '', '', 'Область специфічних характеристик матеріалу: відомості про printed music specific statement', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '208', 'a', 0, 0, 'Специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '208', 'd', 1, 0, 'Паралельні специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'e', 0, 0, 'Місце виробництва', '',                -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'f', 1, 0, 'Адреса виробника', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '210', 'h', 1, 0, 'Дата виробництва', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '211', '', '', 'Запланована дата публікації', 'Запланована дата публікації', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '211', 'a', 0, 0, 'Дата', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '215', '', 1, 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '215', 'a', 0, 0, 'Специфічне визначення матеріалу та обсяг документа', '', 1, NULL, 'biblioitems.pages', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '215', 'c', 0, 0, 'Інші уточнення фізичних характеристик', '', -1, NULL, 'biblioitems.illus', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '215', 'd', 0, 0, 'Розміри', '',                          1, NULL, 'biblioitems.size', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '215', 'e', 0, 0, 'Супроводжувальний матеріал', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '225', 'a', 0, 0, 'Назва серії', '',                      1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'e', 0, 0, 'Підзаголовок', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'h', 0, 0, 'Номер частини', '',                    -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'i', 0, 0, 'Найменування частини', '',             1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'v', 0, 0, 'Визначення тому', '',                  1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'x', 0, 0, 'ISSN серії', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '230', '', 1, 'Область специфіки матеріалу: характеристики електронного ресурсу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '230', 'a', 0, 0, 'Визначення типу та розміру електронного ресурсу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '300', '', 1, 'Загальні примітки', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '300', 'a', 0, 0, 'Текст примітки', '',                   1, NULL, 'biblio.notes', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '301', '', 1, 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '301', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '302', '', 1, 'Примітки, що відносяться до кодованої інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '302', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '303', '', 1, 'Примітки, що відносяться до описової інформації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '303', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '304', '', 1, 'Примітки, що відносяться  до назви і відомостей про відповідальність', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '304', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '305', '', '', 'Примітки про видання та бібліографічну історію', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '305', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '306', '', 1, 'Примітки щодо публікації, розповсюдження тощо', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '306', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '307', '', 1, 'Примітки щодо кількісної/фізичної характеристики', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '307', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '308', '', 1, 'Примітки щодо серій', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '308', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '310', '', 1, 'Примітки щодо оправи та умов придбання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '310', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '311', '', 1, 'Примітки щодо полів зв’язку', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '311', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '312', '', 1, 'Примітки щодо співвіднесених назв', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '312', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '313', '', 1, 'Примітки щодо предметного доступу', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '313', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '314', '', 1, 'Примітки щодо інтелектуальної відповідальності', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '314', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '315', '', 1, 'Примітки щодо специфічних характеристик матеріалу або типу публікації', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '315', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '316', '', 1, 'Примітки щодо каталогізованого примірника', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '316', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '316', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '317', '', 1, 'Примітки щодо походження', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '317', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '317', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '318', '', 1, 'Примітки щодо поводження з примірником', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '318', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'a', 0, 0, 'Поводження', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'b', 1, 0, 'Ідентифікація поводження', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'c', 1, 0, 'Час поводження', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'd', 1, 0, 'Інтервал поводження', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'e', 1, 0, 'Робота з непередбачуваними обставинами', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'f', 1, 0, 'Авторизація', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'h', 1, 0, 'Повноваження', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'i', 1, 0, 'Метод роботи', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'j', 1, 0, 'Місце роботи', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'k', 1, 0, 'Виконавець роботи', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'l', 1, 0, 'Статус', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'n', 1, 0, 'Межі роботи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'o', 1, 0, 'Тип одиниці', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'p', 1, 0, 'Примітка, не призначена для друку', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '318', 'r', 1, 0, 'Примітка, призначена для друку', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '320', '', 1, 'примітка про наявність бібліографії/покажчиків', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '320', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '321', '', 1, 'Примітка про видані окремо покажчики, реферати, посилання', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '321', 'a', 0, 0, 'Примітка про покажчики, реферати, посилання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '321', 'b', 0, 0, 'Дати обсягу', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '321', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '322', '', '', 'Примітки щодо переліку учасників підготовки матеріалу до випуску (проекційні та відеоматеріали і звукозаписи)', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '322', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '323', '', 1, 'Примітки щодо складу виконавців (проекційні та відеоматеріали і звукозаписи)', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '323', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '324', '', '', 'Примітка про версію оригіналу (факсіміле)', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '324', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '325', '', 1, 'Примітки щодо відтворення', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '325', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '326', '', 1, 'Примітки про періодичність (серіальні видання)', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '326', 'a', 0, 0, 'Періодичність', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '326', 'b', 0, 0, 'Дати періодичності', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '327', '', '', 'Примітки про зміст', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '327', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '328', '', 1, 'Примітки про дисертацію', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '328', 'a', 0, 0, 'Текст примітки', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '330', '', 1, 'Короткий звіт або резюме', 'Короткий зміст', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '330', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '332', '', 1, 'Бажана форма посилання для матеріалів, що оброблюються', 'Бажана форма посилання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '332', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '333', '', 1, 'Примітка про читацьке призначення', 'Приміти про особливості користування та поширення', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '333', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '334', '', 1, 'Примітки про нагороди*', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '334', 'a', 0, 0, 'Текст примітки про нагороду', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '334', 'b', 0, 0, 'Назва нагороди', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '334', 'c', 0, 0, 'Рік присудження нагороди', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '334', 'd', 0, 0, 'Країна присудження нагороди', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '336', '', 1, 'Примітки про тип електронного ресурсу', 'Примітки про тип електронного ресурсу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '336', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '337', '', 1, 'Примітки про системні вимоги (електронні ресурси)', 'Системні вимоги', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '337', 'a', 0, 0, 'Текст примітки', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '345', '', '', 'Примітка про відомості щодо комплектування', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '345', 'a', 0, 0, 'Адреса та джерело комплектування/передплати', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '345', 'b', 1, 0, 'Реєстраційний номер документа', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '345', 'c', 1, 0, 'Фізичний носій', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '345', 'd', 1, 0, 'Умови придбання. Ціна документа.', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '410', '', 1, 'Серії (поле зв’язку)', 'Серії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '410', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '410', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', '@', 0, 0, 'номер ідентифікації примітки', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 't', 0, 0, 'Назва', '',                            1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '410', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '411', '', 1, 'Підсерії', 'Підсерії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '411', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '411', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '411', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '411', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '411', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '421', '', 1, 'Додаток', 'Додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '421', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '421', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '421', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '421', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '421', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '422', '', 1, 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '422', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '422', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '422', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '422', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '422', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '423', '', 1, 'Видано з', 'Видано з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '423', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '423', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '423', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '423', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '423', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '430', '', 1, 'Продовжується', 'Продовжується', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '430', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '430', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '430', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '430', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '430', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '431', '', 1, 'Продовжується в частково', 'Продовжується в частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '431', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '431', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '431', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '431', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '431', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '432', '', 1, 'Заміщує', 'Заміщує', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '432', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '432', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '432', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '432', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '432', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '433', '', 1, 'Заміщує в частково', 'Заміщує в частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '433', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '433', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '433', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '433', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '433', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '434', '', 1, 'Поглинуте', 'Поглинуте', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '434', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '434', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '434', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '434', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '434', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '435', '', 1, 'Поглинене частково', 'Поглинене частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '435', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '435', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '435', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '435', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '435', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '436', '', 1, 'Утворене злиттям ..., ..., та ...', 'Утворене злиттям ..., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '436', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '436', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '436', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '436', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '436', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '437', '', 1, 'Відокремилось від…', 'Відокремилось від…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '437', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '437', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '437', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '437', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '437', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '440', '', 1, 'Продовжено як', 'Продовжено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '440', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '440', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '440', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '440', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '440', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '441', '', 1, 'Продовжено частково', 'Продовжено частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '441', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '441', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '441', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '441', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '441', 'z', 0, 0, 'CODEN+', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '442', '', 1, 'Заміщене', 'Заміщене', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '442', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '442', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '442', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '442', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '442', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '443', '', 1, 'Заміщено частково', 'Заміщено частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '443', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '443', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '443', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '443', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '443', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '444', '', 1, 'Те, що поглинуло', 'Те, що поглинуло', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '444', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '444', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '444', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '444', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '444', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '445', '', 1, 'Те, що поглинуло частково', 'Те, що поглинуло частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '445', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '445', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '445', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '445', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '445', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '446', '', 1, 'Поділилося на .., ..., та ...', 'Поділилося на .., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '446', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '446', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '446', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '446', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '446', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '447', '', 1, 'Злито з ... та ... щоб утворити ...', 'Злито з ... та ... щоб утворити ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '447', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '447', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '447', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '447', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '447', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '448', '', 1, 'Повернулося до попередньої назви', 'Повернулося до попередньої назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '448', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '448', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '448', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '448', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '448', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '451', '', 1, 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '451', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '451', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '451', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '451', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '451', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '452', '', 1, 'Інше видання на іншому носії', 'Видання на іншому носії', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '452', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '452', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '452', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '452', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '452', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '453', '', 1, 'Перекладено як', 'Перекладено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '453', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '453', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '453', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '453', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '453', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '454', '', 1, 'Перекладено з…', 'Перекладено з…', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '454', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '454', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', '@', 0, 0, 'номер ідентифікації примітки', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '454', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '455', '', 1, 'Відтворено з…', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '455', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '455', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '455', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '455', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '455', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '456', '', 1, 'Відтворено як', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '456', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '456', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '456', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '456', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '456', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'a', 0, 0, 'Автор', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'c', 0, 0, 'Місце публікації', '',                 -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'd', 0, 0, 'Дата публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'e', 0, 0, 'Відомості про видання', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'p', 0, 0, 'Фізичний опис', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 't', 0, 0, 'Назва', '',                            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'u', 0, 0, 'URL', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'v', 0, 0, 'Номер тому', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '461', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '462', '', 1, 'Піднабір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '462', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '462', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '462', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '462', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '462', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '463', '', 1, 'Окрема фізична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '463', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '463', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '463', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '463', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '463', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '464', '', 1, 'Аналітична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '464', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '464', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '464', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '464', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '464', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '470', '', 1, 'Документ, що є предметом огляду/рецензії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '470', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '470', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '470', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '470', 'y', 0, 0, 'IМіжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '470', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '481', '', 1, 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '481', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '481', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '481', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '481', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '481', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '482', '', 1, 'Переплетено з', 'Переплетено з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '482', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '482', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '482', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '482', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '482', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '488', '', 1, 'Інший співвіднесений твір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '488', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '488', '1', 0, 1, 'Дані, які пов’язуються', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', NULL, '488', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'a', 0, 0, 'Автор', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'c', 0, 0, 'Місце публікації', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'd', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'e', 0, 0, 'Відомості про видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'h', 0, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'i', 0, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'p', 0, 0, 'Фізичний опис', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 't', 0, 0, 'Назва', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'u', 0, 0, 'URL', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'v', 0, 0, 'Номер тому', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '488', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '488', 'z', 0, 0, 'CODEN', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '500', '', 1, 'Уніфікована форма назви', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '500', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'a', 0, 0, 'Уніфікована форма назви', 'Назва',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '500', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '501', '', 1, 'Загальна уніфікована назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '501', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'a', 0, 0, 'Типова назва', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'b', 1, 0, 'Загальне визначення матеріалу', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'e', 0, 0, 'Типова підназва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '501', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '501', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'j', 0, 0, 'Підрозділ форми', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'm', 0, 0, 'Мова (якщо є частиною заголовку)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'r', 1, 0, 'Засоби виконання музичних творів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 's', 1, 0, 'Порядкове визначення  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'u', 0, 0, 'Ключ  музичного твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'w', 0, 0, 'Відомості про аранжування  музичного твору', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'x', 1, 0, 'Тематичний підрозділ', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'y', 1, 0, 'Географічний підрозділ', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '501', 'z', 1, 0, 'Хронологічний підрозділ', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '503', '', 1, 'Уніфікований обумовлений заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '503', 'a', 0, 0, 'Основний уніфікований умовний заголовок', 'Заголовок', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'b', 0, 0, 'Підзаголовок уніфікованого умовного заголовку', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'd', 0, 0, 'Місяць і день', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'e', 0, 0, 'Прізвище особи', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'f', 0, 0, 'Ім’я особи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'h', 0, 0, 'Визначник персонального імені', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'i', 0, 0, 'Назва частини', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'j', 0, 0, 'Рік', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'k', 0, 0, 'Нумерація (арабська)', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'l', 0, 0, 'Нумерація (римська)', '',              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'm', 0, 0, 'Місцевість', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '503', 'n', 0, 0, 'Установа у місцевості', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '510', '', 1, 'Паралельна основна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '510', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'a', 0, 0, 'Паралельна назва', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'j', 0, 0, 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'n', 0, 0, 'Різна інформація', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '510', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '510', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '512', '', 1, 'Назва обкладинки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '512', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'a', 0, 0, 'Назва обкладинки', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'e', 1, 0, 'Інші відомості щодо назви обкладинки', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '512', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '512', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '513', '', 1, 'Назва на додатковому титульному аркуші', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '513', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'a', 0, 0, 'Назва додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'e', 1, 0, 'Інші відомості щодо назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'h', 1, 0, 'Номер частини', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'i', 1, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '513', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '513', 'z', 0, 0, 'Мова назви додаткового титульного аркуша', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '514', '', 1, 'Назва на першій сторінці тексту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '514', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'a', 0, 0, 'Назва перед текстом', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '514', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '514', 'z', 0, 0, 'Мова назви обкладинки', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '515', '', 1, 'Назва на колонтитулі', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '515', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'a', 0, 0, 'Назва колонтитулу', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '515', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '515', 'z', 0, 0, 'Мова назви колонтитулу', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '516', '', 1, 'Назва на корінці', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '516', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'a', 0, 0, 'Назва на спинці', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '516', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '516', 'z', 0, 0, 'Мова назви на спинці', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '517', '', 1, 'Інші варіанти назви', 'Інші варіанти назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '517', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '517', 'a', 0, 0, 'Інший варіант назви', '',            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '517', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '517', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '517', 'z', 0, 0, 'Мова інших варіантів назв', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '518', '', 1, 'Назва сучасною орфографією', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '518', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'a', 0, 0, 'Основна назва, варіант назви або уніфікована форма назви сучасною орфографією, або окремі слова з них', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'e', 1, 0, 'Інша інформація щодо назви', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'i', 1, 0, 'Найменування розділу або частини', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'j', 0, 0, 'Підрозділ форми твору', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'n', 0, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '518', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '518', 'z', 0, 0, 'Мова іншої інформації щодо назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '520', '', 1, 'Попередня назва (серіальні видання)', 'Попередня назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '520', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'a', 0, 0, 'Попередня основна назва', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'e', 1, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'h', 0, 0, 'Нумерація частини (підсерії)', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'i', 0, 0, 'Найменування частини (підсерії)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'j', 0, 0, 'Томи або дати попередньої назви', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'n', 0, 0, 'Текстовий коментар стосовно змісту підполів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'x', 0, 0, 'ISSN попередньої назви', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '520', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '520', 'z', 0, 0, 'Мова попередньої назви', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '530', '', 1, 'Ключова назва (серіальні видання)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '530', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '530', 'a', 0, 0, 'Ключова назва', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '530', 'b', 0, 0, 'Уточнення', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '530', 'j', 0, 0, 'Том або дата, пов’язані з ключовою назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '530', 'v', 0, 0, 'Визначення тому', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '530', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '531', '', 1, 'Скорочена назва (серіальні видання)', 'Скорочена назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '531', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '531', 'a', 0, 0, 'Скорочена ключова назва', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '531', 'b', 0, 0, 'Уточнення', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '531', 'v', 0, 0, 'Визначення тому ', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '531', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '532', '', 1, 'Розширена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '532', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '532', 'a', 0, 0, 'Розширена назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '532', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '532', 'z', 0, 0, 'Мова назви', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '540', '', 1, 'Додаткова назва застосована каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '540', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '540', 'a', 0, 0, 'Додаткова назва', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '540', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '541', '', 1, 'Перекладена назва складена каталогізатором', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '541', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '541', 'a', 0, 0, 'Перекладена назва', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '541', 'e', 0, 0, 'Інші відомості щодо назви', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '541', 'h', 0, 0, 'Нумерація частини', '',              -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '541', 'i', 0, 0, 'Найменування частини', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '541', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '541', 'z', 0, 0, 'Мова перекладеної назви', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '545', '', 1, 'Назва розділу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '545', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '545', 'a', 0, 0, 'Назва розділу', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'h', 0, 0, 'Номер розділу або частини', 'Номер',   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'i', 0, 0, 'Найменування розділу або частини', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'j', 0, 0, 'Підрозділ форми твору', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'k', 0, 0, 'Дата публікації', 'Опубліковано',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'n', 0, 0, 'Змішана інформація', '',               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'q', 0, 0, 'Версія (або дата версії)', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'u', 0, 0, 'Ключ  музичних творів', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'v', 0, 0, 'Визначення тому', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'y', 0, 0, 'Географічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '545', 'z', 0, 0, 'Хронологічний підрозділ', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '600', '', 1, 'Ім`я особи як предметна рубрика', 'Персоналія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '600', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'b', 0, 0, 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'c', 1, 0, 'Доповнення до імені (крім дат)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'd', 0, 0, 'Римські цифри', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'g', 0, 0, 'Розкриття ініціалів особистого імені', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'p', 1, 0, 'Установа/адреса', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '600', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '601', '', 1, 'Найменування колективу як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '601', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'b', 1, 0, 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'c', 1, 0, 'Доповнення до найменування або уточнення', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'd', 0, 0, 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'e', 0, 0, 'Місце знаходження тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'f', 0, 0, 'Дати існування тимчасового колективу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'g', 0, 0, 'Інверсований елемент', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'h', 0, 0, 'Частина найменування, що відрізняється від початкового елемента заголовку рубрики й інверсованого елемента', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'j', 1, 0, 'Формальна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'x', 1, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '601', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '602', '', 1, 'Родове ім`я як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '602', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'a', 0, 0, 'Початковий елемент заголовку рубрики', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'j', 1, 0, 'Формальна підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'x', 1, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '602', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '604', '', 1, 'Автор і назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '604', '1', 1, 0, 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '605', '', 1, 'Назва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '605', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'h', 1, 0, 'Номер розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'i', 1, 0, 'Назва розділу або частини', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'j', 0, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'k', 0, 0, 'Дата публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'm', 0, 0, 'Мова (як частина предметної рубрики)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'n', 1, 0, 'Змішана інформація', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'q', 0, 0, 'Версія (або дата версії)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'r', 1, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 's', 1, 0, 'Числове визначення (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'u', 1, 0, 'Ключ (для музичних творів)', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'w', 1, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '605', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '606', '', 1, 'Найменування теми як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '606', '2', 0, 0, 'Код системи', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', 'a', 0, 1, 'Заголовок рубрики', 'Предмет',         1, NULL, 'bibliosubject.subject', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', 'j', 1, 0, 'Формальний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', 'x', 1, 0, 'Тематичний підзаголовок', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', 'y', 1, 0, 'Географічний підзаголовок', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '606', 'z', 1, 0, 'Хронологічний підзаголовок', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '607', '', 1, 'Географічна назіва як предметна рубрика', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '607', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', 'a', 0, 0, 'Заголовок рубрики', 'Предмет',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '607', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '608', '', 1, 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '608', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', '5', 0, 0, 'Організація, до якої застосовується поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', 'a', 0, 0, 'Початковий елемент заголовку', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', 'j', 1, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', 'x', 1, 0, 'Тематичний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', 'y', 1, 0, 'Географічний підзаголовок', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '608', 'z', 1, 0, 'Хронологічний підзаголовок', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '610', '', 1, 'Неконтрольовані предметні терміни', 'Ключові слова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '610', 'a', 0, 1, 'Предметний термін', 'Предмет',         1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '615', '', 1, 'Предметна категорія (попереднє)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '615', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '615', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '615', 'a', 1, 0, 'Текст елемента предметної категорій', 'Предмет', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '615', 'm', 1, 0, 'Код підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '615', 'n', 1, 0, 'Код предметної категорій', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '615', 'x', 1, 0, 'Текст підрозділу предметної категорії', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '616', '', 1, 'Товарний знак як предметна рубрика', 'Товарний знак', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '616', '2', 0, 0, 'Код системи', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'a', 0, 0, 'Початковий елемент заголовку рубрики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'c', 0, 0, 'Характеристики', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'f', 0, 0, 'Дати', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'j', 0, 0, 'Формальний підзаголовок', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'x', 0, 0, 'Тематична підрубрика', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'y', 0, 0, 'Географічна підрубрика', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '616', 'z', 0, 0, 'Хронологічна підрубрика', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '620', '', 1, 'Місце як точка доступу', 'Місце', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '620', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '620', 'a', 0, 0, 'Країна', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '620', 'b', 0, 0, 'Автономна республіка/область/штат/провінція тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '620', 'c', 0, 0, 'Район/графство/округ/повіт тощо', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '620', 'd', 0, 0, 'Місто', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '626', '', 1, 'Технічні характеристики як точка доступу: електронні ресурси', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '626', 'a', 0, 0, 'Марка та модель комп’ютера', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '626', 'b', 0, 0, 'Мова програмування', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '626', 'c', 0, 0, 'Операційна система', '',             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '629', '', 1, 'Шифр наукової спеціальності як точка доступу', 'Шифр наукової спеціальності', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '629', '3', 0, 0, 'Номер авторитетного запису', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '629', 'a', 0, 0, 'Шифр/найменування наукової спеціальності', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '629', 'b', 0, 0, 'Учений ступінь', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '629', 'c', 0, 0, 'Назва країни, де було подано дисертацію на здобуття вченого ступеню', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '660', '', 1, 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '660', 'a', 0, 0, 'Код', '',                            -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '661', '', 1, 'Код періоду часу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '661', 'a', 0, 0, 'Код періоду часу', '',               -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '670', '', 1, 'PRECIS', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '670', 'b', 0, 0, 'Номер індикатора предмета', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '670', 'c', 0, 0, 'Рядок', '',                          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '670', 'e', 1, 0, 'Код індикатора посилання', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '670', 'z', 0, 0, 'Мова терміна', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '675', '', 1, 'Універсальна десяткова класиікація', 'УДК', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '675', '3', 0, 0, 'Номер класифікаційного запису', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '675', 'a', 0, 0, 'Індекс', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '675', 'v', 0, 0, 'Видання', '',                        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '675', 'z', 0, 0, 'Мова видання', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '676', '', 1, 'Десяткова класифікація Дьюї (DDC)', 'ДКД', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '676', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '676', 'a', 0, 0, 'Індекс', '',                           -1, NULL, 'biblioitems.dewey', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '676', 'v', 0, 0, 'Видання', '',                          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '676', 'z', 0, 0, 'Мова видання', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '680', '', 1, 'Класифікація бібліотеки конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '680', '3', 0, 0, 'Номер класифікаційного запису', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '680', 'a', 0, 0, 'Класифікаційний індекс', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '680', 'b', 0, 0, 'Книжковий знак', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '686', '', 1, 'Індекси інших класифікацій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '686', '2', 0, 0, 'Код системи', '',                      1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '686', '3', 0, 0, 'Номер класифікаційного запису', '',    -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '686', 'a', 0, 0, 'Індекс класифікації', '',              1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '686', 'b', 0, 0, 'Книжковий знак', '',                   -1, 0, '', '', '', 0, '', '', NULL),
 ('TECH', '', '686', 'c', 0, 0, 'Класифікаційний підрозділ', '',        -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '700', '', '', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',    2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',         2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '702', '', 1, 'Ім’я особи – вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '702', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'a', 0, 0, 'Початковий елемент вводу', '',         2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'c', 0, 0, 'Доповнення до імені окрім дат', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'd', 0, 0, 'Римські цифри', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '702', 'p', 0, 0, 'Службові відомості про особу', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '710', '', '', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '710', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '711', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '712', '', 1, 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '712', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', '5', 0, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'a', 0, 0, 'Початковий елемент заголовку', '',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'b', 1, 0, 'Структурний підрозділ', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'c', 1, 0, 'Ідентифікаційні ознаки', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'e', 0, 0, 'Місце проведення  заходу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'f', 0, 0, 'Дата проведення заходу', '',           -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'g', 0, 0, 'Інверсований елемент', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('TECH', '', '712', 'p', 0, 0, 'Адреса', '',                           -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '716', '', 1, 'Торгова марка', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '716', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '716', '4', 0, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '716', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '716', 'c', 0, 0, 'Характеристики', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '716', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '720', '', '', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '720', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '720', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '721', '', 1, 'Родове ім’я - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '721', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '721', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '722', '', 1, 'Родове ім’я — вторинна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '722', '3', 0, 0, 'Номер авторитетного запису', '',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '722', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '722', '5', 1, 0, 'Установа-утримувач примірника', '',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '722', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '722', 'f', 0, 0, 'Дати', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '730', '', 1, 'Ім’я/найменування — інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '730', '4', 1, 0, 'Код відношення', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '730', 'a', 1, 0, 'Ім’я/найменування', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '801', 'a', 0, 1, 'Країна', '',                           -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('TECH', '', '801', 'b', 1, 0, 'Установа', '',                         -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '801', 'c', 0, 0, 'Дата', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('TECH', '', '801', 'g', 1, 0, 'Правила каталогізації', '',            -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '802', '', '', 'Центр ISSN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '802', 'a', 0, 0, 'Код центру ISSN', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '830', '', 1, 'Загальні примітки каталогізатора', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '830', 'a', 0, 0, 'Текст примітки', 'Примітка',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '856', '', 1, 'Електронна адреса та доступ', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '856', 'a', 1, 0, 'Ім’я сервера (Host name)', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'b', 1, 0, 'Номер доступу (Access number)', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'c', 1, 0, 'Відомості про стиснення (Compression information)', 'стиснення', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'd', 1, 0, 'Шлях (Path)', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'e', 1, 0, 'Дата і час останнього доступу (Date and Hour of Consultation and Access)', 'Час останнього доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'f', 1, 0, 'Електронне ім’я (electronic name)', 'електронне ім’я', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'g', 1, 0, 'Унікальне ім’я ресурсу (URN - Uniform Resource Name)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'h', 0, 0, 'Виконавець запиту (Processor of request)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'i', 1, 0, 'Команди (Instruction)', 'Команди',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'j', 0, 0, 'Швидкість передачі даних (BPS - bits per second)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'k', 0, 0, 'Пароль (Password)', 'Пароль',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'l', 0, 0, 'Ім’я користувача (Logon/login) ', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'm', 1, 0, 'Контактні дані для підтримки доступу (Contact for access assistance)', 'Контактні дані', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'n', 0, 0, 'Місце знаходження серверу, що позначений у підполі $a (Name of location of host)', 'адреса', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'o', 0, 0, 'Операційна система (Operating system)', 'Операційна система', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'p', 0, 0, 'Порт (Port)', 'Порт',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'q', 0, 0, 'Тип електронного формату (Electronic Format Type)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'r', 0, 0, 'Установки (Settings)', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 's', 1, 0, 'Розмір файлу (File size)', 'Розмір файлу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 't', 1, 0, 'Емуляція терміналу (Terminal emulation)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'u', 1, 0, 'Універсальна адреса ресурсу (URL - Uniform Resource Locator)', 'URL (універсальна адреса ресурсу)', -1, NULL, 'biblioitems.url', NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'v', 1, 0, 'Термін доступу за даним методом (Hours access method available)', 'Термін доступу', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'w', 1, 0, 'Контрольний номер запису', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'x', 1, 0, 'Службові нотатки (Nonpublic note)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'y', 0, 0, 'Метод доступу', 'Метод доступу',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '856', 'z', 1, 0, 'Не службові нотатки (Public note)', 'нотатки', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('TECH', '886', '', 1, 'Дані, не конвертовані з вихідного формату', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('TECH', NULL, '886', '2', 1, 0, 'Код правил каталогізації і форматів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '886', 'a', 1, 0, 'Мітка поля вихідного формату', '',   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('TECH', NULL, '886', 'b', 1, 0, 'Індикатори та підполя вихідного формату', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);
