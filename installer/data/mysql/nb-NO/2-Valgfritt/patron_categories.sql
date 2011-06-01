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

INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 

-- Adult Patrons
('PT','Låner',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Student',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Hjemmelåner',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Barn',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Ungdom',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Ung voksen',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Lærer',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Styremedlem',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Fjernlån',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','Skole',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Bibliotek',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Bibliotekansatt',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
