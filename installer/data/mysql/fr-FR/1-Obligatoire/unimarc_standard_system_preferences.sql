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

UPDATE systempreferences SET value = 'Père|Mère|grand-parent|Tuteur légal|Autre' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'M|Mme|Mlle' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = '676a' WHERE variable = 'itemcallnumber';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'language';
UPDATE systempreferences SET value = 'Ma bibliothèque' WHERE variable = 'LibraryName';
UPDATE systempreferences SET value = 'fr-FR' WHERE variable = 'OPACLanguages';
UPDATE systempreferences SET value = 1 WHERE variable = 'opaclanguagesdisplay';
UPDATE systempreferences SET value = 'Bienvenue dans Koha...\r\n<hr>' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = 'bibtex,dc,marcxml,marc8,utf8,marcstd,ris' WHERE variable = 'OpacExportOptions';
