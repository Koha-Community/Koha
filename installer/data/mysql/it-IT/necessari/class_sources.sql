-- 
-- Default classification sources and filing rules
-- for Koha.
--
-- Copyright (C) 2007 LiblimeA
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
SET FOREIGN_KEY_CHECKS=0;

-- class sorting (filing) rules
INSERT INTO `class_sort_rules` (`class_sort_rule`, `description`, `sort_routine`) VALUES
                               ('dewey', 'Regole di default per CDD', 'Dewey'),
                               ('lcc', 'Regole di default per LCC', 'LCC'),
                               ('generic', 'Regole generiche per la collocazione con classificazione', 'Generic');


-- classification schemes or sources
INSERT INTO `class_sources` (`cn_source`, `description`, `used`, `class_sort_rule`) VALUES
                            ('ddc', 'Classificazione  decimale Dewey', 1, 'dewey'),
                            ('lcc', 'Classificazione della Library of Congress', 1, 'lcc'),
                            ('udc', 'Classificazione Decimale Universale', 0, 'generic'),
                            ('z', 'Altro sistema di classificazione', 0, 'generic');

SET FOREIGN_KEY_CHECKS=1;