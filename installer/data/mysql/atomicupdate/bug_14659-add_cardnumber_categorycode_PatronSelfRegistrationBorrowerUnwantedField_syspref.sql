UPDATE systempreferences SET value = CONCAT_WS('|', IF(value = '', NULL, value), 'cardnumber') WHERE variable = 'PatronSelfRegistrationBorrowerUnwantedField' AND value NOT LIKE '%cardnumber%';
UPDATE systempreferences SET value = CONCAT_WS('|', IF(value = '', NULL, value), 'categorycode') WHERE variable = 'PatronSelfRegistrationBorrowerUnwantedField' AND value NOT LIKE '%categorycode%';
