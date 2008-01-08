#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use override_context_prefs;
        use_ok('C4::Auth', qw(checkpw));
        use_ok('C4::Context');
}

use vars qw($dbh $ldap);
can_ok('C4::Context', 'config');
can_ok('C4::Context', 'dbh');
can_ok('C4::Auth', qw(checkpw));
    ok($dbh  = C4::Context->dbh(),  "Getting dbh from C4::Context");
$ldap = C4::Context->config('useldapserver') || 0;
diag("Using LDAP? $ldap");

while (1) {		# forever!
	print "Do you want to test further accounts? (If not, just hit return.)\n";
	my ($user, $pass);
	print "Enter username: ";
	chomp($user = <>);
	($user) or exit;
	print "Enter password: ";
	chomp($pass = <>);
	my ($retval,$retcard) = checkpw($dbh,$user,$pass);
	$retval  ||= '';
	$retcard ||= '';
	diag ("checkpw(\$dbh,$user,$pass) " . ($retval ? 'SUCCEEDS' : ' FAILS  ') . "\treturns ($retval,$retcard)");
}

END {
	diag("C4::Auth - end of test");
}
__END__
