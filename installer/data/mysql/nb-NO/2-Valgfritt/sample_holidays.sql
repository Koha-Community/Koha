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

INSERT INTO `repeatable_holidays` VALUES 
(2,'',0,NULL,NULL,'','Søndager'),
(3,'',NULL,1,1,'','1. nyttårsdag'),
(4,'',NULL,1,5,'','1. mai'),
(5,'',NULL,17,5,'','17. mai'),
(6,'',NULL,25,12,'','1. juledag'),
(7,'',NULL,26,12,'','2. juledag');
