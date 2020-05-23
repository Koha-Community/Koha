INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 

-- Adult Patrons
('PT','Erwachsene/r',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Studierende/r',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Ans Haus gebunden',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Kind',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Jugendliche/r',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Junger Erwachsener',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Lehrkraft',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Gremienmitglied',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Fernleihbibliothek',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','Schule',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Bibliothek',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Bibliothekspersonal',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
