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

use CGI qw ( -utf8 );
use Test::MockModule;
use List::MoreUtils qw/all any none/;
use Test::More tests => 2;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use Koha::AuthUtils qw/hash_password/;
use Koha::Database;

my $query = new CGI;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

# Borrower Creation
my $hash = hash_password('password');
my $patron = $builder->build( { source => 'Borrower' } );
Koha::Patrons->find( $patron->{borrowernumber} )->update_password( $patron->{userid}, $hash );

my $session = C4::Auth::get_session("");
$session->flush;

sub myMockedget_from_session {
    my $expected_recent_searches = [
        {
            'time' => 1374978877,
            'query_cgi' => 'cgi_test',
            'total' => 2,
            'query_desc' => 'kw,wrdl: history, '
        }
    ];
    return @{$expected_recent_searches};

}

my $getfrom = new Test::MockModule( 'C4::Search::History' );
$getfrom->mock( 'get_from_session', \&myMockedget_from_session );

my $cgi = new Test::MockModule( 'CGI');
$cgi->mock('cookie', sub {
   my ($self, $key) = @_;
  if (!ref($key) && $key eq 'CGISESSID'){
         return 'ID';
   }
});

sub MockedCheckauth {
    my ($query,$authnotrequired,$flagsrequired,$type) = @_;
    my $userid = $patron->{userid};
    my $sessionID = 234;
    my $flags = {
        superlibrarian    => 1, acquisition       => 0,
        borrowers         => 0,
        catalogue         => 1, circulate         => 0,
        coursereserves    => 0, editauthorities   => 0,
        editcatalogue     => 0, management        => 0,
        parameters        => 0, permissions       => 0,
        plugins           => 0, reports           => 0,
        reserveforothers  => 0, serials           => 0,
        staffaccess       => 0, tools             => 0,
        updatecharges     => 0
    };

    my $session_cookie = $query->cookie(
        -name => 'CGISESSID',
        -value    => '9884013ae2c441d12e0bc9376242d2a8',
        -HttpOnly => 1
    );
    return ( $userid, $session_cookie, $sessionID, $flags );
}

# Mock checkauth
my $auth = new Test::MockModule( 'C4::Auth' );
$auth->mock( 'checkauth', \&MockedCheckauth );

$query->param('koha_login_context', 'opac');
$query->param('userid', $patron->{userid});
$query->param('password', 'password');

# Test when the syspref is disabled
t::lib::Mocks::mock_preference('addSearchHistoryToTheFirstLoggedUser', 0);
my $result = $schema->resultset('SearchHistory')->search()->count;

my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1
    }
);

my $result2 = $schema->resultset('SearchHistory')->search()->count;
is($result2, $result, 'no new search added to borrower');

# Test when the syspref is enabled
t::lib::Mocks::mock_preference('addSearchHistoryToTheFirstLoggedUser', 1);
$query->param('koha_login_context', 'opac');
$query->param('userid', $patron->{userid});
$query->param('password', 'password');
$query->cookie(
        -name     => 'CGISESSID',
        -value    => $session->id,
        -HttpOnly => 1
);

$result = $schema->resultset('SearchHistory')->search()->count;

( $template, $loggedinuser, $cookies ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1
    }
);

$result2 = $schema->resultset('SearchHistory')->search()->count;
is($result2, $result+1, 'new search added to borrower');

# Delete the inserts
$result = $schema->resultset('SearchHistory')->search(undef, { query_cgi => 'cgi_test'});
$result->delete_all();
