#!/usr/bin/perl
#

use strict;
use warnings;
use Test::More;
use vars qw(%cases);

BEGIN {
	# Build a hash for our test cases.  
	# Map: uid => userPassword
	%cases = (
		testuser1 => 'password1',
		Manager   => 'secret',
		rch       => 'password2',
		jmf       => 'password3',
	);
	plan tests => 9 + keys %cases;	# this is why we define %cases in BEGIN
	use_ok('C4::Context');			# this is why we plan tests in BEGIN
	use_ok('C4::Auth_with_ldap', qw/checkauth/);
}

our $width = 18;
our $format = '(%' .$width. 's) returns (%s, %s)';
diag("format: $format\n");
# returns pretty test case description 
sub description ($$$) {
	my $argstring = shift;
	my $dif = $width - length ($argstring);
	($dif > 1) and $argstring .= ' ' x ($dif/2);
	my $ret1 = (defined $_[0] and length $_[0]) ? shift : '';
	my $ret2 = (defined $_[0] and length $_[0]) ? shift : '';
	return sprintf $format, $argstring,$ret1,$ret2;
}

my ($ret1,$ret2,$dbh);
ok($dbh = C4::Context->dbh,	"Getting dbh from C4::Context");

diag("\nThe basis for authentication is that we do NOT just auth everybody.
	So first we'll make sure we reject on bad calls to checkauth.\n");
diag("\nAll further tests will be of the form:\n\t \&checkauth(\$dbh, USER, PASS)\n" .
	"The (USER, PASS) arguments will be displayed with the value(s) returned.");
print "\n";

ok(($ret1,$ret2) = &checkauth($dbh),	description('[ no   args]',$ret1,$ret2));
ok($ret1 == 0, "Valid Rejection");
ok(($ret1,$ret2) = &checkauth($dbh,,),	description('[empty args]',$ret1,$ret2));
ok($ret1 == 0, "Valid Rejection");
ok(($ret1,$ret2) = &checkauth($dbh,'',''),	description("'',''",$ret1,$ret2));
ok($ret1 == 0, "Valid Rejection");

print "\n\n";
diag("Those \nNow let's process " . scalar(keys %cases) . " test cases.\n");
print "\n";
foreach (sort keys %cases) {
	ok(($ret1,$ret2) = &checkauth($dbh,$_,$cases{$_}), description("$_\, $cases{$_}",$ret1,$ret2));
}
print "More tests are needed.\n";
