ALTER TABLE `itemtypes` MODIFY COLUMN `rentalcharge` DECIMAL(28,6) NULL DEFAULT NULL;
ALTER TABLE `itemtypes` ADD `defaultreplacecost` DECIMAL(28,6) NULL DEFAULT NULL AFTER `rentalcharge`;
ALTER TABLE `itemtypes` ADD `processfee` DECIMAL(28,6) NULL DEFAULT NULL AFTER `defaultreplacecost`;
