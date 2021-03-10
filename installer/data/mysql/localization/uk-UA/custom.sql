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

UPDATE `currency` SET `active` = 0;
INSERT INTO `currency` (currency, symbol, rate, active, archived) VALUES
('UAH', 'грн.', 1.0,       1, 0),
('RUB', 'руб.', 0.40532,   0, 0),
('PLN', 'zł',   6.43006,   0, 0);

