ALTER TABLE letter MODIFY COLUMN branchcode varchar(10) NOT NULL DEFAULT '';
ALTER TABLE permissions MODIFY COLUMN code varchar(64) NOT NULL DEFAULT '';

-- $DBversion = "3.23.00.XXX";
-- if(CheckVersion($DBversion)) {
--     $dbh->do(q{
--         ALTER TABLE letter MODIFY COLUMN branchcode varchar(10) NOT NULL DEFAULT ''
--     });
--     $dbh->do(q{
--         ALTER TABLE permissions MODIFY COLUMN code varchar(64) NOT NULL DEFAULT '';
--     });
--     print "Upgrade to $DBversion done (Bug 16402: Fix DB structure to work on MySQL 5.7)\n";
--     SetVersion($DBversion);
-- }
