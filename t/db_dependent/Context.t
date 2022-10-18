#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 4;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

BEGIN {
    my $ret;
    # Note: The overall number of tests may vary by configuration.
    # First we need to check your environmental variables
    for (qw(KOHA_CONF PERL5LIB)) {
        ok( $ret = $ENV{$_}, "ENV{$_} = $ret" );
    }
    use_ok('C4::Context');
}

our $schema;
$schema = Koha::Database->new->schema;

subtest 'Original tests' => sub {
plan tests => 33;
$schema->storage->txn_begin;

my $dbh;
ok($dbh = C4::Context->dbh(), 'Getting dbh from C4::Context');

C4::Context->set_preference('OPACBaseURL','junk');
C4::Context->clear_syspref_cache();
my $OPACBaseURL = C4::Context->preference('OPACBaseURL');
is($OPACBaseURL,'http://junk','OPACBaseURL saved with http:// when missing it');

C4::Context->set_preference('OPACBaseURL','https://junk');
C4::Context->clear_syspref_cache();
$OPACBaseURL = C4::Context->preference('OPACBaseURL');
is($OPACBaseURL,'https://junk','OPACBaseURL saved with https:// as specified');

C4::Context->set_preference('OPACBaseURL','http://junk2');
C4::Context->clear_syspref_cache();
$OPACBaseURL = C4::Context->preference('OPACBaseURL');
is($OPACBaseURL,'http://junk2','OPACBaseURL saved with http:// as specified');

C4::Context->set_preference('OPACBaseURL', '');
$OPACBaseURL = C4::Context->preference('OPACBaseURL');
is($OPACBaseURL,'','OPACBaseURL saved empty as specified');

C4::Context->set_preference('SillyPreference','random');
C4::Context->clear_syspref_cache();
my $SillyPeference = C4::Context->preference('SillyPreference');
is($SillyPeference,'random','SillyPreference saved as specified');
C4::Context->clear_syspref_cache();
C4::Context->enable_syspref_cache();
#$dbh->rollback;

my $koha;
ok($koha = C4::Context->new,  'C4::Context->new');
my @keys = keys %$koha;
my $width = 0;
ok( @keys, 'Expecting entries in context hash' );
if( @keys ) {
    $width = (sort {$a <=> $b} map {length} @keys)[-1];
}
foreach (sort @keys) {
	ok(exists $koha->{$_}, 
		'$koha->{' . sprintf('%' . $width . 's', $_)  . '} exists '
		. ((defined $koha->{$_}) ? "and is defined." : "but is not defined.")
	);
}
my $config;
ok($config = $koha->{config}, 'Getting $koha->{config} ');

# Testing syspref caching

#my $schema = Koha::Database->new()->schema();
$schema->storage->debug(1);
my $trace_read;
open my $trace, '>', \$trace_read or die "Can't open variable: $!";
$schema->storage->debugfh( $trace );

C4::Context->set_preference('SillyPreference', 'thing1');
my $silly_preference = Koha::Config::SysPrefs->find('SillyPreference');
is( $silly_preference->variable, 'SillyPreference', 'set_preference should have kept the case sensitivity' );

my $pref = C4::Context->preference("SillyPreference");
is(C4::Context->preference("SillyPreference"), 'thing1', "Retrieved syspref (value='thing1') successfully with default behavior");
ok( $trace_read, 'Retrieved syspref from database');
$trace_read = q{};

is(C4::Context->preference("SillyPreference"), 'thing1', "Retrieved syspref (value='thing1') successfully with default behavior");
is( $trace_read , q{}, 'Did not retrieve syspref from database');
$trace_read = q{};

C4::Context->disable_syspref_cache();
$silly_preference->set( { value => 'thing2' } )->store();
is(C4::Context->preference("SillyPreference"), 'thing2', "Retrieved syspref (value='thing2') successfully with disabled cache");
ok($trace_read, 'Retrieved syspref from database');
$trace_read = q{};

$silly_preference->set( { value => 'thing3' } )->store();
is(C4::Context->preference("SillyPreference"), 'thing3', "Retrieved syspref (value='thing3') successfully with disabled cache");
ok($trace_read, 'Retrieved syspref from database');
$trace_read = q{};

C4::Context->enable_syspref_cache();
is(C4::Context->preference("SillyPreference"), 'thing3', "Retrieved syspref (value='thing3') successfully from cache");
isnt( $trace_read, q{}, 'The pref should be retrieved from the database if the cache has been enabled');
$trace_read = q{};

# FIXME This was added by Robin and does not pass anymore
# I don't understand why we should expect thing1 while thing3 is in the cache and in the DB
#$dbh->{mock_clear_history} = 1;
## This gives us the value that was cached on the first call, when the cache was active.
#is(C4::Context->preference("SillyPreference"), 'thing1', "Retrieved syspref (value='thing1') successfully from cache");
#$history = $dbh->{mock_all_history};
#is(scalar(@{$history}), 0, 'Did not retrieve syspref from database');

$silly_preference->set( { value => 'thing4' } )->store();
C4::Context->clear_syspref_cache();
is(C4::Context->preference("SillyPreference"), 'thing4', "Retrieved syspref (value='thing4') successfully after clearing cache");
ok($trace_read, 'Retrieved syspref from database');
$trace_read = q{};

is(C4::Context->preference("SillyPreference"), 'thing4', "Retrieved syspref (value='thing4') successfully from cache");
is( $trace_read, q{}, 'Did not retrieve syspref from database');
$trace_read = q{};

my $oConnection = C4::Context->Zconn('biblioserver', 0);
isnt($oConnection->option('async'), 1, "ZOOM connection is synchronous");
$oConnection = C4::Context->Zconn('biblioserver', 1);
is($oConnection->option('async'), 1, "ZOOM connection is asynchronous");

$silly_preference->delete();

# AutoEmailNewUser should be a YesNo pref
C4::Context->set_preference('AutoEmailNewUser', '');
my $yesno_pref = Koha::Config::SysPrefs->find('AutoEmailNewUser');
is( $yesno_pref->value(), 0, 'set_preference should have set the value to 0, instead of an empty string' );


    $schema->storage->txn_rollback;
};
