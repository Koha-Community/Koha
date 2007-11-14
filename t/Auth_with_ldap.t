#!/bin/perl
#

use strict;
use warnings;

use Test::More;
use vars qw(%cases $dbh $config $ldap);

BEGIN {
	%cases = (
		# users from example3.ldif
		sss => 'password1',
		jts => 'password1',
		rch => 'password2',
		jmf => 'password3',
	);
	plan tests => 3 + scalar(keys %cases);
	use_ok('C4::Context');
	use_ok('C4::Auth_with_ldap', qw(checkauth));
}

sub do_checkauth (;$$) { 
	my ($user,$pass) = (shift,shift);
	diag "($user,$pass)";
	my $ret;
	return ($ret = checkauth($dbh,$user,$pass), sprintf("(%s,%s) returns '%s'",$user,$pass,$ret));
}

ok($dbh    = C4::Context->dbh(), 		"Getting dbh from C4::Context");
ok($config = C4::Context->config(), 	"Getting config (hashref) from C4::Context");
ok($ldap   = $config->{ldap}, 			"Getting LDAP info from config");

diag("The basis of Authenticaiton is that we don't auth everybody.");
diag("Let's make sure we reject on bad calls.");
my $ret;
ok(!($ret = checkauth($dbh)),       "should reject (  no  arguments) returns '$ret'");
ok(!($ret = checkauth($dbh,'','')), "should reject (empty arguments) returns '$ret'");
print "\n";
diag("Now let's check " . scalar(keys %cases) . " test cases: ");
foreach (sort keys %cases) {
	ok do_checkauth($_, $cases{$_});
}

1;
