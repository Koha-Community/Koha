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

-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License' WHERE variable = ' or (at your option) any later
-- version.

UPDATE systempreferences SET value = 'cataloguing' WHERE variable = 'AcqCreateItem';
UPDATE systempreferences SET value = '1' WHERE variable = 'AllowRenewalLimitOverride';
UPDATE systempreferences SET value = 'annual' WHERE variable = 'autoBarcode';
UPDATE systempreferences SET value = 'email' WHERE variable = 'EmailFieldPrimary';
UPDATE systempreferences SET value = '1' WHERE variable = 'BiblioAddsAuthorities';
UPDATE systempreferences SET value = 'surname|cardnumber' WHERE variable = 'BorrowerMandatoryField';
UPDATE systempreferences SET value = '0' WHERE variable = 'BorrowersLog';
UPDATE systempreferences SET value = 'Sig|Sig.ra|Sig.na' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = '0' WHERE variable = 'CataloguingLog';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurrencyFormat';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'title' WHERE variable = 'defaultSortField';
UPDATE systempreferences SET value = 'asc' WHERE variable = 'defaultSortOrder';
UPDATE systempreferences SET value = '0' WHERE variable = 'FinesLog';
UPDATE systempreferences SET value = '1' WHERE variable = 'GoogleJackets';
UPDATE systempreferences SET value = '0' WHERE variable = 'IssueLog';
UPDATE systempreferences SET value = 'whitespace' WHERE variable = 'itemBarcodeInputFilter';
UPDATE systempreferences SET value = '676a' WHERE variable = 'itemcallnumber';
UPDATE systempreferences SET value = 'koha@xxx.it' WHERE variable = 'KohaAdminEmailAddress';
UPDATE systempreferences SET value = 'en,it-IT' WHERE variable = 'language';
UPDATE systempreferences SET value = '0' WHERE variable = 'ClaimsLog';
UPDATE systempreferences SET value = ''  WHERE variable = 'MARCOrgCode';
UPDATE systempreferences SET value = '5' WHERE variable = 'maxreserves';
UPDATE systempreferences SET value = '0' WHERE variable = 'OpacAuthorities';
UPDATE systempreferences SET value = 'title' WHERE variable = 'OPACdefaultSortField';
UPDATE systempreferences SET value = 'asc' WHERE variable = 'OPACdefaultSortOrder';
UPDATE systempreferences SET value = 'en,it-IT' WHERE variable = 'OPACLanguages';
UPDATE systempreferences SET value = '1' WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = '<h3>Benvenuto !!</h3>' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = 'Links importanti qui.' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '0' WHERE variable = 'OPACShelfBrowser';
UPDATE systempreferences SET value = '1' WHERE variable = 'OPACURLOpenInNewWindow';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryFuzzy';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryStemming';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryWeightFields';
UPDATE systempreferences SET value = '1' WHERE variable = 'TagsModeration';
UPDATE systempreferences SET value = '30600' WHERE variable = 'timeout';
UPDATE systempreferences SET value = '1' WHERE variable = 'UseICUStyleQuotes';
UPDATE systempreferences SET value = 'URLLinkText' WHERE variable = 'URLLinkText';

UPDATE systempreferences SET value = '#200|<span style=\"font-weight:bold\">|{200a}{. 200c}{ : 200e}{200d}{ / 200f}{ ; 200g}{. 200h}{. 200i}|</span>\r\n#210|. &ndash; |{210a}{ : 210c}{, 210d}|\r\n#215|. &ndash; |{215a}{ ; 215d}|\r\n#225|. &ndash; |{(225a}{ ; 225v)}|\r\n#010|. &ndash; |{ISBN 010a}|' WHERE variable = 'ISBD';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('COUNTRY', 'IT', 'Italia'),
('COUNTRY', 'US', 'Stati Uniti'),
('COUNTRY', 'GB', 'Regno Unito - UK '),
('COUNTRY', 'DE', 'Germania'),
('COUNTRY', 'FR', 'Francia'),
('COUNTRY', 'VA', 'Vaticano'),
('COUNTRY', 'CN', 'Cina'),
('COUNTRY', 'IN', 'India');

INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('LANG', 'ita', 'italiano'),
('LANG', 'eng', 'inglese'),
('LANG', 'ger', 'tedesco'),
('LANG', 'fre', 'francese'),
('LANG', 'lat', 'latino');
