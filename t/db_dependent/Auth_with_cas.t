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

use Test::More tests => 4;
use CGI;

use t::lib::Mocks;
use C4::Context;

BEGIN {
    use_ok('C4::Auth_with_cas');
    can_ok('C4::Auth_with_cas', qw/
            check_api_auth_cas
            checkpw_cas
            login_cas
            logout_cas
            login_cas_url
            /);
}

my $dbh = C4::Context->dbh;
# Start transaction
$dbh->{ AutoCommit } = 0;
$dbh->{ RaiseError } = 1;

C4::Context->disable_syspref_cache();
t::lib::Mocks::mock_preference('OPACBaseURL','http://localhost');
t::lib::Mocks::mock_preference('staffClientBaseURL','localhost:8080');

my $opac_base_url = C4::Context->preference('OpacBaseURL');
my $staff_base_url = C4::Context->preference('staffClientBaseURL');
my $query_string = 'ticket=foo&bar=baz';

$ENV{QUERY_STRING} = $query_string;
$ENV{SCRIPT_NAME} = '/cgi-bin/koha/opac-user.pl';

my $cgi = new CGI($query_string);
$cgi->delete('ticket');

# _url_with_get_params tests
is(C4::Auth_with_cas::_url_with_get_params($cgi, 'opac'),
    "$opac_base_url/cgi-bin/koha/opac-user.pl?bar=baz",
   "_url_with_get_params should return URL without deleted parameters (Bug 12398)");

# intranet url test
is(C4::Auth_with_cas::_url_with_get_params($cgi, 'intranet'),
    "$staff_base_url?bar=baz",
   "Intranet URL should be returned when using intranet login (Bug 13507)");



$dbh->rollback;

1;
