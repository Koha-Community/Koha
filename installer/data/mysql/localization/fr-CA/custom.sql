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

UPDATE systempreferences SET value = 'fre|eng' WHERE variable = 'AdvancedSearchLanguages';
UPDATE systempreferences SET value = 'CA' WHERE variable = 'AmazonLocale';
UPDATE systempreferences SET value = 'père|mère|grand-parent|tuteur légal|autre' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'M.|Mme|Mx' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurencyFormat';
UPDATE systempreferences SET value = 'iso' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'fr' WHERE variable = 'KohaManualLanguage';
UPDATE systempreferences SET value = 'fr-CA,en' WHERE variable = 'StaffInterfaceLanguages';
UPDATE systempreferences SET value = 'http://www.marc21.ca/MaJ/BIB/B{FIELD}.pdf' WHERE variable = 'MarcFieldDocURL';
UPDATE systempreferences SET value = 'pdfformat::layout3pagesfr' WHERE variable = 'OrderPdfFormat';
UPDATE systempreferences SET value = 'fr-CA,en' WHERE variable = 'OPACLanguages';
UPDATE systempreferences SET value = '0|0.05|0.09975|0.14975' WHERE variable = 'TaxRates';
