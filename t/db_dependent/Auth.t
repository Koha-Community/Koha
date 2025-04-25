#!/usr/bin/perl

use Modern::Perl;

use CGI qw ( -utf8 );

use Test::MockObject;
use Test::MockModule;
use List::MoreUtils qw/all any none/;
use Test::More tests => 25;
use Test::NoWarnings;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Members;
use Koha::AuthUtils qw( hash_password );
use Koha::DateUtils qw( dt_from_string );
use Koha::Database;
use Koha::Patrons;
use Koha::Auth::TwoFactorAuth;

BEGIN {
    use_ok(
        'C4::Auth',
        qw( checkauth haspermission checkpw get_template_and_user checkpw_hash get_cataloguing_page_permissions )
    );
}

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: SessionStorage defaults to mysql, but it seems to break transaction
# handling
t::lib::Mocks::mock_preference( 'SessionStorage',       'tmp' );
t::lib::Mocks::mock_preference( 'PrivacyPolicyConsent', '' );      # Disabled

# To silence useless warnings
$ENV{REMOTE_ADDR} = '127.0.0.1';

$schema->storage->txn_begin;

subtest 'checkauth() tests' => sub {

    plan tests => 11;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => undef } } );

    # Mock a CGI object with real userid param
    my $cgi = Test::MockObject->new();
    $cgi->mock(
        'param',
        sub {
            my $var = shift;
            if ( $var eq 'userid' ) { return $patron->userid; }
        }
    );
    $cgi->mock( 'cookie',         sub { return; } );
    $cgi->mock( 'request_method', sub { return 'POST' } );

    my $authnotrequired = 1;
    my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, $authnotrequired );

    is( $userid, undef, 'checkauth() returns undef for userid if no logged in user (Bug 18275)' );

    my $db_user_id   = C4::Context->config('user');
    my $db_user_pass = C4::Context->config('pass');
    $cgi = Test::MockObject->new();
    $cgi->mock( 'cookie', sub { return; } );
    $cgi->mock(
        'param',
        sub {
            my ( $self, $param ) = @_;
            if    ( $param eq 'login_userid' )   { return $db_user_id; }
            elsif ( $param eq 'login_password' ) { return $db_user_pass; }
            else                                 { return; }
        }
    );
    $cgi->mock( 'request_method', sub { return 'POST' } );
    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, $authnotrequired );
    is( $userid, undef, 'If DB user is used, it should not be logged in' );

    my $is_allowed = C4::Auth::haspermission( $db_user_id, { can_do => 'everything' } );

    # FIXME This belongs to t/db_dependent/Auth/haspermission.t but we do not want to c/p the previous mock statements
    ok( !$is_allowed, 'DB user should not have any permissions' );

    subtest 'Prevent authentication when sending credential via GET' => sub {

        plan tests => 2;

        my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
        my $password = set_weak_password($patron);
        $cgi = Test::MockObject->new();
        $cgi->mock( 'cookie', sub { return; } );
        $cgi->mock(
            'param',
            sub {
                my ( $self, $param ) = @_;
                if    ( $param eq 'login_userid' )   { return $patron->userid; }
                elsif ( $param eq 'login_password' ) { return $password; }
                else                                 { return; }
            }
        );

        $cgi->mock( 'request_method', sub { return 'POST' } );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        is( $userid, $patron->userid, 'If librarian user is used and password with POST, they should be logged in' );

        $cgi->mock( 'request_method', sub { return 'GET' } );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        is( $userid, undef, 'If librarian user is used and password with GET, they should not be logged in' );
    };

    subtest 'cas_ticket must be empty in session' => sub {

        plan tests => 2;

        my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
        my $password = 'password';
        t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
        $patron->set_password( { password => $password } );
        $cgi = Test::MockObject->new();
        $cgi->mock( 'cookie', sub { return; } );
        $cgi->mock(
            'param',
            sub {
                my ( $self, $param ) = @_;
                if    ( $param eq 'login_userid' )   { return $patron->userid; }
                elsif ( $param eq 'login_password' ) { return $password; }
                else                                 { return; }
            }
        );

        $cgi->mock( 'request_method', sub { return 'POST' } );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        is( $userid, $patron->userid, 'If librarian user is used and password with POST, they should be logged in' );
        my $session = C4::Auth::get_session($sessionID);
        is( $session->param('cas_ticket'), undef );

    };

    subtest 'sessionID should be passed to the template for auth' => sub {

        plan tests => 1;

        subtest 'hit auth.tt' => sub {

            plan tests => 1;

            my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

            my $password = set_weak_password($patron);

            my $cgi_mock = Test::MockModule->new('CGI');
            $cgi_mock->mock( 'request_method', sub { return 'POST' } );
            my $cgi = CGI->new;

            # Simulating the login form submission
            $cgi->param( 'login_userid',   $patron->userid );
            $cgi->param( 'login_password', $password );

            my ( $userid, $cookie, $sessionID, $flags, $template ) =
                C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
            ok( $template->{VARS}->{sessionID} );
        };
    };

    subtest 'Template params tests (password_expired)' => sub {

        plan tests => 1;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $password = set_weak_password($patron);
        $patron->password_expiration_date( dt_from_string->subtract( days => 1 ) )->store;

        my $cgi_mock = Test::MockModule->new('CGI');
        $cgi_mock->mock( 'request_method', sub { return 'POST' } );
        my $cgi = CGI->new;

        # Simulating the login form submission
        $cgi->param( 'login_userid',   $patron->userid );
        $cgi->param( 'login_password', $password );

        my ( $userid, $cookie, $sessionID, $flags, $template ) =
            C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
        is( $template->{VARS}->{password_has_expired}, 1 );
    };

    subtest 'Reset auth state when changing users' => sub {

        #NOTE: It's easiest to detect this when changing to a non-existent user, since
        #that should trigger a redirect to login (instead of returning a session cookie)
        plan tests => 2;
        my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => undef } } );

        my $session = C4::Auth::get_session();
        $session->param( 'number',    $patron->id );
        $session->param( 'id',        $patron->userid );
        $session->param( 'ip',        '1.2.3.4' );
        $session->param( 'lasttime',  time() );
        $session->param( 'interface', 'intranet' );
        $session->flush;
        my $sessionID = $session->id;

        my ($return) =
            C4::Auth::check_cookie_auth( $sessionID, undef, { skip_version_check => 1, remote_addr => '1.2.3.4' } );
        is( $return, 'ok', 'Patron authenticated' );

        my $mock2 = Test::MockModule->new('CGI');
        $mock2->mock( 'request_method', 'POST' );
        $mock2->mock( 'cookie',         sub { return $sessionID; } );    # oversimplified..
        my $cgi = CGI->new;

        $cgi->param( -name => 'login_userid',       -value => 'Bond' );
        $cgi->param( -name => 'login_password',     -value => 'James Bond' );
        $cgi->param( -name => 'koha_login_context', -value => 1 );
        my ( $userid, $cookie, $flags, $template );
        ( $userid, $cookie, $sessionID, $flags, $template ) =
            C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
        is( $template->{VARS}->{loginprompt}, 1, 'Changing to non-existent user causes a redirect to login' );
    };

    subtest 'While still logged in, relogin with another user' => sub {
        plan tests => 5;

        my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => {} } );
        my $patron2 = $builder->build_object( { class => 'Koha::Patrons', value => {} } );

        # Create 'former' session
        my $session = C4::Auth::get_session();
        $session->param( 'number',    $patron->id );
        $session->param( 'id',        $patron->userid );
        $session->param( 'ip',        '1.2.3.4' );
        $session->param( 'lasttime',  time() );
        $session->param( 'interface', 'opac' );
        $session->flush;
        my $previous_sessionID = $session->id;

        my ($return) = C4::Auth::check_cookie_auth(
            $previous_sessionID, undef,
            { skip_version_check => 1, remote_addr => '1.2.3.4' }
        );
        is( $return, 'ok', 'Former session in shape now' );

        my $mock1 = Test::MockModule->new('C4::Auth');
        $mock1->mock( 'safe_exit', sub { } );
        my $mock2 = Test::MockModule->new('CGI');
        $mock2->mock( 'request_method', 'POST' );
        $mock2->mock( 'cookie',         sub { return $previous_sessionID; } );    # oversimplified..
        my $cgi      = CGI->new;
        my $password = 'Incr3d1blyZtr@ng93$';
        $patron2->set_password( { password => $password } );
        $cgi->param( -name => 'login_userid',       -value => $patron2->userid );
        $cgi->param( -name => 'login_password',     -value => $password );
        $cgi->param( -name => 'koha_login_context', -value => 1 );
        my ( $userid, $cookie, $sessionID, $flags, $template ) =
            C4::Auth::checkauth( $cgi, 0, {}, 'opac', undef, undef, { do_not_print => 1 } );
        is( $userid, $patron2->userid, 'Login of patron2 approved' );
        isnt( $sessionID, $previous_sessionID, 'Did not return previous session ID' );
        ok( $sessionID, 'New session ID not empty' );

        # Similar situation: Relogin with former session of $patron, new user $patron2 has no permissions
        $patron2->flags(undef)->store;
        $session->param( 'number',    $patron->id );
        $session->param( 'id',        $patron->userid );
        $session->param( 'interface', 'intranet' );
        $session->flush;
        $previous_sessionID = $session->id;
        $cgi->param( -name => 'login_userid',       -value => $patron2->userid );
        $cgi->param( -name => 'login_password',     -value => $password );
        $cgi->param( -name => 'koha_login_context', -value => 1 );
        ( $userid, $cookie, $sessionID, $flags, $template ) =
            C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
        is( $template->{VARS}->{nopermission}, 1, 'No permission response' );
    };

    subtest 'Two-factor authentication' => sub {
        plan tests => 18;

        t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 0 );

        my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
        my $password = 'password';
        $patron->set_password( { password => $password } );
        $cgi = Test::MockObject->new();

        my $otp_token;
        our ( $logout, $sessionID, $verified );
        $cgi->mock(
            'param',
            sub {
                my ( $self, $param ) = @_;
                if    ( $param eq 'login_userid' )   { return $patron->userid; }
                elsif ( $param eq 'login_password' ) { return $password; }
                elsif ( $param eq 'otp_token' )      { return $otp_token; }
                elsif ( $param eq 'logout.x' )       { return $logout; }
                else                                 { return; }
            }
        );
        $cgi->mock( 'request_method', sub { return 'POST' } );
        $cgi->mock( 'cookie',         sub { return $sessionID } );

        my $two_factor_auth = Test::MockModule->new('Koha::Auth::TwoFactorAuth');
        $two_factor_auth->mock( 'verify', sub { $verified } );

        my ( $userid, $cookie, $flags );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );

        sub logout {
            my $cgi = shift;
            $logout = 1;
            undef $sessionID;
            C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
            $logout = 0;
        }

        t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'disabled' );
        $patron->auth_method('password')->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid,                                                     $patron->userid, 'Succesful login' );
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), undef,           'Second auth not required' );
        logout($cgi);

        $patron->auth_method('two-factor')->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid,                                                     $patron->userid, 'Succesful login' );
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), undef,           'Second auth not required' );
        logout($cgi);

        t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'enabled' );
        t::lib::Mocks::mock_config( 'encryption_key', '1234tH1s=t&st' );
        $patron->auth_method('password')->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid,                                                     $patron->userid, 'Succesful login' );
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), undef,           'Second auth not required' );
        logout($cgi);

        $patron->encode_secret('one_secret');
        $patron->auth_method('two-factor');
        $patron->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid, $patron->userid, 'Succesful login' );
        my $session = C4::Auth::get_session($sessionID);
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), 1, 'Second auth required' );

        # Wrong OTP token
        $otp_token = "wrong";
        $verified  = 0;
        $patron->auth_method('two-factor')->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid, $patron->userid, 'Succesful login' );
        is(
            C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), 1,
            'Second auth still required after wrong OTP token'
        );

        $otp_token = "good";
        $verified  = 1;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid, $patron->userid, 'Succesful login' );
        is(
            C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), 0,
            'Second auth no longer required if OTP token has been verified'
        );
        logout($cgi);

        t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'enforced' );
        $patron->auth_method('password')->store;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'intranet' );
        is( $userid,                                                           $patron->userid, 'Succesful login' );
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA-setup'), 1,               'Setup 2FA required' );
        logout($cgi);

        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired', undef, 'opac' );
        is( $userid, $patron->userid,                                           'Succesful login at the OPAC' );
        is( C4::Auth::get_session($sessionID)->param('waiting-for-2FA'), undef, 'No second auth required at the OPAC' );

        #
        t::lib::Mocks::mock_preference( 'TwoFactorAuthentication', 'disabled' );
        $session = C4::Auth::get_session($sessionID);
        $session->param( 'waiting-for-2FA', 1 );
        $session->flush;
        my ( $auth_status, undef ) = C4::Auth::check_cookie_auth( $sessionID, undef );
        is( $auth_status, 'ok', 'User authenticated, pref was disabled, access OK' );
        $session->param( 'waiting-for-2FA',       0 );
        $session->param( 'waiting-for-2FA-setup', 1 );
        $session->flush;
        ( $auth_status, undef ) = C4::Auth::check_cookie_auth( $sessionID, undef );
        is( $auth_status, 'ok', 'User waiting for 2FA setup, pref was disabled, access OK' );
    };

    subtest 'loggedinlibrary permission tests' => sub {

        plan tests => 3;
        my $staff_user = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 536870916 } } );

        my $branch = $builder->build_object( { class => 'Koha::Libraries' } );

        my $password = set_weak_password($staff_user);
        my $cgi      = Test::MockObject->new();
        $cgi->mock( 'cookie', sub { return; } );
        $cgi->mock(
            'param',
            sub {
                my ( $self, $param ) = @_;
                if    ( $param eq 'login_userid' )   { return $staff_user->userid; }
                elsif ( $param eq 'login_password' ) { return $password; }
                elsif ( $param eq 'branch' )         { return $branch->branchcode; }
                else                                 { return; }
            }
        );

        $cgi->mock( 'request_method', sub { return 'POST' } );
        my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        my $sesh = C4::Auth::get_session($sessionID);
        is(
            $sesh->param('branch'), $branch->branchcode,
            "If user has permission, they should be able to choose a branch"
        );

        $staff_user->flags(4)->store->discard_changes;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        $sesh = C4::Auth::get_session($sessionID);
        is(
            $sesh->param('branch'), $staff_user->branchcode,
            "If user has not permission, they should not be able to choose a branch"
        );

        $staff_user->flags(1)->store->discard_changes;
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 'authrequired' );
        $sesh = C4::Auth::get_session($sessionID);
        is(
            $sesh->param('branch'), $branch->branchcode,
            "If user is superlibrarian, they should be able to choose a branch"
        );

    };
};

