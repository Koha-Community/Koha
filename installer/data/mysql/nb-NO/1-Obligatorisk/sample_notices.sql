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

INSERT INTO `letter` (module, code, name, title, content) 
VALUES ('circulation','ODUE','Purring','Purring på dokument','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har lån som skulle vært levert. Biblioteket krever ikke inn gebyrer, men vennligst lever eller forny lånet/lånene ved biblioteket.\n\n<<branches.branchname>>\n<<branches.branchaddress1>>\n<<branches.branchaddress2>> <<branches.branchaddress3>>\nTelefon: <<branches.branchphone>>\nFax: <<branches.branchfax>>\nE-post: <<branches.branchemail>>\n\nDersom du har et passord og lånet/lånene kan fornyes kan du gjøre dette på nettet. Dersom du overskrider lånetiden med mer enn 30 dager vil lånekortet bli sperret.\n\nFølgende lån har gått over tiden:\n\n<item>"<<biblio.title>>" av <<biblio.author>>, <<items.itemcallnumber>>, Strekkode: <<items.barcode>> Gebyr: <<items.fine>></item>\n\nPå forhånd takk.\n\n<<branches.branchname>>\n'),
('claimacquisition','ACQCLAIM','Periodikapurring','Eksemplar ikke mottatt','<<aqbooksellers.name>>\r\n<<aqbooksellers.address1>>\r\n<<aqbooksellers.address2>>\r\n<<aqbooksellers.address3>>\r\n<<aqbooksellers.address4>>\r\n<<aqbooksellers.phone>>\r\n\r\n<order>Bestillingsnummer <<aqorders.ordernumber>> (<<aqorders.title>>) (<<aqorders.quantity>> ordered) ($<<aqorders.listprice>> each) har ikke blitt mottatt.</order>'),
('serial','RLIST','Sirkulasjon','Et dokument er nå tilgjengelig','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet er tilgjengelig:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)\r\n\r\nVennligst kom og hent det når det passer.'),
('members','ACCTDETAILS','Mal for kontodetaljer - STANDARD','Dine nye kontodetaljer i Koha.','Hei <<borrowers.title>> <<borrowers.firstname>> <<borrowers.surname>>.\r\n\r\nDine nye detaljer er:\r\n\r\nBruker:  <<borrowers.userid>>\r\nPassord: <<borrowers.password>>\r\n\r\nDersom det oppstår problemer, vennligst kontakt biblioteket.\r\n\r\nVennlig hilsen,\r\nBiblioteket\r\nkohaadmin@yoursite.org'), 
('circulation','DUE','Innleveringspåminnelse','Innleveringspåminnelse','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet må nå leveres:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'), 
('circulation','DUEDGST','Innleveringspåminnelse (sammendrag)','Innleveringspåminnelse','Du har <<count>> dokumenter som skulle vært levert.'), 
('circulation','PREDUE','Forhåndspåminnelse','Forhåndspåminnelse','<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nDette dokumentet må snart leveres:\r\n\r\n<<biblio.title>>, <<biblio.author>> (<<items.barcode>>)'), 
('circulation','PREDUEDGST','Forhåndspåminnelse (sammendrag)','Forhåndspåminnelse','Du har lånt <<count>> dokumenter som snart må leveres.'),
('reserves', 'HOLD', 'Hentemelding', 'Hentemelding fra <<branches.branchname>>', '<<borrowers.firstname>> <<borrowers.surname>>,\r\n\r\nEt reservert dokument er klart til henting fra <<reserves.waitingdate>>:\r\n\r\nTittel: <<biblio.title>>\r\nForfatter: <<biblio.author>>\r\nEksemplar: <<items.copynumber>>\r\nHentested: <<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n<<branches.branchaddress3>>\r\n<<branches.branchcity>> <<branches.branchzip>>'),
('reserves', 'HOLD_PRINT', 'Hentemelding (på papir)', 'Hentemelding', '<<branches.branchname>>\r\n<<branches.branchaddress1>>\r\n<<branches.branchaddress2>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>>\r\n<<borrowers.address>>\r\n<<borrowers.city>> <<borrowers.zipcode>>\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> <<borrowers.cardnumber>>\r\n\r\nDu har et reservert dokument som kan hentes fra  <<reserves.waitingdate>>:\r\n\r\nTittel: <<biblio.title>>\r\nForfatter: <<biblio.author>>\r\nEksemplar: <<items.copynumber>>\r\n'),
('circulation','CHECKIN','Innlevering','Melding om innlevering','Følgende dokument har blitt innlevert:\r\n----\r\n<<biblio.title>>\r\n----\r\nVennlig hilsen\r\nBiblioteket'),
('circulation','CHECKOUT','Utlån','Melding om utlån','Følgende dokument har blitt lånt ut:\r\n----\r\n<<biblio.title>>\r\n----\r\nVennlig hilsen\r\nBiblioteket'),
('reserves', 'HOLDPLACED', 'Melding om reservasjon', 'Melding om reservasjon','Følgende dokument har blitt reservert : <<biblio.title>> (<<biblio.biblionumber>>) av <<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>).'),
('suggestions','ACCEPTED','Forslag godtatt', 'Innkjøpsforslag godtatt','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nBiblioteket har vurdert forslaget i dag. Dokumentet vil bli bestilt så fort det lar seg gjøre. Du vil få en ny melding når bestillingen er gjort, og når dokumentet ankommer biblioteket.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>'),
('suggestions','AVAILABLE','Foreslått dokument tilgjengelig', 'Foreslått dokument tilgjengelig','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nVi har gleden av å informere deg om at dokumentet nå er innlemmet i samlingen.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>'),
('suggestions','ORDERED','Innkjøpsforslag i bestilling', 'Innkjøpsforslag i bestilling','Dear <<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nVi har gleden av å informere deg om at dokumentet du foreslo nå er i bestilling.\n\nDu vil få en ny melding når dokumentet er tilgjengelig.\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>'),
('suggestions','REJECTED','Innkjøpsforslag avslått', 'Innkjøpsforslag avslått','<<borrowers.firstname>> <<borrowers.surname>>,\n\nDu har foreslått at biblioteket kjøper inn <<suggestions.title>> av <<suggestions.author>>.\n\nBiblioteket har vurdert innkjøpsforslaget ditt i dag, og bestemt seg for å ikke ta det til følge.\n\nBegrunnelse: <<suggestions.reason>>\n\nEr det noe du lurer på, vennligst kontakt oss på <<branches.branchemail>>.\n\nVennlig hilsen,\n\n<<branches.branchname>>');
INSERT INTO `letter` (module, code, name, title, content) VALUES ('circulation','RENEWAL','Item Renewal','Renewals','The following items have been renew:\r\n----\r\n<<biblio.title>>\r\n----\r\nThank you for visiting <<branches.branchname>>.');
