#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use CGI;
use Test::MockModule;
use List::MoreUtils qw/all any none/;
use Test::More tests => 4;
use C4::Members;

BEGIN {
        use_ok('C4::Auth');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;


# get_template_and_user tests

{   # Tests for the language URL parameter

    sub MockedCheckauth {
        my ($query,$authnotrequired,$flagsrequired,$type) = @_;
        # return vars
        my $userid = 'cobain';
        my $sessionID = 234;
        # we don't need to bother about permissions for this test
        my $flags = {
            superlibrarian    => 1, acquisition       => 0,
            borrow            => 0, borrowers         => 0,
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
            -value    => 'nirvana',
            -HttpOnly => 1
        );

        return ( $userid, $session_cookie, $sessionID, $flags );
    }

    # Mock checkauth, build the scenario
    my $auth = new Test::MockModule( 'C4::Auth' );
    $auth->mock( 'checkauth', \&MockedCheckauth );

    # Make sure 'EnableOpacSearchHistory' is set
    C4::Context->set_preference('EnableOpacSearchHistory',1);
    # Enable es-ES for the OPAC and staff interfaces
    C4::Context->set_preference('opaclanguages','en,es-ES');
    C4::Context->set_preference('language','en,es-ES');

    # we need a session cookie and have some anonymous search history
    $ENV{"SERVER_PORT"} = 80;
    $ENV{"HTTP_COOKIE"} = 'CGISESSID=nirvana; KohaOpacRecentSearches=%255B%257B%2522time%2522%253A1378313124%252C%2522query_cgi%2522%253A%2522idx%253D%2526q%253Dhistory%2526branch_group_limit%253D%2522%252C%2522total%2522%253A3%252C%2522query_desc%2522%253A%2522kw%252Cwrdl%253A%2520history%252C%2520%2522%257D%252C%257B%2522time%2522%253A1378313137%252C%2522query_cgi%2522%253A%2522idx%253D%2526q%253D%2525D8%2525B9%2525D8%2525B1%2525D8%2525A8%2525D9%25258A%25252F%2525D8%2525B9%2525D8%2525B1%2525D8%2525A8%2525D9%252589%2526branch_group_limit%253D%2522%252C%2522total%2522%253A2%252C%2522query_desc%2522%253A%2522kw%252Cwrdl%253A%2520%25D8%25B9%25D8%25B1%25D8%25A8%25D9%258A%252F%25D8%25B9%25D8%25B1%25D8%25A8%25D9%2589%252C%2520%2522%257D%255D';

    my $query = new CGI;
    $query->param('language','es-ES');

    my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => "about.tmpl",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
            flagsrequired   => { catalogue => 1 },
            debug           => 1
        }
    );

    ok ( ( all { ref($_) eq 'CGI::Cookie' } @$cookies ),
            'BZ9735: the cookies array is flat' );

    # new query, with non-existent language (we only have en and es-ES)
    $query->param('language','tomas');

    ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => "about.tmpl",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
            flagsrequired   => { catalogue => 1 },
            debug           => 1
        }
    );

    ok( ( none { $_->name eq 'KohaOpacLanguage' and $_->value eq 'tomas' } @$cookies ),
        'BZ9735: invalid language, it is not set');

    ok( ( any { $_->name eq 'KohaOpacLanguage' and $_->value eq 'en' } @$cookies ),
        'BZ9735: invalid language, then default to en');
}

$dbh->rollback;
