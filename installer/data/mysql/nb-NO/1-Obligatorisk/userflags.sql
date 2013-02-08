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

INSERT INTO `userflags` VALUES(0,'superlibrarian','Tilgang til alle bibliotekarfunksjoner',0);
INSERT INTO `userflags` VALUES(1,'circulate','Sirkulasjon',0);
INSERT INTO `userflags` VALUES(2,'catalogue','Søke i katalogen (internt)',0);
INSERT INTO `userflags` VALUES(3,'parameters','Endre Kohas systempreferanser',0);
INSERT INTO `userflags` VALUES(4,'borrowers','Legge til og endre lånere',0);
INSERT INTO `userflags` VALUES(5,'permissions','Endre brukerrettigheter',0);
INSERT INTO `userflags` VALUES(6,'reserveforothers','Reservere og endre reservasjoner for lånere',0);
INSERT INTO `userflags` VALUES(7,'borrow','Låne dokumenter',1);
INSERT INTO `userflags` VALUES(9,'editcatalogue','Endre katalogen (Endre bibliografiske poster og eksemplaropplysninger)',0);
INSERT INTO `userflags` VALUES(10,'updatecharges','Endre gebyrer for lånere',0);
INSERT INTO `userflags` VALUES(11,'acquisition','Innkjøp og/eller behandling av forslag',0);
INSERT INTO `userflags` VALUES(12,'management','Endre "library managament parameters"',0);
INSERT INTO `userflags` VALUES(13,'tools','Bruke verktøy (eksport, import, strekkoder)',0);
INSERT INTO `userflags` VALUES(14,'editauthorities','Tilgang til å endre autoriteter',0);
INSERT INTO `userflags` VALUES(15,'serials','Tilgang til å endre abonnementer',0);
INSERT INTO `userflags` VALUES(16,'reports','Tilgang til rapportmodulen',0);
INSERT INTO `userflags` VALUES(17,'staffaccess','Endre innlogging og rettigheter for bibliotekansatte',0);
INSERT INTO `userflags` VALUES(19, 'plugins', 'Koha plugins', '0');
