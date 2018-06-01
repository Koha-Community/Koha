#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use Modern::Perl;

use CGI qw ( -utf8 );

use Test::MockObject;
use Test::MockModule;
use List::MoreUtils qw/all any none/;
use Test::More tests => 22;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth qw(checkpw);
use C4::Members;
use Koha::AuthUtils qw/hash_password/;
use Koha::Database;
use Koha::Patrons;

BEGIN {
    use_ok('C4::Auth');
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;
my $dbh     = C4::Context->dbh;

# FIXME: SessionStorage defaults to mysql, but it seems to break transaction
# handling
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$schema->storage->txn_begin;

subtest 'checkauth() tests' => sub {

    plan tests => 2;

    my $patron = $builder->build({ source => 'Borrower', value => { flags => undef } })->{userid};

    # Mock a CGI object with real userid param
    my $cgi = Test::MockObject->new();
    $cgi->mock( 'param', sub { return $patron; } );
    $cgi->mock( 'cookie', sub { return; } );

    my $authnotrequired = 1;
    my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, $authnotrequired );

    is( $userid, undef, 'checkauth() returns undef for userid if no logged in user (Bug 18275)' );

    my $db_user_id = C4::Context->config('user');
    my $db_user_pass = C4::Context->config('pass');
    $cgi = Test::MockObject->new();
    $cgi->mock( 'cookie', sub { return; } );
    $cgi->mock( 'param', sub {
            my ( $self, $param ) = @_;
            if ( $param eq 'userid' ) { return $db_user_id; }
            elsif ( $param eq 'password' ) { return $db_user_pass; }
            else { return; }
        });
    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, $authnotrequired );
    is ( $userid, undef, 'If DB user is used, it should not be logged in' );
    C4::Context->_new_userenv; # For next tests

};

subtest 'track_login_daily tests' => sub {

    plan tests => 5;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $userid = $patron->userid;

    $patron->lastseen( undef );
    $patron->store();

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "track_login_" . $patron->userid;
    $cache->clear_from_cache($cache_key);

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '1' );

    is( $patron->lastseen, undef, 'Patron should have not last seen when newly created' );

    C4::Auth::track_login_daily( $userid );
    $patron->_result()->discard_changes();
    isnt( $patron->lastseen, undef, 'Patron should have last seen set when TrackLastPatronActivity = 1' );

    sleep(1); # We need to wait a tiny bit to make sure the timestamp will be different
    my $last_seen = $patron->lastseen;
    C4::Auth::track_login_daily( $userid );
    $patron->_result()->discard_changes();
    is( $patron->lastseen, $last_seen, 'Patron last seen should still be unchanged' );

    $cache->clear_from_cache($cache_key);
    C4::Auth::track_login_daily( $userid );
    $patron->_result()->discard_changes();
    isnt( $patron->lastseen, $last_seen, 'Patron last seen should be changed if we cleared the cache' );

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '0' );
    $patron->lastseen( undef )->store;
    $cache->clear_from_cache($cache_key);
    C4::Auth::track_login_daily( $userid );
    $patron->_result()->discard_changes();
    is( $patron->lastseen, undef, 'Patron should still have last seen unchanged when TrackLastPatronActivity = 0' );

};

my $hash1 = hash_password('password');
my $hash2 = hash_password('password');

{ # tests no_set_userenv parameter
    my $patron = $builder->build( { source => 'Borrower' } );
    Koha::Patrons->find( $patron->{borrowernumber} )->update_password( $patron->{userid}, $hash1 );
    my $library = $builder->build(
        {
            source => 'Branch',
        }
    );

    ok( checkpw( $dbh, $patron->{userid}, 'password', undef, undef, 1 ), 'checkpw returns true' );
    is( C4::Context->userenv, undef, 'Userenv should be undef as required' );
    C4::Context->_new_userenv('DUMMY SESSION');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $library->{branchcode}, 'Library 1', 0, '', '');
    is( C4::Context->userenv->{branch}, $library->{branchcode}, 'Userenv gives correct branch' );
    ok( checkpw( $dbh, $patron->{userid}, 'password', undef, undef, 1 ), 'checkpw returns true' );
    is( C4::Context->userenv->{branch}, $library->{branchcode}, 'Userenv branch is preserved if no_set_userenv is true' );
    ok( checkpw( $dbh, $patron->{userid}, 'password', undef, undef, 0 ), 'checkpw still returns true' );
    isnt( C4::Context->userenv->{branch}, $library->{branchcode}, 'Userenv branch is overwritten if no_set_userenv is false' );
}

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
            -value    => 'nirvana',
            -HttpOnly => 1
        );

        return ( $userid, $session_cookie, $sessionID, $flags );
    }

    # Mock checkauth, build the scenario
    my $auth = new Test::MockModule( 'C4::Auth' );
    $auth->mock( 'checkauth', \&MockedCheckauth );

    # Make sure 'EnableOpacSearchHistory' is set
    t::lib::Mocks::mock_preference('EnableOpacSearchHistory',1);
    # Enable es-ES for the OPAC and staff interfaces
    t::lib::Mocks::mock_preference('opaclanguages','en,es-ES');
    t::lib::Mocks::mock_preference('language','en,es-ES');

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
        like ( $@, qr(^bad template path), "The file $template_name should not be accessible" );
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

ok(C4::Auth::checkpw_hash('password', $hash1), 'password validates with first hash');
ok(C4::Auth::checkpw_hash('password', $hash2), 'password validates with second hash');