subtest 'no_set_userenv parameter tests' => sub {

    plan tests => 7;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    my $password = set_weak_password($patron);

    ok( checkpw( $patron->userid, $password, undef, undef, 1 ), 'checkpw returns true' );
    C4::Context->unset_userenv;
    is( C4::Context->userenv, undef, 'Userenv should be undef as required' );
    C4::Context->set_userenv( 0, 0, 0, 'firstname', 'surname', $library->branchcode, 'Library 1', 0, '', '' );
    is( C4::Context->userenv->{branch}, $library->branchcode, 'Userenv gives correct branch' );
    ok( checkpw( $patron->userid, $password, undef, undef, 1 ), 'checkpw returns true' );
    is( C4::Context->userenv->{branch}, $library->branchcode, 'Userenv branch is preserved if no_set_userenv is true' );
    ok( checkpw( $patron->userid, $password, undef, undef, 0 ), 'checkpw still returns true' );
    isnt(
        C4::Context->userenv->{branch}, $library->branchcode,
        'Userenv branch is overwritten if no_set_userenv is false'
    );
};

subtest 'checkpw lockout tests' => sub {

    plan tests => 5;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $password = set_weak_password($patron);
    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 1 );

    my ( $checkpw, undef, undef ) = checkpw( $patron->cardnumber, $password, undef, undef, 1 );
    ok( $checkpw, 'checkpw returns true with right password when logging in via cardnumber' );
    ( $checkpw, undef, undef ) = checkpw( $patron->userid, "wrong_password", undef, undef, 1 );
    is( $checkpw, 0, 'checkpw returns false when given wrong password' );
    $patron = $patron->get_from_storage;
    is( $patron->account_locked, 1, "Account is locked from failed login" );
    ( $checkpw, undef, undef ) = checkpw( $patron->userid, $password, undef, undef, 1 );
    is( $checkpw, undef, 'checkpw returns undef with right password when account locked' );
    ( $checkpw, undef, undef ) = checkpw( $patron->cardnumber, $password, undef, undef, 1 );
    is( $checkpw, undef, 'checkpw returns undef with right password when logging in via cardnumber if account locked' );

};

