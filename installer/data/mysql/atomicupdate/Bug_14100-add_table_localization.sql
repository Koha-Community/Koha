CREATE TABLE `localization` (
      localization_id int(11) NOT NULL AUTO_INCREMENT,
      entity varchar(16) COLLATE utf8_unicode_ci NOT NULL,
      code varchar(64) COLLATE utf8_unicode_ci NOT NULL,
      lang varchar(25) COLLATE utf8_unicode_ci NOT NULL,
      translation text COLLATE utf8_unicode_ci,
      PRIMARY KEY (localization_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
