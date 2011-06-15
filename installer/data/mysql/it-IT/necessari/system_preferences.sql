--
-- System preferences that differ from the global defaults
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License' WHERE variable = ' or (at your option) any later
-- version.
-- 
-- Koha is distributed in the hope that it will be useful' WHERE variable = ' but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with Koha; if not' WHERE variable = ' write to the Free Software Foundation' WHERE variable = ' Inc.' WHERE variable = '
-- 51 Franklin Street' WHERE variable = ' Fifth Floor' WHERE variable = ' Boston' WHERE variable = ' MA 02110-1301 USA.

UPDATE systempreferences SET value = 'cataloguing' WHERE variable = 'AcqCreateItem';
UPDATE systempreferences SET value = '1' WHERE variable = 'AllowOnShelfHolds';
UPDATE systempreferences SET value = '1' WHERE variable = 'AllowRenewalLimitOverride';
UPDATE systempreferences SET value = 'annual' WHERE variable = 'autoBarcode';
UPDATE systempreferences SET value = 'email' WHERE variable = 'AutoEmailPrimaryAddress';
UPDATE systempreferences SET value = '1' WHERE variable = 'BiblioAddsAuthorities';
UPDATE systempreferences SET value = 'city|surname|cardnumber' WHERE variable = 'BorrowerMandatoryField';
UPDATE systempreferences SET value = '0' WHERE variable = 'BorrowersLog';
UPDATE systempreferences SET value = 'Sig|Sig.ra|Sig.na' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = '0' WHERE variable = 'CataloguingLog';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurrencyFormat';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'relevance' WHERE variable = 'defaultSortField';
UPDATE systempreferences SET value = 'asc' WHERE variable = 'defaultSortOrder';
UPDATE systempreferences SET value = '0' WHERE variable = 'FinesLog';
UPDATE systempreferences SET value = '1' WHERE variable = 'FRBRizeEditions';
UPDATE systempreferences SET value = '1' WHERE variable = 'GoogleJackets';
UPDATE systempreferences SET value = '0' WHERE variable = 'IssueLog';
UPDATE systempreferences SET value = 'whitespace' WHERE variable = 'itemBarcodeInputFilter';
UPDATE systempreferences SET value = '676a' WHERE variable = 'itemcallnumber';
UPDATE systempreferences SET value = 'koha@cilea.it' WHERE variable = 'KohaAdminEmailAddress';
UPDATE systempreferences SET value = 'en,it-IT' WHERE variable = 'language';
UPDATE systempreferences SET value = '0' WHERE variable = 'LetterLog';
UPDATE systempreferences SET value = '0' WHERE variable = 'MARCOrgCode';
UPDATE systempreferences SET value = '2' WHERE variable = 'maxreserves';
UPDATE systempreferences SET value = '0' WHERE variable = 'NoZebra';
UPDATE systempreferences SET value = '0' WHERE variable = 'OpacAuthorities';
UPDATE systempreferences SET value = 'relevance' WHERE variable = 'OPACdefaultSortField';
UPDATE systempreferences SET value = 'asc' WHERE variable = 'OPACdefaultSortOrder';
UPDATE systempreferences SET value = '1' WHERE variable = 'OPACFRBRizeEditions';
UPDATE systempreferences SET value = 'en,it-IT' WHERE variable = 'opaclanguages';
UPDATE systempreferences SET value = '1' WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = '<h3>Benvenuto !!</h3>' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = 'Links importanti qui.' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '0' WHERE variable = 'OPACShelfBrowser';
UPDATE systempreferences SET value = '1' WHERE variable = 'OpacTopissue';
UPDATE systempreferences SET value = '1' WHERE variable = 'OPACURLOpenInNewWindow';
UPDATE systempreferences SET value = 'jpg' WHERE variable = 'patronimages';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryFuzzy';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryStemming';
UPDATE systempreferences SET value = '0' WHERE variable = 'QueryWeightFields';
UPDATE systempreferences SET value = '0' WHERE variable = 'ReservesNeedReturns';
UPDATE systempreferences SET value = '1' WHERE variable = 'ReturnBeforeExpiry';
UPDATE systempreferences SET value = '1' WHERE variable = 'TagsModeration';
UPDATE systempreferences SET value = '1' WHERE variable = 'ThingISBN';
UPDATE systempreferences SET value = '30600' WHERE variable = 'timeout';
UPDATE systempreferences SET value = 'URLLinkText' WHERE variable = 'URLLinkText';
UPDATE systempreferences SET value = '1' WHERE variable = 'XISBN';

UPDATE systempreferences SET value = '#200|<span style=\"font-weight:bold\">|{200a}{. 200c}{ : 200e}{200d}{ / 200f}{ ; 200g}{. 200h}{. 200i}|</span>\r\n#210|. &ndash; |{210a}{ : 210c}{, 210d}|\r\n#215|. &ndash; |{215a}{ ; 215d}|\r\n#225|. &ndash; |{(225a}{ ; 225v)}|\r\n#010|. &ndash; |{ISBN 010a}|' WHERE variable = 'ISBD';

UPDATE systempreferences SET value = '\'title\' => \'200a,200c,200d,200e,225a,225d,225e,225f,225h,225i,225v,500*,501*,503*,510*,512*,513*,514*,515*,516*,517*,518*,519*,520*,530*,531*,532*,540*,541*,545*,604t,610t,605a\',\r\n\'author\' => \'200f,600a,601a,604a,700a,700b,700c,700d,700a,701b,701c,701d,702a,702b,702c,702d,710a,710b,710c,710d,711a,711b,711c,711d,712a,712b,712c,712d\',\r\n\'isbn\' => \'010a\',\r\n\'issn\' => \'011a\',\r\n\'biblionumber => \'0909\',\r\n\'itemtype\' => \'200b\',\r\n\'language\' => \'101a\',\r\n\'publisher\' => \'210c\',\r\n\'date\' => \'210d\',\r\n\'note\' => \r\n\'300a,301a,302a,303a,304a,305a,306az,307a,308a,309a,310a,311a,312a,313a,314a,315a,316a,317a,318a,319a,320a,321a,322a,323a,324a,325a,326a,327a,328a,330a,332a,333a,336a,337a,345a\',\r\n\'Koha-Auth-Number\' => \'6009,6019,6029,6039,6049,6059,6069,6109,7009,7019,7029,7109,7119,7129\',\r\n        \'subject\' => \'600*,601*,606*,610*\',\r\n        \'dewey\' => \'676a\',\r\n        \'homebranch\' => \'995a,995b\',\r\n        \'lcn\' => \'995k\'' WHERE variable = 'NoZebraIndexes';
