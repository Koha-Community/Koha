ALTER TABLE creator_layouts ADD COLUMN oblique_title INT(1) NULL DEFAULT 1 AFTER guidebox;

-- $DBversion = "3.21.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q|
--         ALTER TABLE creator_layouts ADD COLUMN oblique_title INT(1) NULL DEFAULT 1 AFTER guidebox
--     |);
--     print "Upgrade to $DBversion done (Bug 12194: Add column oblique_title to layouts)\n";
--     SetVersion($DBversion);
-- }
