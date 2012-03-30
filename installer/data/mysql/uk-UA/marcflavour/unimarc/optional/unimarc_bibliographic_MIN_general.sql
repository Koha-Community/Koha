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

DELETE FROM biblio_framework WHERE frameworkcode='MIN';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('MIN', '[рівень мінімального опису]');
DELETE FROM marc_tag_structure WHERE frameworkcode='MIN';
DELETE FROM marc_subfield_structure WHERE frameworkcode='MIN';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '000', '@', 0, 0, 'Маркер (контрольне поле довжиною 24 байти)', '', -1, 0, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '001', '', '', 'Ідентифікатор запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '001', '@', 0, 0, 'Номер ідентифікації примітки', '',      3, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '005', '', '', 'Ідентифікатор версії', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '010', '', 1, 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'ISBN',                  0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('MIN', '', '010', 'b', 0, 0, 'Уточнення', '',                         -1, 0, '', '', '', 0, '', '', NULL),
 ('MIN', '', '010', 'd', 0, 1, 'Умови придбання і/або ціна', '',        -1, 0, '', '', '', 0, '', '', NULL),
 ('MIN', '', '010', 'z', 0, 1, 'Помилковий ISBN', '',                   -1, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '011', '', 1, 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'ISSN',                  0, NULL, 'biblioitems.issn', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '011', 'b', 0, 0, 'Уточнення', '',                         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '011', 'd', 0, 0, 'Умови придбання і/або ціна', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '011', 'y', 0, 0, 'Анульований ISSN', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '011', 'z', 0, 0, 'Помилковий ISSN', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '012', '', 1, 'Ідентифікатор фінгерпринту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '012', '2', 0, 0, 'Код системи утворення фінгерпринту', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '012', '5', 0, 1, 'Організація, якої стосується поле ідентифікатора фінгерпринту', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '012', 'a', 0, 0, 'Фінгерпринт', '',                     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '020', '', 1, 'Номер документа в національній бібліографії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '020', 'a', 0, 0, 'Код країни', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '020', 'b', 0, 0, 'Номер', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '020', 'z', 1, 0, 'Помилковий номер', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '071', '', 1, 'Видавничі номери (для музичних матеріалів)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '071', 'a', 0, 0, 'Видавничий номер', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '071', 'b', 0, 0, 'Джерело', '',                         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '100', '', '', 'Дані загальної обробки', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '100', 'a', 0, 0, 'Дані загальної обробки', '',            3, NULL, '', '', 'unimarc_field_100.pl', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '101', 1, '', 'Мова документу', 'Мова', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '101', 'a', 1, 0, 'Мова тексту, звукової доріжки тощо', '', 1, NULL, '', 'LANG', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'b', 0, 0, 'Мова проміжного перекладу', '',         -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'c', 0, 0, 'Мова оригіналу', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'd', 0, 0, 'Мова резюме/реферату', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'e', 0, 0, 'Мова сторінок змісту', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'f', 0, 0, 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'g', 0, 0, 'Мова основної назви', '',               -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'h', 0, 0, 'Мова лібрето тощо', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'i', 0, 0, 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '101', 'j', 0, 0, 'Мова субтитрів', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '102', '', '', 'Країна публікації/виробництва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '102', 'a', 0, 0, 'Країна публікації', '',                 1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '102', 'b', 0, 0, 'Місце публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '110', '', '', 'Кодовані дані: серіальні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '110', 'a', 0, 0, 'Кодовані дані про серіальне видання', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '115', '', 1, 'Поле кодованих даних: візуально-проекційні матеріали, відеозаписи та кінофільми', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '115', 'a', 0, 0, 'Кодовані дані — загальні', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '115', 'b', 0, 0, 'Кодовані дані архівних кінофільмів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '116', '', 1, 'Поле кодованих даних: двовимірні зображувальні об’єкти', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '116', 'a', 1, 0, 'Кодовані дані для двовимірних зображувальних об’єктів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '117', '', 1, 'Поле кодованих даних: тривимірні  штучні та природні об’єкти', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '117', 'a', 0, 0, 'Кодовані дані для тривимірних штучних та природних об’єктів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '120', '', '', 'Поле кодованих даних: картографічні матеріали — загальне', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '120', 'a', 0, 0, 'Кодовані дані картографічних матеріалів (загальні)', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '123', '', 1, 'Поле кодованих даних: картографічні матеріали — масштаб та координати', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '123', 'a', 0, 1, 'Тип масштабу', '',                    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'b', 1, 0, 'Постійне відношення лінійного горизонтального масштабу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'c', 1, 0, 'Постійне відношення лінійного вертикального масштабу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'd', 0, 0, 'Координати — Західна довгота', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'e', 0, 0, 'Координати — Східна довгота', '',     -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'f', 0, 0, 'Координати — Північна широта', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'g', 0, 0, 'Координати — Південна широта', '',    -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'h', 1, 0, 'Кутовий масштаб', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'i', 0, 0, 'Схилення – Північна межа', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'j', 0, 0, 'Схилення – Південна межа', '',        -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'k', 0, 0, 'Пряме піднесення — Східна межа', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'm', 0, 0, 'Пряме піднесення — Західна межа', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'n', 0, 0, 'Рівнодення', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '123', 'o', 0, 0, 'Епоха', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '125', '', '', 'Поле кодованих даних: немузичні звукозаписи та нотні видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '125', 'a', 0, 0, 'Формат нотного видання', '',          -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '125', 'b', 0, 0, 'Визначник літературного тексту для немузичних звукозаписів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '130', '', 1, 'Поле кодованих данных: мікроформи — фізичні характеристики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '130', 'a', 1, 0, 'Мікроформа кодовані дані — фізичні характеристики', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '135', '', 1, 'Поле кодованих данных: електронні ресурси', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '135', 'a', 0, 0, 'Кодовані дані для електронних ресурсів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '140', '', '', 'Поле кодованих даних: монографічні стародруки — загальні характеристики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '140', 'a', 1, 0, 'Кодовані дані: загальні', '',         -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '141', '', 1, 'Поле кодованих даних: монографічні стародруки — специфічні характеристики примірника', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '141', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '141', 'a', 1, 0, 'Кодовані дані монографічного стародруку: специфічні характеристики примірника', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '200', 1, '', 'Назва та відомості про відповідальність', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '200', '5', 0, 1, 'Організація – власник примірника', '',  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'a', 1, 1, 'Основна назва', '',                     0, NULL, 'biblio.title', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'b', 0, 0, 'Загальне визначення матеріалу носія інформації', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'c', 0, 0, 'Основна назва твору іншого автора', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'd', 0, 0, 'Паралельна назва', '',                  0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'e', 0, 1, 'Підзаголовок', '',                      0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'f', 0, 0, 'Перші відомості про відповідальність', '', 0, NULL, 'biblio.author', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'g', 0, 0, 'Наступні відомості про відповідальність', '', 0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'h', 0, 0, 'Позначення та/або номер частини', '',   0, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'i', 0, 0, 'Найменування частини', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'v', 0, 0, 'Позначення тому', '',                   -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '200', 'z', 0, 0, 'Мова паралельної основної назви', '',   -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '205', '', 1, 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '205', 'a', 0, 0, 'Відомості про видання', '',             0, NULL, 'biblioitems.editionstatement', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '205', 'b', 0, 0, 'Додаткові відомості про видання', '',   0, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '205', 'd', 0, 0, 'Паралельні відомості про видання', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '205', 'f', 0, 0, 'Перші відомості про відповідальність відносно видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '205', 'g', 0, 0, 'Наступні відомості про відповідальність', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '206', '', 1, 'Область специфічних характеристик матеріалу: картографічні матеріали – математичні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '206', 'a', 0, 0, 'Відомості про математичні дані', '',  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '207', '', '', 'Область специфічних характеристик матеріалу: серіальні видання – нумерація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '207', 'a', 1, 0, 'Нумерація: Визначення дат і томів', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '207', 'z', 1, 0, 'Джерело інформації про нумерацію', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '208', '', '', 'Область специфічних характеристик матеріалу: відомості про printed music specific statement', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '208', 'a', 0, 0, 'Специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '208', 'd', 1, 0, 'Паралельні специфічні відомості про нотне видання', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '210', '', '', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '210', 'a', 0, 0, 'Місце публікування, друку, розповсюдження', '', 0, NULL, 'biblioitems.place', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'b', 0, 1, 'Адреса видавця, розповсюджувача, тощо', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'c', 0, 0, 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, NULL, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'd', 0, 0, 'Дата публікації, розповсюдження, тощо', '', 0, NULL, 'biblioitems.publicationyear', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'e', 0, 0, 'Місце виробництва', '',                 -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'f', 1, 0, 'Адреса виробника', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'g', 1, 0, 'Ім’я виробника, найменування друкарні', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '210', 'h', 1, 0, 'Дата виробництва', '',                  -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '215', '', 1, 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '215', 'a', 0, 0, 'Специфічне визначення матеріалу та обсяг документа', '', 1, NULL, 'biblioitems.pages', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '215', 'c', 0, 0, 'Інші уточнення фізичних характеристик', '', -1, NULL, 'biblioitems.illus', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '215', 'd', 0, 0, 'Розміри', '',                           1, NULL, 'biblioitems.size', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '215', 'e', 0, 0, 'Супроводжувальний матеріал', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '225', '', 1, 'Серія', 'Серія', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '225', 'a', 0, 0, 'Назва серії', '',                       1, NULL, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'd', 0, 0, 'Паралельна назва серії', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'e', 0, 0, 'Підзаголовок', '',                      -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'f', 0, 0, 'Відомості про відповідальність', '',    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'h', 0, 0, 'Номер частини', '',                     -1, NULL, 'biblioitems.number', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'i', 0, 0, 'Найменування частини', '',              1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'v', 0, 0, 'Визначення тому', '',                   1, NULL, 'biblioitems.volume', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'x', 0, 0, 'ISSN серії', '',                        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '225', 'z', 0, 0, 'Мова паралельної назви', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '230', '', 1, 'Область специфіки матеріалу: характеристики електронного ресурсу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '230', 'a', 0, 0, 'Визначення типу та розміру електронного ресурсу', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '316', '', 1, 'Примітки щодо каталогізованого примірника', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '316', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '316', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '317', '', 1, 'Примітки щодо походження', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '317', '5', 0, 1, 'Організація, до якої додається поле', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '317', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '324', '', '', 'Примітка про версію оригіналу (факсіміле)', 'Примітки', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '324', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '325', '', 1, 'Примітки щодо відтворення', 'Примітки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '325', 'a', 0, 0, 'Текст примітки', '',                  -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '430', '', 1, 'Продовжується', 'Продовжується', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '430', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '430', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '430', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '430', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '430', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '431', '', 1, 'Продовжується в частково', 'Продовжується в частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '431', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '431', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '431', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '431', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '431', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '434', '', 1, 'Поглинуте', 'Поглинуте', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '434', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '434', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '434', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '434', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '434', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '435', '', 1, 'Поглинене частково', 'Поглинене частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '435', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '435', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '435', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '435', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '435', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '436', '', 1, 'Утворене злиттям ..., ..., та ...', 'Утворене злиттям ..., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '436', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '436', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '436', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '436', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '436', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '440', '', 1, 'Продовжено як', 'Продовжено як', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '440', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '440', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '440', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '440', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '440', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '441', '', 1, 'Продовжено частково', 'Продовжено частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '441', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '441', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '441', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '441', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '441', 'z', 0, 0, 'CODEN+', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '444', '', 1, 'Те, що поглинуло', 'Те, що поглинуло', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '444', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '444', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '444', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '444', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '444', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '445', '', 1, 'Те, що поглинуло частково', 'Те, що поглинуло частково', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '445', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '445', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '445', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '445', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '445', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '446', '', 1, 'Поділилося на .., ..., та ...', 'Поділилося на .., ..., та ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '446', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '446', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '446', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '446', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '446', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '447', '', 1, 'Злито з ... та ... щоб утворити ...', 'Злито з ... та ... щоб утворити ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '447', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '447', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '447', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '447', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '447', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '448', '', 1, 'Повернулося до попередньої назви', 'Повернулося до попередньої назви', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '448', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '448', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '448', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '448', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '448', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '461', '', 1, 'Набір', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '461', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '461', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', '5', 0, 0, 'Установа в якій поле застосовано', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'a', 0, 0, 'Автор', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'c', 0, 0, 'Місце публікації', '',                  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'd', 0, 0, 'Дата публікації', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'e', 0, 0, 'Відомості про видання', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'h', 0, 0, 'Номер розділу або частини', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'i', 0, 0, 'Назва розділу або частини', '',         -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'p', 0, 0, 'Фізичний опис', '',                     -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 't', 0, 0, 'Назва', '',                             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'u', 0, 0, 'URL', '',                               -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'v', 0, 0, 'Номер тому', '',                        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '461', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '463', '', 1, 'Окрема фізична одиниця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '463', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '463', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '463', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '463', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '463', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '481', '', 1, 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '481', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '481', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '481', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '481', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '481', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '482', '', 1, 'Переплетено з', 'Переплетено з', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', NULL, '482', '0', 0, 0, 'Ідентифікатор бібліографічного запису', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '482', '1', 0, 1, 'Дані, які пов’язуються', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', NULL, '482', '3', 0, 0, 'Номер авторитетного запису', '',      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', '5', 0, 0, 'Установа в якій поле застосовано', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'a', 0, 0, 'Автор', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'c', 0, 0, 'Місце публікації', '',                -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'd', 0, 0, 'Дата публікації', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'e', 0, 0, 'Відомості про видання', '',           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'h', 0, 0, 'Номер розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'i', 0, 0, 'Назва розділу або частини', '',       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'p', 0, 0, 'Фізичний опис', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 't', 0, 0, 'Назва', '',                           -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'u', 0, 0, 'URL', '',                             -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'v', 0, 0, 'Номер тому', '',                      -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'x', 0, 0, 'Міжнародний стандартний номер серіального видання – ISSN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '482', 'y', 0, 0, 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '482', 'z', 0, 0, 'CODEN', '',                             -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '500', '', 1, 'Уніфікована форма назви', 'Назва', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '500', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'a', 0, 0, 'Уніфікована форма назви', 'Назва',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'b', 0, 0, 'Загальне визначення матеріалу носія документа', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'j', 0, 0, 'Підрозділ форми твору', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'v', 0, 0, 'Визначення тому', '',                   -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '500', 'z', 0, 0, 'Хронологічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '530', '', 1, 'Ключова назва (серіальні видання)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '530', '2', 0, 0, 'Код системи', '',                       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '530', 'a', 0, 0, 'Ключова назва', '',                   -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '530', 'b', 0, 0, 'Уточнення', '',                       -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'h', 0, 0, 'Номер розділу або частини', 'Номер',    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'i', 0, 0, 'Найменування розділу або частини', '',  -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '530', 'j', 0, 0, 'Том або дата, пов’язані з ключовою назвою', '', -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'k', 0, 0, 'Дата публікації', 'Опубліковано',       -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'l', 0, 0, 'Підзаголовок форми (підназва форми)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'm', 0, 0, 'Мова (якщо є частиною заголовка)', 'Мова', -1, NULL, '', 'LANGUE', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'n', 0, 0, 'Змішана інформація', '',                -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'q', 0, 0, 'Версія (або дата версії)', '',          -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'r', 0, 0, 'Засоби виконання (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 's', 0, 0, 'Числове визначення  музичних творів', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'u', 0, 0, 'Ключ  музичних творів', '',             -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', NULL, '530', 'v', 0, 0, 'Визначення тому', '',                 -1, NULL, NULL, NULL, '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'w', 0, 0, 'Відомості про аранжування (для музичних творів)', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'x', 0, 0, 'Тематичний (предметний) підрозділ', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'y', 0, 0, 'Географічний підрозділ', '',            -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '530', 'z', 0, 0, 'Хронологічний підрозділ', '',           -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '700', '', 1, 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '700', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'a', 0, 0, 'Початковий елемент вводу', 'автор',     2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'c', 0, 0, 'Доповнення до імені окрім дат', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'd', 0, 0, 'Римські цифри', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'f', 0, 0, 'Дати', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '700', 'p', 0, 0, 'Службові відомості про особу', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '701', '', 1, 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '701', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'a', 0, 0, 'Початковий елемент вводу', '',          2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'b', 0, 0, 'Частина імені, яка відрізняється від початкового елемента вводу', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'c', 0, 0, 'Доповнення до імені окрім дат', '',     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'd', 0, 0, 'Римські цифри', '',                     -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'f', 0, 0, 'Дати', '',                              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'g', 0, 0, 'Розкриття ініціалів власного імені', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '701', 'p', 0, 0, 'Службові відомості про особу', '',      -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '710', '', 1, 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '710', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'a', 0, 0, 'Початковий елемент заголовку', '',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'b', 0, 0, 'Структурний підрозділ', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'c', 0, 0, 'Ідентифікаційні ознаки', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'e', 0, 0, 'Місце проведення  заходу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'f', 0, 0, 'Дата проведення заходу', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'g', 0, 0, 'Інверсований елемент', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '710', 'p', 0, 0, 'Адреса', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '711', '', 1, 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '711', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', '4', 0, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'a', 0, 0, 'Початковий елемент заголовку', '',      2, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'b', 1, 0, 'Структурний підрозділ', '',             -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'c', 1, 0, 'Ідентифікаційні ознаки', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'd', 0, 0, 'Порядковий номер заходу або його частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'e', 0, 0, 'Місце проведення  заходу', '',          -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'f', 0, 0, 'Дата проведення заходу', '',            -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'g', 0, 0, 'Інверсований елемент', '',              -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'h', 0, 0, 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', -1, NULL, '', '', '', NULL, '', NULL, NULL),
 ('MIN', '', '711', 'p', 0, 0, 'Адреса', '',                            -1, NULL, '', '', '', NULL, '', NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '720', '', 1, 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '720', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '720', '4', 1, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '720', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '720', 'f', 0, 0, 'Дати', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '721', '', 1, 'Родове ім’я — альтернативна інтелектуальна відповідальність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '721', '3', 0, 0, 'Номер авторитетного запису', '',        -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '721', '4', 1, 0, 'Код відношення', '',                    -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '721', 'a', 0, 0, 'Початковий елемент заголовку/точки доступу', '', -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '721', 'f', 0, 0, 'Дати', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('MIN', '801', '', 1, 'Джерело походження запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('MIN', '', '801', '2', 0, 0, 'Код бібліографічного формату', '',      -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '801', 'a', 0, 1, 'Країна', '',                            -1, NULL, '', 'COUNTRY', '', NULL, NULL, NULL, 'UA'),
 ('MIN', '', '801', 'b', 1, 0, 'Установа', '',                          -1, NULL, '', 'SOURCE', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '801', 'c', 0, 0, 'Дата', '',                              -1, NULL, '', '', '', NULL, NULL, NULL, NULL),
 ('MIN', '', '801', 'g', 1, 0, 'Правила каталогізації', '',             -1, NULL, '', '', '', NULL, NULL, NULL, 'psbo');
