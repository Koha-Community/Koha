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
use Test::MockModule;
use Test::MockObject;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::Warn;

use C4::Context;

use Koha::Patrons;

my $dbh = '';

# Start transaction
my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new();

# Variables controlling LDAP server config
my $update         = 0;
my $replicate      = 0;
my $auth_by_bind   = 1;
my $anonymous_bind = 1;
my $user           = 'cn=Manager,dc=metavore,dc=com';
my $pass           = 'metavore';

# Variables controlling LDAP behaviour
my $desired_authentication_result = 'success';
my $desired_connection_result     = 'error';
my $desired_admin_bind_result     = 'error';
my $desired_search_result         = 'error';
my $desired_count_result          = 1;
my $desired_bind_result           = 'error';
my $remaining_entry = 1;
my $ret;

# Mock the context module
my $context = Test::MockModule->new('C4::Context');
$context->mock( 'config', \&mockedC4Config );

# Mock the Net::LDAP module
my $net_ldap = Test::MockModule->new('Net::LDAP');

$net_ldap->mock(
    'new',
    sub {
        if ( $desired_connection_result eq 'error' ) {

            # We were asked to fail the LDAP conexion
            return;
        }
        else {
            # Return a mocked Net::LDAP object (Test::MockObject)
            return mock_net_ldap();
        }
    }
);

my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
my $branchcode   = $builder->build( { source => 'Branch' } )->{branchcode};
my $attr_type    = $builder->build(
    {
        source => 'BorrowerAttributeType',
        value  => {
            category_code => $categorycode
        }
    }
);
my $attr_type2    = $builder->build(
    {
        source => 'BorrowerAttributeType',
        value  => {
            category_code => $categorycode
        }
    }
);

my $borrower = $builder->build(
    {
        source => 'Borrower',
        value  => {
            userid       => 'hola',
            branchcode   => $branchcode,
            categorycode => $categorycode
        }
    }
);

$builder->build(
    {
        source => 'BorrowerAttribute',
        value  => {
            borrowernumber => $borrower->{borrowernumber},
            code           => $attr_type->{code},
            attribute      => 'FOO'
        }
    }
);

# C4::Auth_with_ldap needs several stuff set first ^^^
use_ok('C4::Auth_with_ldap');
can_ok(
    'C4::Auth_with_ldap', qw/
      checkpw_ldap
      search_method /
);

