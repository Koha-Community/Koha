ALTER TABLE `opac_news` ADD `borrowernumber` INT(11) default NULL;
ALTER TABLE `opac_news` ADD CONSTRAINT `borrowernumber_fk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers`(`borrowernumber`) ON DELETE SET NULL ON UPDATE SET NULL;
