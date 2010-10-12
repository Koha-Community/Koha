-- phpMyAdmin SQL Dump
-- version 2.9.1.1-Debian-13
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generato il: 04 Feb, 2010 at 10:58 AM
-- Versione MySQL: 5.0.32
-- Versione PHP: 5.2.0-8+etch16
-- 
-- Database: 'koha'
-- 

-- 
-- Dump dei dati per la tabella 'opac_news'
-- 
SET FOREIGN_KEY_CHECKS=0;

INSERT INTO opac_news (idnew, title, new, lang, timestamp, expirationdate, number) VALUES 
(1, 'Benvenuto in Koha', '<p>Koha è un gestionale di biblioteca (ILS) completo e Open Source. Sviluppato inzialmente in New Zealand da Katipo Communications Ltd e messo in linea per la prima volta nel gennaio 2000 per il Horowhenua Library Trust, Koha è ora mantenuto da un gruppo di aziende di servizi e dipendenti di biblioteca distribuiti in tutto il mondo.</p>', 'koha', '2007-10-29 00:00:00', '2099-01-10', 1),
(2, 'Cosa c''è di nuovo ?', '<p>Ora che hai installato cosa, qual''è il passo successivo ? Qui alcuni suggerimenti:</p>\r\n<ul>\r\n<li><a href="http://koha.org/documentation/">Leggi la documentazione di Koha</a></li>\r\n<li><a href="http://wiki.koha.org">Leggi/aggiorna il Wiki di Koha Wiki</a></li>\r\n<li><a href="http://koha.org/community/mailing-lists.html">Leggi e contribusci alle liste di discussione</a></li>\r\n<li><a href="http://bugs.koha.org">Descrivi e segnala i bug di Koha</a></li>\r\n<li>Chatta con gli utenti e gli sviluppatori di Koha sul server irc.katipo.co.nz,  porta 6667 canale #koha</li>\r\n<li><a href="http://stats.workbuffer.org/irclog/koha/today">Leggi il log della chat di Koha di oggi</a></li>\r\n</ul>\r\n', 'koha', '2007-10-29 00:00:00', '2099-01-10', 2);

SET FOREIGN_KEY_CHECKS=1;