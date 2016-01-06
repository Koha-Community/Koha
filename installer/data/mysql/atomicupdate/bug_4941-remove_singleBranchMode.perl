use Modern::Perl;
use C4::Context;

my $dbh = C4::Context->dbh;

my ( $db_value ) = $dbh->selectrow_array(q|SELECT count(*) FROM branches|);
my $pref_value = C4::Context->preference("singleBranchMode") || 0;
if ( $db_value > 1 and $pref_value == 1 ) {
    warn "WARNING: You have more than 1 libraries in your branches tables but the singleBranchMode system preference is on.\n";
    warn "This configuration does not make sense. The system preference is going to be deleted,\n";
    warn "and this parameter will be based on the number of libraries defined.\n";
}
$dbh->do(q|DELETE FROM systempreferences WHERE variable="singleBranchMode"|);
