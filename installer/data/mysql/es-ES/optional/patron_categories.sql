INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES 

-- Adult Patrons
('PT','Usuario',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('ST','Estudiante',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),
('HB','Domicilio',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','A'),

-- Children
('K','Niño',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('J','Juvenil',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),
('YA','Adulto joven',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','C'),

-- Professionals
('T','Maestro',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','P'),
('B','Board',99,17,5,NULL,NULL,'0.000000',1,NULL,'0.000000','P'),

-- Institutional
('IL','Préstamo interbibliotecario',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('SC','Escuela',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),
('L','Biblioteca',99,999,18,NULL,NULL,'0.000000',1,NULL,'0.000000','I'),

-- Staff
('S','Empleados',99,999,18,NULL,NULL,'0.000000',0,NULL,'0.000000','S');
