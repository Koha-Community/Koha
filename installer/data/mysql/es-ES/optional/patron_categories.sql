INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 

-- Adult Patrons
('PT','Patron',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Student',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Home Bound',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Kid',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Juvenile',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Young Adult',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Teacher',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Board',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Inter-Library Loan',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','School',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Library',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Staff',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
