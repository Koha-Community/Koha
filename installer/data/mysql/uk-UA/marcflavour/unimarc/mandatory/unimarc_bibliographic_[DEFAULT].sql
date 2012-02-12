# **************************************************************************
# СТРУКТУРА KOHA УКРМАРК ДЛЯ БІБЛІОГРАФІЧНИХ ЗАПИСІВ (UKRAINIAN UNIMARC BIBLIOGRAPHIC) 
#
# Версія 0.6 - виділення блоків полів з підполями (для полегшення керування та клонування)
# 29 березня 2009 року
#
# створено
# Сергієм Дубиком (Serhij Dubyk - serhijdubyk@gmail.com)
#
# з
#
# UNIMARC manual : bibliographic format 1994 / IFLA Universal
#  Bibliographic Control and International MARC Core Programme (UBCIM). -
#  "The following list represents the state of the format as at 1 March
#  2000.  It includes the changes published in Update 3." -
#  http://www.ifla.org/VI/3/p1996-1/sec-uni.htm.
#  2006-03-15 a;
#
# UNIMARC manual: bibliographic format / IFLA UNIMARC Core Activity; ed. By Alan Hopkinson. 
#  3rd ed. - München: Saur, 2008. (IFLA Series in Bibliographic Control, 36). 
#  ISBN 978-3-598-24284-7, 760 p.
#  http://www.ifla.org/VI/8/unimarc-concise-bibliographic-format-2008.pdf
# **************************************************************************

-- truncate marc_tag_structure;
-- truncate marc_subfield_structure;

-- DELETE FROM biblio_framework WHERE frameworkcode='';
/*INSERT INTO biblio_framework 
(frameworkcode, frameworktext) VALUES 
('',           'по умовчанню');*/

DELETE FROM marc_tag_structure WHERE frameworkcode='';

DELETE FROM marc_subfield_structure WHERE frameworkcode='';

# *******************************************************
# ПОЛЯ/ПІДПОЛЯ КОХА ТА ЛОКАЛЬНІ.
# *******************************************************

INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian,                       libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder,     isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('000',      '@',           'Контрольне поле фіксованої довжини', '',        0,            0,           '',          0,     '',                 '',             'unimarc_leader.pl', 0,       1,        '',              '',        '',     NULL);

# biblio.biblionumber перенесений до 999^9
/*INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('001', '@', 'Номер ідентифікації примітки', '', 0, 0, '', 3, '', '', '', 0, 1, '', '', '', NULL);*/

INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian,      libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder,         isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('005',    '@',         'Контрольне поле', '',      0,          0,         '',        0,   '',               '',           'marc21_field_005.pl', 0,     1,      '',            '',      '',   NULL);

