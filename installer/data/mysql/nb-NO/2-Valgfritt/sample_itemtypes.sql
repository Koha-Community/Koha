-- 
-- Default classification sources and filing rules
-- for Koha.
--
-- Copyright (C) 2011 Magnus Enger Libriotech
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

INSERT INTO itemtypes (itemtype, description, rentalcharge, notforloan, imageurl, summary) VALUES
('BK', 'Bøker',0,0,'bridge/book.png',''),
('MX', 'Blandet innhold',0,0,'bridge/kit.png',''),
('CF', 'Datafiler',0,0,'bridge/computer_file.png',''),
('MP', 'Kart',0,0,'bridge/map.png',''),
('VM', 'Visuelt materiale',0,1,'bridge/dvd.png',''),
('MU', 'Musikk',5,0,'bridge/sound.png',''),
('CR', 'Periodika',0,0,'bridge/periodical.png',''),
('REF', 'Oppslagsverk',0,1,'','');
