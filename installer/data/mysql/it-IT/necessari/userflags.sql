SET FOREIGN_KEY_CHECKS=0;

INSERT INTO `userflags` VALUES(0,'superlibrarian','Accesso a tutte le funzioni bibliotecarie',0);
INSERT INTO `userflags` VALUES(1,'circulate','Libri per la circolazione',0);
INSERT INTO `userflags` VALUES(2,'catalogue','Visualizza il catalogo (interfaccia del bibliotecario)',0);
INSERT INTO `userflags` VALUES(3,'parameters','Imposta i parametri di Koha',0);
INSERT INTO `userflags` VALUES(4,'borrowers','Aggiungi o modifica gli utenti',0);
INSERT INTO `userflags` VALUES(5,'permissions','Imposta i permessi utente',0);
INSERT INTO `userflags` VALUES(6,'reserveforothers','Prenota i libri per gli utenti',0);
INSERT INTO `userflags` VALUES(7,'borrow','Presta i libri',1);
INSERT INTO `userflags` VALUES(9,'editcatalogue','Modifica il catalogo (modifica i dati bibliografici e titoli)',0);
INSERT INTO `userflags` VALUES(10,'updatecharges','Aggiorna le tariffe del prestito',0);
INSERT INTO `userflags` VALUES(11,'acquisition','Gestione delle acquisizioni e dei suggerimenti d\'acquisto',0);
INSERT INTO `userflags` VALUES(12,'management','Imposta i parametri della gestione della biblioteca',0);
INSERT INTO `userflags` VALUES(13,'tools','Usa i tools (export, import, barcodes )',0);
INSERT INTO `userflags` VALUES(14,'editauthorities','autorizza la modifica delle authorities',0);
INSERT INTO `userflags` VALUES(15,'serials','autorizza la gestione degli abbonamenti ai periodici',0);
INSERT INTO `userflags` VALUES(16,'reports','autorizza accesso al modulo dei reports',0);
INSERT INTO `userflags` VALUES(17,'staffaccess','modifica la login o i permessi degli staff users',0);
INSERT INTO `userflags` VALUES(18,'coursereserves','Course Reserves',0);
INSERT INTO `userflags` VALUES(19, 'plugins', 'Koha plugins', '0');

SET FOREIGN_KEY_CHECKS=1;