# get_template_and_user tests

subtest 'get_template_and_user' => sub {    # Tests for the language URL parameter

    sub MockedCheckauth {
        my ( $query, $authnotrequired, $flagsrequired, $type ) = @_;

        # return vars
        my $userid    = 'cobain';
        my $sessionID = 234;

        # we don't need to bother about permissions for this test
        my $flags = {
            superlibrarian   => 1, acquisition => 0,
            borrowers        => 0,
            catalogue        => 1, circulate       => 0,
            coursereserves   => 0, editauthorities => 0,
            editcatalogue    => 0,
            parameters       => 0, permissions => 0,
            plugins          => 0, reports     => 0,
            reserveforothers => 0, serials     => 0,
            staffaccess      => 0, tools       => 0,
            updatecharges    => 0
        };

        my $session_cookie = $query->cookie(
            -name     => 'CGISESSID',
            -value    => 'nirvana',
            -HttpOnly => 1
        );

        return ( $userid, [$session_cookie], $sessionID, $flags );
    }

    # Mock checkauth, build the scenario
    my $auth = Test::MockModule->new('C4::Auth');
    $auth->mock( 'checkauth', \&MockedCheckauth );

    # Make sure 'EnableOpacSearchHistory' is set
    t::lib::Mocks::mock_preference( 'EnableOpacSearchHistory', 1 );

    # Enable es-ES for the OPAC and staff interfaces
    t::lib::Mocks::mock_preference( 'OPACLanguages',           'en,es-ES' );
    t::lib::Mocks::mock_preference( 'StaffInterfaceLanguages', 'en,es-ES' );

    # we need a session cookie
    $ENV{"SERVER_PORT"} = 80;
    $ENV{"HTTP_COOKIE"} = 'CGISESSID=nirvana';

    my $query = CGI->new;
    $query->param( 'language', 'es-ES' );

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

    ok(
        ( all { ref($_) eq 'CGI::Cookie' } @$cookies ),
        'BZ9735: the cookies array is flat'
    );

    # new query, with non-existent language (we only have en and es-ES)
    $query->param( 'language', 'tomas' );

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

    ok(
        ( none { $_->name eq 'KohaOpacLanguage' and $_->value eq 'tomas' } @$cookies ),
        'BZ9735: invalid language, it is not set'
    );

    ok(
        ( any { $_->name eq 'KohaOpacLanguage' and $_->value eq 'en' } @$cookies ),
        'BZ9735: invalid language, then default to en'
    );

    for my $template_name (
        qw(
        ../../../../../../../../../../../../../../../etc/passwd
        test/../../../../../../../../../../../../../../etc/passwd
        /etc/passwd
        test/does_not_finished_by_tt_t
        )
        )
    {
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
        like( $@, qr(bad template path), "The file $template_name should not be accessible" );
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
    is( $file_exists, 1, 'The file errors/errorpage.tt should be accessible (contains integers)' );

    # Regression test for env opac search limit override
    $ENV{"OPAC_SEARCH_LIMIT"}   = "branch:CPL";
    $ENV{"OPAC_LIMIT_OVERRIDE"} = 1;

    ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => 'opac-main.tt',
            query           => $query,
            type            => 'opac',
            authnotrequired => 1,
        }
    );
    is( $template->{VARS}->{'opac_name'},         "CPL",        "Opac name was set correctly" );
    is( $template->{VARS}->{'opac_search_limit'}, "branch:CPL", "Search limit was set correctly" );

    $ENV{"OPAC_SEARCH_LIMIT"} = "branch:multibranch-19";

    ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name   => 'opac-main.tt',
            query           => $query,
            type            => 'opac',
            authnotrequired => 1,
        }
    );
    is( $template->{VARS}->{'opac_name'},         "multibranch-19",        "Opac name was set correctly" );
    is( $template->{VARS}->{'opac_search_limit'}, "branch:multibranch-19", "Search limit was set correctly" );

    delete $ENV{"HTTP_COOKIE"};
};

# Check that there is always an OPACBaseURL set.
my $input = CGI->new();
my ( $template1, $borrowernumber, $cookie );
( $template1, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-detail.tt",
        type            => "opac",
        query           => $input,
        authnotrequired => 1,
    }
);

ok(
    ( any { 'OPACBaseURL' eq $_ } keys %{ $template1->{VARS} } ),
    'OPACBaseURL is in OPAC template'
);

my ($template2);
( $template2, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/detail.tt",
        type            => "intranet",
        query           => $input,
        authnotrequired => 1,
    }
);

ok(
    ( any { 'OPACBaseURL' eq $_ } keys %{ $template2->{VARS} } ),
    'OPACBaseURL is in Staff template'
);

my $hash1 = hash_password('password');
my $hash2 = hash_password('password');

ok( C4::Auth::checkpw_hash( 'password', $hash1 ), 'password validates with first hash' );
ok( C4::Auth::checkpw_hash( 'password', $hash2 ), 'password validates with second hash' );

