#!/usr/bin/perl
#

use strict;
use warnings;

use Test::More;
use Test::MockModule;
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

diag "Testing syspref caching.";

my $dbh = C4::Context->dbh;
$dbh->disconnect;

my $module = new Test::MockModule('C4::Context');
$module->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);

my $history;
$dbh = C4::Context->dbh;

$dbh->{mock_add_resultset} = [ ['value'], ['thing1'] ];
$dbh->{mock_add_resultset} = [ ['value'], ['thing2'] ];
$dbh->{mock_add_resultset} = [ ['value'], ['thing3'] ];
$dbh->{mock_add_resultset} = [ ['value'], ['thing4'] ];

is(C4::Context->preference("SillyPreference"), 'thing1', "Retrieved syspref (value='thing1') successfully with default behavior");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Retrieved syspref from database');

$dbh->{mock_clear_history} = 1;
is(C4::Context->preference("SillyPreference"), 'thing1', "Retrieved syspref (value='thing1') successfully with default behavior");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 0, 'Did not retrieve syspref from database');

C4::Context->disable_syspref_cache();
is(C4::Context->preference("SillyPreference"), 'thing2', "Retrieved syspref (value='thing2') successfully with disabled cache");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Retrieved syspref from database');

$dbh->{mock_clear_history} = 1;
is(C4::Context->preference("SillyPreference"), 'thing3', "Retrieved syspref (value='thing3') successfully with disabled cache");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Retrieved syspref from database');

C4::Context->enable_syspref_cache();
$dbh->{mock_clear_history} = 1;
is(C4::Context->preference("SillyPreference"), 'thing3', "Retrieved syspref (value='thing3') successfully from cache");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 0, 'Did not retrieve syspref from database');

C4::Context->clear_syspref_cache();
$dbh->{mock_clear_history} = 1;
is(C4::Context->preference("SillyPreference"), 'thing4', "Retrieved syspref (value='thing4') successfully after clearing cache");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 1, 'Retrieved syspref from database');

$dbh->{mock_clear_history} = 1;
is(C4::Context->preference("SillyPreference"), 'thing4', "Retrieved syspref (value='thing4') successfully from cache");
$history = $dbh->{mock_all_history};
is(scalar(@{$history}), 0, 'Did not retrieve syspref from database');

done_testing();

1;
