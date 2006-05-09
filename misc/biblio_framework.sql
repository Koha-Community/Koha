alter table biblio add frameworkcode char(4);
update biblio,marc_biblio set biblio.frameworkcode=marc_biblio.frameworkcode where marc_biblio.biblionumber=biblio.biblionumber;
alter table biblioitems add marcxml text;
alter table biblioitems add lcsort varchar(25);
alter table items add onloan date;
alter table items add Cutterextra varchar(45);