subtest 'Check value of login_attempts in checkpw' => sub {
    plan tests => 11;

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 3 );

    # Only interested here in regular login
    $C4::Auth::cas  = 0;
    $C4::Auth::ldap = 0;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron->login_attempts(2);
    $patron->password('123')->store;    # yes, deliberately not hashed

    is( $patron->account_locked, 0, 'Patron not locked' );
    my @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );

    # Note: 123 will not be hashed to 123 !
    is( $test[0], 0, 'checkpw should have failed' );
    $patron->discard_changes;           # refresh
    is( $patron->login_attempts, 3, 'Login attempts increased' );
    is( $patron->account_locked, 1, 'Check locked status' );

    # And another try to go over the limit: different return value!
    @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( @test, 0, 'checkpw failed again and returns nothing now' );
    $patron->discard_changes;           # refresh
    is( $patron->login_attempts, 3, 'Login attempts not increased anymore' );

    # Administrative lockout cannot be undone?
    # Pass the right password now (or: add a nice mock).
    my $auth = Test::MockModule->new('C4::Auth');
    $auth->mock( 'checkpw_hash', sub { return 1; } );    # not for production :)
    $patron->login_attempts(0)->store;
    @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( $test[0], 1, 'Build confidence in the mock' );
    $patron->login_attempts(-1)->store;
    is( $patron->account_locked, 1, 'Check administrative lockout' );
    @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( @test, 0, 'checkpw gave red' );
    $patron->discard_changes;                                       # refresh
    is( $patron->login_attempts, -1, 'Still locked out' );
    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', '' );    # disable
    is( $patron->account_locked, 1, 'Check administrative lockout without pref' );
};

subtest 'Check value of login_attempts in checkpw' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 3 );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron->set_password( { password => '123', skip_validation => 1 } );

    my @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( $test[0], 1, 'Patron authenticated correctly' );

    $patron->password_expiration_date('2020-01-01')->store;
    @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( $test[0], -2, 'Patron returned as expired correctly' );

    ## Make our patron the anonymous patron
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $patron->id );
    @test = checkpw( $patron->userid, '123', undef, 'opac', 1 );
    is( $test[0], -3, 'Patron returned as anonymous patron correctly' );
};

subtest '_timeout_syspref' => sub {

    plan tests => 6;

    t::lib::Mocks::mock_preference( 'timeout', "100" );
    is( C4::Auth::_timeout_syspref, 100, );

    t::lib::Mocks::mock_preference( 'timeout', "2d" );
    is( C4::Auth::_timeout_syspref, 2 * 86400, );

    t::lib::Mocks::mock_preference( 'timeout', "2D" );
    is( C4::Auth::_timeout_syspref, 2 * 86400, );

    t::lib::Mocks::mock_preference( 'timeout', "10h" );
    is( C4::Auth::_timeout_syspref, 10 * 3600, );

    t::lib::Mocks::mock_preference( 'timeout', "10x" );
    warning_is { is( C4::Auth::_timeout_syspref, 600, ); }
    "The value of the system preference 'timeout' is not correct, defaulting to 600",
        'Bad values throw a warning and fallback to 600';
};

subtest 'check_cookie_auth' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'timeout', "1d" );    # back to default

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );

    # Mock a CGI object with real userid param
    my $cgi = Test::MockObject->new();
    $cgi->mock(
        'param',
        sub {
            my $var = shift;
            if ( $var eq 'userid' ) { return $patron->userid; }
        }
    );
    $cgi->mock( 'multi_param',    sub { return q{} } );
    $cgi->mock( 'cookie',         sub { return; } );
    $cgi->mock( 'request_method', sub { return 'POST' } );

    $ENV{REMOTE_ADDR} = '127.0.0.1';

    # Setting authnotrequired=1 or we wont' hit the return but the end of the sub that prints headers
    my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 1 );

    my ( $auth_status, $session ) = C4::Auth::check_cookie_auth($sessionID);
    isnt(
        $auth_status, 'ok',
        'check_cookie_auth should not return ok if the user has not been authenticated before if no permissions needed'
    );
    is(
        $auth_status, 'anon',
        'check_cookie_auth should return anon if the user has not been authenticated before and no permissions needed'
    );

    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 1 );

    ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $sessionID, { catalogue => 1 } );
    isnt(
        $auth_status, 'ok',
        'check_cookie_auth should not return ok if the user has not been authenticated before and permissions needed'
    );
    is(
        $auth_status, 'anon',
        'check_cookie_auth should return anon if the user has not been authenticated before and permissions needed'
    );

    #FIXME We should have a test to cover 'failed' status when a user has logged in, but doesn't have permission
};

subtest 'checkauth & check_cookie_auth' => sub {
    plan tests => 33;

    # flags = 4 => { catalogue => 1 }
    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 4 } } );
    my $password = set_weak_password($patron);

    my $cgi_mock = Test::MockModule->new('CGI');
    $cgi_mock->mock( 'request_method', sub { return 'POST' } );

    my $cgi = CGI->new;

    my $auth = Test::MockModule->new('C4::Auth');

    # Tests will fail if we hit safe_exit
    $auth->mock( 'safe_exit', sub { return } );

    my ( $userid, $cookie, $sessionID, $flags );
    {
        # checkauth will redirect and safe_exit if not authenticated and not authorized
        local *STDOUT;
        my $stdout;
        open STDOUT, '>', \$stdout;
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
        like( $stdout, qr{<title\s*>\s*Log in to your account} );
        $sessionID = ( $stdout =~ m{Set-Cookie: CGISESSID=((\d|\w)+);} ) ? $1 : undef;
        ok($sessionID);
        close STDOUT;
    };

    my $first_sessionID = $sessionID;

    $ENV{"HTTP_COOKIE"} = "CGISESSID=$sessionID";

    # Not authenticated yet, the login form is displayed
    my $template;
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    is( $template->{VARS}->{loginprompt}, 1, );

    # Sending undefined fails obviously
    my ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $sessionID, { catalogue => 1 } );
    is( $auth_status, 'failed' );
    is( $session,     undef );

    # Simulating the login form submission
    $cgi->param( 'login_userid',   $patron->userid );
    $cgi->param( 'login_password', $password );

    # Logged in!
    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
    is( $sessionID, $first_sessionID );
    is( $userid,    $patron->userid );

    ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $sessionID, { catalogue => 1 } );
    is( $auth_status, 'ok' );
    is( $session->id, $first_sessionID );

    my $patron_to_delete = $builder->build_object( { class => 'Koha::Patrons' } );
    my $fresh_userid     = $patron_to_delete->userid;
    $patron_to_delete->delete;
    my $old_userid = $patron->userid;

    # change the current session user's userid
    $patron->userid($fresh_userid)->store;
    ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $sessionID, { catalogue => 1 } );
    is( $auth_status, 'expired' );
    is( $session,     undef );

    # restore userid and generate a new session
    $patron->userid($old_userid)->store;
    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
    is( $sessionID, $first_sessionID );
    is( $userid,    $patron->userid );

    # Logging out!
    $cgi->param( 'logout.x', 1 );
    $cgi->delete( 'login_userid', 'login_password' );
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );

    is( $sessionID, undef );
    is( $ENV{"HTTP_COOKIE"}, "CGISESSID=$first_sessionID", 'HTTP_COOKIE not unset' );
    ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $first_sessionID, { catalogue => 1 } );
    is( $auth_status, "expired" );
    is( $session,     undef );

    {
        # Trying to access without sessionID
        $cgi = CGI->new;
        ( $auth_status, $session ) = C4::Auth::check_cookie_auth( undef, { catalogue => 1 } );
        is( $auth_status, 'failed' );
        is( $session,     undef );

        # This will fail on permissions
        undef $ENV{"HTTP_COOKIE"};
        {
            local *STDOUT;
            my $stdout;
            open STDOUT, '>', \$stdout;
            ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
            close STDOUT;
        }
        is( $userid,    undef );
        is( $sessionID, undef );
    }

    {
        # First logging in
        $cgi = CGI->new;
        $cgi->param( 'login_userid',   $patron->userid );
        $cgi->param( 'login_password', $password );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
        is( $userid, $patron->userid );
        $first_sessionID = $sessionID;

        # Patron does not have the borrowers permission
        # $ENV{"HTTP_COOKIE"} = "CGISESSID=$sessionID"; # not needed, we use $cgi here
        {
            local *STDOUT;
            my $stdout;
            open STDOUT, '>', \$stdout;
            ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { borrowers => 1 } );
            close STDOUT;
        }
        is( $userid,    undef );
        is( $sessionID, undef );

        # When calling check_cookie_auth, the session will be deleted
        ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $first_sessionID, { borrowers => 1 } );
        is( $auth_status, "failed" );
        is( $session,     undef );
        ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $first_sessionID, { borrowers => 1 } );
        is( $auth_status, 'expired', 'Session no longer exists' );

        # NOTE: It is not what the UI is doing.
        # From the UI we are allowed to hit an unauthorized page then reuse the session to hit back authorized area.
        # It is because check_cookie_auth is ALWAYS called from checkauth WITHOUT $flagsrequired
        # It then return "ok", when the previous called got "failed"

        # Try reusing the deleted session: since it does not exist, we should get a new one now when passing correct permissions
        $cgi->cookie( -name => 'CGISESSID', value => $first_sessionID );
        ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 } );
        is( $userid, $patron->userid );
        isnt( $sessionID, undef,            'Check if we have a sessionID' );
        isnt( $sessionID, $first_sessionID, 'New value expected' );
        ( $auth_status, $session ) = C4::Auth::check_cookie_auth( $sessionID, { catalogue => 1 } );
        is( $auth_status, "ok" );
        is( $session->id, $sessionID, 'Same session' );

        # Two additional tests on userenv
        is( C4::Context->userenv->{id}, $userid, 'Check userid in userenv' );
    }
};

