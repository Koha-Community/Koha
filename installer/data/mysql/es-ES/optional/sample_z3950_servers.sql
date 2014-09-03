INSERT INTO `z3950servers`
(`host`, `port`, `db`, `userid`, `password`, `servername`, `id`, `checked`, `rank`, `syntax`, `encoding`) VALUES
('lx2.loc.gov',210,'LCDB','','','LIBRARY OF CONGRESS',1,1,1,'USMARC','utf8'),
('clio-db.cc.columbia.edu',7090,'voyager','','','COLUMBIA UNIVERSITY',6,0,0,'USMARC','MARC-8'),
('siris-libraries.si.edu',210,'Default','','','SMITHSONIAN INSTITUTION LIBRARIES',10,0,0,'USMARC','MARC-8'); 

#Insert SRU server
INSERT INTO z3950servers
(host, port, db, servername, syntax, encoding, servertype, sru_fields)
VALUES
('lx2.loc.gov',210,'LCDB','LIBRARY OF CONGRESS SRU','USMARC','utf8','sru','title=dc.title,isbn=bath.isbn,srchany=cql.anywhere,author=dc.author,issn=bath.issn,subject=dc.subject,stdid=bath.standardIdentifier');
