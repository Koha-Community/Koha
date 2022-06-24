#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use DBI;
use Test::More tests => 32;
use Test::MockModule;
use Test::Warn;
use YAML::XS;

use t::lib::Mocks;

BEGIN {
    use_ok('C4::Context');
}

subtest 'yaml_preference() tests' => sub {

    plan tests => 3;

    my $data = [ 'uno', 'dos', { 'tres' => 'cuatro' } ];

    my $context = Test::MockModule->new( 'C4::Context' );
    $context->mock( 'preference', YAML::XS::Dump($data) );

    my $pref = C4::Context->new->yaml_preference( 'nothing' );

    is_deeply( $pref, $data, 'yaml_preference returns the right structure' );

    $context->mock( 'preference', qq{- uno: dsa\n\t- dos: asd} );
    warning_like
        { $pref = C4::Context->new->yaml_preference('nothing') }
        qr/^Unable to parse nothing syspref/,
        'Invalid YAML on syspref throws a warning';
    is( $pref, undef, 'Invalid YAML on syspref makes it return undef' );

    $context->unmock( 'preference' );
};

subtest 'needs_install() tests' => sub {

    plan tests => 2;

    t::lib::Mocks::mock_preference( 'Version', '3.0.0' );
    is( C4::Context->needs_install, 0, 'Preference is defined, no need to install' );

    t::lib::Mocks::mock_preference( 'Version', undef ); # the behaviour when ->preference fails to fetch
    is( C4::Context->needs_install, 1, "->preference(Version) is not defined, need to install" );
};

subtest 'csv_delimiter() tests' => sub {

    plan tests => 4;

    t::lib::Mocks::mock_preference( 'CSVDelimiter', undef );
    is( C4::Context->csv_delimiter, ',', "csv_delimiter returns comma if system preference CSVDelimiter is undefined" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', '' );
    is( C4::Context->csv_delimiter, ',', "csv_delimiter returns comma if system preference CSVDelimiter is empty string" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ';' );
    is( C4::Context->csv_delimiter, ';', "csv_delimiter returns semicolon if system preference CSVDelimiter is semicolon" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', 'tabulation' );
    is( C4::Context->csv_delimiter, "\t", "csv_delimiter returns '\t' if system preference CSVDelimiter is tabulation" );
};

my $context = Test::MockModule->new('C4::Context');
my $userenv = {};

$context->mock('userenv', sub {
    return $userenv;
});

local $SIG{__WARN__} = sub { die $_[0] };

eval { C4::Context::IsSuperLibrarian(); };
like ( $@, qr/not defined/, "IsSuperLibrarian logs an error if no userenv is defined" );

$userenv->{flags} = 42;
my $is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if userenv is defined" );
is ( $is_super_librarian, 0, "With flag=42, it is not a super librarian" );

$userenv->{flags} = 421;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if userenv is defined" );
is ( $is_super_librarian, 1, "With flag=1, it is a super librarian" );

$userenv->{flags} = undef;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if \$userenv->{flags} is undefined" );
is ( $is_super_librarian, 0, "With flag=undef, it is not a super librarian" );

$userenv->{flags} = 0;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if \$userenv->{flags} is equal to 0" );
is ( $is_super_librarian, 0, "With flag=0, it is not a super librarian" );

# C4::Context::interface
my $lastwarn;
local $SIG{__WARN__} = sub { $lastwarn = $_[0] };
is(C4::Context->interface, 'opac','interface defaults to opac');
is(C4::Context->interface('foobar'), 'opac', 'interface foobar');
like($lastwarn, qr/invalid interface : 'foobar'/, 'interface warn on foobar');
is(C4::Context->interface, 'opac', 'interface still opac');
is(C4::Context->interface('intranet'), 'intranet', 'interface intranet');
is(C4::Context->interface, 'intranet', 'interface still intranet');
is(C4::Context->interface('foobar'), 'intranet', 'interface foobar again');
is(C4::Context->interface, 'intranet', 'interface still intranet');
is(C4::Context->interface('OPAC'), 'opac', 'interface OPAC uc');
is(C4::Context->interface, 'opac', 'interface still opac');
#Bug 14751
is( C4::Context->interface( 'SiP' ), 'sip', 'interface SiP' );
is( C4::Context->interface( 'COMMANDLINE' ), 'commandline', 'interface commandline uc' );
is( C4::Context->interface( 'CRON' ), 'cron', 'interface cron uc' );

{
    local %ENV = %ENV;
    delete $ENV{HTTPS};
    is( C4::Context->https_enabled, 0, "Undefined HTTPS env returns 0");
    $ENV{HTTPS} = '1';
    is( C4::Context->https_enabled, 0, "Invalid 1 HTTPS env returns 0");
    $ENV{HTTPS} = 'off';
    is( C4::Context->https_enabled, 0, "off HTTPS env returns 0");
    $ENV{HTTPS} = 'OFF';
    is( C4::Context->https_enabled, 0, "OFF HTTPS env returns 0");
    $ENV{HTTPS} = 'on';
    is( C4::Context->https_enabled, 1, "on HTTPS env returns 1");
    $ENV{HTTPS} = 'ON';
    is( C4::Context->https_enabled, 1, "ON HTTPS env returns 1");
}
