INSERT INTO z3950servers (host, port, db, userid, password, servername, id, checked, rank, syntax, timeout, servertype, encoding) VALUES
('lx2.loc.gov',210,'LCDB','','','LIBRARY OF CONGRESS',1,0,0,'USMARC',0,'zed','utf8'),
('z3950.bibsys.no',2100,'BIBSYS','','','BIBSYS',12,1,1,'NORMARC',0,'zed','ISO_8859-1'),
('z3950.nb.no',2100,'Norbok','','','NORBOK',13,0,0,'NORMARC',0,'zed','ISO_8859-1'),
('z3950.nb.no',2100,'Sambok','','','SAMBOK',14,0,0,'NORMARC',0,'zed','ISO_8859-1'),
('z3950.deich.folkebibl.no',210,'data','','','DEICHMAN',15,0,0,'NORMARC',0,'zed','ISO_8859-1');

#Insert SRU server
INSERT INTO z3950servers
(host, port, db, servername, syntax, encoding, servertype, sru_fields)
VALUES
('lx2.loc.gov',210,'LCDB','LIBRARY OF CONGRESS SRU','USMARC','utf8','sru','title=dc.title,isbn=bath.isbn,srchany=cql.anywhere,author=dc.author,issn=bath.issn,subject=dc.subject,stdid=bath.standardIdentifier');
