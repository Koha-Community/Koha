#!/usr/bin/perl
#
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 6;
use Test::MockModule;
use Test::Warn;
use DBD::Mock;

use CGI;
use C4::Context;

# Mock Variables
my $matchpoint = 'userid';
my %mapping = ( 'userid' => { 'is' => 'uid' }, );
$ENV{'uid'} = "test1234";

#my %shibboleth = (
#    'matchpoint' => $matchpoint,
#    'mapping'    => \%mapping
#);

# Setup Mocks
## Mock Context
my $context = new Test::MockModule('C4::Context');

### Mock ->dbh
$context->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);

### Mock ->config
$context->mock( 'config', \&mockedConfig );

sub mockedConfig {
    my $param = shift;

    my %shibboleth = (
        'matchpoint' => $matchpoint,
        'mapping'    => \%mapping
    );

    return \%shibboleth;
}

### Mock ->preference
$context->mock( 'preference', \&mockedPref );

sub mockedPref {
    my $param = $_[1];
    my $return;

    if ( $param eq 'OPACBaseURL' ) {
        $return = "testopac.com";
    }

    return $return;
}

# Convenience methods
## Reset Context
sub reset_config {
    $matchpoint = 'userid';
    %mapping    = ( 'userid' => { 'is' => 'uid' }, );
    $ENV{'uid'} = "test1234";

    return 1;
}

# Tests
my $dbh = C4::Context->dbh();

# Can module load
use_ok('C4::Auth_with_shibboleth');
$C4::Auth_with_shibboleth::debug = '0';

# Subroutine tests
## shib_ok
subtest "shib_ok tests" => sub {
    plan tests => 5;
    my $result;

    # correct config, no debug
    is( shib_ok(), '1', "good config" );

    # bad config, no debug
    $matchpoint = undef;
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not defined' }, ],
      "undefined matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    $matchpoint = 'email';
    warnings_are { $result = shib_ok() }
    [ { carped => 'shibboleth matchpoint not mapped' }, ],
      "unmapped matchpoint = fatal config, warning given";
    is( $result, '0', "bad config" );

    # add test for undefined shibboleth block

    reset_config();
};

## logout_shib
#my $query = CGI->new();
#is(logout_shib($query),"https://".$opac."/Shibboleth.sso/Logout?return="."https://".$opac,"logout_shib");

## login_shib_url
my $query_string = 'language=en-GB';
$ENV{QUERY_STRING} = $query_string;
$ENV{SCRIPT_NAME}  = '/cgi-bin/koha/opac-user.pl';
my $query = CGI->new($query_string);
is(
    login_shib_url($query),
    'https://testopac.com'
      . '/Shibboleth.sso/Login?target='
      . 'https://testopac.com/cgi-bin/koha/opac-user.pl' . '%3F'
      . $query_string,
    "login shib url"
);

## get_login_shib
subtest "get_login_shib tests" => sub {
    plan tests => 4;
    my $login;

    # good config
    ## debug off
    $C4::Auth_with_shibboleth::debug = '0';
    warnings_are { $login = get_login_shib() }[],
      "good config with debug off, no warnings recieved";
    is( $login, "test1234",
        "good config with debug off, attribute value returned" );

    ## debug on
    $C4::Auth_with_shibboleth::debug = '1';
    warnings_are { $login = get_login_shib() }[
        "koha borrower field to match: userid",
        "shibboleth attribute to match: uid",
        "uid value: test1234"
    ],
      "good config with debug enabled, correct warnings recieved";
    is( $login, "test1234",
        "good config with debug enabled, attribute value returned" );

# bad config - with shib_ok implimented, we should never reach this sub with a bad config
};

## checkpw_shib
subtest "checkpw_shib tests" => sub {
    plan tests => 12;

    my $shib_login = 'test1234';
    my @borrower_results =
      ( [ 'cardnumber', 'userid' ], [ 'testcardnumber', 'test1234' ], );
    $dbh->{mock_add_resultset} = \@borrower_results;

    my ( $retval, $retcard, $retuserid );

    # debug off
    $C4::Auth_with_shibboleth::debug = '0';

    # good user
    warnings_are {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $dbh, $shib_login );
    }
    [], "good user with no debug";
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );

    # bad user
    warnings_are {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $dbh, $shib_login );
    }
    [], "bad user with no debug";
    is( $retval, "0", "user not authenticated" );

    # reset db mock
    $dbh->{mock_add_resultset} = \@borrower_results;

    # debug on
    $C4::Auth_with_shibboleth::debug = '1';

    # good user
    warnings_exist {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $dbh, $shib_login );
    }
    [ qr/checkpw_shib/, qr/User Shibboleth-authenticated as:/ ],
      "good user with debug enabled";
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );

    # bad user
    warnings_exist {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $dbh, $shib_login );
    }
    [
        qr/checkpw_shib/,
        qr/User Shibboleth-authenticated as:/,
        qr/not a valid Koha user/
    ],
      "bad user with debug enabled";
    is( $retval, "0", "user not authenticated" );

};

## _get_uri
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://testopac.com", "https opac uri returned" );

## _get_shib_config
