INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
VALUES ('OAI-PMH:DeletedRecord','persistent','Koha\'s deletedbiblio table will never be deleted (persistent) or might be deleted (transient)','transient|persistent','Choice');
ALTER TABLE oai_sets_biblios DROP FOREIGN KEY oai_sets_biblios_ibfk_1;
