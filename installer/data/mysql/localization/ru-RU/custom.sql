--
-- System preferences that differ from the global defaults
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- Koha is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Koha; if not, see <https://www.gnu.org/licenses>.

--- classification schemes or sources
DELETE FROM `class_sources`;
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`, `class_split_rule`) VALUES
                            ('ddc',     'Десятичная классификация Дьюи (ДКД)', 1, 'dewey', 'dewey'),
                            ('lcc',     'Классификация Библиотеки Конгресса (КБК)', 1, 'lcc', 'lcc'),
                            ('udc',     'Универсальная десятичная классификация', 0, 'generic', 'generic'),
                            ('sudocs',  'Классификация SuDoc (U.S. GPO)', 0, 'generic', 'generic'),
                            ('anscr',   'ANSCR (звукозаписи)', 0, 'generic', 'generic'),
                            ('rubbk',   'Таблицы ББК для научных библиотек в 30-ти томах', 0, 'generic', 'generic'),
                            ('rugasnti','Рубрикатор ГАСНТИ', 0, 'generic', 'generic'),
                            ('rubbkd',  'Таблицы ББК для детских библиотек в 1 т.', 0, 'generic', 'generic'),
                            ('rubbkm',  'Таблицы ББК для массовых библиотек в 1 т.', 0, 'generic', 'generic'),
                            ('rubbko',  'Таблицы ББК для областных библиотек в 4-х томах', 0, 'generic', 'generic'),
                            ('rubbknp', 'Переиздания таблиц ББК для научных библиотек в 30-ти томах', 0, 'generic', 'generic'),
                            ('rubbkn',  'Таблицы ББК для научных библиотек в 5-ти томах', 0, 'generic', 'generic'),
                            ('rubbkmv', 'Таблицы ББК для массовых военных библиотек', 0, 'generic', 'generic'),
                            ('rubbkk',  'Таблицы ББК для краеведческих каталогов библиотек', 0, 'generic', 'generic'),
                            ('z',       'Другие/типовые схемы классификации', 0, 'generic', 'generic');

UPDATE systempreferences SET value = 'Господин|Госпожа|Мистер|Миссис|Уважаемый|Уважаемая|Товарищ|Добродий|Добродийка' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'udc' WHERE variable = 'DefaultClassificationSource';
UPDATE systempreferences SET value = 'ru-RU,uk-UA,en,fr-FR,de-DE' WHERE variable = 'StaffInterfaceLanguages';
UPDATE systempreferences SET value = 'ru-RU,uk-UA,en,fr-FR,de-DE' WHERE variable = 'OPACLanguages';

UPDATE systempreferences SET value = '#200|<h2>Заглавие: |{200a}{. 200c}{ : 200e}{200d}{. 200h}{. 200i}|</h2>\r\n#500|<label class="ipt">Унифицированое заглавие: </label>|{500a}{. 500i}{. 500h}{. 500m}{. 500q}{. 500k}<br/>|\r\n#517|<label class="ipt"> </label>|{517a}{ : 517e}{. 517h}{, 517i}<br/>|\r\n#541|<label class="ipt"> </label>|{541a}{ : 541e}<br/>|\r\n#200||<label class="ipt">Автора: </label><br/>|\r\n#700||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7009}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{700c}{ 700b}{ 700a}{ 700d}{ (700f)}{. 7004}<br/>|\r\n#701||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7019}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{701c}{ 701b}{ 701a}{ 701d}{ (701f)}{. 7014}<br/>|\r\n#702||<a href="opac-search.pl?op=do_search&marclist=7009&operator==&type=intranet&value={7029}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{702c}{ 702b}{ 702a}{ 702d}{ (702f)}{. 7024}<br/>|\r\n#710||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7109}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{710a}{ (710c)}{. 710b}{ : 710d}{ ; 710f}{ ; 710e}<br/>|\r\n#711||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7119}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{711a}{ (711c)}{. 711b}{ : 711d}{ ; 711f}{ ; 711e}<br/>|\r\n#712||<a href="opac-search.pl?op=do_search&marclist=7109&operator==&type=intranet&value={7129}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по автору"></a>{712a}{ (712c)}{. 712b}{ : 712d}{ ; 712f}{ ; 712e}<br/>|\r\n#210|<label class="ipt">Унифицированная форма заглавия: </label>|{ 210a}<br/>|\r\n#210|<label class="ipt">Издатель: </label>|{ 210c}<br/>|\r\n#210|<label class="ipt">Дата публикации: </label>|{ 210d}<br/>|\r\n#215|<label class="ipt">Физическое описание: </label>|{215a}{ : 215c}{ ; 215d}{ + 215e}|<br/>\r\n#225|<label class="ipt">Серія:</label>|<a href="opac-search.pl?op=do_search&marclist=225a&operator==&type=intranet&value={225a}"> <img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {225a}"></a>{ (225a}{ = 225d}{ : 225e}{. 225h}{. 225i}{ / 225f}{, 225x}{ ; 225v}|)<br/>\r\n#200||<label class="ipt">Тематические рубрики: </label><br/>|\r\n#600||<a href="opac-search.pl?op=do_search&marclist=6009&operator==&type=intranet&value={6009}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6009}"></a>{ 600c}{ 600b}{ 600a}{ 600d}{ (600f)} {-- 600x }{-- 600z }{-- 600y}<br />|\r\n#604||<a href="opac-search.pl?op=do_search&marclist=6049&operator==&type=intranet&value={6049}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6049}"></a>{ 604a}{. 604t}<br />|\r\n#601||<a href="opac-search.pl?op=do_search&marclist=6019&operator==&type=intranet&value={6019}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6019}"></a>{ 601a}{ (601c)}{. 601b}{ : 601d} { ; 601f}{ ; 601e}{ -- 601x }{-- 601z }{-- 601y}<br />|\r\n#605||<a href="opac-search.pl?op=do_search&marclist=6059&operator==&type=intranet&value={6059}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6059}"></a>{ 605a}{. 605i}{. 605h}{. 605k}{. 605m}{. 605q} {-- 605x }{-- 605z }{-- 605y }{-- 605l}<br />|\r\n#606||<a href="opac-search.pl?op=do_search&marclist=6069&operator==&type=intranet&value={6069}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6069}">xx</a>{ 606a}{-- 606x }{-- 606z }{606y }<br />|\r\n#607||<a href="opac-search.pl?op=do_search&marclist=6079&operator==&type=intranet&value={6079}"><img border="0" src="/opac-tmpl/css/en/images/filefind.png" height="15" title="Поиск по {6079}"></a>{ 607a}{-- 607x}{-- 607z}{-- 607y}<br />|\r\n#010|<label class="ipt">ISBN: </label>|{010a}|<br/>\r\n#011|<label class="ipt">ISSN: </label>|{011a}|<br/>\r\n#200||<label class="ipt">Заметки: </label>|<br/>\r\n#300||{300a}|<br/>\r\n#320||{320a}|<br/>\r\n#327||{327a}|<br/>\r\n#328||{328a}|<br/>\r\n#200||<br/><h2>Экземпляры</h2>|\r\n#200|<table>|<th>Расположение</th><th>Cote</th>|\r\n#995||<tr><td>{995e}&nbsp;&nbsp;</td><td> {995k}</td></tr>|\r\n#200|||</table>' WHERE variable = 'ISBD';

DELETE FROM `z3950servers`;
INSERT INTO `z3950servers`
(`host`, `port`, `db`, `userid`, `password`, `servername`, `id`, `checked`, `rank`, `syntax`, `servertype`, `encoding`) VALUES
('z3950.bnf.fr', 2211, 'TOUT-UTF8', 'Z3950', 'Z3950_BNF', 'BNF2', 2, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('62.76.8.149', 210, 'books', '', '', 'НАУЧНАЯ БИБЛИОТЕКА БАШКИРСКОГО ГОСУДАРСТВЕННОГО УНИВЕРСИТЕТА', 3, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('81.30.205.34', 210, 'books', '', '', 'НАЦИОНАЛЬНАЯ БИБЛИОТЕКА ИМ. АХМЕТ-ЗАКИ ВАЛИДИ (БД BOOKS)', 4, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('libor.pstu.ru', 210, 'books', '', '', 'ПЕРМСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ (БД BOOKS)', 5, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('212.3.135.157', 210, 'books', '', '', 'СМОЛЕНСКАЯ ОБЛАСТНАЯ УНИВЕРСАЛЬНАЯ БИБЛИОТЕКА (БД BOOKS)', 6, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('212.3.135.157', 210, 'books_r', '', '', 'СМОЛЕНСКАЯ ОБЛАСТНАЯ УНИВЕРСАЛЬНАЯ БИБЛИОТЕКА (БД BOOKS_R)', 63, 1, 1, 'UNIMARC', 'zed', 'utf8'),
('212.3.135.157', 210, 'soub', '', '', 'СМОЛЕНСКАЯ ОБЛАСТНАЯ УНИВЕРСАЛЬНАЯ БИБЛИОТЕКА (БД SOUB)', 7, 1, 1, 'UNIMARC', 'zed', 'utf8');


UPDATE `currency` SET `active`=0;
INSERT INTO `currency` (`currency`, `symbol`, `rate`, active) VALUES ('UAH','грн.',1.0, 0);
INSERT INTO `currency` (`currency`, `symbol`, `rate`, active) VALUES ('RUB','руб.',21.166, 1);
