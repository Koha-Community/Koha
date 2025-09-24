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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::MockModule;
use Test::MockObject;

use CGI;

use t::lib::Mocks;
use C4::Context;
use Koha::Database;

BEGIN {
    use_ok( 'C4::Auth_with_cas', qw( check_api_auth_cas checkpw_cas login_cas logout_cas login_cas_url ) );
    can_ok(
        'C4::Auth_with_cas', qw/
            check_api_auth_cas
            checkpw_cas
            login_cas
            logout_cas
            login_cas_url
            /
    );
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

C4::Context->disable_syspref_cache();
t::lib::Mocks::mock_preference( 'OPACBaseURL',        'http://localhost' );
t::lib::Mocks::mock_preference( 'staffClientBaseURL', 'http://localhost:8080' );

my $opac_base_url  = C4::Context->preference('OpacBaseURL');
my $staff_base_url = C4::Context->preference('staffClientBaseURL');
my $query_string   = 'ticket=foo&bar=baz';

$ENV{QUERY_STRING} = $query_string;
$ENV{SCRIPT_NAME}  = '/cgi-bin/koha/opac-user.pl';

my $cgi = CGI->new($query_string);
$cgi->delete('ticket');

# _url_with_get_params tests
is(
    C4::Auth_with_cas::_url_with_get_params( $cgi, 'opac' ),
    "$opac_base_url/cgi-bin/koha/opac-user.pl?bar=baz",
    "_url_with_get_params should return URL without deleted parameters (Bug 12398)"
);

$ENV{SCRIPT_NAME} = '/cgi-bin/koha/circ/circulation-home.pl';

# intranet url test
is(
    C4::Auth_with_cas::_url_with_get_params( $cgi, 'intranet' ),
    "$staff_base_url/cgi-bin/koha/circ/circulation-home.pl?bar=baz",
    "Intranet URL should be returned when using intranet login (Bug 13507)"
);

subtest 'logout_cas() tests' => sub {

    plan tests => 4;

    my $cas_url = "https://mycasserver.url";

    my $auth_with_cas_mock = Test::MockModule->new('C4::Auth_with_cas');
    $auth_with_cas_mock->mock(
        '_get_cas_and_service',
        sub {
            my $cas = Test::MockObject->new();
            $cas->mock(
                'logout_url',
                sub {
                    return "$cas_url/logout/?url=https://mykoha.url";
                }
            );
            return ( $cas, "$cas_url?logout.x=1" );
        }
    );

    my $cas_version;
    my $expected_logout_url;

    # Yeah, this gets funky
    my $cgi_mock = Test::MockModule->new('CGI');
    $cgi_mock->mock(
        'redirect',
        sub {
            my ( $self, $url ) = @_;
            return $url;
        }
    );

    # Test CAS 2.0 behavior
    $cas_version         = 2;
    $expected_logout_url = "$cas_url/logout/?url=https://mykoha.url";

    my $redirect_output = '';
    close(STDOUT);
    open( STDOUT, ">", \$redirect_output ) or die "Error opening STDOUT";

    t::lib::Mocks::mock_preference( 'casServerVersion', $cas_version );
    C4::Auth_with_cas::logout_cas( CGI->new, 'anything' );
    is( $redirect_output, $expected_logout_url, "The generated URL is correct (v$cas_version\.0)" );
    unlike( $redirect_output, qr/logout\.x\=1/, 'logout.x=1 gets removed' );

    # Test CAS 3.0 behavior
    $redirect_output = '';
    close(STDOUT);
    open( STDOUT, ">", \$redirect_output ) or die "Error opening STDOUT";

    $cas_version         = 3;
    $expected_logout_url = "$cas_url/logout/?service=https://mykoha.url";

    t::lib::Mocks::mock_preference( 'casServerVersion', $cas_version );
    C4::Auth_with_cas::logout_cas( CGI->new, 'anything' );
    is( $redirect_output, $expected_logout_url, "The generated URL is correct (v$cas_version\.0)" );
    unlike( $redirect_output, qr/logout\.x\=1/, 'logout.x=1 gets removed' );
};
