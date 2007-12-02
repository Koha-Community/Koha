#!/bin/perl
#

use strict;
use warnings;

use Test::More;
use vars qw(%cases $dbh $config $context $ldap);

BEGIN {
	%cases = (
		# users from t/LDAP/example3.ldif
		sss => 'password1',
		jts => 'password1',
		rch => 'password2',
		jmf => 'password3',
	);
	plan tests => 7 + scalar(keys %cases);
	use_ok('C4::Context');
	use_ok('C4::Auth_with_ldap', qw(checkpw_ldap));
}

sub do_checkpw_ldap (;$$) { 
	my ($user,$pass) = (shift,shift);
	diag "($user,$pass)";
	my $ret;
	return ($ret = checkpw_ldap($dbh,$user,$pass), sprintf("(%s,%s) returns '%s'",$user,$pass,$ret));
}

ok($context= C4::Context->new(), 	"Getting new C4::Context object");
ok($dbh    = C4::Context->dbh(), 	"Getting dbh from C4::Context");
ok($dbh    = $context->dbh(), 		"Getting dbh from \$context object");

diag("The basis of Authentication is that we don't auth everybody.");
diag("Let's make sure we reject on bad calls.");
my $ret;
ok(!($ret = checkpw_ldap($dbh)),       "should reject (  no  arguments) returns '$ret'");
ok(!($ret = checkpw_ldap($dbh,'','')), "should reject (empty arguments) returns '$ret'");
print "\n";
diag("Now let's check " . scalar(keys %cases) . " test cases: ");
foreach (sort keys %cases) {
	ok do_checkpw_ldap($_, $cases{$_});
}

1;
