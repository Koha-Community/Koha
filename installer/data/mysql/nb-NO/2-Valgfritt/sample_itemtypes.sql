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

INSERT INTO itemtypes (itemtype, description, rentalcharge, notforloan, imageurl, summary) VALUES
('BK', 'Bøker',0,0,'bridge/book.gif',''),
('MX', 'Blandet innhold',0,0,'bridge/kit.gif',''),
('CF', 'Datafiler',0,0,'bridge/computer_file.gif',''),
('MP', 'Kart',0,0,'bridge/map.gif',''),
('VM', 'Visuelt materiale',0,1,'bridge/dvd.gif',''),
('MU', 'Musikk',5,0,'bridge/sound.gif',''),
('CR', 'Periodika',0,0,'bridge/periodical.gif',''),
('REF', 'Oppslagsverk',0,1,'','');
