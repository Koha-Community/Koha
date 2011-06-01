-- 
-- Default classification sources and filing rules
-- for Koha.
--
-- Copyright (C) 2011 Magnus Enger Libriotech
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

-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey', 'Standard sortering for DDK', 'Dewey'),
                               ('lcc', 'Standard sortering for LCC', 'LCC'),
                               ('generic', 'Generelle sorteringsregler', 'Generic');


-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                            ('ddc', 'Dewey desimalklassifikasjon', 1, 'dewey'),
                            ('lcc', 'Library of Congress klassifikasjon', 1, 'lcc'),
                            ('udc', 'Universell desimalklassifikasjon', 0, 'generic'),
                            ('sudocs', 'SuDoc klassifikasjon (U.S. GPO)', 0, 'generic'),
                            ('anscr', 'ANSCR (Lydopptak)', 0, 'generic'),
                            ('z', 'Andre klassifikasjonsskjema', 0, 'generic');
