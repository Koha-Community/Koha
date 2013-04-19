#!/usr/bin/env perl

use Modern::Perl;
use Test::More tests =>14;

use Test::MockModule;
use DBD::Mock;

use_ok('C4::Members');

my $module_context = new Test::MockModule('C4::Context');
$module_context->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);

my $dbh = C4::Context->dbh;
my $rs = [];

my $pref = "10";
set_pref( $module_context, $pref );

$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{123456789} ), 1, "123456789 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678901234567890} ), 1, "12345678901234567890 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 is equal to $pref");

$pref = q|10,10|; # Same as before !
set_pref( $module_context, $pref );
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{123456789} ), 1, "123456789 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678901234567890} ), 1, "12345678901234567890 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 is equal to $pref");

$pref = q|8,10|; # between 8 and 10 chars
set_pref( $module_context, $pref );
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678} ), 0, "12345678 matches $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678901234567890} ), 1, "12345678901234567890 is longer than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567} ), 1, "1234567 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "1234567890 matches $pref");

$pref = q|8,|; # At least 8 chars
set_pref( $module_context, $pref );
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567} ), 1, "1234567 is shorter than $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{12345678901234567890} ), 0, "12345678901234567890 matches $pref");
$dbh->{mock_add_resultset} = $rs;
is( C4::Members::checkcardnumber( q{1234567890} ), 0, "12345678 matches $pref");

sub set_pref {
    my ( $module, $value ) = @_;
    $module->mock('preference', sub { return $value } );
}