subtest 'Userenv clearing in check_cookie_auth' => sub {

    # Note: We did already test userenv for a logged-in user in previous subtest
    plan tests => 8;

    t::lib::Mocks::mock_preference( 'timeout', 600 );
    my $cgi = CGI->new;

    # Create a new anonymous session by passing a fake session ID
    $cgi->cookie( -name => 'CGISESSID', -value => 'fake_sessionID' );
    my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 1 );
    my ( $auth_status, $session ) = C4::Auth::check_cookie_auth($sessionID);
    is( $auth_status,                 'anon', 'Should be anonymous' );
    is( defined C4::Context->userenv, 1,      'There should be a userenv' );
    is( C4::Context->userenv->{id},   q{},    'userid should be empty string' );

    # Make the session expire now, check_cookie_auth will delete it
    $session->param( 'lasttime', time() - 1200 );
    $session->flush;
    ( $auth_status, $session ) = C4::Auth::check_cookie_auth($sessionID);
    is( $auth_status,         'expired', 'Should be expired' );
    is( C4::Context->userenv, undef,     'Environment should be cleared too' );

    # Show that we clear the userenv again: set up env and check deleted session
    C4::Context->set_userenv;    # empty
    is( defined C4::Context->userenv, 1, 'There should be an empty userenv again' );
    ( $auth_status, $session ) = C4::Auth::check_cookie_auth($sessionID);
    is( $auth_status,         'expired', 'Should be expired already' );
    is( C4::Context->userenv, undef,     'Environment should be cleared again' );
};

subtest 'create_basic_session tests' => sub {
    plan tests => 13;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $session = C4::Auth::create_basic_session( { patron => $patron, interface => 'opac' } );

    isnt( $session->id, undef, 'A new sessionID was created' );
    is( $session->param('number'),       $patron->borrowernumber,      'Session parameter number matches' );
    is( $session->param('id'),           $patron->userid,              'Session parameter id matches' );
    is( $session->param('cardnumber'),   $patron->cardnumber,          'Session parameter cardnumber matches' );
    is( $session->param('firstname'),    $patron->firstname,           'Session parameter firstname matches' );
    is( $session->param('surname'),      $patron->surname,             'Session parameter surname matches' );
    is( $session->param('branch'),       $patron->branchcode,          'Session parameter branch matches' );
    is( $session->param('branchname'),   $patron->library->branchname, 'Session parameter branchname matches' );
    is( $session->param('flags'),        $patron->flags,               'Session parameter flags matches' );
    is( $session->param('emailaddress'), $patron->email,               'Session parameter emailaddress matches' );
    is( $session->param('ip'),           $session->remote_addr(),      'Session parameter ip matches' );
    is( $session->param('interface'),    'opac',                       'Session parameter interface matches' );

    $session = C4::Auth::create_basic_session( { patron => $patron, interface => 'staff' } );
    is( $session->param('interface'), 'intranet', 'Staff interface gets converted to intranet' );
};

subtest 'check_cookie_auth overwriting interface already set' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'SessionRestrictionByIP', 0 );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $session = C4::Auth::get_session();
    $session->param( 'number',    $patron->id );
    $session->param( 'id',        $patron->userid );
    $session->param( 'ip',        '1.2.3.4' );
    $session->param( 'lasttime',  time() );
    $session->param( 'interface', 'opac' );
    $session->flush;

    C4::Context->interface('intranet');
    C4::Auth::check_cookie_auth( $session->id );
    is( C4::Context->interface, 'intranet', 'check_cookie_auth did not overwrite' );
    delete $C4::Context::context->{interface};    # clear context interface
    C4::Auth::check_cookie_auth( $session->id );
    is(
        C4::Context->interface, 'opac',
        'check_cookie_auth used interface from session when context interface was empty'
    );

    t::lib::Mocks::mock_preference( 'SessionRestrictionByIP', 1 );
};

$schema->storage->txn_rollback;

subtest 'get_cataloguing_page_permissions() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**2 } } );    # catalogue

    ok(
        !C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        '"catalogue" is not enough to see the cataloguing page'
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->id,
                module_bit     => 24,               # stockrotation
                code           => 'manage_rotas',
            },
        }
    );

    t::lib::Mocks::mock_preference( 'StockRotation', 1 );
    ok(
        C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        '"stockrotation => manage_rotas" is enough'
    );

    t::lib::Mocks::mock_preference( 'StockRotation', 0 );
    ok(
        !C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        '"stockrotation => manage_rotas" is not enough when `StockRotation` is disabled'
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->id,
                module_bit     => 13,                     # tools
                code           => 'manage_staged_marc',
            },
        }
    );

    ok(
        C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        'Having one of the listed `tools` subperm is enough'
    );

    $schema->resultset('UserPermission')->search( { borrowernumber => $patron->id } )->delete;

    ok(
        !C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        'Permission removed, no access'
    );

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->id,
                module_bit     => 9,                    # editcatalogue
                code           => 'delete_all_items',
            },
        }
    );

    ok(
        C4::Auth::haspermission( $patron->userid, get_cataloguing_page_permissions() ),
        'Having any `editcatalogue` subperm is enough'
    );

    $schema->storage->txn_rollback;
};

