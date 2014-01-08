INSERT INTO z3950servers
(host, port, db, userid, password, name, checked, rank, syntax, encoding,recordtype) VALUES 
('lx2.loc.gov',210,'LCDB','','','LIBRARY OF CONGRESS',1,1,'USMARC','utf8','biblio'),
('lx2.loc.gov',210,'NAF','','','LIBRARY OF CONGRESS NAMES',1,1,'USMARC','utf8','authority'),
('lx2.loc.gov',210,'SAF','','','LIBRARY OF CONGRESS SUBJECTS',1,2,'USMARC','utf8','authority'),
('clio-db.cc.columbia.edu',7090,'voyager','','','COLUMBIA UNIVERSITY',0,0,'USMARC','MARC-8','biblio'),
('siris-libraries.si.edu',210,'Default','','','SMITHSONIAN INSTITUTION LIBRARIES',0,0,'USMARC','MARC-8','biblio'); 
