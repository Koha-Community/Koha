--
-- System preferences that differ from the global defaults
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License, or (at your option) any later
-- version.
-- 
-- Koha is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with Koha; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

UPDATE systempreferences SET value = 1 WHERE variable = 'BiblioAddsAuthorities';
UPDATE systempreferences SET value = 'cardnumber|surname|address' WHERE variable = 'BorrowerMandatoryField';
UPDATE systempreferences SET value = 'Père|Mère|grand-parent|Tuteur légal|Autre' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'M|Mme|Mlle' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 0 WHERE variable = 'CataloguingLog';
UPDATE systempreferences SET value = 1 WHERE variable = 'expandedSearchOption';
UPDATE systempreferences SET value = 0 WHERE variable = 'FinesLog';
UPDATE systempreferences SET value = 'holdingbranch' WHERE variable = 'HomeOrHoldingBranchReturn';
UPDATE systempreferences SET value = '' WHERE variable = 'intranet_includes';
UPDATE systempreferences SET value = 0 WHERE variable = 'IssueLog';
UPDATE systempreferences SET value = '676a' WHERE variable = 'itemcallnumber';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'language';
UPDATE systempreferences SET value = 0 WHERE variable = 'LetterLog';
UPDATE systempreferences SET value = 'Ma bibliothèque' WHERE variable = 'LibraryName';
UPDATE systempreferences SET value = 0 WHERE variable = 'MARCOrgCode';
UPDATE systempreferences SET value = 2 WHERE variable = 'maxreserves';
UPDATE systempreferences SET value = 0 WHERE variable = 'NotifyBorrowerDeparture';
UPDATE systempreferences SET value = 1 WHERE variable = 'OpacBrowser';
UPDATE systempreferences SET value = 1 WHERE variable = 'OpacCloud';
UPDATE systempreferences SET value = 0 WHERE variable = 'OpacHighlightedWords';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'opaclanguages';
UPDATE systempreferences SET value = 1 WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = 'Bienvenue dans Koha...\r\n<hr>' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = '' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = 'serialcollection' WHERE variable = 'opacSerialDefaultTab';
UPDATE systempreferences SET value = 'jpg' WHERE variable = 'patronimages';
UPDATE systempreferences SET value = 0 WHERE variable = 'QueryFuzzy';
UPDATE systempreferences SET value = 0 WHERE variable = 'QueryStemming';
UPDATE systempreferences SET value = 0 WHERE variable = 'QueryWeightFields';
UPDATE systempreferences SET value = 10 WHERE variable = 'ReservesMaxPickUpDelay';
UPDATE systempreferences SET value = 0 WHERE variable = 'ReservesNeedReturns';
UPDATE systempreferences SET value = 0 WHERE variable = 'ReturnLog';
UPDATE systempreferences SET value = 1 WHERE variable = 'SearchMyLibraryFirst';
UPDATE systempreferences SET value = 0 WHERE variable = 'SubscriptionLog';
UPDATE systempreferences SET value = 30600 WHERE variable = 'timeout';

UPDATE `systempreferences` SET value = "'title' => '200a,200c,200d,200e,225a,225d,225e,225f,225h,225i,225v,500*,501*,503*,510*,512*,513*,514*,515*,516*,517*,518*,519*,520*,530*,531*,532*,540*,541*,545*,604t,610t,605a',
        'author' =>'200f,600a,601a,604a,700a,700b,700c,700d,700a,701b,701c,701d,702a,702b,702c,702d,710a,710b,710c,710d,711a,711b,711c,711d,712a,712b,712c,712d',
        'isbn' => '010a',
        'issn' => '011a',
        'biblionumber' =>'0909',
        'itemtype' => '200b',
        'language' => '101a',
        'publisher' => '210c',
        'date' => '210d',
        'note' => '300a,301a,302a,303a,304a,305a,306az,307a,308a,309a,310a,311a,312a,313a,314a,315a,316a,317a,318a,319a,320a,321a,322a,323a,324a,325a,326a,327a,328a,330a,332a,333a,336a,337a,345a',
        'Koha-Auth-Number' => '6009,6019,6029,6039,6049,6059,6069,6109,7009,7019,7029,7109,7119,7129',
        'subject' => '600*,601*,606*,610*',
        'dewey' => '676a',
        'homebranch' => '995a,995b',
        'lcn' => '995k'" WHERE variable = 'NoZebraIndexes';
