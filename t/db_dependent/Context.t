#!/usr/bin/perl
#

use strict;
use warnings;

use Test::More tests => 91;
use vars qw($debug $koha $dbh $config $ret);

BEGIN {
		$debug = $ENV{DEBUG} || 0;
		diag("Note: The overall number of tests may vary by configuration.");
		diag("First we need to check your environmental variables");
		for (qw(KOHA_CONF PERL5LIB)) {
			ok($ret = $ENV{$_}, "ENV{$_} = $ret");
		}
		use_ok('C4::Context');
		use_ok('C4::Utils', qw/ :all /);
}

ok($koha = C4::Context->new,  'C4::Context->new');
ok($dbh = C4::Context->dbh(), 'Getting dbh from C4::Context');
ok($ret = C4::Context->KOHAVERSION, '  (function)  KOHAVERSION = ' . ($ret||''));
ok($ret =       $koha->KOHAVERSION, '       $koha->KOHAVERSION = ' . ($ret||''));
my @keys = keys %$koha;
diag("Number of keys in \%\$koha: " . scalar @keys); 
our $width = 0;
if (ok(@keys)) { 
	$width = maxwidth(@keys);
	$debug and diag "widest key is $width";
}
foreach (sort @keys) {
	ok(exists $koha->{$_}, 
		'$koha->{' . sprintf('%' . $width . 's', $_)  . '} exists '
		. ((defined $koha->{$_}) ? "and is defined." : "but is not defined.")
	);
}
diag "Examining defined key values.";
foreach (grep {defined $koha->{$_}} sort @keys) {
	print "\n";
	hashdump('$koha->{' . sprintf('%' . $width . 's', $_)  . '}', $koha->{$_});
}
ok($config = $koha->{config}, 'Getting $koha->{config} ');

# diag("Examining configuration.");
diag("Note: The overall number of tests may vary by configuration.  Disregard the projected number.");
1;
__END__

