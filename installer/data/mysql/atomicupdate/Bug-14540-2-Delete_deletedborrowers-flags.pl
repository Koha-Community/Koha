use C4::Context;
my $dbh = C4::Context->dbh();

$dbh->do("ALTER TABLE deletedborrowers DROP COLUMN flags");
print "Upgrade done (Bug 14540-2 - Drop deletedborrowers.flags column.)\n";
