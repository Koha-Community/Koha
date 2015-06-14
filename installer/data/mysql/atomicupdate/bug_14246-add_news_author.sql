ALTER TABLE `opac_news` ADD `borrowernumber` int(11) default NULL AFTER `number`;
ALTER TABLE `opac_news` ADD CONSTRAINT `borrowernumber_fk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers`(`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE;