subtest 'checkpw_ldap tests' => sub {

    plan tests => 4;

    my $dbh = C4::Context->dbh;
    ## Connection fail tests
    $desired_connection_result = 'error';
    warning_is {
        $ret =
          C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola', password => 'hey' );
    }
    'LDAP connexion failed',
      'checkpw_ldap prints correct warning if LDAP conexion fails';
    is( $ret, 0, 'checkpw_ldap returns 0 if LDAP conexion fails' );

    ## Connection success tests
    $desired_connection_result = 'success';

    subtest 'auth_by_bind = 1 tests' => sub {

        plan tests => 11;

        $auth_by_bind = 1;

        $desired_authentication_result = 'success';
        $anonymous_bind                = 1;
        $desired_admin_bind_result   = 'error';
        $desired_search_result         = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
        qr/Anonymous LDAP bind failed: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP anonymous bind fails';
        is( $ret, 0, 'checkpw_ldap returns 0 if LDAP anonymous bind fails' );

        $anonymous_bind = 0;
        $user = undef;
        $pass = undef;
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
        qr/LDAP bind failed as kohauser hola: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP bind_by_auth fails';
        is( $ret, 0, 'checkpw_ldap returns 0 if LDAP bind_by_auth fails' );

        $desired_authentication_result = 'success';
        $anonymous_bind                = 1;
        $desired_admin_bind_result   = 'success';
        $desired_search_result         = 'success';
        $desired_count_result          = 1;
        $desired_bind_result = 'success';
        $update                        = 1;
        reload_ldap_module();

        t::lib::Mocks::mock_preference( 'ExtendedPatronAttributes', 1 );
        my $auth = Test::MockModule->new('C4::Auth_with_ldap');
        $auth->mock(
            'update_local',
            sub {
                return $borrower->{cardnumber};
            }
        );
        $auth->mock(
            'ldap_entry_2_hash',
            sub {
                return (
                    $attr_type2->{code}, 'BAR'
                );
            }
        );

        C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola', password => 'hey' );
        ok(
            @{
                C4::Members::Attributes::GetBorrowerAttributes(
                    $borrower->{borrowernumber}
                )
            },
            'Extended attributes are not deleted'
        );

        is( C4::Members::Attributes::GetBorrowerAttributeValue($borrower->{borrowernumber}, $attr_type2->{code}), 'BAR', 'Mapped attribute is BAR' );
        $auth->unmock('update_local');
        $auth->unmock('ldap_entry_2_hash');

        $update               = 0;
        $desired_count_result = 0;    # user auth problem
        Koha::Patrons->find( $borrower->{borrowernumber} )->delete;
        reload_ldap_module();
        is(
            C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola', password => 'hey' ),
            0,
            'checkpw_ldap returns 0 if user lookup returns 0'
        );

        $desired_bind_result = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
        qr/LDAP bind failed as kohauser hola: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, -1,
            'checkpw_ldap returns -1 LDAP bind fails for user (Bug 8148)' );

        # regression tests for bug 12831
        $desired_authentication_result = 'error';
        $anonymous_bind                = 0;
        $desired_admin_bind_result   = 'error';
        $desired_search_result         = 'success';
        $desired_count_result          = 0;           # user auth problem
        $desired_bind_result = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
        qr/LDAP bind failed as kohauser hola: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, 0,
            'checkpw_ldap returns 0 LDAP bind fails for user (Bug 12831)' );

    };

    subtest 'auth_by_bind = 0 tests' => sub {

        plan tests => 8;

        $auth_by_bind = 0;

        # Anonymous bind
        $anonymous_bind            = 1;
        $user                      = 'cn=Manager,dc=metavore,dc=com';
        $pass                      = 'metavore';
        $desired_admin_bind_result = 'error';
        $desired_bind_result       = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
qr/LDAP bind failed as ldapuser cn=Manager,dc=metavore,dc=com: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, 0, 'checkpw_ldap returns 0 if bind fails' );

        $anonymous_bind            = 1;
        $desired_admin_bind_result = 'success';
        $desired_bind_result = 'error';
        $desired_search_result = 'success';
        $desired_count_result = 1;
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
qr/LDAP Auth rejected : invalid password for user 'hola'./,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, -1, 'checkpw_ldap returns -1 if bind fails (Bug 8148)' );

        # Non-anonymous bind
        $anonymous_bind            = 0;
        $desired_admin_bind_result = 'error';
        $desired_bind_result = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
qr/LDAP bind failed as ldapuser cn=Manager,dc=metavore,dc=com: LDAP error #1: error_name/,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, 0, 'checkpw_ldap returns 0 if bind fails' );

        $anonymous_bind            = 0;
        $desired_admin_bind_result = 'success';
        $desired_bind_result = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( $dbh, 'hola',
                password => 'hey' );
        }
qr/LDAP Auth rejected : invalid password for user 'hola'./,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, -1, 'checkpw_ldap returns -1 if bind fails (Bug 8148)' );

    };
};

subtest 'search_method tests' => sub {

    plan tests => 3;

    my $ldap = mock_net_ldap();

    # Null params tests
    is( C4::Auth_with_ldap::search_method( $ldap, undef ),
        undef, 'search_method returns undef on undefined userid' );
    is( C4::Auth_with_ldap::search_method( undef, 'undef' ),
        undef, 'search_method returns undef on undefined ldap object' );

    # search ->code and !->code
    $desired_search_result = 'error';
    reload_ldap_module();
    my $eval_retval =
      eval { $ret = C4::Auth_with_ldap::search_method( $ldap, 'undef' ); };
    like(
        $@,
        qr/LDAP search failed to return object : 1/,
'search_method prints correct warning when db->search returns error code'
    );
};

# Function that mocks the call to C4::Context->config(param)
sub mockedC4Config {
    my $class = shift;
    my $param = shift;

    if ( $param eq 'useshibboleth' ) {
        return 0;
    }
    if ( $param eq 'ldapserver' ) {
        my %ldap_mapping = (
            firstname    => { is => 'givenname' },
            surname      => { is => 'sn' },
            address      => { is => 'postaladdress' },
            city         => { is => 'l' },
            zipcode      => { is => 'postalcode' },
            branchcode   => { is => 'branch' },
            userid       => { is => 'uid' },
            password     => { is => 'userpassword' },
            email        => { is => 'mail' },
            categorycode => { is => 'employeetype' },
            phone        => { is => 'telephonenumber' },
        );

        my %ldap_config = (
            anonymous_bind => $anonymous_bind,
            auth_by_bind   => $auth_by_bind,
            base           => 'dc=metavore,dc=com',
            hostname       => 'localhost',
            mapping        => \%ldap_mapping,
            pass           => $pass,
            principal_name => '%s@my_domain.com',
            replicate      => $replicate,
            update         => $update,
            user           => $user,
        );
        return \%ldap_config;
    }
    if ( $param =~ /(intranetdir|opachtdocs|intrahtdocs)/x ) {
        return q{};
    }
    if ( ref $class eq 'HASH' ) {
        return $class->{$param};
    }
    return;
}

