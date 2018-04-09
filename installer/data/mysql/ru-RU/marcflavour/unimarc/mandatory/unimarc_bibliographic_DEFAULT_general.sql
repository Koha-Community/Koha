# **************************************************************************
#                RUSSIAN UNIMARC BIBLIOGRAPHIC
#   СТРУКТУРА KOHA РУСМАРК ДЛЯ БИБЛИОГРАФИЧЕСКИХ ЗАПИСЕЙ
#
# version 0.8 (5.1.2011) - reformating by script csv2marc_structures.pl, exrtact local data to separate file
# version 0.6 (10.9.2009) - first work russian versiuon for Коха 3.0.Х
#
# Serhij Dubyk (Сергей Дубик), serhijdubyk@gmail.com, 2009,2010,2011
#
#   SOURCE FROM:
#
# 1) RUSMARC - РОССИЙСКИЙ КОММУНИКАТИВНЫЙ ФОРМАТ (российская версия UNIMARC)
#    http://www.rba.ru/rusmarc/
#    2009
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

-- DELETE FROM biblio_framework WHERE frameworkcode='';
-- INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('', 'по умолчанию');
DELETE FROM marc_tag_structure WHERE frameworkcode='';
DELETE FROM marc_subfield_structure WHERE frameworkcode='';

