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

$| = 1;
use Module::Load::Conditional qw/check_install/;
use Test::More;
use Test::MockModule;
use Test::Warn;

use CGI;
use C4::Context;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 11;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use Test::DBIx::Class { schema_class => 'Koha::Schema', connect_info => ['dbi:SQLite:dbname=:memory:','',''] };

# Mock Variables
my $matchpoint = 'userid';
my %mapping = ( 'userid' => { 'is' => 'uid' }, );
$ENV{'uid'} = "test1234";

# Setup Mocks
## Mock Context
my $context = new Test::MockModule('C4::Context');

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
my $OPACBaseURL = "testopac.com";
$context->mock( 'preference', \&mockedPref );

sub mockedPref {
    my $param = $_[1];
    my $return;

    if ( $param eq 'OPACBaseURL' ) {
        $return = $OPACBaseURL;
    }

    return $return;
}

## Mock Database
my $database = new Test::MockModule('Koha::Database');

### Mock ->schema
$database->mock( 'schema', \&mockedSchema );

sub mockedSchema {
    return Schema();
}

## Convenience method to reset config
sub reset_config {
    $matchpoint = 'userid';
    %mapping    = ( 'userid' => { 'is' => 'uid' }, );
    $ENV{'uid'} = "test1234";

    return 1;
}

# Tests
##############################################################

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

# bad config - with shib_ok implemented, we should never reach this sub with a bad config
};

## checkpw_shib
subtest "checkpw_shib tests" => sub {
    plan tests => 13;

    my $shib_login;
    my ( $retval, $retcard, $retuserid );

    # Setup Mock Database Data
    fixtures_ok [
        'Borrower' => [
            [qw/cardnumber userid surname address city/],
            [qw/testcardnumber test1234 renvoize myaddress johnston/],
        ],
      ],
      'Installed some custom fixtures via the Populate fixture class';

    # debug off
    $C4::Auth_with_shibboleth::debug = '0';

    # good user
    $shib_login = "test1234";
    warnings_are {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $shib_login );
    }
    [], "good user with no debug";
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );

    # bad user
    $shib_login = 'martin';
    warnings_are {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $shib_login );
    }
    [], "bad user with no debug";
    is( $retval, "0", "user not authenticated" );

    # debug on
    $C4::Auth_with_shibboleth::debug = '1';

    # good user
    $shib_login = "test1234";
    warnings_exist {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $shib_login );
    }
    [ qr/checkpw_shib/, qr/koha borrower field to match: userid/,
      qr/shibboleth attribute to match: uid/,
      qr/User Shibboleth-authenticated as:/ ],
      "good user with debug enabled";
    is( $retval,    "1",              "user authenticated" );
    is( $retcard,   "testcardnumber", "expected cardnumber returned" );
    is( $retuserid, "test1234",       "expected userid returned" );

    # bad user
    $shib_login = "martin";
    warnings_exist {
        ( $retval, $retcard, $retuserid ) = checkpw_shib( $shib_login );
    }
    [
        qr/checkpw_shib/,
        qr/koha borrower field to match: userid/,
        qr/shibboleth attribute to match: uid/,
        qr/User Shibboleth-authenticated as:/,
        qr/not a valid Koha user/
    ],
      "bad user with debug enabled";
    is( $retval, "0", "user not authenticated" );

};

## _get_uri
$OPACBaseURL = "testopac.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://testopac.com", "https opac uri returned" );

$OPACBaseURL = "http://testopac.com";
my $result;
warning_like { $result = C4::Auth_with_shibboleth::_get_uri() }
             [ qr/Shibboleth requires OPACBaseURL to use the https protocol!/ ],
             "improper protocol - received expected warning";
is( $result, "https://testopac.com", "https opac uri returned" );

$OPACBaseURL = "https://testopac.com";
is( C4::Auth_with_shibboleth::_get_uri(),
    "https://testopac.com", "https opac uri returned" );

$OPACBaseURL = undef;
warning_like { $result = C4::Auth_with_shibboleth::_get_uri() }
             [ qr/OPACBaseURL not set!/ ],
             "undefined OPACBaseURL - received expected warning";
is( $result, "https://", "https opac uri returned" );

## _get_shib_config
# Internal helper function, covered in tests above