# Function that mocks the call to Net::LDAP
sub mock_net_ldap {

    my $mocked_ldap = Test::MockObject->new();

    $mocked_ldap->mock( 'bind', sub {
        if (is_admin_bind(@_)) {
            return mock_net_ldap_message(
                ($desired_admin_bind_result eq 'error' ) ? 1 : 0, # code
                ($desired_admin_bind_result eq 'error' ) ? 1 : 0, # error
                ($desired_admin_bind_result eq 'error' ) ? 'error_name' : 0, # error_name
                ($desired_admin_bind_result eq 'error' ) ? 'error_text' : 0  # error_text
            );
        }
        else {
            if ( $desired_bind_result eq 'error' ) {
                return mock_net_ldap_message(1,1,'error_name','error_text');
            }
            return mock_net_ldap_message(0,0,'','');
        }
    });

    $mocked_ldap->mock(
        'search',
        sub {

            $remaining_entry = 1;

            return mock_net_ldap_search(
                {
                    count => ($desired_count_result)
                    ? $desired_count_result
                    : 1,    # default to 1
                    code => ( $desired_search_result eq 'error' )
                    ? 1
                    : 0,    # 0 == success
                    error => ( $desired_search_result eq 'error' ) ? 1
                    : 0,
                    error_text => ( $desired_search_result eq 'error' )
                    ? 'error_text'
                    : undef,
                    error_name => ( $desired_search_result eq 'error' )
                    ? 'error_name'
                    : undef,
                    shift_entry => mock_net_ldap_entry( 'sampledn', 1 )
                }
            );

        }
    );

    return $mocked_ldap;
}

sub mock_net_ldap_search {
    my ($parameters) = @_;

    my $count       = $parameters->{count};
    my $code        = $parameters->{code};
    my $error       = $parameters->{error};
    my $error_text  = $parameters->{error_text};
    my $error_name  = $parameters->{error_name};
    my $shift_entry = $parameters->{shift_entry};

    my $mocked_search = Test::MockObject->new();
    $mocked_search->mock( 'count',       sub { return $count; } );
    $mocked_search->mock( 'code',        sub { return $code; } );
    $mocked_search->mock( 'error',       sub { return $error; } );
    $mocked_search->mock( 'error_name',  sub { return $error_name; } );
    $mocked_search->mock( 'error_text',  sub { return $error_text; } );
    $mocked_search->mock( 'shift_entry', sub {
        if ($remaining_entry) {
            $remaining_entry--;
            return $shift_entry;
        }
        return '';
    });

    return $mocked_search;
}

sub mock_net_ldap_message {
    my ( $code, $error, $error_name, $error_text ) = @_;

    my $mocked_message = Test::MockObject->new();
    $mocked_message->mock( 'code',       sub { $code } );
    $mocked_message->mock( 'error',      sub { $error } );
    $mocked_message->mock( 'error_name', sub { $error_name } );
    $mocked_message->mock( 'error_text', sub { $error_text } );

    return $mocked_message;
}

sub mock_net_ldap_entry {
    my ( $dn, $exists ) = @_;

    my $mocked_entry = Test::MockObject->new();
    $mocked_entry->mock( 'dn',     sub { return $dn; } );
    $mocked_entry->mock( 'exists', sub { return $exists } );

    return $mocked_entry;
}

# TODO: Once we remove the global variables in C4::Auth_with_ldap
# we shouldn't need this...
# ... Horrible hack
sub reload_ldap_module {
    delete $INC{'C4/Auth_with_ldap.pm'};
    require C4::Auth_with_ldap;
    C4::Auth_with_ldap->import;
    return;
}

sub is_admin_bind {
    my @args = @_;

    if ($#args <= 1 || $args[1] eq 'cn=Manager,dc=metavore,dc=com') {
        return 1;
    }

    return 0;
}

$schema->storage->txn_rollback();

