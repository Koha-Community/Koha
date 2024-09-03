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
-- along with Koha; if not, see <http://www.gnu.org/licenses>.

UPDATE systempreferences SET value = 'surname|cardnumber' WHERE variable = 'BorrowerMandatoryField';
UPDATE systempreferences SET value = 'far|mor' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'Fru|Frøken|Herr' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurrencyFormat';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'nb-NO' WHERE variable = 'StaffInterfaceLanguages';
UPDATE systempreferences SET value = 'nb-NO' WHERE variable = 'OPACLanguages';
UPDATE systempreferences SET value = '<p>Velkommen til Koha...</p><hr />' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = '<p>Viktige lenker kan plasseres her</p>' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '<a href="https://worldcat.org/search?q={TITLE}" target="_blank">Andre bibliotek (WorldCat)</a><a href="https://scholar.google.com/scholar?q={TITLE}" target="_blank">Andre databaser (Google Scholar)</a><a href="https://www.bookfinder.com/search/?author={AUTHOR}&amp;title={TITLE}&amp;st=xl&amp;ac=qr" target="_blank">Nettbutikker (Bookfinder.com)</a>' WHERE variable = 'OPACSearchForTitleIn';
-- Sunday = 0, Monday = 1, etc.
UPDATE systempreferences SET value = '1' WHERE variable = 'CalendarFirstDayOfWeek';
UPDATE systempreferences SET value = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Æ Ø Å' WHERE variable = 'alphabet';
UPDATE systempreferences SET value = 'nor' WHERE variable = 'DefaultLanguageField008';

UPDATE `currency` SET `active` = 0;
INSERT INTO `currency` (`currency`, `rate`, `symbol`, `active`) VALUES ('NOK', 1.0, 'kr', '1');

INSERT INTO z3950servers (host, port, db, userid, password, servername, id, checked, `rank`, syntax, timeout, servertype, encoding) VALUES
('lx2.loc.gov',210,'LCDB','','','LIBRARY OF CONGRESS',1,0,0,'USMARC',0,'zed','utf8'),
('z3950.bibsys.no',2100,'BIBSYS','','','BIBSYS',12,1,1,'MARC21',0,'zed','ISO_8859-1'),
('z3950.nb.no',2100,'Norbok','','','NORBOK',13,0,0,'MARC21',0,'zed','ISO_8859-1'),
('z3950.nb.no',2100,'Sambok','','','SAMBOK',14,0,0,'MARC21',0,'zed','ISO_8859-1'),
('z3950.deich.folkebibl.no',210,'data','','','DEICHMAN',15,0,0,'MARC21',0,'zed','ISO_8859-1');

#Insert SRU server
INSERT INTO z3950servers
(host, port, db, servername, syntax, encoding, servertype, sru_fields)
VALUES
('lx2.loc.gov',210,'LCDB','LIBRARY OF CONGRESS SRU','USMARC','utf8','sru','title=dc.title,isbn=bath.isbn,srchany=cql.anywhere,author=dc.author,issn=bath.issn,subject=dc.subject,stdid=bath.standardIdentifier');
