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

UPDATE systempreferences SET value = 'surname|cardnumber' WHERE variable = 'BorrowerMandatoryField';
UPDATE systempreferences SET value = 'far|mor' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'Fru|Frøken|Herr' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurrencyFormat';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'nb-NO' WHERE variable = 'language';
UPDATE systempreferences SET value = 'nb-NO' WHERE variable = 'opaclanguages';
UPDATE systempreferences SET value = '<p>Velkommen til Koha...</p><hr />' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = '<p>Viktige lenker kan plasseres her</p>' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '<li><a href="http://worldcat.org/search?q={TITLE}" target="_blank">Andre bibliotek (WorldCat)</a></li><li><a href="https://scholar.google.com/scholar?q={TITLE}" target="_blank">Andre databaser (Google Scholar)</a></li><li><a href="http://www.bookfinder.com/search/?author={AUTHOR}&amp;title={TITLE}&amp;st=xl&amp;ac=qr" target="_blank">Nettbutikker (Bookfinder.com)</a></li>' WHERE variable = 'OPACSearchForTitleIn';
-- Sunday = 0, Monday = 1, etc.
UPDATE systempreferences SET value = '1' WHERE variable = 'CalendarFirstDayOfWeek';
UPDATE systempreferences SET value = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Æ Ø Å' WHERE variable = 'alphabet';
UPDATE systempreferences SET value = 'nor' WHERE variable = 'DefaultLanguageField008';
