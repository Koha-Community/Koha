DROP TABLE IF EXISTS `accountoffsets`;

CREATE TABLE IF NOT EXISTS `account_offset_types` (
  `type` varchar(16) NOT NULL, -- The type of offset this is
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_offsets` (
  `id` int(11) NOT NULL auto_increment, -- unique identifier for each offset
  `credit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline the increased the patron's balance
  `debit_id` int(11) NULL DEFAULT NULL, -- The id of the accountline that decreased the patron's balance
  `type` varchar(16) NOT NULL, -- The type of offset this is
  `amount` decimal(26,6) NOT NULL, -- The amount of the change
  `created_on` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `account_offsets_ibfk_p` FOREIGN KEY (`credit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_offsets_ibfk_f` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_offsets_ibfk_t` FOREIGN KEY (`type`) REFERENCES `account_offset_types` (`type`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT IGNORE INTO account_offset_types ( type ) VALUES
('Writeoff'),
('Payment'),
('Lost Item'),
('Manual Debit'),
('Reverse Payment'),
('Forgiven'),
('Dropbox'),
('Rental Fee'),
('Fine Update'),
('Fine');