subtest 'checkpw() return values tests' => sub {

    plan tests => 3;

    subtest 'Internal check tests' => sub {

        plan tests => 29;

        $schema->storage->txn_begin;

        my $account_locked;
        my $password_expired;

        my $mock_patron = Test::MockModule->new('Koha::Patron');
        $mock_patron->mock( 'account_locked',   sub { return $account_locked; } );
        $mock_patron->mock( 'password_expired', sub { return $password_expired; } );

        # Only interested here in regular login
        t::lib::Mocks::mock_config( 'useshibboleth', undef );
        $C4::Auth::cas  = 0;
        $C4::Auth::ldap = 0;

        my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
        my $password = set_weak_password($patron);

        my $patron_to_delete  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $unused_userid     = $patron_to_delete->userid;
        my $unused_cardnumber = $patron_to_delete->cardnumber;
        $patron_to_delete->delete;

        $account_locked = 1;
        my @return = checkpw( $patron->userid, $password, undef, );
        is_deeply( \@return, [], 'If the account is locked, empty list is returned' );

        $account_locked = 0;

        my @matchpoints = qw(userid cardnumber);
        foreach my $matchpoint (@matchpoints) {

            @return = checkpw( $patron->$matchpoint, $password, undef, );

            is( $return[0],        1,                   "Password validation successful returns 1 ($matchpoint)" );
            is( $return[1],        $patron->cardnumber, '`cardnumber` returned' );
            is( $return[2],        $patron->userid,     '`userid` returned' );
            is( ref( $return[3] ), 'Koha::Patron',      'Koha::Patron object reference returned' );
            is( $return[3]->id,    $patron->id,         'Correct patron returned' );
        }

        @return = checkpw( $patron->userid, $password . 'hey', undef, );

        is( scalar @return,    2, "Two results on invalid password scenario" );
        is( $return[0],        0, '0 returned on invalid password' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        $password_expired = 1;
        @return           = checkpw( $patron->userid, $password, undef, );

        is( scalar @return,     2, "Two results on expired password scenario" );
        is( $return[0],        -2, '-2 returned' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        t::lib::Mocks::mock_preference( 'AnonymousPatron', $patron->id );
        @return = checkpw( $patron->userid, $password, undef, );

        is( scalar @return,     2, "Two results on expired password scenario" );
        is( $return[0],        -3, '-3 returned' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        @return = checkpw( $unused_userid, $password, undef, );

        is( scalar @return, 2,     "Two results on non-existing userid scenario" );
        is( $return[0],     0,     '0 returned' );
        is( $return[1],     undef, 'Undef returned, representing no match' );

        @return = checkpw( $unused_cardnumber, $password, undef, );

        is( scalar @return, 2,     "Only one result on non-existing cardnumber scenario" );
        is( $return[0],     0,     '0 returned' );
        is( $return[1],     undef, 'Undef returned, representing no match' );

        $schema->storage->txn_rollback;
    };

    subtest 'CAS check (mocked) tests' => sub {

        plan tests => 29;

        $schema->storage->txn_begin;

        my $account_locked;
        my $password_expired;

        my $mock_patron = Test::MockModule->new('Koha::Patron');
        $mock_patron->mock( 'account_locked',   sub { return $account_locked; } );
        $mock_patron->mock( 'password_expired', sub { return $password_expired; } );

        # Only interested here in regular login
        t::lib::Mocks::mock_config( 'useshibboleth', undef );
        $C4::Auth::cas  = 1;
        $C4::Auth::ldap = 0;

        my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
        my $password = 'thePassword123';
        $patron->set_password( { password => $password, skip_validation => 1 } );

        my $patron_to_delete  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $unused_userid     = $patron_to_delete->userid;
        my $unused_cardnumber = $patron_to_delete->cardnumber;
        $patron_to_delete->delete;

        my $ticket = '123456';
        my $query  = CGI->new;
        $query->param( -name => 'ticket', -value => $ticket );

        my @cas_return = ( 1, $patron->cardnumber, $patron->userid, $ticket, Koha::Patrons->find( $patron->id ) );

        my $cas_mock = Test::MockModule->new('C4::Auth');
        $cas_mock->mock( 'checkpw_cas', sub { return @cas_return; } );

        $account_locked = 1;
        my @return = checkpw( $patron->userid, $password, $query, );
        is_deeply( \@return, [], 'If the account is locked, empty list is returned' );

        $account_locked = 0;

        my @matchpoints = qw(userid cardnumber);
        foreach my $matchpoint (@matchpoints) {

            @return = checkpw( $patron->$matchpoint, $password, $query, );

            is( $return[0],        1,                   "Password validation successful returns 1 ($matchpoint)" );
            is( $return[1],        $patron->cardnumber, '`cardnumber` returned' );
            is( $return[2],        $patron->userid,     '`userid` returned' );
            is( ref( $return[3] ), 'Koha::Patron',      'Koha::Patron object reference returned' );
            is( $return[3]->id,    $patron->id,         'Correct patron returned' );
        }

        @return = checkpw( $patron->userid, $password . 'hey', $query, );

        is( scalar @return,    2, "Two results on invalid password scenario" );
        is( $return[0],        0, '0 returned on invalid password' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        $password_expired = 1;
        @return           = checkpw( $patron->userid, $password, $query, );

        is( scalar @return,     2, "Two results on expired password scenario" );
        is( $return[0],        -2, '-2 returned' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        t::lib::Mocks::mock_preference( 'AnonymousPatron', $patron->id );
        @return = checkpw( $patron->userid, $password, undef, );
        is( scalar @return,     2, "Two results on expired password scenario" );
        is( $return[0],        -3, '-3 returned' );
        is( ref( $return[1] ), 'Koha::Patron' );
        is( $return[1]->id,    $patron->id, 'Patron matched correctly' );

        @return = checkpw( $unused_userid, $password, $query, );

        is( scalar @return, 2,     "Two results on non-existing userid scenario" );
        is( $return[0],     0,     '0 returned' );
        is( $return[1],     undef, 'Undef returned, representing no match' );

        @return = checkpw( $unused_cardnumber, $password, $query, );

        is( scalar @return, 2,     "Only one result on non-existing cardnumber scenario" );
        is( $return[0],     0,     '0 returned' );
        is( $return[1],     undef, 'Undef returned, representing no match' );

        $schema->storage->txn_rollback;
    };

    subtest 'Shibboleth check (mocked) tests' => sub {

        plan tests => 6;

        $schema->storage->txn_begin;

        my $account_locked;
        my $password_expired;

        my $mock_patron = Test::MockModule->new('Koha::Patron');
        $mock_patron->mock( 'account_locked',   sub { return $account_locked; } );
        $mock_patron->mock( 'password_expired', sub { return $password_expired; } );

        # Only interested here in regular login
        t::lib::Mocks::mock_config( 'useshibboleth', 1 );
        $C4::Auth::cas  = 0;
        $C4::Auth::ldap = 0;

        my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
        my $password = 'thePassword123';
        $patron->set_password( { password => $password, skip_validation => 1 } );

        my $patron_to_delete  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $unused_userid     = $patron_to_delete->userid;
        my $unused_cardnumber = $patron_to_delete->cardnumber;
        $patron_to_delete->delete;

        my @shib_return = ( 1, $patron->cardnumber, $patron->userid, Koha::Patrons->find( $patron->id ) );

        my $auth_mock = Test::MockModule->new('C4::Auth');
        $auth_mock->mock( 'shib_ok',        1 );
        $auth_mock->mock( 'get_login_shib', 1 );

        my $shib_mock = Test::MockModule->new('C4::Auth_with_shibboleth');
        $shib_mock->mock( 'checkpw_shib', sub { return @shib_return; } );

        $account_locked = 1;
        my @return = checkpw( $patron->userid );
        is_deeply( \@return, [], 'If the account is locked, empty list is returned' );

        $account_locked = 0;

        @return = checkpw();

        is( $return[0],        1,                   "Password validation successful returns 1" );
        is( $return[1],        $patron->cardnumber, '`cardnumber` returned' );
        is( $return[2],        $patron->userid,     '`userid` returned' );
        is( ref( $return[3] ), 'Koha::Patron',      'Koha::Patron object reference returned' );
        is( $return[3]->id,    $patron->id,         'Correct patron returned' );

        $schema->storage->txn_rollback;
    };
};

subtest 'StaffLoginLibraryBasedOnIP' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 0 );
    t::lib::Mocks::mock_preference( 'StaffLoginLibraryBasedOnIP',    0 );

    my $patron   = $builder->build_object( { class => 'Koha::Patrons',   value => { flags    => 1 } } );
    my $branch   = $builder->build_object( { class => 'Koha::Libraries', value => { branchip => "127.0.0.1" } } );
    my $password = 'password';
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password( { password => $password } );

    my $cgi_mock = Test::MockModule->new('CGI');
    $cgi_mock->mock( 'request_method', sub { return 'POST' } );
    my $cgi  = CGI->new;
    my $auth = Test::MockModule->new('C4::Auth');

    # Simulating the login form submission
    $cgi->param( 'login_userid',   $patron->userid );
    $cgi->param( 'login_password', $password );

    $ENV{REMOTE_ADDR} = '127.0.0.1';
    my ( $userid, $cookie, $sessionID, $flags ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid, $patron->userid, "User successfully logged in" );
    my $session = C4::Auth::get_session($sessionID);
    is( $session->param('branch'), $patron->branchcode, "Logged in branch is set to the patron's branchcode" );

    my $template;
    t::lib::Mocks::mock_preference( 'StaffLoginLibraryBasedOnIP', 1 );

    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid, $patron->userid, "User successfully logged in" );
    $session = C4::Auth::get_session($sessionID);
    is( $session->param('branch'), $branch->branchcode, "Logged in branch is set based on the IP from REMOTE_ADDR " );

    # StaffLoginRestrictLibraryByIP overrides StaffLoginLibraryBasedOnIP
    t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 1 );
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    is(
        $template->{VARS}->{wrongip}, 1,
        "StaffLoginRestrictLibraryByIP prevents StaffLoginLibraryBasedOnIP from logging user in to another branch"
    );

    t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 0 );
    my $other_branch = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => { branchip => "127.0.0.1", branchcode => substr( "z" . $branch->branchcode, 0, 10 ) }
        }
    );
    ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid, $patron->userid, "User successfully logged in" );
    $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $branch->branchcode,
        "Logged in branch is set based which branch when two libraries have same IP?"
    );

};

