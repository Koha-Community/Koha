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

UPDATE systempreferences SET value = 'takaaja' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = '' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurencyFormat';
UPDATE systempreferences SET value = 'de' WHERE variable = 'AddressFormat';
UPDATE systempreferences SET value = 'dmydot' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'z' WHERE variable = 'DefaultClassificationSource';
UPDATE systempreferences SET value = 'Tervetuloa Kohan asiakaskäyttöliittymään!' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = '' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '' WHERE variable = 'OpacNavBottom';
UPDATE systempreferences SET value =
    '<li><a href="http://worldcat.org/search?q={TITLE}" target="_blank">Muut kirjastot (WorldCat)</a></li>
    <li><a href="http://www.scholar.google.com/scholar?q={TITLE}" target="_blank">Google Scholar</a></li>
    <li><a href="http://www.bookfinder.com/search/?author={AUTHOR}&amp;title={TITLE}&amp;st=xl&amp;ac=qr" target="_blank">Verkkokaupat (Bookfinder.com)</a></li>
    <li><a href="https://openlibrary.org/search/?author=({AUTHOR})&title=({TITLE})" target="_blank">Open Library (openlibrary.org)</a></li>'
    WHERE variable = 'OPACSearchForTitleIn';
-- Sunday = 0, Monday = 1, etc.
UPDATE systempreferences SET value = '1' WHERE variable = 'CalendarFirstDayOfWeek';
UPDATE systempreferences SET value = '0.24|0.14|0.10|0.00' WHERE variable = 'gist';
UPDATE systempreferences SET value = 'Vaihda tämä ilmoitus muokkaamalla järjestelmäasetusta <a href="/cgi-bin/koha/admin/preferences.pl?op=search&searchfield=RoutingListNote#jumped">RoutingListNote</a>.' where variable = 'RoutingListNote';
UPDATE systempreferences SET value = 'barcode' WHERE variable = 'uniqueitemfields';
UPDATE systempreferences SET value = 'fi-FI,en' WHERE variable = 'language';
UPDATE systempreferences SET value = 'fi-FI,en' WHERE variable = 'opaclanguages';
UPDATE systempreferences SET value = '1' WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = 'fin' WHERE variable = 'DefaultLanguageField008';
UPDATE systempreferences SET value = 'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Å Ä Ö' WHERE variable = 'alphabet';
