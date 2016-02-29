#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use CGI qw ( -utf8 );
use Test::MockModule;
use List::MoreUtils qw/all any none/;
use Test::More tests => 13;
use Test::Warn;
use C4::Members;
use Koha::AuthUtils qw/hash_password/;

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

    # we need a session cookie
    $ENV{"SERVER_PORT"} = 80;
    $ENV{"HTTP_COOKIE"} = 'CGISESSID=nirvana';

    my $query = new CGI;
    $query->param('language','es-ES');

    my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => "about.tt",
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
            template_name   => "about.tt",
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

    for my $template_name (
        qw(
            ../../../../../../../../../../../../../../../etc/passwd
            test/../../../../../../../../../../../../../../etc/passwd
            /etc/passwd
            test/does_not_finished_by_tt_t
        )
    ) {
        eval {
            ( $template, $loggedinuser, $cookies ) = get_template_and_user(
                {
                    template_name   => $template_name,
                    query           => $query,
                    type            => "intranet",
                    authnotrequired => 1,
                    flagsrequired   => { catalogue => 1 },
                }
            );
        };
        like ( $@, qr(^bad template path), 'The file $template_name should not be accessible' );
    }
    ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => 'errors/errorpage.tt',
            query           => $query,
            type            => "intranet",
            authnotrequired => 1,
            flagsrequired   => { catalogue => 1 },
        }
    );
    my $file_exists = ( -f $template->{filename} ) ? 1 : 0;
    is ( $file_exists, 1, 'The file errors/errorpage.tt should be accessible (contains integers)' );
}

# Check that there is always an OPACBaseURL set.
my $input = CGI->new();
my ( $template1, $borrowernumber, $cookie );
( $template1, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-detail.tt",
        type => "opac",
        query => $input,
        authnotrequired => 1,
    }
);

ok( ( any { 'OPACBaseURL' eq $_ } keys %{$template1->{VARS}} ),
    'OPACBaseURL is in OPAC template' );

my ( $template2 );
( $template2, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/detail.tt",
        type => "intranet",
        query => $input,
        authnotrequired => 1,
    }
);

ok( ( any { 'OPACBaseURL' eq $_ } keys %{$template2->{VARS}} ),
    'OPACBaseURL is in Staff template' );

my $hash1 = hash_password('password');
my $hash2 = hash_password('password');

ok(C4::Auth::checkpw_hash('password', $hash1), 'password validates with first hash');
ok(C4::Auth::checkpw_hash('password', $hash2), 'password validates with second hash');

$dbh->rollback;
