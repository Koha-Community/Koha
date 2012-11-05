INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES ('StoreLastBorrower','0','','If ON, the last borrower to return an item will be stored in items.last_returned_by','YesNo');

CREATE TABLE IF NOT EXISTS `items_last_borrower` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemnumber` int(11) NOT NULL,
  `borrowernumber` int(11) NOT NULL,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `itemnumber` (`itemnumber`),
  KEY `borrowernumber` (`borrowernumber`),
  CONSTRAINT `items_last_borrower_ibfk_2` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `items_last_borrower_ibfk_1` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
