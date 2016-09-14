UPDATE systempreferences SET type="Choice" where variable="UsageStatsLibraryType";

UPDATE systempreferences SET value="Canada"          WHERE variable="UsageStatsCountry" AND value="CANADA";
UPDATE systempreferences SET value="Czech Republic"  WHERE variable="UsageStatsCountry" AND value="CZ";
UPDATE systempreferences SET value="United Kingdom"  WHERE variable="UsageStatsCountry" AND (value="England" OR value="UK");
UPDATE systempreferences SET value="Spain"           WHERE variable="UsageStatsCountry" AND value="España";
UPDATE systempreferences SET value="Greece"          WHERE variable="UsageStatsCountry" AND value="GR";
UPDATE systempreferences SET value="Ireland"         WHERE variable="UsageStatsCountry" AND value="Irelanbd";
UPDATE systempreferences SET value="Mexico"          WHERE variable="UsageStatsCountry" AND value="México";
UPDATE systempreferences SET value="Peru"            WHERE variable="UsageStatsCountry" AND value="Perú";
UPDATE systempreferences SET value="Dominican Rep."  WHERE variable="UsageStatsCountry" AND value="República Dominicana";
UPDATE systempreferences SET value="Trinidad & Tob." WHERE variable="UsageStatsCountry" AND value="Trinidad";
UPDATE systempreferences SET value="Turkey"          WHERE variable="UsageStatsCountry" AND value="Türkiye";
UPDATE systempreferences SET value="USA"             WHERE variable="UsageStatsCountry" AND (value="United States" OR value="United States of America" OR value="US");
UPDATE systempreferences SET value="Zimbabwe"        WHERE variable="UsageStatsCountry" AND value="Zimbabbwe";
