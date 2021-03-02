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

UPDATE systempreferences SET value = 'padre|madre' WHERE variable = 'borrowerRelationship';
UPDATE systempreferences SET value = 'Sr.|Sra.' WHERE variable = 'BorrowersTitles';
UPDATE systempreferences SET value = 'FR' WHERE variable = 'CurencyFormat';
UPDATE systempreferences SET value = 'us' WHERE variable = 'AddressFormat';
UPDATE systempreferences SET value = 'metric' WHERE variable = 'dateformat';
UPDATE systempreferences SET value = 'ddc' WHERE variable = 'DefaultClassificationSource';
UPDATE systempreferences SET value = 'Bienvenido al catálogo!' WHERE variable = 'OpacMainUserBlock';
UPDATE systempreferences SET value = '' WHERE variable = 'OpacNav';
UPDATE systempreferences SET value = '' WHERE variable = 'OpacNavBottom';
UPDATE systempreferences SET value = '1' WHERE variable = 'CalendarFirstDayOfWeek';
UPDATE systempreferences SET value = '1' WHERE variable = 'opaclanguagesdisplay';
