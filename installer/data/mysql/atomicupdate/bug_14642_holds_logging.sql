INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES
('HoldsLog','1',NULL,'If ON, log create/cancel/suspend/resume actions on holds.','YesNo');

-- $DBversion = "16.06.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES
--         ('HoldsLog','1',NULL,'If ON, log create/cancel/suspend/resume actions on holds.','YesNo');
--     });

--     print "Upgrade to $DBversion done (Bug 14642: Add logging of hold modifications)\n";
--     SetVersion($DBversion);
-- }
