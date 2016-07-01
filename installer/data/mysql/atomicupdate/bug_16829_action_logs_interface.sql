ALTER TABLE `action_logs` ADD COLUMN `interface` VARCHAR(30) DEFAULT NULL AFTER `info`;
ALTER TABLE `action_logs` ADD KEY `interface` (`interface`);

-- $DBversion = "16.06.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         ALTER TABLE `action_logs` ADD COLUMN `interface` VARCHAR(30) DEFAULT NULL AFTER `info`;
--     });
--     $dbh->do({
--         ALTER TABLE `action_logs` ADD KEY `interface` (`interface`);
--     });
--     print "Upgrade to $DBversion done (Bug 16829: action_logs should have an 'interface' column)\n";
--     SetVersion($DBversion);
-- }
