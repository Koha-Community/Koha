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
	plan tests => 8 + scalar(keys %cases);
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

$ldap = $ENV{KOHA_USELDAPSERVER};
if(defined($ldap)) {
    diag "Overriding KOHA_CONF <useldapserver> with \$ENV{KOHA_USELDAPSERVER} = $ldap";
} else {
    diag 'Note: You can use $ENV{KOHA_USELDAPSERVER} to override KOHA_CONF <useldapserver> for this test';
    $ldap = C4::Context->config('useldapserver');
}
ok(defined($ldap), "Checking if \$ENV{KOHA_USELDAPSERVER} or <useldapserver> is defined");

SKIP: {
    $ldap or skip("LDAP is disabled.", scalar(keys %cases) + 2);
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
}
1;
