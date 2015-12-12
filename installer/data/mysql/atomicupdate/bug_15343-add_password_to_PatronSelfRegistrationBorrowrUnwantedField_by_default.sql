UPDATE systempreferences SET value = CONCAT_WS('|', IF(value='', NULL, value), "password") WHERE variable="PatronSelfRegistrationBorrowerUnwantedField" AND value NOT LIKE "%password%";
