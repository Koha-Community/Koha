ALTER TABLE borrower_modifications ADD COLUMN extended_attributes text DEFAULT NULL AFTER privacy;

-- $DBversion = "16.12.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--
--     $dbh->do( "ALTER TABLE borrower_modifications
--                      ADD COLUMN extended_attributes text DEFAULT NULL
--                      AFTER privacy" );
--     print "Upgrade to $DBversion done (Bug 8835). Everything is fine.\n";
--
--     SetVersion($DBversion);
-- }
