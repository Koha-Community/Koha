INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES

-- Adult Patrons
('PT','Asiakas',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Opiskelija',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Kotona pysyvä',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Lapsi',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Nuori',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Nuori aikuinen',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Opettaja',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Hallituksen jäsen',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Kaukopalvelu',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','Koulu',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Kirjasto',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Virkailija',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