# biblioitems.biblioitemnumber перенесений до 999^a
/*INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('090', 'Numéro biblio (koha)', '', 0, 0, '', '');*/
/*INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('090', '9', 'Номер бібліотечного запису (Koha)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('090', 'a', 'Номер бібліотечної одиниці (Koha)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);*/

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('099', 'Informations locales (Koha)', '', 0, 0, '', '');
INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian,                    libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('099',      'c',           'Date creation notice (Koha)',     '',        0,            0,           'biblio.datecreated', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('099',      'd',           'Date modification notice (Koha)', '',        0,            0,           'biblio.timestamp', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian,        libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('700',   '9',           'Внутрішній код Koha', '',        0,             0,          '',          7,     '',                 '',             '',              0,        1,       '',              '',        '7009', NULL);

INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('701',      '9',           'Внутрішній код Koha', '', 0, 0, '', 7, '', '', '', 0, 1, '', '', '7019', NULL);

INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('702',      '9',           'Внутрішній код Koha', '', 0, 0, '', 7, '', '', '', 0, 1, '', '', '7029', NULL);

# old 990s from french Unimarc
/*INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('990', 'Знак або запис про зміст', '', 0, 0, NULL, '');*/
/*INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('990', '5', 'Ідентифікатор екземпляра', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'a', 'Запис про зміст цієї установи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'b', 'Визначник/кваліфікатор', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'c', 'Абревіатура бібліотеки', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'd', 'Абревіатура особливого фонду', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'e', 'Стан з’єднання', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'f', 'Особливості екземпляра', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'g', 'Походження', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'l', 'Фактичне розташування', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'p', 'Спеціальні фонди', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'r', 'Вид мікроформи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 's', 'Матеріальний опис мікроформи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 't', 'Дата передруку', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'v', 'Код управління блоків', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'y', 'Частка праці, що служила для копії', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('990', 'z', 'Останній випуск reu', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);*/
# new 942s from English Marc21
INSERT INTO marc_tag_structure 
(tagfield, liblibrarian,                  libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('942',    'Додаткові дані (Коха)', '',      0,          0,         '',               '');
INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian,                            libopac, repeatable, mandatory, kohafield,            tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('942',    '0',        'Koha issues (borrowed), all copies',     '',      0,        0,       'biblioitems.totalissues', 9,  '',              '',           '',             0,     -5,     '',            '',      '',   NULL),
('942',    '2',        'Код системи класифікації для розстановки фонду', '', 0,     0,       'biblioitems.cn_source',   9,  '',              '',           '',  0,  0,   '',  '',  '', NULL),
('942',    '6',        'Нормалізована класифікація Коха для сортування',  '', 0,    0,       'biblioitems.cn_sort',     -1, '',              '',           '',  0,  7,   '',  '',  '', NULL),
('942',    'a',        'Тип одиниці [ЗАСТАРІЛЕ]',                '',      0,        0,       '',                        9,  '',              '',           '',  0,  -5,  '',  '',  '', NULL),
('942',    'b',        'Код структури запису Коха',              '',      0,        0,       'biblio.frameworkcode',    9,  '',              '',           '',  0,  -5,  '',  '',  '', NULL),
('942',    'c',        'Тип одиниці (рівень запису)',            '',      0,        1,       'biblioitems.itemtype',    9,  'itemtypes',     '',           '',  0,  0,   '',  '',  '', NULL),
('942',    'e',        'Видання /частина шифру/',                '',      0,        0,       'biblioitems.cn_edition',  9,  'CN_EDITION',    '',           '',  0,  0,   '',  '',  '', NULL),
('942',    'h',        'Класифікаційна частина шифру збереження','',      0,        0,       'biblioitems.cn_class',    9,  '',              '',           '',  0,  0,   '',  '',  '', NULL),
('942',    'i',        'Примірникова частина шифру збереження',  '',      1,        0,       'biblioitems.cn_item',     9,  '',              '',           '',  0,  9,   '',  '',  '', NULL),
('942',    'j',        'Шифр зберігання (повністю)',             'Шифр замовлення',0,0,      '',                        9,  '',              '',           '',  0,  -5,  '',  '',  '', NULL),
('942',    'k',        'Префікс шифру зберігання',               '',      0,        0,       'biblioitems.cn_prefix',   9,  '',              '',           '',  0,  0,   '',  '',  '', NULL),
('942',    'm',        'Суфікс шифру зберігання',                '',      0,        0,       'biblioitems.cn_suffix',   9,  '',              '',           '',  0,  0,   '',  '',  '', NULL),
('942',    'n',        'Статус приховування в ЕК',               '',      0,        0,       '',                        9,  'SUPPRESS',      '',           '',  0,  0,   '',  '',  '', NULL),
('942',    's',        'Serial record flag',                     'Serial record', 0,0,       'biblio.serial',           9,  '',              '',           '',  0,  -5,  '',  '',  '', NULL),
('942',    't',        'Номер комплекту/примірника',             '',      0,        0,       'biblioitems.cn_item',     9,  '',              '',           '',  0,  -5,  '',  '',  '', NULL),
('942',    'v',        'Авторський (кеттерівський) знак, дати чи термін, що додаються до класифікаційного індексу','',0,0,'',9,'',           '',           '',  0,  -5,  '',  '',  '', NULL);

-- adapted from English and French Marc21
INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('952', 'Дані про примірники та розташування (Koha)', '', 0, 0, '', '');
INSERT INTO marc_subfield_structure 
(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('952',   '0',         'Статус вилучення', '', 0, 0, 'items.wthdrawn', 10, 'WTHDRAWN', '', '', 0, 0, '', '', '', NULL),
('952',   '1',         'Статус доступності', '', 0, 0, 'items.itemlost', 10, 'LOST', '', '', 0, 0, '', '', '', NULL),
('952',   '2',         'Джерело класифікації чи схема поличного розташування', '', 0, 0, 'items.cn_source', 10, 'cn_source', '', '', NULL, 0, '', '', '', NULL),
('952',   '3',         'Ідентифікація описуваного матеріалу (об’єднаний том чи інша частина)', '', 0, 0, 'items.materials', 10, '', '', '', NULL, -1, '', '', '', NULL),
('952',   '4',         'Стан пошкодження', '', 0, 0, 'items.damaged', 10, 'DAMAGED', '', '', NULL, 0, '', '', '', NULL),
('952',   '5',         'Статус обмеження доступу', '', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, '', '', '', NULL),
('952',   '6',         'Нормалізована класифікація Коха для сортування', '', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, '', '', '', NULL),
('952',   '7',         'Не для випожичання', '', 0, 0, 'items.notforloan', 10, 'NOT_LOAN', '', '', 0, 0, '', '', '', NULL),
('952',   '8',         'Колекція', '', 0, 0, 'items.ccode', 10, 'CCODE', '', '', 0, 0, '', '', '', NULL),
('952',   '9',         'Внутрішній № примірника в Koha (items.itemnumber)', '', 0, 0, 'items.itemnumber', -1, '', '', '', 0, 0, '', '', '', NULL),
('952',   'a',         'Постійне місце зберігання', '', 0, 0, 'items.homebranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
('952',   'b',         'Поточне місце зберігання', '', 0, 0, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
('952',   'c',         'Загальне розташування полиці', '', 0, 0, 'items.location', 10, 'LOC', '', '', 0, 0, '', '', '', NULL),
('952',   'd',         'Дата отримання', '', 0, 0, 'items.dateaccessioned', 10, '', '', 'dateaccessioned.pl', 0, 0, '', '', '', NULL),
('952',   'e',         'Джерело надходження', '', 0, 0, 'items.booksellerid', 10, '', '', '', 0, 0, '', '', '', NULL),
('952',   'f',         'Кодований визначник розташування', '', 0, 0, 'items.coded_location_qualifier', 10, '', '', '', NULL, 0, '', '', '', NULL),
('952',   'g',         'Вартість, звичайна закупівельна ціна', '', 0, 0, 'items.price', 10, '', '', '', 0, 0, '', '', '', NULL),
('952',   'h',         'Serial Enumeration / chronology','Serial Enumeration / chronology', 0, 0, 'items.enumchron', 10, '', '', '', 0, 0, '', '', '', NULL),
('952',   'j',         'Поличний контрольний номер', '', 0, 0, 'items.stack', 10, 'STACK', '', '', NULL, -1, '', '', '', NULL),
('952',   'i',         'Інвентарний номер', '', 0, 0, '', 10, '', '', '', NULL, 0, '', '', '', NULL),
('952',   'k',         'Дата останнього редагування примірника', '', 0, 0, '', 10, '', '', '', NULL, -1, '', '', '', NULL),
('952',   'l',         'Видач загалом', '', 0, 0, 'items.issues', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   'm',         'Продовжень загалом', '', 0, 0, 'items.renewals', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   'n',         'Загалом резервувань', '', 0, 0, 'items.reserves', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   'o',         'Повний (примірниковий) шифр збереження', '', 0, 0, 'items.itemcallnumber', 10, '', '', NULL, 0, 0, '', '', '', NULL),
('952',   'p',         'Штрих-код', '', 0, 0, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, '', '', '', NULL),
('952',   'q',         'Видано (дата)', '', 0, 0, 'items.onloan', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   'r',         'Дата, коли останній раз бачено примірник', '', 0, 0, 'items.datelastseen', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   's',         'Дата останнього випожичання', '', 0, 0, 'items.datelastborrowed', 10, '', '', '', NULL, -5, '', '', '', NULL),
('952',   't',         'Порядковий номер комплекту/примірника', '', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, '', '', '', NULL),
('952',   'u',         'Уніфікований ідентифікатор ресурсів', '', 0, 0, 'items.uri', 10, '', '', '', 1, 0, '', '', '', NULL),
('952',   'v',         'Вартість, ціна заміни', '', 0, 0, 'items.replacementprice', 10, '', '', '', 0, 0, '', '', '', NULL),
('952',   'w',         'Дата, для якої чинна ціна', '', 0, 0, 'items.replacementpricedate', 10, '', '', '', 0, 0, '', '', '', NULL),
('952',   'x',         'Службова примітка (lost item payment)', '', 1, 0, 'items.paidfor', 10, '', '', '', NULL, 7, '', '', '', NULL),
('952',   'y',         'Тип одиниці (рівень примірника)', '', 0, 0, 'items.itype', 10, 'itemtypes', '', '', NULL, 0, '', '', '', NULL),
('952',   'z',         'Загальнодоступна примітка', '', 0, 0, 'items.itemnotes', 10, '', '', '', NULL, 0, '', '', '', NULL);
# from Recommendation 995 (was in old French Unimarc)
/*('995',   '3',         'Статус обмеження доступу', '', 0, 0, 'items.restricted', 10, 'RESTRICTED', '', '', 0, 0, '', '', '', NULL),
('995',   '4',         'Koha normalized збіріганняclassification for sorting', '', 0, 0, 'items.cn_sort', -1, '', '', '', 0, 7, '', '', '', NULL),
('995',   '5',         'Coded location qualifier', '', 0, 0, '', 10, '', '', 'marc21_locationqualifier.pl', NULL, 0, '', '', '', NULL),
('995',   '6',         'Copy number', '', 0, 0, 'items.copynumber', 10, '', '', '', NULL, 0, '', '', '', NULL),
('995',   '7',         'Uniform Resource Identifier', '', 0, 0, 'items.uri', 10, '', '', '', 0, 0, '', '', '', NULL),
('995',   'a',         'Власник документу, вільним текст', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'b',         'Власник документу (кодовані дані)', '', 0, 1, 'items.homebranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
('995',   'c',         'Місце повернення/зберігання, вільним текстом', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'd',         'Місце повернення/зберігання (кодовані дані)', '', 0, 1, 'items.holdingbranch', 10, 'branches', '', '', 0, 0, '', '', '', NULL),
('995',   'e',         'Кваліфікація розміщення примірника, області', '', 0, 0, 'items.location',      10, 'LOC', '', '', 0, 0, '', '', '', NULL),
('995',   'f',         'Штрих-код', '',                  0, 1, 'items.barcode', 10, '', '', 'barcode.pl', 0, 0, '', '', '', NULL),
('995',   'g',         'Штрих-код, префікс', '',         0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'h',         'Штрих-код, приріст', '',         0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'i',         'Штрих-код, суфікс', '',          0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'j',         'Штрих-код',         'штрих-код', 0, 0, '', 10, '', '', '', 0, 0, '', '', '', NULL),
('995',   'k',         'Інвентарний номер', '',          0, 0, 'items.itemcallnumber', 10, '', '', '', 0, 0, '', '', '', NULL),
('995',   'l',         'Томовість', '',                  0, 0, '', -1, 'items.materials', '', '', 0, 0, '', '', '', NULL),
('995',   'm',         'Дата останнього доступу до примірника', '', 0, 0, 'items.datelastseen', 10, '', '', '', 0, 0, '', '', '', NULL),
('995',   'n',         'Дата передбачуваного відновлення доступності', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'o',         'Типи обігу (не для випожичання)', '', 0, 0, 'items.notforloan', 10, 'loan', '', '', 0, 0, '', '', '', NULL),
('995',   'r',         'Тип документа та його матеріальний носій (папір, КД,...)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'q',         'Цільова публіка (за віком)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   's',         'Елемент сортування (пошуку)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('995',   'u',         'Загальнодоступна примітка', '', 0, 0, 'items.itemnotes', 10, '', '', '', 0, 0, '', '', '', NULL),*/

-- тут деяке пояcнення щодо 952f - http://www.nabble.com/What-is-the-coded-location-qualifier-in-952-%24f-td25495799.html

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('999', 'Внутрішні контрольні номери (Koha)', '', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('999', '9', 'Внутрішній № в Koha (biblio.biblionumber)', '', 0, 0, 'biblio.biblionumber', -1, '', '', '', 0, -5, '', '', '', NULL),
('999', 'a', 'Внутрішній № бібліотечного запису в Koha (biblioitems.biblioitemnumber)', '', 0, 0, 'biblioitems.biblioitemnumber', -1, '', '', '', 0, -5, '', '', '', NULL);


# *******************************************************
# ПОЛЯ/ПІДПОЛЯ УКРМАРКУ.
# *******************************************************

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('001', 'Ідентифікатор запису', '', 0, 0, '', '');

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('005', 'Ідентифікатор версії', '', 0, 0, NULL, '');

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('010', 'Міжнародний стандартний книжковий номер (ISBN)', 'ISBN', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('010', '9', 'Тираж',                      '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('010', 'a', 'Номер (ISBN)', 'ISBN', 0, 0, 'biblioitems.isbn', 0, '', '', '', 0, 0, '', '', '', NULL),
('010', 'b', 'Уточнення',                  '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('010', 'd', 'Умови придбання і/або ціна', '', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
('010', 'z', 'Помилковий ISBN',            '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('011', 'Міжнародний стандартний номер серіального видання (ISSN)', 'ISSN', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('011', '9', 'Тираж',        '',     0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('011', 'a', 'Номер (ISSN)', 'ISSN', 0, 0, 'biblioitems.issn', 0, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('011', 'b', 'Уточнення',    '',     0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('011', 'd', 'Умови придбання і/або ціна', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('011', 'y', 'Анульований ISSN',           '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('011', 'z', 'Помилковий ISSN',            '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('012', 'Ідентифікатор фінгерпринту', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('012', '2', 'Код системи утворення фінгерпринту', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('012', '5', 'Організація, якої стосується поле ідентифікатора фінгерпринту', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('012', 'a', 'Фінгерпринт', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('013', 'Міжнародний стандартний номер нотного видання (ISMN)', 'ISMN', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('013', 'a', 'Код ISMN', 'ISMN', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('013', 'b', 'Характеристики', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('013', 'd', 'Умови придбання та/або ціна', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('013', 'z', 'Помилковий ISMN', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('014', 'Ідентифікатор статті', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('014', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('014', 'a', 'Ідентифікатор статті', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('014', 'z', 'Помилковий ідентифікатор статті', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('015', 'Міжнародний стандартний номер технічного звіту (ISRN)', 'ISRN', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('015', 'a', 'Код ISRN', 'ISRN', 0, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
('015', 'b', 'Характеристики', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('015', 'd', 'Умови придбання і/або ціна', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('015', 'z', 'Скасований/недійсний/помилковий ISRN', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('016', 'Міжнародний стандартний код звуко-/відео-/аудіовізу­ального запису (ISRC)', 'ISRC', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('016', 'a', 'Код ISRC', 'ISRC', 0, 0, '', 0, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('016', 'b', 'Характеристики', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('016', 'd', 'Сфера доступності та/або ціна', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('016', 'z', 'Помилковий ISRC', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('020', 'Номер документа в національній бібліографії', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('020', 'a', 'Код країни', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('020', 'b', 'Номер', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('020', 'z', 'Помилковий номер', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('020', '9', 'Основна назва видання Української/іншої національної книжкової палати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('021', 'Номер державної реєстрації', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('021', 'a', 'Код країни', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('021', 'b', 'Номер', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('021', 'z', 'Помилковий номер державної реєстрації', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('022', 'Номер публікації органів державної влади', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('022', 'a', 'Код країни', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('022', 'b', 'Номер', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('022', 'z', 'Помилковий номер', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('035', 'Інші системні номери', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('035', 'a', 'Ідентифікатор запису+', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('035', 'z', 'Скасований чи помилковий ідентифікатор запису', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('040', 'CODEN (для серіальних видань)', 'CODEN', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('040', 'a', 'CODEN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('040', 'z', 'Помилковий CODEN', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('071', 'Видавничі номери (для музичних матеріалів)', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('071', 'a', 'Видавничий номер', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('071', 'b', 'Джерело', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('100', 'Дані загальної обробки', '', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('100', 'a', 'Дані загальної обробки', '', 0, 0, '', 3, '', '', 'unimarc_field_100.pl', 0, 1, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('101', 'Мова документу', 'Мова', 0, 1, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('101', 'a', 'Мова тексту, звукової доріжки тощо', '', 0, 1, '', 1, 'LANG', '', '', 0, 0, '', '', '', NULL),
('101', 'b', 'Мова проміжного перекладу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'c', 'Мова оригіналу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'd', 'Мова резюме/реферату', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'e', 'Мова сторінок змісту', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'f', 'Мова титульного аркуша, яка відрізняється від мов основного тексту документа', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'g', 'Мова основної назви', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'h', 'Мова лібрето тощо', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'i', 'Мова супровідного матеріалу (крім резюме, реферату, лібрето тощо)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('101', 'j', 'Мова субтитрів', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('102', 'Країна публікації/виробництва', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('102', 'a', 'Країна публікації', '', 0, 0, '', 1, 'COUNTRY', '', '', NULL, NULL, '', NULL, NULL, NULL),
('102', 'b', 'Місце публікації', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('105', 'Поле кодованих даних: текстові матеріали (монографічні)', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('105', 'a', 'Кодовані дані про монографію', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('106', 'Поле кодованих даних: текстові матеріали — фізичні характеристики', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('106', 'a', 'Кодовані дані позначення фізичної форми текстових матеріалів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('110', 'Кодовані дані: серіальні видання', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('110', 'a', 'Кодовані дані про серіальне видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('115', 'Поле кодованих даних: візуально-проекційні матеріали, відеозаписи та кінофільми', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('115', 'a', 'Кодовані дані — загальні', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('115', 'b', 'Кодовані дані архівних кінофільмів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('116', 'Поле кодованих даних: двовимірні зображувальні об’єкти', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('116', 'a', 'Кодовані дані для двовимірних зображувальних об’єктів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('117', 'Поле кодованих даних: тривимірні  штучні та природні об’єкти', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('117', 'a', 'Кодовані дані для тривимірних штучних та природних об’єктів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('120', 'Поле кодованих даних: картографічні матеріали — загальне', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('120', 'a', 'Кодовані дані картографічних матеріалів (загальні)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('121', 'Поле кодованих даних: картографічні матеріали: фізичні характеристики', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('121', 'a', 'Кодовані дані картографічних матеріалів: фізичні характеристики (загальні)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('121', 'b', 'Кодовані дані аерофотографічної та космічної зйомки: Фізичні характеристики', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('122', 'Поле кодованих даних: період часу, охоплюваний змістом документа', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('122', 'a', 'Період часу від 9999 до н.е. до теперішнього часу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('123', 'Поле кодованих даних: картографічні матеріали — масштаб та координати', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('123', 'a', 'Тип масштабу', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'b', 'Постійне відношення лінійного горизонтального масштабу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'c', 'Постійне відношення лінійного вертикального масштабу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'd', 'Координати — Західна довгота', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'e', 'Координати — Східна довгота', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'f', 'Координати — Північна широта', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'g', 'Координати — Південна широта', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'h', 'Кутовий масштаб', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'i', 'Схилення – Північна межа', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'j', 'Схилення – Південна межа', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'k', 'Пряме піднесення — Східна межа', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'm', 'Пряме піднесення — Західна межа', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'n', 'Рівнодення', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('123', 'o', 'Епоха', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('124', 'Поле кодованих даних: картографічні матеріали — специфічні характеристики матеріалу', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('124', 'a', 'Характеристика зображення', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'b', 'Форма картографічного документу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'c', 'Техніка подання фотографічних або нефотографічних зображень', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'd', 'Позиція платформи фотографування або дистанційного датчика', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'e', 'Категорія супутника для одержання дистанційного зображення', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'f', 'Найменування супутника для дистанційного зображення', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('124', 'g', 'Техніка запису для одержання дистанційного зображення', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('125', 'Поле кодованих даних: немузичні звукозаписи та нотні видання', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('125', 'a', 'Формат нотного видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('125', 'b', 'Визначник літературного тексту для немузичних звукозаписів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('126', 'Поле кодованих даних: звукозаписи — фізичні характеристики', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('126', 'a', 'Кодовані дані: загальні', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('126', 'b', 'Кодовані дані: спеціальні', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('127', 'Поле кодованих даних: тривалість звукозаписів і музичного виконання (для нотних видань)', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('127', 'a', 'Тривалість', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('128', 'Поле кодованих даних: жанр і форма музичної композиції,засоби виконання', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('128', 'a', 'Жанр і форма твору (музичне відтворення або партитура)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('128', 'b', 'Інструменти або голоси для ансамблів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('128', 'c', 'Інструменти або голоси для солістів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('130', 'Поле кодованих данных: мікроформи — фізичні характеристики', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('130', 'a', 'Мікроформа кодовані дані — фізичні характеристики', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('131', 'Поле кодованих даних: картографічні матеріали — геодезичні та координатні сітки та система вимірів', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('131', 'a', 'Сфероїд', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'b', 'Горизонтальна основа системи координат', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'c', 'Сітка координат', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'd', 'Накладені сітки', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'e', 'Додаткова сітка', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'f', 'Початок відліку висот', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'g', 'Одиниці виміру висот', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'h', 'Переріз рельєфу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'i', 'Допоміжний переріз рельєфу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'j', 'Одиниці батиметричного виміру глибин', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'k', 'Батиметричні інтервали (шкала глибин)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('131', 'l', 'Додаткові ізобати (додатковий батиметричний інтервал)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('135', 'Поле кодованих данных: електронні ресурси', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('135', 'a', 'Кодовані дані для електронних ресурсів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('140', 'Поле кодованих даних: монографічні стародруки — загальні характеристики', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('140', 'a', 'Кодовані дані: загальні', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('141', 'Поле кодованих даних: монографічні стародруки — специфічні характеристики примірника', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('141', '5', 'Організація, до якої додається поле', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('141', 'a', 'Кодовані дані монографічного стародруку: специфічні характеристики примірника', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('200', 'Назва та відомості про відповідальність', 'Назва', 0, 1, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('200', '5', 'Організація – власник примірника', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'b', 'Загальне визначення матеріалу носія інформації', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'c', 'Основна назва твору іншого автора', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'd', 'Паралельна назва', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'e', 'Підзаголовок', '', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
('200', 'h', 'Позначення та/або номер частини', '', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
('200', 'i', 'Найменування частини', '', 1, 0, '', 0, '', '', '', 0, 0, '', '', '', NULL),
('200', 'v', 'Позначення тому', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'z', 'Мова паралельної основної назви', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('200', 'g', 'Наступні відомості про відповідальність', '', 1, 0, 'additionalauthors.author', 0, '', '', '', 0, 0, '', '', '', NULL),
('200', 'f', 'Перші відомості про відповідальність', '', 1, 0, 'biblio.author', 0, '', '', '', 0, 0, '', '', '', NULL),
('200', 'a', 'Основна назва', '', 1, 1, 'biblio.title', 0, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('205', 'Відомості про видання', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('205', 'a', 'Відомості про видання', '', 0, 0, 'biblioitems.editionstatement', 0, '', '', '', 0, 0, '', '', '', NULL),
('205', 'b', 'Додаткові відомості про видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('205', 'd', 'Паралельні відомості про видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('205', 'f', 'Перші відомості про відповідальність відносно видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('205', 'g', 'Наступні відомості про відповідальність', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('206', 'Область специфічних характеристик матеріалу: картографічні матеріали – математичні дані', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('206', 'a', 'Відомості про математичні дані', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('207', 'Область специфічних характеристик матеріалу: серіальні видання – нумерація', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('207', 'a', 'Нумерація: Визначення дат і томів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('207', 'z', 'Джерело інформації про нумерацію', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('208', 'Область специфічних характеристик матеріалу: відомості про printed music specific statement', '', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('208', 'a', 'Специфічні відомості про нотне видання', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('208', 'd', 'Паралельні специфічні відомості про нотне видання', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('210', 'Публікування, розповсюдження тощо (вихідні дані)', 'Місце та час видання', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('210', 'b', 'Адреса видавця, розповсюджувача, тощо', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('210', 'e', 'Місце виробництва', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('210', 'f', 'Адреса виробника', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('210', 'g', 'Ім’я виробника, найменування друкарні', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('210', 'h', 'Дата виробництва', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('210', 'a', 'Місце публікування, друку, розповсюдження', '', 0, 0, 'biblioitems.place', 0, '', '', '', 0, 0, '', '', '', NULL),
('210', 'd', 'Дата публікації, розповсюдження, тощо', '', 0, 0, 'biblioitems.publicationyear', 0, '', '', '', 0, 0, '', '', '', NULL),
('210', 'c', 'Назва видавництва, ім’я видавця, розповсюджувача, тощо', '', 0, 0, 'biblioitems.publishercode', 0, '', '', 'unimarc_field_210c.pl', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('211', 'Запланована дата публікації', 'Запланована дата публікації', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('211', 'a', 'Дата', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('215', 'Область кількісної характеристики (фізична характеристика)', 'Фізичний опис', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('215', 'e', 'Супроводжувальний матеріал', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('215', 'c', 'Інші уточнення фізичних характеристик', '', 0, 0, 'biblioitems.illus', 1, '', '', '', 0, 0, '', '', '', NULL),
('215', 'a', 'Специфічне визначення матеріалу та обсяг документа', '', 1, 0, 'biblioitems.pages', 1, '', '', '', 0, 0, '', '', '', NULL),
('215', 'd', 'Розміри', '', 1, 0, 'biblioitems.size', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('225', 'Серія', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('225', 'a', 'Назва серії',                    '', 0, 0, 'biblio.seriestitle', 1, '', '', 'unimarc_field_225a.pl', 0, 0, '', '', '', NULL),
('225', 'd', 'Паралельна назва серії',         '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'e', 'Підзаголовок',                   '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'f', 'Відомості про відповідальність', 'biblioitems.editionresponsiblity', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'i', 'Найменування частини',           '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'h', 'Номер частини',                  '', 1, 0, 'biblioitems.number', -1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'v', 'Визначення тому',                '', 1, 0, 'biblioitems.volume', 1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'x', 'ISSN серії',                     '', 1, 0, 'biblioitems.collectionissn', -1, '', '', '', 0, 0, '', '', '', NULL),
('225', 'z', 'Мова паралельної назви',         '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('230', 'Область специфіки матеріалу: характеристики електронного ресурсу', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('230', 'a', 'Визначення типу та розміру електронного ресурсу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('300', 'Загальні примітки', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('300', 'a', 'Текст примітки', '', 0, 0, 'biblio.notes', 1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('301', 'Примітки, що відносяться до ідентифікаційних номерів', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('301', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('302', 'Примітки, що відносяться до кодованої інформації', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('302', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('303', 'Примітки, що відносяться до описової інформації', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('303', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('304', 'Примітки, що відносяться  до назви і відомостей про відповідальність', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('304', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('305', 'Примітки про видання та бібліографічну історію', 'Примітки', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('305', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('306', 'Примітки щодо публікації, розповсюдження тощо', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('306', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('307', 'Примітки щодо кількісної/фізичної характеристики', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('307', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('308', 'Примітки щодо серій', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('308', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('310', 'Примітки щодо оправи та умов придбання', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('310', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('311', 'Примітки щодо полів зв’язку', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('311', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('312', 'Примітки щодо співвіднесених назв', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('312', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('313', 'Примітки щодо предметного доступу', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('313', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('314', 'Примітки щодо інтелектуальної відповідальності', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('314', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('315', 'Примітки щодо специфічних характеристик матеріалу або типу публікації', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('315', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('316', 'Примітки щодо каталогізованого примірника', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('316', '5', 'Організація, до якої додається поле', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('316', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('317', 'Примітки щодо походження', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('317', '5', 'Організація, до якої додається поле', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('317', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('318', 'Примітки щодо поводження з примірником', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('318', '5', 'Організація, до якої додається поле', '', 1, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'a', 'Поводження', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'b', 'Ідентифікація поводження', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'c', 'Час поводження', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'd', 'Інтервал поводження', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'e', 'Робота з непередбачуваними обставинами', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'f', 'Авторизація', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'h', 'Повноваження', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'i', 'Метод роботи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'j', 'Місце роботи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'k', 'Виконавець роботи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'l', 'Статус', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'n', 'Межі роботи', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'o', 'Тип одиниці', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'p', 'Примітка, не призначена для друку', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('318', 'r', 'Примітка, призначена для друку', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('320', 'примітка про наявність бібліографії/покажчиків', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('320', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('321', 'Примітка про видані окремо покажчики, реферати, посилання', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('321', 'a', 'Примітка про покажчики, реферати, посилання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('321', 'b', 'Дати обсягу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('321', 'x', 'Міжнародний стандартний номер серіального видання ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('322', 'Примітки щодо переліку учасників підготовки матеріалу до випуску (проекційні та відеоматеріали і звукозаписи)', 'Примітки', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('322', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('323', 'Примітки щодо складу виконавців (проекційні та відеоматеріали і звукозаписи)', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('323', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('324', 'Примітка про версію оригіналу (факсіміле)', 'Примітки', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('324', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('325', 'Примітки щодо відтворення', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('325', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('326', 'Примітки про періодичність (серіальні видання)', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('326', 'a', 'Періодичність', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('326', 'b', 'Дати періодичності', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('327', 'Примітки про зміст', 'Примітки', 1, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('327', 'a', 'Текст примітки', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'b', 'Назва розділу: рівень 1', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'c', 'Назва розділу: рівень 2', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'd', 'Назва розділу: рівень 3', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'e', 'Назва розділу: рівень 4', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'f', 'Назва розділу: рівень 5', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'g', 'Назва розділу: рівень 6', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'h', 'Назва розділу: рівень 7', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'i', 'Назва розділу: рівень 8', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'p', 'Діапазон сторінок або номер першої сторінки розділу', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'u', 'Універсальний ідентифікатор ресурсу (URI)', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('327', 'z', 'Інша інформація, що стосується розділу', '', 1, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('328', 'Примітки про дисертацію', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('328', 'a', 'Текст примітки', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('330', 'Короткий звіт або резюме', 'Короткий зміст', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('330', 'a', 'Текст примітки', '', 0, 0, 'biblio.abstract', 1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('332', 'Бажана форма посилання для матеріалів, що оброблюються', 'Бажана форма посилання', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('332', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('333', 'Примітка про читацьке призначення', 'Приміти про особливості користування та поширення', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('333', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('334', 'Примітки про нагороди*', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('334', 'a', 'Текст примітки про нагороду', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('334', 'b', 'Назва нагороди', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('334', 'c', 'Рік присудження нагороди', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('334', 'd', 'Країна присудження нагороди', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('336', 'Примітки про тип електронного ресурсу', 'Примітки про тип електронного ресурсу', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('336', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('337', 'Примітки про системні вимоги (електронні ресурси)', 'Системні вимоги', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('337', 'a', 'Текст примітки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('345', 'Примітка про відомості щодо комплектування', 'Примітки', 0, 0, NULL, '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('345', 'a', 'Адреса та джерело комплектування/передплати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('345', 'b', 'Реєстраційний номер документа', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('345', 'c', 'Фізичний носій', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('345', 'd', 'Умови придбання. Ціна документа.', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('410', 'Серії (поле зв’язку)', 'Серії', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('410', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('410', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', '5', 'Установа в якій поле застосовано', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', '@', 'номер ідентифікації примітки', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'a', 'Автор', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'c', 'Місце публікації', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'd', 'Дата публікації', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'e', 'Відомості про видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'h', 'Номер розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'i', 'Назва розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'p', 'Фізичний опис', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 't', 'Назва', '', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'u', 'URL', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'v', 'Номер тому', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('410', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('411', 'Підсерії', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('411', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('411', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('411', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('421', 'Додаток', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('421', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('421', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('421', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('422', 'Видання, до якого належить додаток', 'Видання, до якого належить додаток', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('422', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('422', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('422', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('423', 'Видано з', 'Видано з', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('423', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('423', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('423', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('430', 'Продовжується', 'Продовжується', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('430', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('430', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('430', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('431', 'Продовжується в частково', 'Продовжується в частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('431', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('431', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('431', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('432', 'Заміщує', 'Заміщує', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('432', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('432', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('432', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('433', 'Заміщує в частково', 'Заміщує в частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('433', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('433', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('433', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('434', 'Поглинуте', 'Поглинуте', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('434', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('434', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('434', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('435', 'Поглинене частково', 'Поглинене частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('435', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('435', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('435', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('436', 'Утворене злиттям ..., ..., та ...', 'Утворене злиттям ..., ..., та ...', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('436', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('436', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('436', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('437', 'Відокремилось від…', 'Відокремилось від…', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('437', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('437', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('437', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('440', 'Продовжено як', 'Продовжено як', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('440', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('440', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('440', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('441', 'Продовжено частково', 'Продовжено частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('441', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('441', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('441', 'z', 'CODEN+', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('442', 'Заміщене', 'Заміщене', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('442', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('442', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('442', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('443', 'Заміщено частково', 'Заміщено частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('443', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('443', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('443', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('444', 'Те, що поглинуло', 'Те, що поглинуло', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('444', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('444', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('444', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('445', 'Те, що поглинуло частково', 'Те, що поглинуло частково', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('445', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('445', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('445', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('446', 'Поділилося на .., ..., та ...', 'Поділилося на .., ..., та ...', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('446', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('446', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('446', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('447', 'Злито з ... та ... щоб утворити ...', 'Злито з ... та ... щоб утворити ...', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('447', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('447', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('447', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('448', 'Повернулося до попередньої назви', 'Повернулося до попередньої назви', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('448', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('448', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('448', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('451', 'Інше видання на тому ж носії', 'Інше видання на тому ж носії', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('451', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('451', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('451', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('452', 'Інше видання на іншому носії', 'Видання на іншому носії', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('452', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('452', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('452', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('453', 'Перекладено як', 'Перекладено як', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('453', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('453', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('453', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('454', 'Перекладено з…', 'Перекладено з…', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('454', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('454', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', '5', 'Установа в якій поле застосовано', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', '@', 'номер ідентифікації примітки', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'a', 'Автор', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'c', 'Місце публікації', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'd', 'Дата публікації', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'e', 'Відомості про видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'h', 'Номер розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'i', 'Назва розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'p', 'Фізичний опис', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 't', 'Назва', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'u', 'URL', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'v', 'Номер тому', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('454', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('455', 'Відтворено з…', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('455', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('455', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('455', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('456', 'Відтворено як', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('456', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('456', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('456', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('461', 'Набір', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('461', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('461', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('461', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', '5', 'Установа в якій поле застосовано', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'a', 'Автор', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'c', 'Місце публікації', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'd', 'Дата публікації', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'e', 'Відомості про видання', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'h', 'Номер розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'i', 'Назва розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'p', 'Фізичний опис', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 't', 'Назва', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'u', 'URL', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'v', 'Номер тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('461', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('462', 'Піднабір', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('462', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('462', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('462', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('463', 'Окрема фізична одиниця', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('463', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('463', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('463', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('464', 'Аналітична одиниця', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('464', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('464', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('464', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('470', 'Документ, що є предметом огляду/рецензії', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('470', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('470', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'y', 'IМіжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('470', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('481', 'Також переплетено в цьому томі', 'Також переплетено в цьому томі', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('481', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('481', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('481', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('482', 'Переплетено з', 'Переплетено з', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('482', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('482', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('482', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('488', 'Інший співвіднесений твір', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('488', '0', 'Ідентифікатор бібліографічного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', '1', 'Дані, які пов’язуються', '', 1, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('488', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', '5', 'Установа в якій поле застосовано', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'a', 'Автор', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'c', 'Місце публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'd', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'e', 'Відомості про видання', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'h', 'Номер розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'i', 'Назва розділу або частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'p', 'Фізичний опис', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 't', 'Назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'u', 'URL', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'v', 'Номер тому', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'x', 'Міжнародний стандартний номер серіального видання – ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'y', 'Міжнародний стандартний книжковий номер - ISBN / Міжнародний стандартний музичний номер – ISMN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('488', 'z', 'CODEN', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('500', 'Уніфікована форма назви', 'Назва', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('500', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'a', 'Уніфікована форма назви', 'Назва', 0, 0, 'biblio.unititle', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('500', 'z', 'Хронологічний підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('501', 'Загальна уніфікована назва', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('501', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'a', 'Типова назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'b', 'Загальне визначення матеріалу', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'e', 'Типова підназва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'j', 'Підрозділ форми', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'k', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'm', 'Мова (якщо є частиною заголовку)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'r', 'Засоби виконання музичних творів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 's', 'Порядкове визначення  музичного твору', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'u', 'Ключ  музичного твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'w', 'Відомості про аранжування  музичного твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'x', 'Тематичний підрозділ', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'y', 'Географічний підрозділ', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('501', 'z', 'Хронологічний підрозділ', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('503', 'Уніфікований обумовлений заголовок', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('503', 'a', 'Основний уніфікований умовний заголовок', 'Заголовок', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'b', 'Підзаголовок уніфікованого умовного заголовку', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'd', 'Місяць і день', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'e', 'Прізвище особи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'f', 'Ім’я особи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'h', 'Визначник персонального імені', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'i', 'Назва частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'j', 'Рік', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'k', 'Нумерація (арабська)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'l', 'Нумерація (римська)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'm', 'Місцевість', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('503', 'n', 'Установа у місцевості', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('510', 'Паралельна основна назва', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('510', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'a', 'Паралельна назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'e', 'Інша інформація щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'h', 'Номер частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'i', 'Найменування частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'j', 'Том без індивідуальної назви або дати, які є визначенням тому, пов’язані з паралельною назвою', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'n', 'Різна інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('510', 'z', 'Мова назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('512', 'Назва обкладинки', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('512', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'a', 'Назва обкладинки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'e', 'Інші відомості щодо назви обкладинки', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'i', 'Найменування розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('512', 'z', 'Мова назви обкладинки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('513', 'Назва на додатковому титульному аркуші', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('513', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'a', 'Назва додаткового титульного аркуша', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'e', 'Інші відомості щодо назви додаткового титульного аркуша', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'h', 'Номер частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'i', 'Найменування частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('513', 'z', 'Мова назви додаткового титульного аркуша', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('514', 'Назва на першій сторінці тексту', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('514', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'a', 'Назва перед текстом', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'e', 'Інші відомості щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'i', 'Найменування розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('514', 'z', 'Мова назви обкладинки', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('515', 'Назва на колонтитулі', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('515', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'a', 'Назва колонтитулу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'e', 'Інша інформація щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'i', 'Найменування розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('515', 'z', 'Мова назви колонтитулу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('516', 'Назва на корінці', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('516', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'a', 'Назва на спинці', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'e', 'Інші відомості щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'i', 'Найменування розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('516', 'z', 'Мова назви на спинці', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('517', 'Інші варіанти назви', 'Інші варіанти назви', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('517', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'a', 'Інший варіант назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'e', 'Інші відомості щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('517', 'z', 'Мова інших варіантів назв', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('518', 'Назва сучасною орфографією', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('518', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'a', 'Основна назва, варіант назви або уніфікована форма назви сучасною орфографією, або окремі слова з них', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'e', 'Інша інформація щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'i', 'Найменування розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'j', 'Підрозділ форми твору', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'n', 'Змішана інформація', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('518', 'z', 'Мова іншої інформації щодо назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('520', 'Попередня назва (серіальні видання)', 'Попередня назва', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('520', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'a', 'Попередня основна назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'e', 'Інші відомості щодо назви', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'h', 'Нумерація частини (підсерії)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'i', 'Найменування частини (підсерії)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'j', 'Томи або дати попередньої назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'n', 'Текстовий коментар стосовно змісту підполів', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'x', 'ISSN попередньої назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('520', 'z', 'Мова попередньої назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('530', 'Ключова назва (серіальні видання)', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('530', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'a', 'Ключова назва', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'b', 'Уточнення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'j', 'Том або дата, пов’язані з ключовою назвою', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('530', 'z', 'Хронологічний підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('531', 'Скорочена назва (серіальні видання)', 'Скорочена назва', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('531', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'a', 'Скорочена ключова назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'b', 'Уточнення', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'v', 'Визначення тому ', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('531', 'z', 'Хронологічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('532', 'Розширена назва', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('532', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'a', 'Розширена назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('532', 'z', 'Мова назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('540', 'Додаткова назва застосована каталогізатором', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('540', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'a', 'Додаткова назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('540', 'z', 'Хронологічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('541', 'Перекладена назва складена каталогізатором', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('541', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'a', 'Перекладена назва', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'e', 'Інші відомості щодо назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'h', 'Нумерація частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'i', 'Найменування частини', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('541', 'z', 'Мова перекладеної назви', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('545', 'Назва розділу', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('545', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'a', 'Назва розділу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'b', 'Загальне визначення матеріалу носія документа', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'h', 'Номер розділу або частини', 'Номер', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'i', 'Найменування розділу або частини', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'j', 'Підрозділ форми твору', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'k', 'Дата публікації', 'Опубліковано', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'm', 'Мова (якщо є частиною заголовка)', 'Мова', 0, 0, '', -1, 'LANGUE', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'n', 'Змішана інформація', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'q', 'Версія (або дата версії)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'r', 'Засоби виконання (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 's', 'Числове визначення  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'u', 'Ключ  музичних творів', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'v', 'Визначення тому', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'x', 'Тематичний (предметний) підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'y', 'Географічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('545', 'z', 'Хронологічний підрозділ', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('600', 'Ім’я особи як предметна рубрика', 'Персоналія', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('600', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', '9', 'Визначення локальної системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'a', 'Початковий елемент заголовку рубрики', 'Предмет', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'b', 'Решта імені, що відрізняється від початкового елементу заголовку рубрики', '', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'c', 'Доповнення до імені (крім дат)', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'd', 'Римські цифри', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'g', 'Розкриття ініціалів особистого імені', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'j', 'Формальний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'p', 'Установа/адреса', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'x', 'Тематичний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'y', 'Географічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('600', 'z', 'Хронологічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('601', 'Найменування колективу як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('601', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', '9', 'Визначення локальної системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'a', 'Початковий елемент заголовку рубрики', 'Предмет', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'b', 'Підрозділ або найменування, якщо воно записане під місцезнаходженням', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'c', 'Доповнення до найменування або уточнення', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'd', 'Номер тимчасового колективу та/або номер частини тимчасового колективу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'e', 'Місце знаходження тимчасового колективу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'f', 'Дати існування тимчасового колективу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'g', 'Інверсований елемент', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'h', 'Частина найменування, що відрізняється від початкового елемента заголовку рубрик', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'j', 'Формальна підрубрика', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'x', 'Тематична підрубрика', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'y', 'Географічна підрубрика', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('601', 'z', 'Хронологічна підрубрика', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('602', 'Родове ім’я як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('602', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', '9', 'Визначення локальної системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'a', 'Початковий елемент заголовку рубрики', 'Предмет', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'f', 'Дати', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'j', 'Формальна підрубрика', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'x', 'Тематична підрубрика', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'y', 'Географічна підрубрика', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('602', 'z', 'Хронологічна підрубрика', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('604', 'Автор і назва як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('604', '1', 'Ім’я чи найменування автора та назва твору, що зв’язуються', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('605', 'Назва як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('605', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', '9', 'Визначення локальної системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'a', 'Заголовок рубрики', 'Предмет', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'h', 'Номер розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'i', 'Назва розділу або частини', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'j', 'Формальний підзаголовок', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'k', 'Дата публікації', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'l', 'Підзаголовок форми (підназва форми)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'm', 'Мова (як частина предметної рубрики)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'n', 'Змішана інформація', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'q', 'Версія (або дата версії)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'r', 'Засоби виконання (для музичних творів)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 's', 'Числове визначення (для музичних творів)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'u', 'Ключ (для музичних творів)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'w', 'Відомості про аранжування (для музичних творів)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'x', 'Тематичний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'y', 'Географічний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('605', 'z', 'Хронологічний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('606', 'Найменування теми як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('606', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('606', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('606', '9', 'Визначення локальної системи (внутрішній код Коха)', '', 0, 0, '', 1, '', '', '', 0, 1, '', '', '', NULL),
('606', 'a', 'Заголовок рубрики', 'Предмет', 0, 0, 'bibliosubject.subject', 1, '', '', '', 0, 0, '', '', '', NULL),
('606', 'j', 'Формальний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('606', 'x', 'Тематичний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('606', 'y', 'Географічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('606', 'z', 'Хронологічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('607', 'Географічна назва як предметна рубрика', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('607', '2', 'Код системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', '9', 'Визначення локальної системи', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', 'a', 'Заголовок рубрики', 'Предмет', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('607', 'j', 'Формальний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', 'x', 'Тематичний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', 'y', 'Географічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('607', 'z', 'Хронологічний підзаголовок', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('608', 'Форма, жанр, фізичні характеристики як предметний заголовок', 'Предмет', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('608', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', '5', 'Організація, до якої застосовується поле', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', '9', 'Визначення локальної системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', 'a', 'Початковий елемент заголовку', 'Предмет', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', 'j', 'Формальний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', 'x', 'Тематичний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', 'y', 'Географічний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('608', 'z', 'Хронологічний підзаголовок', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('610', 'Неконтрольовані предметні терміни', 'Ключові слова', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('610', 'a', 'Предметний термін', 'Предмет', 1, 0, '', 1, '', '', '', 0, 0, '', '', '610a', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('615', 'Предметна категорія (попереднє)', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('615', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', '9', 'Визначення локальної системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', 'a', 'Текст елемента предметної категорій', 'Предмет', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', 'm', 'Код підрозділу предметної категорії', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', 'n', 'Код предметної категорій', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('615', 'x', 'Текст підрозділу предметної категорії', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('616', 'Товарний знак як предметна рубрика', 'Товарний знак', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('616', '2', 'Код системи', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'a', 'Початковий елемент заголовку рубрики', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'c', 'Характеристики', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'f', 'Дати', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'j', 'Формальний підзаголовок', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'x', 'Тематична підрубрика', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'y', 'Географічна підрубрика', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('616', 'z', 'Хронологічна підрубрика', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('620', 'Місце як точка доступу', 'Місце', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('620', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('620', 'a', 'Країна', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('620', 'b', 'Автономна республіка/область/штат/провінція тощо', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('620', 'c', 'Район/графство/округ/повіт тощо', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('620', 'd', 'Місто', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('626', 'Технічні характеристики як точка доступу: електронні ресурси', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('626', 'a', 'Марка та модель комп’ютера', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('626', 'b', 'Мова програмування', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('626', 'c', 'Операційна система', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('629', 'Шифр наукової спеціальності як точка доступу', 'Шифр наукової спеціальності', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('629', '3', 'Номер авторитетного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('629', 'a', 'Шифр/найменування наукової спеціальності', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('629', 'b', 'Учений ступінь', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('629', 'c', 'Назва країни, де було подано дисертацію на здобуття вченого ступеню', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('660', 'Код географічного регіону', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('660', 'a', 'Код', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('661', 'Код періоду часу', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('661', 'a', 'Код періоду часу', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('670', 'PRECIS', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('670', 'b', 'Номер індикатора предмета', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('670', 'c', 'Рядок', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('670', 'e', 'Код індикатора посилання', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('670', 'z', 'Мова терміна', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('675', 'Універсальна десяткова класиікація', 'УДК', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('675', '3', 'Номер класифікаційного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('675', 'a', 'Індекс', '', 0, 0, '', 1, '', '', '', 0, 0, '', '', '', NULL),
('675', 'v', 'Видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('675', 'z', 'Мова видання', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('676', 'Десяткова класифікація Дьюї (DDC)', 'ДКД', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('676', '3', 'Номер класифікаційного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('676', 'a', 'Індекс', '', 0, 0, 'biblioitems.dewey', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('676', 'v', 'Видання', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('676', 'z', 'Мова видання', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('680', 'Класифікація бібліотеки конгресу США', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('680', '3', 'Номер класифікаційного запису', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('680', 'a', 'Класифікаційний індекс', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('680', 'b', 'Книжковий знак', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('686', 'Індекси інших класифікацій', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('686', '2', 'Код системи',                   '', 0, 0, '',  1, 'cn_source', '', '', 0, 0, '', '', '', NULL),
('686', '3', 'Номер класифікаційного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('686', '9', 'Визначення локальної системи',  '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('686', 'a', 'Індекс класифікації',           '', 0, 0, '',  1, '', '', '', 0, 0, '', '', '', NULL),
('686', 'b', 'Книжковий знак',                '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('686', 'c', 'Класифікаційний підрозділ',     '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('700', 'Особисте ім’я - первинна  інтелектуальна відповідальність', 'Особисте ім’я', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('700',   '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('700',   '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('700',   'a', 'Початковий елемент вводу', 'автор', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('700',   'b', 'Частина імені, яка відрізняється від початкового елемента вводу', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('700',   'c', 'Доповнення до імені окрім дат', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('700',   'd', 'Римські цифри', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('700',   'f', 'Дати', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('700',   'g', 'Розкриття ініціалів власного імені', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('700',   'p', 'Службові відомості про особу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('701', 'Ім’я особи – альтернативна інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('701', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('701', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('701', 'a', 'Початковий елемент вводу', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('701', 'b', 'Частина імені, яка відрізняється від початкового елемента вводу', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('701', 'c', 'Доповнення до імені окрім дат', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('701', 'd', 'Римські цифри', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('701', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('701', 'g', 'Розкриття ініціалів власного імені', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('701', 'p', 'Службові відомості про особу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('702', 'Ім’я особи – вторинна інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('702', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', '5', 'Установа-утримувач примірника', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', 'a', 'Початковий елемент вводу', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('702', 'b', 'Частина імені, яка відрізняється від початкового елемента вводу', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('702', 'c', 'Доповнення до імені окрім дат', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', 'd', 'Римські цифри', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('702', 'g', 'Розкриття ініціалів власного імені', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('702', 'p', 'Службові відомості про особу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('710', 'Найменування колективу - первинна  інтелектуальна відповідальність', 'Найменування колективу', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('710', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'a', 'Початковий елемент заголовку', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('710', 'b', 'Структурний підрозділ', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'c', 'Ідентифікаційні ознаки', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'd', 'Порядковий номер заходу або його частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'e', 'Місце проведення  заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'f', 'Дата проведення заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'g', 'Інверсований елемент', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'h', 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('710', 'p', 'Адреса', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('711', 'Найменування колективу - альтернативна  інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('711', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'a', 'Початковий елемент заголовку', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('711', 'b', 'Структурний підрозділ', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'c', 'Ідентифікаційні ознаки', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'd', 'Порядковий номер заходу або його частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'e', 'Місце проведення  заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'f', 'Дата проведення заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'g', 'Інверсований елемент', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'h', 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('711', 'p', 'Адреса', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('712', 'Найменування колективу - вторинна  інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('712', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', '5', 'Установа-утримувач примірника', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'a', 'Початковий елемент заголовку', '', 0, 0, '', 7, '', '', '', 0, 0, '', '', '', NULL),
('712', 'b', 'Структурний підрозділ', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'c', 'Ідентифікаційні ознаки', '', 0, 1, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'd', 'Порядковий номер заходу або його частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'e', 'Місце проведення  заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'f', 'Дата проведення заходу', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'g', 'Інверсований елемент', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'h', 'Частина найменування відмінна від початкового елементу заголовка та інверсованої частини', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('712', 'p', 'Адреса', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('716', 'Торгова марка', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('716', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('716', '4', 'Код відношення', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('716', 'a', 'Початковий елемент заголовку/точки доступу', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('716', 'c', 'Характеристики', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('716', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('720', 'Родове ім’я - первинна  інтелектуальна відповідальність', 'Родове ім’я', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('720', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('720', '4', 'Код відношення', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('720', 'a', 'Початковий елемент заголовку/точки доступу', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('720', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('721', 'Родове ім’я - альтернативна  інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('721', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('721', '4', 'Код відношення', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('721', 'a', 'Початковий елемент заголовку/точки доступу', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('721', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('722', 'Родове ім’я - вторинна  інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('722', '3', 'Номер авторитетного запису', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('722', '4', 'Код відношення', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('722', '5', 'Установа-утримувач примірника', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('722', 'a', 'Початковий елемент заголовку/точки доступу', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('722', 'f', 'Дати', '', 0, 0, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('730', 'Ім’я/найменування - інтелектуальна відповідальність', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('730', '4', 'Код відношення', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL),
('730', 'a', 'Ім’я/найменування', '', 0, 1, '', -1, '', '', '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('801', 'Джерело походження запису', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('801', '2', 'Код бібліографічного формату', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('801', 'a', 'Країна', '', 0, 0, '', 3, 'COUNTRY', '', '', 0, 0, '', '', '', NULL),
('801', 'b', 'Установа', '', 0, 0, '', 3, '', '', '', 0, 0, '', '', '', NULL),
('801', 'c', 'Дата', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL),
('801', 'g', 'Правила каталогізації', '', 0, 0, '', -1, '', '', '', 0, 0, '', '', '', NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('802', 'Центр ISSN', '', 0, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('802', 'a', 'Код центру ISSN', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('830', 'Загальні примітки каталогізатора', 'Примітки', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('830', 'a', 'Текст примітки', 'Примітка', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('852', 'Місцезнаходження та шифр зберігання',             '',         1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('852', '2', 'Код системи класифікації для розстановки фонду', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'a', 'Ідентифікатор організації', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'b', 'Найменування підрозділу, фонду чи колекції', '', 1, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'c', 'Адреса', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'd', 'Визначник місцезнаходження (в кодований формі)', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'e', 'Визначник місцезнаходження (не в кодований формі)', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'g', 'Префікс шифру зберігання', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'j', 'Шифр зберігання', 'Шифр замовлення', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'k', 'Форма заголовку/імені автора, що використовуються для організації фонду', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'l', 'Суфікс шифру зберігання', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'm', 'Ідентифікатор одиниці', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'n', 'Ідентифікатор екземпляра', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'p', 'Код країни основного місцезнаходження', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 't', 'Номер примірника', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'x', 'Службова примітка', '', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', ''),
('852', 'y', 'Загальнодоступна примітка', 'Нотатки', 0, 0, '', 8, '', '', '', 0, 0, '', NULL, '', '');

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('856', 'Електронна адреса та доступ', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('856', 'a', 'Ім’я сервера (Host name)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'b', 'Номер доступу (Access number)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'c', 'Відомості про стиснення (Compression information)', 'стиснення', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'd', 'Шлях (Path)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'e', 'Дата і час останнього доступу (Date and Hour of Consultation and Access)', 'Час останнього доступу', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'f', 'Електронне ім’я (electronic name)', 'електронне ім’я', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'g', 'Унікальне ім’я ресурсу (URN - Uniform Resource Name)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'h', 'Виконавець запиту (Processor of request)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'i', 'Команди (Instruction)', 'Команди', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'j', 'Швидкість передачі даних (BPS - bits per second)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'k', 'Пароль (Password)', 'Пароль', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'l', 'Ім’я користувача (Logon/login) ', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'm', 'Контактні дані для підтримки доступу (Contact for access assistance)', 'Контактні дані', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'n', 'Місце знаходження серверу, що позначений у підполі $a (Name of location of host)', 'адреса', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'o', 'Операційна система (Operating system)', 'Операційна система', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'p', 'Порт (Port)', 'Порт', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'q', 'Тип електронного формату (Electronic Format Type)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'r', 'Установки (Settings)', '', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 's', 'Розмір файлу (File size)', 'Розмір файлу', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 't', 'Емуляція терміналу (Terminal emulation)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'v', 'Термін доступу за даним методом (Hours access method available)', 'Термін доступу', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'u', 'Універсальна адреса ресурсу (URL - Uniform Resource Locator)', 'URL (універсальна адреса ресурсу)', 0, 1, 'biblioitems.url', -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'w', 'Контрольний номер запису', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'x', 'Службові нотатки (Nonpublic note)', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'y', 'Метод доступу', 'Метод доступу', 0, 0, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('856', 'z', 'Не службові нотатки (Public note)', 'нотатки', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);

INSERT INTO marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode) VALUES
('886', 'Дані, не конвертовані з вихідного формату', '', 1, 0, '', '');
INSERT INTO marc_subfield_structure (tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue) VALUES
('886', '2', 'Код правил каталогізації і форматів', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('886', 'a', 'Мітка поля вихідного формату', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL),
('886', 'b', 'Індикатори та підполя вихідного формату', '', 0, 1, NULL, -1, NULL, NULL, '', NULL, NULL, '', NULL, NULL, NULL);
