-- 
-- Default MARC matching rules for Koha
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
-- You should have received a copy of the GNU General Public License along with
-- Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
-- Suite 330, Boston, MA  02111-1307 USA

INSERT INTO marc_matchers (code, description, record_type, threshold) 
    VALUES ('ISBN', '020$a', 'biblio', 1000);
INSERT INTO matchpoints (matcher_id, search_index, score) SELECT MAX(matcher_id), 'isbn', 1000 FROM marc_matchers;
INSERT INTO matcher_matchpoints SELECT MAX(matcher_id), MAX(matchpoint_id) FROM matchpoints;
INSERT INTO matchpoint_components (matchpoint_id, sequence, tag, subfields) 
    SELECT MAX(matchpoint_id), 1, '020', 'a' FROM matchpoints;
INSERT INTO matchpoint_component_norms (matchpoint_component_id, sequence, norm_routine) 
    SELECT MAX(matchpoint_component_id), 1, 'ISBN' FROM matchpoint_components;

INSERT INTO marc_matchers (code, description, record_type, threshold) 
    VALUES ('ISSN', '022$a', 'biblio', 1000);
INSERT INTO matchpoints (matcher_id, search_index, score) SELECT MAX(matcher_id), 'isbn', 1000 FROM marc_matchers;
INSERT INTO matcher_matchpoints SELECT MAX(matcher_id), MAX(matchpoint_id) FROM matchpoints;
INSERT INTO matchpoint_components (matchpoint_id, sequence, tag, subfields) 
    SELECT MAX(matchpoint_id), 1, '022', 'a' FROM matchpoints;
INSERT INTO matchpoint_component_norms (matchpoint_component_id, sequence, norm_routine) 
    SELECT MAX(matchpoint_component_id), 1, 'ISSN' FROM matchpoint_components;