# *******************************************************
#                 ПОЛЯ/ПОДПОЛЯ РУСМАРК
# *******************************************************

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '000', '', '', 'Маркер записи', 'Маркер записи', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '000', '@', 0, 0, 'Контрольное поле фиксированной длины', '', 0, 1, '', '', 'unimarc_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '001', '', '', 'Идентификатор записи', 'Идентификатор записи', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '001', '@', 0, 0, 'контрольное поле', 'контрольное поле',     0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '005', '', '', 'Идентификатор версии', 'Идентификатор версии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '005', '@', 0, 0, 'Контрольное поле', '',                     0, 1, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '010', '', 1, 'Международный стандартный номер книги (ISBN)', 'Международный стандартный номер книги (ISBN)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '010', 'a', 0, 0, 'Номер (ISBN)', 'Номер (ISBN)',             0, 0, 'biblioitems.isbn', '', '', 0, NULL, '', ''),
 ('', '', '010', 'b', 0, 1, 'Уточнения', 'Уточнения',                   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '010', 'd', 0, 0, 'Цена', 'Цена',                             0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '010', 'z', 0, 1, 'Ошибочный ISBN', 'Ошибочный ISBN',         0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '011', '', 1, 'Международный стандартный номер сериального издания (ISSN)', 'Международный стандартный номер сериального издания (ISSN)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '011', 'a', 0, 0, 'Номер (ISSN)', 'Номер (ISSN)',             0, 0, 'biblioitems.issn', '', '', 0, NULL, '', ''),
 ('', '', '011', 'b', 0, 1, 'Уточнения', 'Уточнения',                   0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '011', 'd', 0, 1, 'Цена', 'Цена',                             0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '011', 'y', 0, 1, 'Отмененный ISSN', 'Отмененный ISSN',       0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '011', 'z', 0, 1, 'Ошибочный ISSN', 'Ошибочный ISSN',         0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '012', '', 1, 'Идентификатор Фингерпринт', 'Идентификатор Фингерпринт', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '012', '2', 0, 0, 'Системный код Фингерпринт', 'Системный код Фингерпринт', 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '012', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '012', 'a', 0, 0, 'Фингерпринт', 'Фингерпринт',               0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '013', '', 1, 'Международный стандартный номер издания музыкального произведения (ISMN)', 'Международный стандартный номер издания музыкального произведения (ISMN)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '013', 'a', 0, 0, 'Номер (ISMN)', 'Номер (ISMN)',             0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '013', 'b', 0, 1, 'Уточнения', 'Уточнения',                   0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '013', 'd', 0, 0, 'Цена', 'Цена',                             0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '013', 'z', 0, 1, 'Ошибочный ISMN', 'Ошибочный ISMN',         0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '014', '', 1, 'Идентификатор статьи', 'Идентификатор статьи', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '014', '2', 0, 0, 'Код системы', 'Код системы',               0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '014', 'a', 0, 0, 'Идентификатор статьи', 'Идентификатор статьи', 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '014', 'z', 0, 1, 'Ошибочный идентификатор статьи', 'Ошибочный идентификатор статьи', 0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '015', '', 1, 'Международный стандартный номер технического отчета (ISRN)', 'Международный стандартный номер технического отчета (ISRN)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '015', 'a', 0, 0, 'Номер (ISRN)', 'Номер (ISRN)',             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '015', 'b', 0, 1, 'Уточнения', 'Уточнения',                   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '015', 'd', 0, 0, 'Цена и/или условия доступности', 'Цена и/или условия доступности', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '015', 'z', 0, 0, 'Ошибочный ISRN', 'Ошибочный ISRN',         0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '016', '', 1, 'Международный стандартный номер аудио/видео записи (ISRC)', 'Международный стандартный номер аудио/видео записи (ISRC)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '016', 'a', 0, 0, 'Номер (ISRC)', 'Номер (ISRC)',             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '016', 'b', 0, 1, 'Уточнения', 'Уточнения',                   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '016', 'd', 0, 0, 'Цена', 'Цена',                             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '016', 'z', 0, 0, 'Ошибочный ISRC', 'Ошибочный ISRC',         0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '017', '', 1, 'Другой стандартный идентификатор', 'Другой стандартный идентификатор', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '017', '2', 0, 0, 'Источник номера/кода', 'Источник номера/кода', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '017', 'a', 0, 0, 'Стандартный номер', 'Стандартный номер',   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '017', 'b', 0, 0, 'Уточнения', 'Уточнения',                   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '017', 'd', 0, 0, 'Цена', 'Цена',                             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '017', 'z', 0, 1, 'Ошибочный номер/код', 'Ошибочный номер/код', 0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '020', '', 1, 'Номер документа в национальной библиографии', 'Номер документа в национальной библиографии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '020', 'a', 0, 0, 'Код страны', 'Код страны',                 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '020', 'b', 0, 0, 'Номер', 'Номер',                           0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '020', 'z', 0, 1, 'Ошибочный номер', 'Ошибочный номер',       0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '021', '', 1, 'Номер государственной регистрации', 'Номер государственной регистрации', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '021', 'a', 0, 0, 'Код страны', 'Код страны',                 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '021', 'b', 0, 0, 'Номер', 'Номер',                           0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '021', 'z', 0, 1, 'Ошибочный номер государственной регистрации', 'Ошибочный номер государственной регистрации', 0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '022', '', 1, 'Номер публикации органа государственной власти', 'Номер публикации органа государственной власти', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '022', 'a', 0, 0, 'Код страны', 'Код страны',                 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '022', 'b', 0, 0, 'Номер', 'Номер',                           0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '022', 'z', 0, 1, 'Ошибочный номер', 'Ошибочный номер',       0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '029', '', 1, 'Номер документа (нормативно-технические и технические документы. Неопубликованные документы)', 'Номер документа (нормативно-технические и технические документы. Неопубликованные документы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '029', 'a', 0, 0, 'Страна', 'Страна',                         0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '029', 'b', 0, 1, 'Номер', 'Номер',                           0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '029', 'c', 0, 0, 'Тип номера документа', 'Тип номера документа', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '029', 'd', 0, 0, 'Индекс международной классификации', 'Индекс международной классификации', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '029', 'f', 0, 0, 'Организация', 'Организация',               0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '035', '', 1, 'Другие системные номера', 'Другие системные номера', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '035', 'a', 0, 0, 'Идентификатор записи', 'Идентификатор записи', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '035', 'z', 0, 1, 'Отмененный или ошибочный идентификатор записи', 'Отмененный или ошибочный идентификатор записи', 0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '036', '', 1, 'Музыкальный инципит', 'Музыкальный инципит', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '036', '2', 0, 0, 'Код системы музыкальной нотации', 'Код системы музыкальной нотации', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'a', 0, 0, 'Номер произведения', 'Номер произведения', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'b', 0, 1, 'Номер части', 'Номер части',               0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'c', 0, 0, 'Номер инципита', 'Номер инципита',         0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'd', 0, 0, 'Голос/инструмент', 'Голос/инструмент',     0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'e', 0, 0, 'Роль', 'Роль',                             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'f', 0, 1, 'Название части', 'Название части',         0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'g', 0, 0, 'Тональность или лад', 'Тональность или лад', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'm', 0, 0, 'Ключ', 'Ключ',                             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'n', 0, 0, 'Ключевой знак альтерации', 'Ключевой знак альтерации', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'o', 0, 0, 'Музыкальный размер', 'Музыкальный размер', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'p', 0, 0, 'Музыкальная нотация', 'Музыкальная нотация', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'q', 0, 1, 'Комментарии (произвольный текст)', 'Комментарии (произвольный текст)', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'r', 0, 0, 'Примечание в кодированной форме', 'Примечание в кодированной форме', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 't', 0, 1, 'Литературный инципит', 'Литературный инципит', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'u', 0, 1, 'Универсальный идентификатор ресурса', 'Универсальный идентификатор ресурса', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '036', 'z', 0, 1, 'Язык текста', 'Язык текста',               0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '039', '', 1, 'Номер заявки (патентные документы)', 'Номер заявки (патентные документы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '039', 'a', 0, 0, 'Страна ', 'Страна ',                       0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '039', 'b', 0, 0, 'Номер заявки', 'Номер заявки',             0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '039', 'c', 0, 0, 'Дата подачи заявки', 'Дата подачи заявки', 0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '040', '', 1, 'CODEN (для сериальних изданий)', 'CODEN (для сериальних изданий)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '040', 'a', 0, 0, 'CODEN', 'CODEN',                           0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '040', 'z', 0, 1, 'Ошибочный CODEN', 'Ошибочный CODEN',       0, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '071', '', 1, 'Издательский номер', 'Издательский номер', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '071', 'a', 0, 0, 'Номер, присвоенный агентством', 'Номер, присвоенный агентством', 0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '071', 'b', 0, 0, 'Источник ', 'Источник ',                   0, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '071', 'c', 0, 0, 'Уточнение ', 'Уточнение ',                 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '071', 'd', 0, 0, 'Цена ', 'Цена ',                           0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '071', 'z', 0, 1, 'Ошибочный номер', 'Ошибочный номер',       0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '079', '', 1, 'Издательские номера (кроме звукозаписей и нотных изданий) (устаревшее)', 'Издательские номера (кроме звукозаписей и нотных изданий) (устаревшее)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '079', 'a', 0, 0, 'Издательский номер, присвоенный агентством', 'Издательский номер, присвоенный агентством', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '079', 'b', 0, 0, 'Источник ', 'Источник ',                   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '079', 'd', 0, 0, 'Цена ', 'Цена ',                           0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '079', 'z', 0, 1, 'Ошибочный номер', 'Ошибочный номер',       0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '100', '', '', 'Данные общей обработки', 'Данные общей обработки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '100', 'a', 0, 0, 'Данные общей обработки', 'Данные общей обработки', 1, 0, '', '', 'unimarc_field_100.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '101', '', '', 'Язык документа', 'Язык документа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '101', 'a', 0, 1, 'Язык текста, звукозаписи и т.д.', 'Язык текста, звукозаписи и т.д.', 1, 0, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'b', 0, 1, 'Язык промежуточного перевода', 'Язык промежуточного перевода', 1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'c', 0, 1, 'Язык оригинала', 'Язык оригинала',         1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'd', 0, 1, 'Язык резюме', 'Язык резюме',               1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'e', 0, 1, 'Язык оглавления', 'Язык оглавления',       1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'f', 0, 1, 'Язык титульного листа', 'Язык титульного листа', 1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'g', 0, 0, 'Язык основного заглавия', 'Язык основного заглавия', 1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'h', 0, 1, 'Язык либретто и т.п.', 'Язык либретто и т.п.', 1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'i', 0, 1, 'Язык сопроводительного материала (кроме либретто, краткого содержания и аннотаци', 'Язык сопроводительного материала (кроме либретто, краткого содержания и аннотаци', 1, -5, '', 'LANG', '', 0, NULL, '', ''),
 ('', '', '101', 'j', 0, 1, 'Язык субтитров', 'Язык субтитров',         1, -5, '', 'LANG', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '102', '', '', 'Страна публикации или производства', 'Страна публикации или производства', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '102', '2', 0, 1, 'Код системы (источник кода, отличный от ISO)', 'Код системы (источник кода, отличный от ISO)', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '102', 'a', 0, 1, 'Страна публикации', 'Страна публикации',   1, 0, '', 'COUNTRY', '', 0, NULL, '', ''),
 ('', '', '102', 'b', 0, 1, 'Место издания (не ISO)', 'Место издания (не ISO)', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '102', 'c', 0, 1, 'Место издания (ISO)', 'Место издания (ISO)', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '105', '', '', 'Поле кодированных данных: текстовые материалы, монографические', 'Поле кодированных данных: текстовые материалы, монографические', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '105', 'a', 0, 0, 'Кодированные данные о монографическом текстовом документе', 'Кодированные данные о монографическом текстовом документе', 1, 0, '', '', 'unimarc_field_105.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '106', '', '', 'Поле кодированных данных: форма документа', 'Поле кодированных данных: форма документа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '106', 'a', 0, 0, 'Форма документа: кодированные данные: обозначение носителя', 'Форма документа: кодированные данные: обозначение носителя', 1, -5, '', '', 'unimarc_field_106.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '110', '', '', 'Поле кодированных данных: продолжающиеся ресурсы', 'Поле кодированных данных: продолжающиеся ресурсы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '110', 'a', 0, 0, 'Кодированные данные продолжающегося ресурса', 'Кодированные данные продолжающегося ресурса', 1, -5, '', '', 'unimarc_field_110.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '115', '', 1, 'Поле кодированных данных: визуально-проекционные материалы, видеозаписи и кинофильмы', 'Поле кодированных данных: визуально-проекционные материалы, видеозаписи и кинофильмы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '115', 'a', 0, 0, 'Кодированные данные - общие', 'Кодированные данные - общие', 1, -5, '', '', 'unimarc_field_115a.pl', 0, NULL, '', ''),
 ('', '', '115', 'b', 0, 0, 'Кинофильмы - кодированные данные архивные', 'Кинофильмы - кодированные данные архивные', 1, -5, '', '', 'unimarc_field_115b.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '116', '', 1, 'Поле кодированных данных: изобразительные материалы', 'Поле кодированных данных: изобразительные материалы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '116', 'a', 0, 0, 'Кодированные данные для изобразительных материалов', 'Кодированные данные для изобразительных материалов', 1, -5, '', '', 'unimarc_field_116.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '117', '', 1, 'Поле кодированных данных: трехмерные искусственные и естественные объекты', 'Поле кодированных данных: трехмерные искусственные и естественные объекты', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '117', 'a', 0, 0, 'Кодированные данные об искусственном или естественном трехмерном объекте', 'Кодированные данные об искусственном или естественном трехмерном объекте', 1, -5, '', '', 'unimarc_field_117.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '120', '', '', 'Поле кодированных данных: картографические материалы - общие характеристики', 'Поле кодированных данных: картографические материалы - общие характеристики', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '120', 'a', 0, 0, 'Кодированные данные о картографическом материале (общие)', 'Кодированные данные о картографическом материале (общие)', 1, -5, '', '', 'unimarc_field_120.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '121', '', '', 'Поле кодированных данных: картографические материалы - физические характеристики', 'Поле кодированных данных: картографические материалы - физические характеристики', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '121', 'a', 0, 0, 'Кодированные данные о картографическом материале: физические характеристики - об', 'Кодированные данные о картографическом материале: физические характеристики - об', 1, -5, '', '', 'unimarc_field_121a.pl', 0, NULL, '', ''),
 ('', '', '121', 'b', 0, 0, 'Кодированные данные аэросъемок и космических съемок: физические характеристики', 'Кодированные данные аэросъемок и космических съемок: физические характеристики', 1, -5, '', '', 'unimarc_field_121b.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '122', '', 1, 'Поле кодированных данных: период времени, охватываемый содержанием документа', 'Поле кодированных данных: период времени, охватываемый содержанием документа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '122', 'a', 0, 1, 'Период времени от 9999 г. до н.э. до настоящего времени', 'Период времени от 9999 г. до н.э. до настоящего времени', 1, -5, '', '', 'unimarc_field_122.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '123', '', 1, 'Поле кодированных данных: картографические материалы - масштаб и координаты', 'Поле кодированных данных: картографические материалы - масштаб и координаты', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '123', 'a', 0, 0, 'Тип масштаба', 'Тип масштаба',             1, -5, '', '', 'unimarc_field_123a.pl', 0, NULL, '', ''),
 ('', '', '123', 'b', 0, 1, 'Постоянное отношение линейного горизонтального масштаба', 'Постоянное отношение линейного горизонтального масштаба', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'c', 0, 1, 'Постоянное отношение линейного вертикального масштаба', 'Постоянное отношение линейного вертикального масштаба', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'd', 0, 0, 'Координаты - Граничная западная долгота', 'Координаты - Граничная западная долгота', 1, -5, '', '', 'unimarc_field_123d.pl', 0, NULL, '', ''),
 ('', '', '123', 'e', 0, 0, 'Координаты - Граничная восточная долгота', 'Координаты - Граничная восточная долгота', 1, -5, '', '', 'unimarc_field_123e.pl', 0, NULL, '', ''),
 ('', '', '123', 'f', 0, 0, 'Координаты - Граничная северная широта', 'Координаты - Граничная северная широта', 1, -5, '', '', 'unimarc_field_123f.pl', 0, NULL, '', ''),
 ('', '', '123', 'g', 0, 0, 'Координаты - Граничная южная широта ', 'Координаты - Граничная южная широта ', 1, -5, '', '', 'unimarc_field_123g.pl', 0, NULL, '', ''),
 ('', '', '123', 'h', 0, 1, 'Угловой масштаб', 'Угловой масштаб',       1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'i', 0, 0, 'Склонение - Северная граница', 'Склонение - Северная граница', 1, -5, '', '', 'unimarc_field_123i.pl', 0, NULL, '', ''),
 ('', '', '123', 'j', 0, 0, 'Склонение - Южная граница', 'Склонение - Южная граница', 1, -5, '', '', 'unimarc_field_123j.pl', 0, NULL, '', ''),
 ('', '', '123', 'k', 0, 0, 'Прямое восхождение - Восточная граница', 'Прямое восхождение - Восточная граница', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'm', 0, 0, 'Прямое восхождение - Западная граница', 'Прямое восхождение - Западная граница', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'n', 0, 0, 'Равноденствие ', 'Равноденствие ',         1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'o', 0, 0, 'Эпоха ', 'Эпоха ',                         1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '123', 'p', 0, 0, 'Планета, к которой относится информация в поле', 'Планета, к которой относится информация в поле', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '124', '', '', 'Поле кодированных данных: картографические материалы - специфические характеристики материала', 'Поле кодированных данных: картографические материалы - специфические характеристики материала', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '124', 'a', 0, 0, 'Характер изображения', 'Характер изображения', 1, -5, '', '', 'unimarc_field_124a.pl', 0, NULL, '', ''),
 ('', '', '124', 'b', 0, 1, 'Форма картографической единицы', 'Форма картографической единицы', 1, -5, '', '', 'unimarc_field_124b.pl', 0, NULL, '', ''),
 ('', '', '124', 'c', 0, 1, 'Способы представления фотографических и нефотографических изображений ', 'Способы представления фотографических и нефотографических изображений ', 1, -5, '', '', 'unimarc_field_124c.pl', 0, NULL, '', ''),
 ('', '', '124', 'd', 0, 1, 'Позиция площадки фотографирования или дистанционного датчика', 'Позиция площадки фотографирования или дистанционного датчика', 1, -5, '', '', 'unimarc_field_124d.pl', 0, NULL, '', ''),
 ('', '', '124', 'e', 0, 1, 'Категория спутника для получения дистанционного изображения', 'Категория спутника для получения дистанционного изображения', 1, -5, '', '', 'unimarc_field_124e.pl', 0, NULL, '', ''),
 ('', '', '124', 'f', 0, 1, 'Наименование спутника для получения дистанционного изображения', 'Наименование спутника для получения дистанционного изображения', 1, -5, '', '', 'unimarc_field_124f.pl', 0, NULL, '', ''),
 ('', '', '124', 'g', 0, 1, 'Техника записи для получения дистанционного изображения', 'Техника записи для получения дистанционного изображения', 1, -5, '', '', 'unimarc_field_124g.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '125', '', '', 'Поле кодированных данных: звукозаписи и нотные издания', 'Поле кодированных данных: звукозаписи и нотные издания', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '125', 'a', 0, 0, 'Форма изложения нотного текста', 'Форма изложения нотного текста', 1, -5, '', '', 'unimarc_field_125a.pl', 0, NULL, '', ''),
 ('', '', '125', 'b', 0, 0, 'Определитель литературного текста (для немузыкального исполнения)', 'Определитель литературного текста (для немузыкального исполнения)', 1, -5, '', '', 'unimarc_field_125b.pl', 0, NULL, '', ''),
 ('', '', '125', 'c', 0, 0, 'Несколько форм изложения нотного текста', 'Несколько форм изложения нотного текста', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '126', '', '', 'Поле кодированных данных: звукозаписи - физические характеристики', 'Поле кодированных данных: звукозаписи - физические характеристики', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '126', 'a', 0, 1, 'Кодированные данные звукозаписи (общие)', 'Кодированные данные звукозаписи (общие)', 1, -5, '', '', 'unimarc_field_126a.pl', 0, NULL, '', ''),
 ('', '', '126', 'b', 0, 0, 'Кодированные данные звукозаписи (уточнения)', 'Кодированные данные звукозаписи (уточнения)', 1, -5, '', '', 'unimarc_field_126b.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '127', '', '', 'Поле кодированных данных: продолжительность звукозаписей и нотных изданий (музыкальное исполнение)', 'Поле кодированных данных: продолжительность звукозаписей и нотных изданий (музыкальное исполнение)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '127', 'a', 0, 1, 'Продолжительность', 'Продолжительность',   1, -5, '', '', 'unimarc_field_127.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '128', '', 1, 'Поле кодированных данных: музыкальная форма, тональность и лад', 'Поле кодированных данных: музыкальная форма, тональность и лад', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '128', 'a', 0, 1, 'Музыкальная форма', 'Музыкальная форма',   1, -5, '', '', 'unimarc_field_128a.pl', 0, NULL, '', ''),
 ('', '', '128', 'b', 0, 1, '[Устаревшее] Инструменты или голоса, необходимые для ансамблей (музыкальное восп', '[Устаревшее] Инструменты или голоса, необходимые для ансамблей (музыкальное восп', 1, -5, '', '', 'unimarc_field_128b.pl', 0, NULL, '', ''),
 ('', '', '128', 'c', 0, 1, '[Устаревшее] Инструменты или голоса, рекомендуемые для солистов (музыкальное вос', '[Устаревшее] Инструменты или голоса, рекомендуемые для солистов (музыкальное вос', 1, -5, '', '', 'unimarc_field_128c.pl', 0, NULL, '', ''),
 ('', '', '128', 'd', 0, 0, 'Тональность или лад музыкального произведения', 'Тональность или лад музыкального произведения', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '130', '', 1, 'Поле кодированных данных: микроформы - физические характеристики', 'Поле кодированных данных: микроформы - физические характеристики', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '130', 'a', 0, 1, 'Кодированные данные: микроформы - физические характеристики', 'Кодированные данные: микроформы - физические характеристики', 1, -5, '', '', 'unimarc_field_130.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '131', '', '', 'Поле кодированных данных: картографические материалы - геодезические и координатные сетки и система ', 'Поле кодированных данных: картографические материалы - геодезические и координатные сетки и система ', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '131', 'a', 0, 1, 'Сфероид', 'Сфероид',                       1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'b', 0, 1, 'Горизонтальная основа системы координат', 'Горизонтальная основа системы координат.', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'c', 0, 1, 'Система координат', 'Система координат',   1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'd', 0, 1, 'Наложенные сетки', 'Наложенные сетки',     1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'e', 0, 1, 'Дополнительная сетка', 'Дополнительная сетка', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'f', 0, 1, 'Начало отсчета высот', 'Начало отсчета высот', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'g', 0, 1, 'Единицы измерения высот', 'Единицы измерения высот', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'h', 0, 1, 'Сечение рельефа', 'Сечение рельефа',       1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'i', 0, 1, 'Вспомогательное сечение рельефа', 'Вспомогательное сечение рельефа', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'j', 0, 1, 'Единицы батиметрического измерения глубин', 'Единицы батиметрического измерения глубин', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'k', 0, 1, 'Батиметрические интервалы (шкала глубин)', 'Батиметрические интервалы (шкала глубин)', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '131', 'l', 0, 1, 'Дополнительные изобаты', 'Дополнительные изобаты', 1, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '135', '', 1, 'Поле кодированных данных: электронные ресурсы', 'Поле кодированных данных: электронные ресурсы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '135', 'a', 0, 0, 'Кодированные данные для электронного ресурса', 'Кодированные данные для электронного ресурса', 1, -5, '', '', 'unimarc_field_135a.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '139', '', 1, 'Поле кодированных данных: электронные ресурсы', 'Поле кодированных данных: электронные ресурсы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '139', 'a', 0, 0, 'Кодированные данные', 'Кодированные данные', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '139', 'x', 0, 1, 'Формат данных или файловое расширение', 'Формат данных или файловое расширение', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '140', '', '', 'Поле кодированных данных: cтаропечатные издания - общая информация', 'Поле кодированных данных: cтаропечатные издания - общая информация', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '140', 'a', 0, 0, 'Кодированные данные о старопечатном издании - Основные', 'Кодированные данные о старопечатном издании - Основные', 1, -5, '', '', 'unimarc_field_140.pl', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '141', '', 1, 'Поле кодированных данных: cтаропечатные издания - характеристики экземпляра', 'Поле кодированных данных: cтаропечатные издания - характеристики экземпляра', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '141', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 1, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '141', 'a', 0, 0, 'Кодированные данные старопечатного издания - характеристики экземпляра', 'Кодированные данные старопечатного издания - характеристики экземпляра', 1, -5, '', '', 'unimarc_field_141.pl', 0, NULL, '', ''),
 ('', '', '141', 'b', 0, 0, 'Специфические характеристики переплета', 'Специфические характеристики переплета', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '141', 'c', 0, 0, 'Возраст переплета', 'Возраст переплета',   1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '145', '', 1, 'Поле кодированных данных: средство исполнения музыкального произведения', 'Поле кодированных данных: средство исполнения музыкального произведения', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '145', 'a', 0, 0, 'Тип средства исполнения', 'Тип средства исполнения', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '145', 'b', 0, 1, 'Инструмент/голос, дирижер, другой исполнитель или средство исполнения', 'Инструмент/голос, дирижер, другой исполнитель или средство исполнения', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '145', 'c', 0, 1, 'Тип ансамбля', 'Тип ансамбля',             1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '145', 'd', 0, 1, 'Группа в составе ансамбля', 'Группа в составе ансамбля', 1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '145', 'e', 0, 1, 'Количество партий', 'Количество партий',   1, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '145', 'f', 0, 1, 'Число исполнителей', 'Число исполнителей', 1, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '200', 1, '', 'Заглавие и сведения об ответственности', 'Заглавие и сведения об ответственности', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '200', '5', 0, 0, 'Организация, к которой относится поле', 'Организация, к которой относится поле', 2, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'a', 1, 1, 'Основное заглавие', 'Основное заглавие',   2, 0, 'biblio.title', '', '', 0, NULL, '', ''),
 ('', '', '200', 'b', 0, 1, 'Общее обозначение материала', 'Общее обозначение материала', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'c', 0, 1, 'Основное заглавие произведения другого автора', 'Основное заглавие произведения другого автора', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'd', 0, 1, 'Параллельное заглавие', 'Параллельное заглавие', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'f', 0, 1, 'Первые сведения об ответственности', 'Первые сведения об ответственности', 2, 0, 'biblio.author', '', '', 0, NULL, '', ''),
 ('', '', '200', 'g', 0, 1, 'Последующие сведения об ответственности', 'Последующие сведения об ответственности', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'h', 0, 1, 'Обозначение и номер части', 'Обозначение и номер части', 2, 0, 'biblioitems.number', '', '', 0, NULL, '', ''),
 ('', '', '200', 'i', 0, 1, 'Наименование части', 'Наименование части', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'v', 0, 0, 'Обозначение тома', 'Обозначение тома',     2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '200', 'z', 0, 1, 'Язык параллельного заглавия', 'Язык параллельного заглавия', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '205', '', 1, 'Сведения об издании', 'Сведения об издании', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '205', 'a', 0, 0, 'Сведения об издании', 'Сведения об издании', 2, 0, 'biblioitems.editionstatement', '', '', 0, NULL, '', ''),
 ('', '', '205', 'b', 0, 1, 'Дополнительные сведения об издании', 'Дополнительные сведения об издании', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '205', 'd', 0, 1, 'Параллельные сведения об издании', 'Параллельные сведения об издании', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '205', 'f', 0, 1, 'Сведения об ответственности, относящиеся к изданию', 'Сведения об ответственности, относящиеся к изданию', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '205', 'g', 0, 1, 'Последующие сведения об ответственности, относящиеся к изданию', 'Последующие сведения об ответственности, относящиеся к изданию', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '206', '', 1, 'Область специфических сведений: картографические материалы - математические данные', 'Область специфических сведений: картографические материалы - математические данные', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '206', 'a', 0, 0, 'Сведения о математических данных', 'Сведения о математических данных', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '206', 'b', 0, 1, 'Сведения о масштабе', 'Сведения о масштабе', 2, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '206', 'c', 0, 0, 'Сведения о проекции', 'Сведения о проекции', 2, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '206', 'd', 0, 0, 'Сведения о координатах', 'Сведения о координатах', 2, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '206', 'e', 0, 0, 'Сведения о зоне склонения', 'Сведения о зоне склонения', 2, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '206', 'f', 0, 0, 'Сведения о равноденствии', 'Сведения о равноденствии', 2, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '207', '', '', 'Область специфических сведений: нумерация продолжающихся ресурсов', 'Область специфических сведений: нумерация продолжающихся ресурсов', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '207', 'a', 0, 1, 'Нумерация: даты и обозначения томов', 'Нумерация: даты и обозначения томов', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '207', 'z', 0, 1, 'Источник информации о нумерации', 'Источник информации о нумерации', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '208', '', '', 'Область специфических сведений: нотные издания', 'Область специфических сведений: нотные издания', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '208', 'a', 0, 0, 'Форма изложения нотного текста', 'Форма изложения нотного текста', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '208', 'd', 0, 1, 'Параллельные сведения о форме изложения нотного текста', 'Параллельные сведения о форме изложения нотного текста', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '210', '', 1, 'Публикация, распространение и др.', 'Публикация, распространение и др.', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '210', 'a', 0, 1, 'Место издания, распространения и т.д.', 'Место издания, распространения и т.д.', 2, 0, 'biblioitems.place', '', '', 0, NULL, '', ''),
 ('', '', '210', 'b', 0, 1, 'Адрес издателя, распространителя и т. д.', 'Адрес издателя, распространителя и т. д.', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '210', 'c', 0, 1, 'Имя издателя, распространителя и т. д.', 'Имя издателя, распространителя и т. д.', 2, 0, 'biblioitems.publishercode', '', 'unimarc_field_210c.pl', 0, NULL, '', ''),
 ('', '', '210', 'd', 0, 1, 'Дата издания, распространения и т.д.', 'Дата издания, распространения и т.д.', 2, 0, 'biblioitems.publicationyear', '', '', 0, NULL, '', ''),
 ('', '', '210', 'e', 0, 1, 'Место изготовления', 'Место изготовления', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '210', 'f', 0, 1, 'Адрес изготовителя', 'Адрес изготовителя', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '210', 'g', 0, 1, 'Имя изготовителя', 'Имя изготовителя',     2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '210', 'h', 0, 1, 'Дата изготовления', 'Дата изготовления',   2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '211', '', '', 'Запланированная дата издания', 'Запланированная дата издания', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '211', 'a', 0, 0, 'Дата', 'Дата',                             2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '215', '', '', 'Физическая характеристика', 'Физическая характеристика', 'biblioitem');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '215', 'a', 0, 1, 'Специфическое обозначение материала и объем', 'Специфическое обозначение материала и объем', 2, 0, 'biblioitems.pages', '', '', 0, NULL, '', ''),
 ('', '', '215', 'c', 0, 0, 'Другие сведения о физической характеристике', 'Другие сведения о физической характеристике', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '215', 'd', 0, 1, 'Размеры', 'Размеры',                       2, 0, 'biblioitems.size', '', '', 0, NULL, '', ''),
 ('', '', '215', 'e', 0, 1, 'Сопроводительный материал', 'Сопроводительный материал', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '225', '', 1, 'Серия', 'Серия', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '225', 'a', 0, 0, 'Основное заглавие серии', 'Основное заглавие серии', 2, 0, 'biblio.seriestitle', '', 'unimarc_field_225a.pl', 0, NULL, '', ''),
 ('', '', '225', 'd', 0, 1, 'Параллельное заглавие серии', 'Параллельное заглавие серии', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '225', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '225', 'f', 0, 1, 'Сведения об ответственности', 'Сведения об ответственности', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '225', 'h', 0, 1, 'Обозначение или номер части', 'Обозначение или номер части', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '225', 'i', 0, 1, 'Наименование части', 'Наименование части', 2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '225', 'v', 0, 1, 'Обозначение тома', 'Обозначение тома',     2, 0, 'biblioitems.volume', '', '', 0, NULL, '', ''),
 ('', '', '225', 'x', 0, 1, 'ISSN серии', 'ISSN серии',                 2, 0, 'biblioitems.collectionissn', '', '', 0, NULL, '', ''),
 ('', '', '225', 'z', 0, 1, 'Язык параллельного заглавия', 'Язык параллельного заглавия', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '229', '', '', 'Область специфических сведений: нормативно-технические и технические документы. Неопубликованные док', 'Область специфических сведений: нормативно-технические и технические документы. Неопубликованные док', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '229', 'a', 0, 0, 'Сведения ', 'Сведения ',                   2, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '230', '', 1, 'Область специфических сведений: электронные ресурсы', 'Область специфических сведений: электронные ресурсы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '230', 'a', 0, 0, 'Обозначение и объем ресурса ', 'Обозначение и объем ресурса ', 2, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '239', '', '', 'Область специфических сведений: нормативные и технические документы', 'Область специфических сведений: нормативные и технические документы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '239', 'a', 0, 1, 'Сведения ', 'Сведения ',                   2, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '300', '', 1, 'Общие примечания', 'Общие примечания', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '300', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, 0, 'biblio.notes', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '301', '', 1, 'Примечания, относящиеся к идентификационным номерам', 'Примечания, относящиеся к идентификационным номерам', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '301', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '302', '', 1, 'Примечания, относящиеся к кодированной информации', 'Примечания, относящиеся к кодированной информации', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '302', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '303', '', 1, 'Общие примечания, относящиеся к описательной информации', 'Общие примечания, относящиеся к описательной информации', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '303', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '304', '', 1, 'Примечания, относящиеся к заглавию и сведениям об ответственности', 'Примечания, относящиеся к заглавию и сведениям об ответственности', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '304', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '305', '', '', 'Примечания о дате основания издания', 'Примечания о дате основания издания', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '305', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '306', '', 1, 'Примечания, относящиеся к публикации, распространению', 'Примечания, относящиеся к публикации, распространению', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '306', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '307', '', 1, 'Примечания, относящиеся к физическому описанию', 'Примечания, относящиеся к физическому описанию', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '307', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '308', '', 1, 'Примечания, относящиеся к серии', 'Примечания, относящиеся к серии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '308', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '309', '', 1, 'Примечания об основном источнике информации и об особенностях полиграфического оформления и исполнен', 'Примечания об основном источнике информации и об особенностях полиграфического оформления и исполнен', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '309', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '310', '', 1, 'Примечания, относящиеся к переплету и условиям доступности', 'Примечания, относящиеся к переплету и условиям доступности', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '310', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '311', '', 1, 'Примечания, относящиеся к полям связи (Примечания о связи с другими произведениями (изданиями))', 'Примечания, относящиеся к полям связи (Примечания о связи с другими произведениями (изданиями))', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '311', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '312', '', 1, 'Примечания, относящиеся к взаимосвязанным заглавиям', 'Примечания, относящиеся к взаимосвязанным заглавиям', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '312', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '313', '', 1, 'Примечания, относящиеся к тематическому доступу', 'Примечания, относящиеся к тематическому доступу', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '313', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '314', '', 1, 'Примечания, относящиеся к сведениям об интеллектуальной ответственности', 'Примечания, относящиеся к сведениям об интеллектуальной ответственности', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '314', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '315', '', 1, 'Примечания, относящиеся к сведениям о материале и т.п.', 'Примечания, относящиеся к сведениям о материале и т.п.', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '315', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '316', '', 1, 'Примечания об особенностях экземпляра', 'Примечания об особенностях экземпляра', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '316', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '316', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '316', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '317', '', 1, 'Примечания о происхождении экземпля', 'Примечания о происхождении экземпля', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '317', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '317', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '317', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '318', '', 1, 'Примечания о действии (над экземпляром)', 'Примечания о действии (над экземпляром)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '318', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'a', 0, 1, 'Действие', 'Действие',                     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'b', 0, 1, 'Идентификация действия', 'Идентификация действия', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'c', 0, 1, 'Время действия', 'Время действия',         3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'd', 0, 1, 'Интервал действия', 'Интервал действия',   3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'e', 0, 1, 'Условие действия ("в связи с …")', 'Условие действия ("в связи с …")', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'f', 0, 1, 'Санкционирование', 'Санкционирование',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'h', 0, 1, 'Юрисдикция', 'Юрисдикция',                 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'i', 0, 1, 'Метод действия', 'Метод действия',         3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'j', 0, 1, 'Место действия', 'Место действия',         3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'k', 0, 1, 'Исполнитель действия', 'Исполнитель действия', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'l', 0, 1, 'Состояние', 'Состояние',                   3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'n', 0, 1, 'Мера (степень)', 'Мера (степень)',         3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'o', 0, 1, 'Тип элемента', 'Тип элемента',             3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'p', 0, 1, 'Непубликуемое примечание', 'Непубликуемое примечание', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'r', 0, 1, 'Публикуемое примечание', 'Публикуемое примечание', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '318', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '320', '', 1, 'Примечания о наличии в документе библиографии/указателя', 'Примечания о наличии в документе библиографии/указателя', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '320', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '320', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '321', '', 1, 'Примечания об отдельно изданных указателях/рефератах/ссылках, отражающих каталогизируемый документ', 'Примечания об отдельно изданных указателях/рефератах/ссылках, отражающих каталогизируемый документ', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '321', 'a', 0, 0, 'Примечания об указателях, рефератах, ссылках', 'Примечания об указателях, рефератах, ссылках', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '321', 'b', 0, 0, 'Даты охвата', 'Даты охвата',               3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '321', 'c', 0, 0, 'Местонахождение в источнике', 'Местонахождение в источнике', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '321', 'u', 0, 0, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '321', 'x', 0, 0, 'Международный стандартный номер', 'Международный стандартный номер', 3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '322', '', '', 'Примечания об участниках создания (визуально-проекционные и видеоматериалы, звукозаписи)', 'Примечания об участниках создания (визуально-проекционные и видеоматериалы, звукозаписи)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '322', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '323', '', 1, 'Примечание о главных создателях, исполнителях, участниках (виз.-проекц. и видеоматериалы, звукозап.)', 'Примечание о главных создателях, исполнителях, участниках (виз.-проекц. и видеоматериалы, звукозап.)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '323', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '324', '', '', 'Примечание о первоначальной (оригинальной) версии', 'Примечание о первоначальной (оригинальной) версии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '324', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '325', '', 1, 'Примечание о копии', 'Примечание о копии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '325', 'a', 0, 0, 'Текст примечания.', 'Текст примечания.',   3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '326', '', 1, 'Примечания о периодичности (продолжающиеся ресурсы)', 'Примечания о периодичности (продолжающиеся ресурсы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '326', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '326', 'b', 0, 0, 'Даты периодичности', 'Даты периодичности', 3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '327', '', 1, 'Примечания о содержании', 'Примечания о содержании', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '327', 'a', 0, 1, 'Текст примечания', 'Текст примечания',     3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'b', 0, 1, 'Название раздела: уровень 1', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'c', 0, 1, 'Название раздела: уровень 2', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'd', 0, 1, 'Название раздела: уровень 3', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'e', 0, 1, 'Название раздела: уровень 4', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'f', 0, 1, 'Название раздела: уровень 5', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'g', 0, 1, 'Название раздела: уровень 6', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'h', 0, 1, 'Название раздела: уровень 7', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'i', 0, 1, 'Название раздела: уровень 8', '',          3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'p', 0, 1, 'Диапазон страниц или номер первой страницы раздела', '', 3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', '', 3, 0, '', '', '', 0, '', '', NULL),
 ('', '', '327', 'z', 0, 1, 'Другая информация, относящаяся к разделу', '', 3, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '328', '', 1, 'Примечания о диссертации', 'Примечания о диссертации', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '328', 'a', 0, 1, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '330', '', 1, 'Резюме или реферат', 'Резюме или реферат', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '330', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, 0, 'biblio.abstract', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '332', '', 1, 'Желаемая форма ссылки для материалов, которые обрабатываются', 'Желаемая форма ссылки для материалов, которые обрабатываются', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '332', 'a', 0, 0, 'Желаемая форма ссылки', 'Желаемая форма ссылки', 3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '333', '', 1, 'Примечания об особенностях распространения и использования', 'Примечания об особенностях распространения и использования', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '333', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '334', '', 1, 'Примечание о наградах', 'Примечание о наградах', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '334', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '334', 'b', 0, 1, 'Название награды', 'Название награды',     3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '334', 'c', 0, 0, 'Год присуждения награды', 'Год присуждения награды', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '334', 'd', 0, 0, 'Страна присуждения награды', 'Страна присуждения награды', 3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '334', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '336', '', 1, 'Примечание о виде электронного ресурса', 'Примечание о виде электронного ресурса', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '336', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '337', '', 1, 'Примечание о системных требованиях (электронные ресурсы)', 'Примечание о системных требованиях (электронные ресурсы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '337', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '337', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '345', '', '', 'Примечание, относящееся к информации о комплектовании', 'Примечание, относящееся к информации о комплектовании', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '345', '5', 0, 0, 'Код организации', 'Код организации',       3, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '345', 'a', 0, 1, 'Адрес источника комплектования/подписки', 'Адрес источника комплектования/подписки', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '345', 'b', 0, 1, 'Учетный/регистрационный номер', 'Учетный/регистрационный номер', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '345', 'c', 0, 1, 'Носитель', 'Носитель',                     3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '345', 'd', 0, 1, 'Условия доступности', 'Условия доступности', 3, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '345', 'u', 0, 1, 'Универсальный идентификатор ресурса (URI)', 'Универсальный идентификатор ресурса (URI)', 3, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '410', '', 1, 'Серии', 'Серии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '410', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '410', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '410', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '411', '', 1, 'Подсерии', 'Подсерии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '411', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '411', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '411', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '412', '', 1, 'Источник отрывка или отдельного оттиска', 'Источник отрывка или отдельного оттиска', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '412', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'a', 0, 0, 'Автор', 'Автор',                           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'c', 0, 0, 'Место публикации ', 'Место публикации ',   4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'd', 0, 0, 'Дата публикации ', 'Дата публикации ',     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 't', 0, 0, 'Название', 'Название',                     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'x', 0, 0, 'Международный стандартный номер сериального издания - ISSN', 'Международный стандартный номер сериального издания - ISSN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '412', 'z', 0, 0, 'CODEN ', 'CODEN ',                         4, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '413', '', 1, 'Отрывок или отдельный оттиск', 'Отрывок или отдельный оттиск', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '413', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'a', 0, 0, 'Автор', 'Автор',                           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'c', 0, 0, 'Место публикации ', 'Место публикации ',   4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'd', 0, 0, 'Дата публикации ', 'Дата публикации ',     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 't', 0, 0, 'Название', 'Название',                     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'x', 0, 0, 'Международный стандартный номер сериального издания - ISSN', 'Международный стандартный номер сериального издания - ISSN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '413', 'z', 0, 0, 'CODEN ', 'CODEN ',                         4, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '421', '', 1, 'Приложение', 'Приложение', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '421', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '421', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '421', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '422', '', 1, 'Издание, к которому относится приложение', 'Издание, к которому относится приложение', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '422', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '422', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '422', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '423', '', 1, 'Издается в одной обложке вместе с ...', 'Издается в одной обложке вместе с ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '423', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '423', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '423', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '424', '', 1, 'Обновлен...', 'Обновлен...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '424', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'a', 0, 0, 'Автор', 'Автор',                           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'd', 0, 0, 'Дата публикации ', 'Дата публикации ',     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 't', 0, 0, 'Название', 'Название',                     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'x', 0, 0, 'Международный стандартный номер сериального издания - ISSN', 'Международный стандартный номер сериального издания - ISSN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '424', 'z', 0, 0, 'CODEN ', 'CODEN ',                         4, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '425', '', 1, 'Обновляет...', 'Обновляет...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '425', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'a', 0, 0, 'Автор', 'Автор',                           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'c', 0, 0, 'Место публикации ', 'Место публикации ',   4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'd', 0, 0, 'Дата публикации ', 'Дата публикации ',     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 't', 0, 0, 'Название', 'Название',                     4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'x', 0, 0, 'Международный стандартный номер сериального издания - ISSN', 'Международный стандартный номер сериального издания - ISSN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '425', 'z', 0, 0, 'CODEN ', 'CODEN ',                         4, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '430', '', 1, 'Продолжен', 'Продолжен', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '430', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '430', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '430', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '431', '', 1, 'Продолжен частично', 'Продолжен частично', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '431', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '431', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '431', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '432', '', 1, 'Заменен', 'Заменен', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '432', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '432', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '432', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '433', '', 1, 'Заменен частично', 'Заменен частично', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '433', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '433', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '433', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '434', '', 1, 'Поглощенный', 'Поглощенный', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '434', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '434', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '434', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '435', '', 1, 'Поглощено частично', 'Поглощено частично', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '435', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '435', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '435', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '436', '', 1, 'Издания, участвовавшие в слиянии', 'Издания, участвовавшие в слиянии', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '436', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '436', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '436', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '437', '', 1, 'Отделилось от', 'Отделилось от', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '437', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '437', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '437', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '440', '', 1, 'Продолжается под ...', 'Продолжается под ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '440', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '440', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '440', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '441', '', 1, 'Продолжается частично под ...', 'Продолжается частично под ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '441', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '441', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '441', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '442', '', 1, 'Заменен на ...', 'Заменен на ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '442', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '442', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '442', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '443', '', 1, 'Заменен частично на ...', 'Заменен частично на ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '443', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '443', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '443', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '444', '', 1, 'Поглотивший', 'Поглотивший', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '444', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '444', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '444', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '445', '', 1, 'То, которое поглотило частично', 'То, которое поглотило частично', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '445', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '445', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '445', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '446', '', 1, 'Разделился на ...', 'Разделился на ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '446', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '446', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '446', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '447', '', 1, 'Слитно из ... и ... чтобы образовать ...', 'Слитно из ... и ... чтобы образовать ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '447', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '447', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '447', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '448', '', 1, 'Возобновился под прежним заглавием', 'Возобновился под прежним заглавием', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '448', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '448', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '448', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '451', '', 1, 'Другое издание [каталогизируемого документа] на аналогичном носителе', 'Другое издание [каталогизируемого документа] на аналогичном носителе', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '451', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '451', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '451', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '452', '', 1, 'Другое издание [каталогизируемого документа] на другом носителе', 'Другое издание [каталогизируемого документа] на другом носителе', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '452', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '452', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '452', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '453', '', 1, 'Перевод', 'Перевод', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '453', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '453', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '453', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '454', '', 1, 'Оригинал (перевода)', 'Оригинал (перевода)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '454', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '454', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '454', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '455', '', 1, 'Оригинал, с которого сделана копия', 'Оригинал, с которого сделана копия', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '455', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '455', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '455', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '456', '', 1, 'Репродуцировано в ...', 'Репродуцировано в ...', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '456', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '456', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '456', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '461', '', 1, 'Уровень набора', 'Уровень набора', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '461', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '461', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '461', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '462', '', 1, 'Уровень поднабора', 'Уровень поднабора', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '462', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '462', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '462', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '463', '', 1, 'Уровень физической единицы', 'Уровень физической единицы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '463', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '463', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '463', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '464', '', 1, 'Аналитический уровень', 'Аналитический уровень', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '464', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '464', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '464', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '470', '', 1, 'Рецензируемый, реферируемый документ', 'Рецензируемый, реферируемый документ', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '470', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '470', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '470', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '481', '', 1, 'Также в этом переплете', 'Также в этом переплете', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '481', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '481', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '481', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '482', '', 1, 'Приплетено к', 'Приплетено к', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '482', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '482', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '482', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '488', '', 1, 'Другие взаимосвязанные произведения (документы)', 'Другие взаимосвязанные произведения (документы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '488', '0', 0, 0, 'Идентификатор библиографической записи', 'Идентификатор библиографической записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', '1', 0, 1, 'Подполе связи', 'Подполе связи',           4, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '488', '3', 0, 0, 'Номер авторитетной записи', 'Номер авторитетной записи', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', '5', 0, 0, 'Учреждение в которой поле применено', 'Учреждение в которой поле применено', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'a', 0, 0, 'Автор', 'Автор',                           4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'c', 0, 0, 'Место публикации', 'Место публикации',     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'd', 0, 0, 'Дата публикации', 'Дата публикации',       4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'e', 0, 0, 'Сведения об издании', 'Сведения об издании', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'h', 0, 0, 'Номер раздела или части', 'Номер раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'i', 0, 0, 'Название раздела или части', 'Название раздела или части', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'p', 0, 0, 'Физическое описание', 'Физическое описание', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 't', 0, 0, 'Название', 'Название',                     4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'u', 0, 0, 'Уніфікований покажчик інформаційного ресурсу (URL)', 'Уніфікований покажчик інформаційного ресурсу (URL)', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'v', 0, 1, 'Номер тома', 'Номер тома',                 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'x', 0, 0, 'ISSN', 'ISSN',                             4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'y', 0, 0, 'ISBN / Международный стандартный музыкальный номер - ISMN', 'ISBN / Международный стандартный музыкальный номер - ISMN', 4, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '488', 'z', 0, 0, 'CODEN', 'CODEN',                           4, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '500', '', 1, 'Унифицированное заглавие', 'Унифицированное заглавие', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '500', '2', 0, 0, 'Код системы предметизации', 'Код системы предметизации', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', '3', 0, 0, 'Номер авторитетной/нормативной записи', 'Номер авторитетной/нормативной записи', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'a', 0, 0, 'Унифицированное заглавие', 'Унифицированное заглавие', 5, 0, 'biblio.unititle', '', '', 0, NULL, '', ''),
 ('', '', '500', 'b', 0, 1, 'Общее обозначение материала', 'Общее обозначение материала', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'h', 0, 1, 'Обозначение или номер раздела или части', 'Обозначение или номер раздела или части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'i', 0, 1, 'Наименование раздела или части', 'Наименование раздела или части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'k', 0, 0, 'Дата публикации', 'Дата публикации',       5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'l', 0, 1, 'Сведения, относящиеся к заглавию/сведения о виде, жанре, характере документа', 'Сведения, относящиеся к заглавию/сведения о виде, жанре, характере документа', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'm', 0, 0, 'Язык (если является частью заголовка)', 'Язык (если является частью заголовка)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'n', 0, 1, 'Прочие сведения', 'Прочие сведения',       5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'q', 0, 0, 'Версия (или дата версии) (перевод)', 'Версия (или дата версии) (перевод)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'r', 0, 0, 'Средства исполнения (для музыкальных произведений)', 'Средства исполнения (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 's', 0, 1, 'Цифровое обозначение (для музыкальных произведений)', 'Цифровое обозначение (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'u', 0, 0, 'Ключ (для музыкальных произведений)', 'Ключ (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'v', 0, 0, 'Обозначение тома', 'Обозначение тома',     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'w', 0, 0, 'Сведения об аранжировке (для музыкальных произведений)', 'Сведения об аранжировке (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '500', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '501', '', 1, 'Унифицированное типовое заглавие', 'Унифицированное типовое заглавие', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '501', '2', 0, 0, 'Код системы', 'Код системы',               5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'a', 0, 0, 'Унифицированное типовое заглавие', 'Унифицированное типовое заглавие', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'b', 0, 1, 'Общее обозначение материала', 'Общее обозначение материала', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'e', 0, 0, 'Сведения, относящиеся к унифицированному типовому заглавию', 'Сведения, относящиеся к унифицированному типовому заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'k', 0, 0, 'Дата публикации', 'Дата публикации',       5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'm', 0, 0, 'Язык (если является частью заголовка)', 'Язык (если является частью заголовка)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'r', 0, 1, 'Средства исполнения (для музыкальных произведений)', 'Средства исполнения (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 's', 0, 1, 'Цифровое обозначение (для музыкальных произведений)', 'Цифровое обозначение (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'u', 0, 0, 'Ключ (для музыкальных произведений)', 'Ключ (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'w', 0, 0, 'Сведения об аранжировке (для музыкальных произведений)', 'Сведения об аранжировке (для музыкальных произведений)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '501', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '503', '', 1, 'Унифицированный условный заголовок', 'Унифицированный условный заголовок', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '503', 'a', 0, 0, 'Унифицированный заголовок', 'Унифицированный заголовок', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'b', 0, 0, 'Подзаголовок формы', 'Подзаголовок формы', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'd', 0, 1, 'Месяц и день', 'Месяц и день',             5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'e', 0, 0, 'Имя лица или родовое имя', 'Имя лица или родовое имя', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'f', 0, 0, 'Личное имя', 'Личное имя',                 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'h', 0, 0, 'Уточнение имени лица', 'Уточнение имени лица', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'i', 0, 0, 'Заглавие части', 'Заглавие части',         5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'j', 0, 1, 'Год', 'Год',                               5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'k', 0, 0, 'Нумерация (арабская)', 'Нумерация (арабская)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'l', 0, 0, 'Нумерация (римская)', 'Нумерация (римская)', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'm', 0, 0, 'Местность', 'Местность',                   5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '503', 'n', 0, 0, 'Учреждение', 'Учреждение',                 5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '509', '', 1, 'Заголовок - структурированное географическое или тематическое наименование', 'Заголовок - структурированное географическое или тематическое наименование', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '509', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'a', 0, 1, 'Географическое / тематическое наименование - начальный элемент ввода', 'Географическое / тематическое наименование - начальный элемент ввода', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'b', 0, 1, 'Географическое / тематическое наименование - структурное подразделение', 'Географическое / тематическое наименование - структурное подразделение', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'c', 0, 1, 'Уточняющий признак', 'Уточняющий признак', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'e', 0, 1, 'Идентифицирующий признак - географическая принадлежность', 'Идентифицирующий признак - географическая принадлежность', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'f', 0, 1, 'Даты', 'Даты',                             5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'g', 0, 0, 'Инвертируемая часть', 'Инвертируемая часть', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'h', 0, 1, 'Географический термин (город, река, область, и т.п.)', 'Географический термин (город, река, область, и т.п.)', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'l', 0, 0, 'Вид издания', 'Вид издания',               5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '509', 'n', 0, 0, 'Масштаб', 'Масштаб',                       5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '510', '', 1, 'Параллельное заглавие', 'Параллельное заглавие', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '510', 'a', 0, 0, 'Параллельное заглавие', 'Параллельное заглавие', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'h', 0, 1, 'Обозначение или номер части', 'Обозначение или номер части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'i', 0, 1, 'Наименование части', 'Наименование части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'j', 0, 0, 'Том или даты, связанные с заглавием', 'Том или даты, связанные с заглавием', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'n', 0, 0, 'Прочие сведения', 'Прочие сведения',       5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '510', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '512', '', 1, 'Заглавие обложки', 'Заглавие обложки', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '512', 'a', 0, 0, 'Заглавие обложки', 'Заглавие обложки',     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '512', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '512', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '513', '', 1, 'Заглавие на дополнительном титульном листе', 'Заглавие на дополнительном титульном листе', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '513', 'a', 0, 0, 'Заглавие на дополнительном титульном листе', 'Заглавие на дополнительном титульном листе', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '513', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '513', 'h', 0, 0, 'Обозначение или номер части ', 'Обозначение или номер части ', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '513', 'i', 0, 0, 'Наименование части', 'Наименование части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '513', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '514', '', 1, 'Заглавие на первой странице текста', 'Заглавие на первой странице текста', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '514', 'a', 0, 0, 'Заглавие на первой странице текста', 'Заглавие на первой странице текста', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '514', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '514', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '515', '', 1, 'Заглавие на колонтитуле', 'Заглавие на колонтитуле', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '515', 'a', 0, 0, 'Заглавие на колонтитуле', 'Заглавие на колонтитуле', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '515', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '516', '', 1, 'Заглавие на корешке [издания]', 'Заглавие на корешке [издания]', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '516', 'a', 0, 0, 'Заглавие на корешке', 'Заглавие на корешке', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '516', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '516', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '517', '', 1, 'Другие варианты заглавия', 'Другие варианты заглавия', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '517', 'a', 0, 0, 'Вариант заглавия', 'Вариант заглавия',     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '517', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '517', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '518', '', 1, 'Заглавие в стандартном современном правописании', 'Заглавие в стандартном современном правописании', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '518', 'a', 0, 0, 'Основное заглавие, вариант заглавия или унифицированное заглавие', 'Основное заглавие, вариант заглавия или унифицированное заглавие', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '518', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '520', '', 1, 'Прежнее заглавие (продолжающиеся ресурсы)', 'Прежнее заглавие (продолжающиеся ресурсы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '520', 'a', 0, 0, 'Прежнее основное заглавие', 'Прежнее основное заглавие', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'h', 0, 1, 'Обозначение и номер части', 'Обозначение и номер части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'i', 0, 1, 'Наименование части', 'Наименование части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'j', 0, 0, 'Тома или даты выхода документа под прежним заглавием', 'Тома или даты выхода документа под прежним заглавием', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'n', 0, 0, 'Прочие сведения', 'Прочие сведения',       5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'x', 0, 0, 'ISSN прежнего заглавия', 'ISSN прежнего заглавия', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '520', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '530', '', 1, 'Ключевое заглавие (продолжающиеся ресурсы)', 'Ключевое заглавие (продолжающиеся ресурсы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '530', 'a', 0, 0, 'Ключевое заглавие', 'Ключевое заглавие',   5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '530', 'b', 0, 0, 'Уточнение', 'Уточнение',                   5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '530', 'j', 0, 0, 'Том или даты, связанные с заглавием', 'Том или даты, связанные с заглавиемume or Dates Associated with Key Title', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '530', 'v', 0, 0, 'Обозначение тома', 'Обозначение тома',     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '530', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '531', '', 1, 'Сокращенное заглавие (продолжающиеся ресурсы)', 'Сокращенное заглавие (продолжающиеся ресурсы)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '531', 'a', 0, 0, 'Заглавие', 'Заглавие',                     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '531', 'b', 0, 0, 'Уточнение', 'Уточнение',                   5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '531', 'v', 0, 0, 'Обозначение тома', 'Обозначение тома',     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '531', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '532', '', 1, 'Расширенное заглавие', 'Расширенное заглавие', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '532', 'a', 0, 0, 'Заглавие', 'Заглавие',                     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '532', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '540', '', 1, 'Дополнительное заглавие, применяемое каталогизатором', 'Дополнительное заглавие, применяемое каталогизатором', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '540', 'a', 0, 0, 'Заглавие', 'Заглавие',                     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '540', 'e', 0, 0, 'Сведения о заглавии', 'Сведения о заглавии', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '540', 'h', 0, 0, 'Обозначение или номер части', 'Обозначение или номер части', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '540', 'i', 0, 0, 'Наименование части', 'Наименование части', 5, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '540', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '541', '', 1, 'Перевод заглавия, сделанный каталогизатором', 'Перевод заглавия, сделанный каталогизатором', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '541', 'a', 0, 0, 'Заглавие', 'Заглавие',                     5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '541', 'e', 0, 1, 'Сведения, относящиеся к заглавию', 'Сведения, относящиеся к заглавию', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '541', 'h', 0, 1, 'Обозначение или номер части', 'Обозначение или номер части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '541', 'i', 0, 1, 'Наименование части', 'Наименование части', 5, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '541', 'z', 0, 0, 'Язык заглавия', 'Язык заглавия',           5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '545', '', 1, 'Заглавие части', 'Заглавие части', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '545', 'a', 0, 0, 'Заглавие части', 'Заглавие части',         5, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '600', '', 1, 'Имя лица как предмет', 'Имя лица как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', '3', 0, 0, 'Номер авторитетной/нормативной записи', 'Номер авторитетной/нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'b', 0, 0, 'Часть имени, кроме начального элемента ввода', 'Часть имени, кроме начального элемента ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'c', 0, 1, 'Дополнения к именам, кроме дат', 'Дополнения к именам, кроме дат', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'd', 0, 0, 'Римские цифры', 'Римские цифры',           6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'f', 0, 0, 'Даты', 'Даты',                             6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'g', 0, 0, 'Расширение инициалов личного имени', 'Расширение инициалов личного имени', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'p', 0, 0, 'Наименование / адрес организации', 'Наименование / адрес организации', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '600', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '601', '', 1, 'Наименование организации как предмет', 'Наименование организации как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '601', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'b', 0, 1, 'Структурное подразделение организации', 'Структурное подразделение организации', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'c', 0, 1, 'Идентифицирующий признак', 'Идентифицирующий признак', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'd', 0, 0, 'Порядковый номер временной организации и / или порядковый номер ее части', 'Порядковый номер временной организации и / или порядковый номер ее части', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'e', 0, 0, 'Место проведения временной организации', 'Место проведения временной организации', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'f', 0, 0, 'Дата проведения временной организации', 'Дата проведения временной организации', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'g', 0, 0, 'Инверсированный элемент', 'Инверсированный элемент', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'h', 0, 0, 'Часть наименования, отличная от начального элемента ввода и от инверсированного', 'Часть наименования, отличная от начального элемента ввода и от инверсированного', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '601', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '602', '', 1, 'Родовое имя как предмет', 'Родовое имя как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '602', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'f', 0, 0, 'Даты', 'Даты',                             6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '602', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '604', '', 1, 'Имя и заглавие как предмет', 'Имя и заглавие как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '604', '1', 0, 1, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '605', '', 1, 'Заглавие как предмет', 'Заглавие как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '605', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'h', 0, 1, 'Обозначение или номер раздела или части ', 'Обозначение или номер раздела или части ', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'i', 0, 1, 'Наименование части', 'Наименование части', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'k', 0, 0, 'Дата публикации', 'Дата публикации',       6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'l', 0, 0, 'Сведения, относящиеся к заглавию / сведения о виде, жанре, характере документа', 'Сведения, относящиеся к заглавию / сведения о виде, жанре, характере документа', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'm', 0, 0, 'Язык', 'Язык',                             6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'n', 0, 1, 'Прочие сведения', 'Прочие сведения',       6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'q', 0, 0, 'Версия (или дата версии)', 'Версия (или дата версии)', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'r', 0, 1, 'Средства исполнения (для музыкальных произведений)', 'Средства исполнения (для музыкальных произведений)', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 's', 0, 1, 'Цифровое обозначение (для музыкальных произведений)', 'Цифровое обозначение (для музыкальных произведений)', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'u', 0, 1, 'Ключ (для музыкальных произведений)', 'Ключ (для музыкальных произведений)', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'w', 0, 1, 'Сведения об аранжировке (для музыкальных произведений)', 'Сведения об аранжировке (для музыкальных произведений)', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '605', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '606', '', 1, 'Наименование темы как предмет', 'Наименование темы как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '606', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '606', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '606', 'a', 0, 0, 'Наименование темы', 'Наименование темы',   6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '606', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '606', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '606', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '606', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '607', '', 1, 'Географическое наименование как предмет', 'Географическое наименование как предмет', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '607', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '607', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '607', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '607', 'a', 0, 0, 'Географическое наименование', 'Географическое наименование', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '607', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '607', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '607', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '607', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '608', '', 1, 'Форма, жанр, физические характеристики документа как точка доступа', 'Форма, жанр, физические характеристики документа как точка доступа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '608', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', '3', 0, 0, 'Номер авторитетной/нормативной записи', 'Номер авторитетной/нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', '5', 0, 0, 'Организация - держатель экземпляра, к которому относится поле', 'Организация - держатель экземпляра, к которому относится поле', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '608', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '608', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '610', '', 1, 'Неконтролируемые предметные термины', 'Неконтролируемые предметные термины', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '610', 'a', 0, 1, 'Тематический термин', 'Тематический термин', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '615', '', 1, 'Предметная категория', 'Предметная категория', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '615', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '615', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '615', 'a', 0, 0, 'Начальный элемент ввода вышестоящей предметной категории в текстовой форме', 'Начальный элемент ввода вышестоящей предметной категории в текстовой форме', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '615', 'm', 0, 1, 'Дополнение предметной категории (подзаголовок) в кодированной форме', 'Дополнение предметной категории (подзаголовок) в кодированной форме', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '615', 'n', 0, 1, 'Начальный элемент ввода вышестоящей предметной категории в кодированной форме', 'Начальный элемент ввода вышестоящей предметной категории в кодированной форме', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '615', 'x', 0, 1, 'Дополнение предметной категории (подзаголовок) в текстовой форме', 'Дополнение предметной категории (подзаголовок) в текстовой форме', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '616', '', 1, 'Торговая марка как точка доступа', 'Торговая марка как точка доступа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '616', '2', 0, 0, 'Код системы', 'Код системы',               6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'c', 0, 1, 'Уточнение', 'Уточнение',                   6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'f', 0, 0, 'Даты', 'Даты',                             6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'j', 0, 1, 'Формальный подзаголовок', 'Формальный подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'x', 0, 1, 'Тематический подзаголовок', 'Тематический подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'y', 0, 1, 'Географический подзаголовок', 'Географический подзаголовок', 6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '616', 'z', 0, 1, 'Хронологический подзаголовок', 'Хронологический подзаголовок', 6, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '620', '', 1, 'Место и дата как точка доступа', 'Место и дата как точка доступа', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '620', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'a', 0, 0, 'Страна', 'Страна',                         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'b', 0, 0, 'Республика / штат / провинция и т.п.', 'Республика / штат / провинция и т.п.', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'c', 0, 0, 'Край / область / округ / графство / департамент и т.п.', 'Край / область / округ / графство / департамент и т.п.', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'd', 0, 0, 'Город', 'Город',                           6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'e', 0, 1, 'Место (исполнения, записи и т.д.)', 'Место (исполнения, записи и т.д.)', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'f', 0, 1, 'Дата', 'Дата',                             6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'g', 0, 0, 'Сезон', 'Сезон',                           6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'h', 0, 0, 'Повод, основание (например, по случаю…, к годовщине…, приурочено…)', 'Повод, основание (например, по случаю…, к годовщине…, приурочено…)', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '620', 'i', 0, 0, 'Дата окончания / финала', 'Дата окончания / финала', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '626', '', 1, 'Технические характеристики как точка доступа: электронные ресурсы', 'Технические характеристики как точка доступа: электронные ресурсы', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '626', 'a', 0, 0, 'Марка и модель компютера', 'Марка и модель компютера', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '626', 'b', 0, 0, 'Язык программирования', 'Язык программирования', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '626', 'c', 0, 0, 'Операционная система', 'Операционная система', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '660', '', 1, 'Код географического региона (GAC)', 'Код географического региона (GAC)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '660', 'a', 0, 0, 'Код географического региона', 'Код географического региона', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '661', '', 1, 'Код периода времени', 'Код периода времени', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '661', 'a', 0, 0, 'Код периода времени', 'Код периода времени', 6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '670', '', 1, 'PRECIS', 'PRECIS', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '670', 'b', 0, 0, 'Номер индикатора предмета', 'Номер индикатора предмета', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '670', 'c', 0, 0, 'Строка', 'Строка',                         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '670', 'e', 0, 1, 'Код индикатора ссылки', 'Код индикатора ссылки', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '670', 'z', 0, 0, 'Язык терминов', 'Язык терминов',           6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '675', '', 1, 'Универсальная десятичная классификация (UDC/УДК)', 'Универсальная десятичная классификация (UDC/УДК)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '675', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '675', 'a', 0, 0, 'Индекс', 'Индекс',                         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '675', 'v', 0, 0, 'Издание', 'Издание',                       6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '675', 'z', 0, 0, 'Язык издания', 'Язык издания',             6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '676', '', 1, 'Десятичная классификация Дьюи (DDC/ДДК)', 'Десятичная классификация Дьюи (DDC/ДДК)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '676', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '676', 'a', 0, 0, 'Индекс', 'Индекс',                         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '676', 'v', 0, 0, 'Издание', 'Издание',                       6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '676', 'z', 0, 0, 'Язык издания', 'Язык издания',             6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '679', '', 1, 'Индексы международных классификаций объектов промышленной собственности', 'Индексы международных классификаций объектов промышленной собственности', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '679', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '679', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '679', 'a', 0, 0, 'Индекс', 'Индекс',                         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '679', 'v', 0, 0, 'Издание', 'Издание',                       6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '680', '', 1, 'Классификация Библиотеки Конгресса (LCC/КБК)', 'Классификация Библиотеки Конгресса (LCC/КБК)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '680', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '680', 'a', 0, 0, 'Классификационный индекс', 'Классификационный индекс', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '680', 'b', 0, 0, 'Книжный номер', 'Книжный номер',           6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '686', '', 1, 'Индексы других классификаций', 'Индексы других классификаций', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '686', '2', 0, 0, 'Код системы', 'Код системы',               6, 0, '', 'classif', '', 0, NULL, '', ''),
 ('', '', '686', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '686', 'a', 0, 1, 'Классификационный индекс', 'Классификационный индекс', 6, 0, '', '', 'unimarc_field_686a.pl', 0, NULL, '', ''),
 ('', '', '686', 'b', 0, 1, 'Книжный номер', 'Книжный номер',           6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '686', 'c', 0, 1, 'Подразделение классификационного индекса', 'Подразделение классификационного индекса', 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '686', 'v', 0, 0, 'Издание', 'Издание',                       6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '700', '', '', 'Имя лица — первичная ответственность', 'Имя лица - первичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '700', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'b', 0, 0, 'Часть имени, кроме начального элемента ввода', 'Часть имени, кроме начального элемента ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'c', 0, 1, 'Дополнение к именам, кроме дат', 'Дополнение к именам, кроме дат', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'd', 0, 0, 'Римские цифры', 'Римские цифры',           7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'g', 0, 0, 'Расширение инициалов личного имени', 'Расширение инициалов личного имени', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '700', 'p', 0, 0, 'Наименование/адрес организации', 'Наименование/адрес организации', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '701', '', 1, 'Имя лица — альтернативная ответственность', 'Имя лица — альтернативная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '701', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '701', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'b', 0, 0, 'Часть имени, кроме начального элемента ввода', 'Часть имени, кроме начального элемента ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'c', 0, 1, 'Дополнение к именам, кроме дат', 'Дополнение к именам, кроме дат', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'd', 0, 0, 'Римские цифры', 'Римские цифры',           7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'g', 0, 0, 'Расширение инициалов личного имени', 'Расширение инициалов личного имени', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '701', 'p', 0, 0, 'Наименование/адрес организации', 'Наименование/адрес организации', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '702', '', 1, 'Имя лица — вторичная ответственность', 'Имя лица — вторичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '702', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '702', '5', 0, 0, 'Организация, к которой относится поле', 'Организация, к которой относится поле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'b', 0, 0, 'Часть имени, кроме начального элемента ввода', 'Часть имени, кроме начального элемента ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'c', 0, 1, 'Дополнение к именам, кроме дат', 'Дополнение к именам, кроме дат', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'd', 0, 0, 'Римские цифры', 'Римские цифры',           7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'g', 0, 0, 'Расширение инициалов личного имени', 'Расширение инициалов личного имени', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '702', 'p', 0, 0, 'Наименование/адрес организации', 'Наименование/адрес организации', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '710', '', '', 'Наименование организации - первичная ответственность', 'Наименование организации - первичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '710', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '710', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'b', 0, 1, 'Структурное подразделение', 'Структурное подразделение', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'c', 0, 1, 'Идентифицирующий признак', 'Идентифицирующий признак', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'd', 0, 0, 'Порядковый номер временной организации и / или порядковый номер ее части', 'Порядковый номер временной организации и / или порядковый номер ее части', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'e', 0, 0, 'Место проведения временной организации', 'Место проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'f', 0, 0, 'Дата проведения временной организации', 'Дата проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'g', 0, 0, 'Инверсированный элемент', 'Инверсированный элемент', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'h', 0, 0, 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '710', 'p', 0, 0, 'Местонахождение', 'Местонахождение',       7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '711', '', 1, 'Наименование организации - альтернативная ответственность', 'Наименование организации - альтернативная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '711', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '711', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'b', 0, 1, 'Структурное подразделение', 'Структурное подразделение', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'c', 0, 1, 'Идентифицирующий признак', 'Идентифицирующий признак', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'd', 0, 0, 'Порядковый номер временной организации и / или порядковый номер ее части', 'Порядковый номер временной организации и / или порядковый номер ее части', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'e', 0, 0, 'Место проведения временной организации', 'Место проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'f', 0, 0, 'Дата проведения временной организации', 'Дата проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'g', 0, 0, 'Инверсированный элемент', 'Инверсированный элемент', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'h', 0, 0, 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '711', 'p', 0, 0, 'Местонахождение', 'Местонахождение',       7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '712', '', 1, 'Наименование организации - вторичная ответственность', 'Наименование организации - вторичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '712', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '712', '5', 0, 0, 'Организация, к которой относится поле', 'Организация, к которой относится поле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'b', 0, 1, 'Структурное подразделение', 'Структурное подразделение', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'c', 0, 1, 'Идентифицирующий признак', 'Идентифицирующий признак', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'd', 0, 0, 'Порядковый номер временной организации и / или порядковый номер ее части', 'Порядковый номер временной организации и / или порядковый номер ее части', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'e', 0, 0, 'Место проведения временной организации', 'Место проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'f', 0, 0, 'Дата проведения временной организации', 'Дата проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'g', 0, 0, 'Инверсированный элемент', 'Инверсированный элемент', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'h', 0, 0, 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '712', 'p', 0, 0, 'Местонахождение', 'Местонахождение',       7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '716', '', 1, 'Торговая марка', 'Торговая марка', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '716', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '716', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '716', 'c', 0, 1, 'Уточнение', 'Уточнение',                   7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '716', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '720', '', '', 'Родовое имя - первичная ответственность', 'Родовое имя - первичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '720', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '720', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '720', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '720', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '721', '', 1, 'Родовое имя - альтернативная ответственность', 'Родовое имя - альтернативная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '721', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '721', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '721', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '721', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '722', '', 1, 'Родовое имя - вторичная ответственность', 'Родовое имя - вторичная ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '722', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '722', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '722', '5', 0, 0, 'Организация, к которой относится поле', 'Организация, к которой относится поле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '722', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '722', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '730', '', 1, 'Имя/наименование - ответственность', 'Имя/наименование - ответственность', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '730', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '730', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '790', '', 1, 'Имя лица - альтернативная форма', 'Имя лица - альтернативная форма', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '790', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '790', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'b', 0, 0, 'Часть имени, кроме начального элемента ввода', 'Часть имени, кроме начального элемента ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'c', 0, 1, 'Дополнение к именам, кроме дат', 'Дополнение к именам, кроме дат', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'd', 0, 0, 'Римские цифры', 'Римские цифры',           7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'f', 0, 0, 'Даты', 'Даты',                             7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'g', 0, 0, 'Расширение инициалов личного имени', 'Расширение инициалов личного имени', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '790', 'p', 0, 0, 'Наименование/адрес организации', 'Наименование/адрес организации', 7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '791', '', 1, 'Наименование организации - альтернативная форма', 'Наименование организации - альтернативная форма', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '791', '3', 0, 0, 'Номер авторитетной / нормативной записи', 'Номер авторитетной / нормативной записи', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', '4', 0, 1, 'Код отношения', 'Код отношения',           7, 0, '', 'QUALIF', '', 0, NULL, '', ''),
 ('', '', '791', 'a', 0, 0, 'Начальный элемент ввода', 'Начальный элемент ввода', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'b', 0, 1, 'Структурное подразделение', 'Структурное подразделение', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'c', 0, 1, 'Идентифицирующий признак', 'Идентифицирующий признак', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'd', 0, 0, 'Порядковый номер временной организации и / или порядковый номер ее части', 'Порядковый номер временной организации и / или порядковый номер ее части', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'e', 0, 0, 'Место проведения временной организации', 'Место проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'f', 0, 0, 'Дата проведения временной организации', 'Дата проведения временной организации', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'g', 0, 0, 'Инверсированный элемент', 'Инверсированный элемент', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'h', 0, 0, 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 'Часть наименования, отличная от начального элемента ввода и инверсированного эле', 7, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '791', 'p', 0, 0, 'Местонахождение', 'Местонахождение',       7, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '801', '', 1, 'Источник записи', 'Источник записи', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '801', '2', 0, 0, 'Код формата', 'Код формата',               8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '801', 'a', 0, 0, 'Страна', 'Страна',                         8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '801', 'b', 0, 0, 'Организация', 'Организация',               8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '801', 'c', 0, 0, 'Дата составления', 'Дата составления',     8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '801', 'g', 0, 1, 'Правила каталогизации', 'Правила каталогизации', 8, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '802', '', '', 'Центр ISSN', 'Центр ISSN', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '802', 'a', 0, 0, 'Код центра ISSN', 'Код центра ISSN',       8, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '830', '', 1, 'Общее примечание, составленное каталогизатором', 'Общее примечание, составленное каталогизатором', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '830', 'a', 0, 0, 'Текст примечания', 'Текст примечания',     8, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '850', '', 1, 'Организация – держатель', 'Организация – держатель', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '850', 'a', 0, 1, 'Идентификатор организации', 'Идентификатор организации', 8, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '852', '', 1, 'Местонахождение и шифр хранения', 'Местонахождение и шифр хранения', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '852', '2', 0, 0, 'Код системы', 'Код системы',               8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'a', 0, 0, 'Идентификатор организации', 'Идентификатор организации', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'b', 0, 1, 'Наименование фонда или коллекции (Sub-Location Identifier) ', 'Наименование фонда или коллекции (Sub-Location Identifier) ', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'c', 0, 0, 'Адрес', 'Адрес',                           8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'd', 0, 0, 'Определитель местонахождения (в кодированной форме)', 'Определитель местонахождения (в кодированной форме)', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'e', 0, 0, 'Определитель местонахождения (не в кодированной форме)', 'Определитель местонахождения (не в кодированной форме)', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'g', 0, 0, 'Префикс шифра хранения', 'Префикс шифра хранения', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'j', 0, 0, 'Шифр хранения (Call Number)', 'Шифр хранения (Call Number)', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'k', 0, 0, 'Заглавие, имя автора, автор / заглавие, используемое для организации фонда', 'Заглавие, имя автора, автор / заглавие, используемое для организации фонда', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'l', 0, 0, 'Суффикс шифра хранения', 'Суффикс шифра хранения', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'm', 0, 0, 'Идентификатор единицы', 'Идентификатор единицы', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'n', 0, 0, 'Идентификатор экземпляра', 'Идентификатор экземпляра', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'p', 0, 0, 'Страна', 'Страна',                         8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 't', 0, 0, 'Номер экземпляра', 'Номер экземпляра',     8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'x', 0, 1, 'Не публикуемое примечание', 'Не публикуемое примечание', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '852', 'y', 0, 1, 'Публикуемое примечание', 'Публикуемое примечание', 8, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '856', '', 1, 'Местонахождение электронных ресуров и доступ к ним', 'Местонахождение электронных ресуров и доступ к ним', 'rusmarc856');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '856', '2', 0, 0, 'Текст ссылки (Link text)', 'Текст ссылки (Link text)', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'a', 0, 1, 'Имя хоста (Host name)', 'Имя хоста (Host name)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'b', 0, 1, 'Цифровой код доступа (Access number)', 'Цифровой код доступа (Access number)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'c', 0, 1, 'Сведения о сжатии (Compression information)', 'Сведения о сжатии (Compression information)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'd', 0, 1, 'Путь (Path)', 'Путь (Path)',               8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'e', 0, 0, 'Дата и время последнего доступа (Date and Hour of Consultation and Access)', 'Дата и время последнего доступа (Date and Hour of Consultation and Access)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'f', 0, 1, 'Электронное имя (Electronic name)', 'Электронное имя (Electronic name)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'g', 0, 1, 'Универсальное имя ресурса (Uniform resource name)', 'Универсальное имя ресурса (Uniform resource name)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'h', 0, 0, 'Исполнитель запроса (Processor of request)', 'Исполнитель запроса (Processor of request)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'i', 0, 1, 'Команда (Instruction)', 'Команда (Instruction)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'j', 0, 0, 'Скорость передачи данных (bits per second)', 'Скорость передачи данных (bits per second)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'k', 0, 0, 'Пароль (Password)', 'Пароль (Password)',   8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'l', 0, 0, 'Имя пользователя (logon/login)', 'Имя пользователя (logon/login)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'm', 0, 1, 'Координаты для получения помощи по доступу (Contact for access assistance)', 'Координаты для получения помощи по доступу (Contact for access assistance)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'n', 0, 0, 'Название местонахождения сервера, определенного в подполе $a (Name of location o', 'Название местонахождения сервера, определенного в подполе $a (Name of location o', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'o', 0, 0, 'Операционная система (Operating system)', 'Операционная система (Operating system)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'p', 0, 0, 'Порт (Port)', 'Порт (Port)',               8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'q', 0, 0, 'Тип электронного формата (Electronic Format Type)', 'Тип электронного формата (Electronic Format Type)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'r', 0, 0, 'Установки (Settings)', 'Установки (Settings)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 's', 0, 1, 'Размер файла (File size)', 'Размер файла (File size)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 't', 0, 1, 'Эмуляция терминала (Terminal emulation)', 'Эмуляция терминала (Terminal emulation)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'u', 0, 0, 'Универсальный идентификатор ресурса (Uniform Resource Identifier)', 'Универсальный идентификатор ресурса (Uniform Resource Identifier)', 8, 0, 'biblioitems.url', '', '', 1, NULL, '', ''),
 ('', '', '856', 'v', 0, 1, 'Часы доступа по данному типу (Hours access method available)', 'Часы доступа по данному типу (Hours access method available)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'w', 0, 1, 'Контрольный номер записи (Record control number)', 'Контрольный номер записи (Record control number)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'x', 0, 1, 'Непубликуемое примечание (Nonpublic note)', 'Непубликуемое примечание (Nonpublic note)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'y', 0, 0, 'Тип доступа (Access method)', 'Тип доступа (Access method)', 8, -5, '', '', '', 0, NULL, '', ''),
 ('', '', '856', 'z', 0, 1, 'Публикуемое примечание (Public note)', 'Публикуемое примечание (Public note)', 8, -5, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '886', '', 1, 'Данные, неконвертируемые из исходного формата', 'Данные, неконвертируемые из исходного формата', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '886', '2', 0, 0, 'Код формата', 'Код формата',               8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '886', 'a', 0, 0, 'Метка поля в исходном формате', 'Метка поля в исходном формате', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '886', 'b', 0, 0, 'Содержимое поля в исходном формате', 'Содержимое поля в исходном формате', 8, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '899', '', 1, 'Данные о местонахождении (устаревшее)', 'Данные о местонахождении (устаревшее)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '899', 'a', 0, 0, 'Местонахождение', 'Местонахождение',       8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'b', 0, 0, 'Наименование фонда или коллекции', 'Наименование фонда или коллекции', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'c', 0, 1, 'Местонахождение стеллажа', 'Местонахождение стеллажа', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'h', 0, 0, 'Классификационная часть шифра', 'Классификационная часть шифра', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'i', 0, 1, 'Часть, характеризующая документ', 'Часть, характеризующая документ', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'j', 0, 0, 'Шифр хранения', 'Шифр хранения',           8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'k', 0, 0, 'Префикс шифра хранения', 'Префикс шифра хранения', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'l', 0, 0, 'Полочная форма заглавия', 'Полочная форма заглавия', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'm', 0, 0, 'Суффикс шифра хранения', 'Суффикс шифра хранения', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'p', 0, 0, 'Обозначение единицы хранения', 'Обозначение единицы хранения', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 't', 0, 0, 'Номер экземпляра', 'Номер экземпляра',     8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'x', 0, 1, 'Не публикуемое примечание', 'Не публикуемое примечание', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'y', 0, 1, 'Публикуемое примечание', 'Публикуемое примечание', 8, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '899', 'z', 0, 1, 'Публикуемое примечание', 'Публикуемое примечание', 8, 0, '', '', '', 0, NULL, '', '');

-- Create the ACQ framework based on the default framework, fields 995 only
INSERT IGNORE INTO biblio_framework VALUES( 'ACQ', 'Acquisition framework' );
INSERT INTO marc_tag_structure(tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ' FROM marc_tag_structure WHERE tagfield='995' AND frameworkcode='';

INSERT INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue, maxlength FROM marc_subfield_structure WHERE tagfield='995' AND frameworkcode='';

INSERT INTO marc_tag_structure(tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ'
FROM marc_tag_structure
WHERE frameworkcode="" AND tagfield IN (
    SELECT tagfield
    FROM marc_subfield_structure
    WHERE (
            kohafield="biblio.title"
        OR  kohafield="biblio.author"
        OR  kohafield="biblioitems.publishercode"
        OR  kohafield="biblioitems.editionstatement"
        OR  kohafield="biblioitems.publicationyear"
        OR  kohafield="biblioitems.isbn"
        OR  kohafield="biblio.seriestitle"
    ) AND frameworkcode=""
);
INSERT INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue, maxlength
FROM marc_subfield_structure
WHERE frameworkcode=""
AND kohafield IN ("biblio.title", "biblio.author", "biblioitems.publishercode", "biblioitems.editionstatement", "biblioitems.publicationyear", "biblioitems.isbn", "biblio.seriestitle" );
