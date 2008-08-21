SET NAMES utf8;
INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 
('ADULT','Adulte',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ETUD','Etudiant',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

('ENF','Enfant',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('ADO','Adolescent',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

('PROF','Professeur',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('PERS','Personnel bibliothèque',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),

('PEB','Prêt Entre Bibliothèque',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('PMI','PMI',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('BDP','Bibliothèque Départementale',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I');

