INSERT INTO z3950servers
(host, port, db, userid, password, servername, checked, `rank`, syntax, encoding,recordtype,attributes) VALUES
('lx2.loc.gov',210,'LCDB','','','Bibliothèque du congrès',1,1,'USMARC','utf8','biblio',''),
('lx2.loc.gov',210,'NAF','','','Bibliothèque du congrès NOMS',1,1,'USMARC','utf8','authority',''),
('lx2.loc.gov',210,'SAF','','','Bibliothèque du congrès SUJETS',1,2,'USMARC','utf8','authority',''),
('catalogue.banq.qc.ca',210,'IRIS','','','BANQ',0,1,'USMARC','MARC-8','biblio','@attr 4=1'),
('siris-libraries.si.edu',210,'Default','','','Bibliothèques de l''institution Smithsonian',0,0,'USMARC','MARC-8','biblio','');
