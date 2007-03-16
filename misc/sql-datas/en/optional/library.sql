INSERT INTO `branches` (branchcode, branchname) VALUES ('MAIN','Main Library');
INSERT INTO `currency` (currency, rate) VALUES ('USD', 1.0);
INSERT INTO `z3950servers` (`host`, `port`, `db`, `userid`, `password`, `name`, `id`, `checked`, `rank`, `syntax`) VALUES ('z3950.loc.gov',7090,'Voyager','','','LIBRARY OF CONGRESS',1,0,2,'USMARC'),('amicus.collectionscanada.ca',210,'NL','','','AMICUS',2,0,3,'USMARC'),('66.213.78.76',9999,'NPLKoha','','','NELSONVILLE PUBLIC LIBRARY',3,0,4,'USMARC');
INSERT INTO `categories` (`categorycode`, `description`, `enrolmentperiod`, `upperagelimit`, `dateofbirthrequired`, `finetype`, `bulk`, `enrolmentfee`, `overduenoticerequired`, `issuelimit`, `reservefee`, `category_type`) VALUES ('PATRON','patron',20,100,10,NULL,NULL,'0.000000',0,NULL,'0.000000','A');