subtest 'StaffLoginRestrictLibraryByIP' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 0 );

    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'password';
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password( { password => $password } );

    my $cgi_mock = Test::MockModule->new('CGI');
    $cgi_mock->mock( 'request_method', sub { return 'POST' } );
    my $cgi  = CGI->new;
    my $auth = Test::MockModule->new('C4::Auth');

    # Simulating the login form submission
    $cgi->param( 'login_userid',   $patron->userid );
    $cgi->param( 'login_password', $password );

    $ENV{REMOTE_ADDR} = '127.0.0.1';
    my ( $userid, $cookie, $sessionID, $flags ) = C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid, $patron->userid, "Standard login without StaffLoginRestrictLibraryByIP" );

    my $template;
    t::lib::Mocks::mock_preference( 'StaffLoginRestrictLibraryByIP', 1 );

    # StaffLoginRestrictLibraryByIP: "Require staff to log in from a computer in the IP address range specified by their library (if any)"
    $patron->library->branchip('')->store;    # There is none, allow access from anywhere
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid,   $patron->userid, "Login is successful when patron's branch does not have an IP" );
    is( $template, undef,           "Template is undef as none passed and not sent to error page" );

    $patron->library->branchip('1.2.3.4')->store;
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    is(
        $template->{VARS}->{wrongip}, 1,
        "Login denied when no branch specified and IP does not match patron's branch IP"
    );

    $patron->library->branchip('127.0.0.1')->store;
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    is( $userid,   $patron->userid, "Login is successful when patron IP and branch IP match" );
    is( $template, undef,           "Template is undef as none passed and not sent to error page" );

    my $other_library = $builder->build_object( { class => 'Koha::Libraries', value => { branchip => '127.0.0.1' } } );
    $patron->library->branchip('127.0.0.1')->store;
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    my $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $patron->branchcode,
        "If no branch specified, and IP matches patron branch, login is successful at patron branch even if another branch IP matches"
    );

    $cgi->param( 'branch', $other_library->branchcode );
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $other_library->branchcode,
        "StaffLoginRestrictLibraryByIP allows specifying a branch as long as the IP matches"
    );

    $other_library->branchip('129.0.0.1')->store;
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    is( $template->{VARS}->{wrongip}, 1, "Login denied when branch specified and IP does not match branch IP" );

    my $noip_library = $builder->build_object( { class => 'Koha::Libraries', value => { branchip => '' } } );
    $cgi->param( 'branch', $noip_library->branchcode );
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet' );
    $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $noip_library->branchcode,
        "When a branch with no IP set is chosen, we respect the choice regardless of current IP"
    );

    $ENV{REMOTE_ADDR} = '129.0.0.1';          # Set current IP to match other_branch
    $cgi->param( 'branch', '' );              # Do not pass a branch
    $patron->library->branchip('')->store;    # Unset user branch IP, to allow IP matching on any branch
                                              # Add a second branch with same IP
    my $another_library = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => { branchip => "129.0.0.1", branchcode => substr( "z" . $other_library->branchcode, 0, 10 ) }
        }
    );
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $patron->library->branchcode,
        "When user branch has no IP, and no branch chosen, user is logged in to their homebranch"
    );

    $cgi->param( 'branch', $another_library->branchcode )
        ;    # Choose branch with duplicate IP and alphabetically later branchcode
    ( $userid, $cookie, $sessionID, $flags, $template ) =
        C4::Auth::checkauth( $cgi, 0, { catalogue => 1 }, 'intranet', undef, undef, { do_not_print => 1 } );
    $session = C4::Auth::get_session($sessionID);
    is(
        $session->param('branch'), $another_library->branchcode,
        "When there is an IP conflict, we use the chosen branch if it matches"
    );

    $schema->storage->txn_rollback;

};

