alter table biblio add frameworkcode char(4);
update biblio,marc_biblio set biblio.frameworkcode=marc_biblio.frameworkcode where marc_biblio.biblionumber=biblio.biblionumber;
