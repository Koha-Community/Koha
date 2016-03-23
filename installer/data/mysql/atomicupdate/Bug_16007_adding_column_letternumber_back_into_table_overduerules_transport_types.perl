my $dbh = C4::Context->dbh;
my ($print_error) = $dbh->{PrintError};
$dbh->{RaiseError} = 0;
$dbh->{PrintError} = 0;
$dbh->do("ALTER TABLE overduerules_transport_types ADD COLUMN letternumber INT(1) NOT NULL DEFAULT 1 AFTER id");
$dbh->{PrintError} = $print_error;
print "Bug 16007: Make sure overduerules_transport_types.letternumber exists\n";
