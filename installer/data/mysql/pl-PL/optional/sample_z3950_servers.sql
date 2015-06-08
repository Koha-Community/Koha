INSERT INTO z3950servers
(host, port, db, userid, password, servername, checked, rank, syntax, encoding,recordtype) VALUES
('alpha.bn.org.pl',210,'INNOPAC','','','BIBLIOTEKA NARODOWA',1,1,'MARC21','utf8', 'biblio'),
('lx2.loc.gov',210,'LCDB','','','LIBRARY OF CONGRESS',1,1,'USMARC','utf8','biblio'),
('lx2.loc.gov',210,'NAF','','','LIBRARY OF CONGRESS NAMES',1,1,'USMARC','utf8','authority'),
('lx2.loc.gov',210,'SAF','','','LIBRARY OF CONGRESS SUBJECTS',1,2,'USMARC','utf8','authority'),
('clio-db.cc.columbia.edu',7090,'voyager','','','COLUMBIA UNIVERSITY',0,0,'USMARC','MARC-8','biblio');

#Insert SRU server
INSERT INTO z3950servers
(host, port, db, servername, syntax, encoding, servertype, sru_fields)
VALUES
('lx2.loc.gov',210,'LCDB','LIBRARY OF CONGRESS SRU','USMARC','utf8','sru','title=dc.title,isbn=bath.isbn,srchany=cql.anywhere,author=dc.author,issn=bath.issn,subject=dc.subject,stdid=bath.standardIdentifier');
