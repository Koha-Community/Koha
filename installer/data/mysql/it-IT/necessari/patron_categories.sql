INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 

-- Adult Patrons
('PT','Utente',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Studente',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Gruppa familiare',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Bambino',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Ragazzo',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Adolescente',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Insegnante',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Associati',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Prestito Interbibliotecario',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','Scuola',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Biblioteca',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Staff',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
