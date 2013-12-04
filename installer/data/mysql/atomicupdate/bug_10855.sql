CREATE TABLE `additional_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tablename` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `authorised_value_category` varchar(16) NOT NULL DEFAULT '',
  `marcfield` varchar(16) NOT NULL DEFAULT '',
  `searchable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `fields_uniq` (`tablename`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `additional_field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `field_id` int(11) NOT NULL,
  `record_id` int(11) NOT NULL,
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `field_record` (`field_id`,`record_id`),
  CONSTRAINT `afv_fk` FOREIGN KEY (`field_id`) REFERENCES `additional_fields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
