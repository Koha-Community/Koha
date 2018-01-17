ALTER TABLE `issuingrules` DROP PRIMARY KEY; 
ALTER TABLE `issuingrules` ADD `issuingrules_id` INT( 11 ) NOT NULL auto_increment PRIMARY KEY FIRST; 
ALTER TABLE `issuingrules` ADD CONSTRAINT UNIQUE `issuingrules_selects` (`branchcode`,`categorycode`,`itemtype`); 