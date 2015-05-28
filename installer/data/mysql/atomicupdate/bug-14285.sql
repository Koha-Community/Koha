INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added)
VALUES ( 'IN', 'region', 'India','2015-05-28');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IN', 'region', 'en', 'India');

INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
VALUES ( 'IN', 'region', 'bn', 'ভারত');

-- $DBversion = "3.21.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q|
--         INSERT IGNORE INTO language_subtag_registry( subtag, type, description, added)
--         VALUES ( 'IN', 'region', 'India','2015-05-28');
--     |);
--
--     $dbh->do(q|
--         INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
--         VALUES ( 'IN', 'region', 'en', 'India');
--     |);
--
--     $dbh->do(q|
--         INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
--         VALUES ( 'IN', 'region', 'bn', 'ভারত');
--     |);
--
--     print "Upgrade to $DBversion done (Bug 14285: Add new region India)\n";
--     SetVersion ($DBversion);
-- }