subtest 'AutoSelfCheckAllowed' => sub {
    plan tests => 5;

    my $query = CGI->new;
    my $auth  = Test::MockModule->new('C4::Auth');
    $auth->mock( 'safe_exit', sub { return } );

    t::lib::Mocks::mock_preference( 'AutoSelfCheckAllowed', 0 );
    C4::Context->unset_userenv();

    # Pref is off, cannot access sco
    {
        # checkauth will redirect and safe_exit if not authenticated and not authorized
        local *STDOUT;
        my $stdout;
        open STDOUT, '>', \$stdout;
        my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
            {
                template_name => "sco/sco-main.tt",
                query         => $query,
                type          => "opac",
                flagsrequired => { self_check => "self_checkout_module" },
            }
        );
        like( $stdout, qr{<title\s*>\s*Log in to your account} );
        close STDOUT;
    };

    # Pref is on from here
    t::lib::Mocks::mock_preference( 'AutoSelfCheckAllowed', 1 );

    t::lib::Mocks::mock_preference( 'AutoSelfCheckID',   '' );
    t::lib::Mocks::mock_preference( 'AutoSelfCheckPass', '' );

    # Credential prefs are empty, cannot access sco
    {
        # checkauth will redirect and safe_exit if not authenticated and not authorized
        local *STDOUT;
        my $stdout;
        open STDOUT, '>', \$stdout;
        my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
            {
                template_name => "sco/sco-main.tt",
                query         => $query,
                type          => "opac",
                flagsrequired => { self_check => "self_checkout_module" },
            }
        );
        like( $stdout, qr{<title\s*>\s*Log in to your account} );
        close STDOUT;
    };

    my $sco_patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $password   = set_weak_password($sco_patron);
    t::lib::Mocks::mock_preference( 'AutoSelfCheckID',   $sco_patron->userid );
    t::lib::Mocks::mock_preference( 'AutoSelfCheckPass', $password );

    # Credential pref are good but patron does not have the self_checkout_module subpermission
    {
        # checkauth will redirect and safe_exit if not authenticated and not authorized
        local *STDOUT;
        my $stdout;
        open STDOUT, '>', \$stdout;
        my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
            {
                template_name => "sco/sco-main.tt",
                query         => $query,
                type          => "opac",
                flagsrequired => { self_check => "self_checkout_module" },
            }
        );
        like( $stdout, qr{<title\s*>\s*Log in to your account} );
        close STDOUT;
    };

    # All good from now
    C4::Context->dbh->do(
        q|
            INSERT INTO user_permissions (borrowernumber, module_bit, code) VALUES (?, ?, ?)
        |, undef, $sco_patron->borrowernumber, 23, 'self_checkout_module'
    );
    my ( $template, $loggedinuser, $cookies ) = get_template_and_user(
        {
            template_name => "sco/sco-main.tt",
            query         => $query,
            type          => "opac",
            flagsrequired => { self_check => "self_checkout_module" },
        }
    );
    is( $template->{VARS}->{logged_in_user}->id, $sco_patron->id );
    is( $loggedinuser,                           $sco_patron->id );
};

subtest 'checkpw for users with shared cardnumber / userid ' => sub {

    plan tests => 8;

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron_1->set_password( { password => "OnePassword" } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons', value => { userid => $patron_1->cardnumber } } );
    $patron_2->set_password( { password => "PasswordTwo" } );

    my ( $checkpw, $cardnumber, $userid, $patron ) = checkpw( $patron_1->cardnumber, "OnePassword", undef, undef, 1 );
    ok( $checkpw, 'checkpw returns true for right password when logging in via cardnumber' );
    is( $cardnumber, $patron_1->cardnumber, 'checkpw returns correct cardnumber' );
    is( $userid,     $patron_1->userid,     'checkpw returns correct userid' );
    is( $patron->id, $patron_1->id,         'checkpw returns correct patron' );

    ( $checkpw, $cardnumber, $userid, $patron ) = checkpw( $patron_2->userid, "PasswordTwo", undef, undef, 1 );
    ok( $checkpw, 'checkpw returns true for right password when logging in via userid' );
    is( $cardnumber, $patron_2->cardnumber, 'checkpw returns correct cardnumber' );
    is( $userid,     $patron_2->userid,     'checkpw returns correct userid' );
    is( $patron->id, $patron_2->id,         'checkpw returns correct patron' );

};

subtest 'DISABLE_SYSPREF permission tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    # Test the permission checking logic directly using haspermission
    my $patron_no_debug =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 4 } } );    # catalogue only
    my $patron_with_debug =
        $builder->build_object( { class => 'Koha::Patrons', value => { flags => 4 } } );    # catalogue only initially
    my $superlibrarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );

    # Add debug permission to second patron by setting the flag directly
    # Debug permission is bit 32, so we set that bit
    my $debug_flag = 1 << 32;
    $patron_with_debug->flags( $patron_with_debug->flags | $debug_flag )->store;

    # Test that our permission check logic works correctly
    ok(
        !haspermission( $patron_no_debug->userid, { debug => 1 } ),
        'Patron without debug permission correctly denied'
    );

    ok(
        haspermission( $patron_with_debug->userid, { debug => 1 } ),
        'Patron with debug permission correctly allowed'
    );

    ok(
        haspermission( $superlibrarian->userid, { debug => 1 } ),
        'Superlibrarian correctly allowed debug permission'
    );

    # Test the actual logic more directly by mocking CGI and checking environment variables
    my $cgi = Test::MockObject->new();
    $cgi->mock(
        'param',
        sub {
            my ( $self, $param ) = @_;
            return 'yes' if $param eq 'DISABLE_SYSPREF_IntranetUserCSS';
            return;
        }
    );

    # Mock userenv for patron without debug permission
    C4::Context->set_userenv(
        $patron_no_debug->borrowernumber,
        $patron_no_debug->userid,
        $patron_no_debug->cardnumber,
        $patron_no_debug->firstname,
        $patron_no_debug->surname,
        $patron_no_debug->branchcode,
        $patron_no_debug->library->branchname,
        $patron_no_debug->flags,
        $patron_no_debug->email // '',
        ''
    );

    # Create mock input for get_template_and_user to trigger our syspref logic
    my $input_mock = { query => $cgi };

    # Simulate the permission check in get_template_and_user
    delete $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"};

    # Test the logic: Should not override for patron without permission
    if ( C4::Context->userenv && haspermission( C4::Context->userenv->{'id'}, { debug => 1 } ) ) {
        $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} = q{} if $cgi->param("DISABLE_SYSPREF_IntranetUserCSS");
    }

    ok(
        !exists $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"},
        'IntranetUserCSS not overridden for patron without debug permission'
    );

    # Now test with patron who has debug permission
    C4::Context->set_userenv(
        $patron_with_debug->borrowernumber,
        $patron_with_debug->userid,
        $patron_with_debug->cardnumber,
        $patron_with_debug->firstname,
        $patron_with_debug->surname,
        $patron_with_debug->branchcode,
        $patron_with_debug->library->branchname,
        $patron_with_debug->flags,
        $patron_with_debug->email // '',
        ''
    );

    delete $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"};

    # Test the logic: Should override for patron with permission
    if ( C4::Context->userenv && haspermission( C4::Context->userenv->{'id'}, { debug => 1 } ) ) {
        $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} = q{} if $cgi->param("DISABLE_SYSPREF_IntranetUserCSS");
    }

    ok(
        exists $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} && $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} eq '',
        'IntranetUserCSS correctly overridden for patron with debug permission'
    );

    # Test superlibrarian
    C4::Context->set_userenv(
        $superlibrarian->borrowernumber,
        $superlibrarian->userid,
        $superlibrarian->cardnumber,
        $superlibrarian->firstname,
        $superlibrarian->surname,
        $superlibrarian->branchcode,
        $superlibrarian->library->branchname,
        $superlibrarian->flags,
        $superlibrarian->email // '',
        ''
    );

    delete $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"};

    # Test the logic: Should override for superlibrarian
    if ( C4::Context->userenv && haspermission( C4::Context->userenv->{'id'}, { debug => 1 } ) ) {
        $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} = q{} if $cgi->param("DISABLE_SYSPREF_IntranetUserCSS");
    }

    ok(
        exists $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} && $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"} eq '',
        'IntranetUserCSS correctly overridden for superlibrarian'
    );

    # Clean up
    delete $ENV{"OVERRIDE_SYSPREF_IntranetUserCSS"};
    C4::Context->unset_userenv();

    $schema->storage->txn_rollback;
};

sub set_weak_password {
    my ($patron) = @_;
    my $password = 'password';
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password( { password => $password } );
    return $password;
}
