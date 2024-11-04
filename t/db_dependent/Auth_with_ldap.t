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
use C4::Auth;

use Koha::Patrons;
use Koha::DateUtils qw( dt_from_string );

# Hide all the subrouteine redefined warnings when running this test..
# We reload the ldap module lots in the test and each reload triggers the
# 'Subroutine X redefined at' warning.. disable that to make the test output
# readable.
$SIG{__WARN__} = sub {
    my $warning = shift;
    warn $warning unless $warning =~ /Subroutine .* redefined at/;
};

# Start transaction
my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new();

# Variables controlling LDAP server config
my $update         = 0;
my $replicate      = 0;
my $welcome        = 0;
my $auth_by_bind   = 1;
my $anonymous_bind = 1;
my $user           = 'cn=Manager,dc=metavore,dc=com';
my $pass           = 'metavore';
my $attrs          = {};

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

my $patron = Koha::Patrons->find($borrower->{borrowernumber});

# C4::Auth_with_ldap needs several stuff set first ^^^
use_ok('C4::Auth_with_ldap', qw( checkpw_ldap ));
can_ok(
    'C4::Auth_with_ldap', qw/
      checkpw_ldap
      search_method /
);

subtest 'checkpw_ldap tests' => sub {

    plan tests => 5;

    ## Connection fail tests
    $desired_connection_result = 'error';
    warning_is {
        $ret =
          C4::Auth_with_ldap::checkpw_ldap( 'hola', password => 'hey' );
    }
    'LDAP connexion failed',
      'checkpw_ldap prints correct warning if LDAP conexion fails';
    is( $ret, 0, 'checkpw_ldap returns 0 if LDAP conexion fails' );

    ## Connection success tests
    $desired_connection_result = 'success';

    subtest 'auth_by_bind = 1 tests' => sub {

        plan tests => 15;

        $auth_by_bind = 1;

        $desired_authentication_result = 'success';
        $anonymous_bind                = 1;
        $desired_admin_bind_result   = 'error';
        $desired_search_result         = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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

        C4::Auth_with_ldap::checkpw_ldap( 'hola', password => 'hey' );
        ok(
            Koha::Patrons->find($borrower->{borrowernumber})->extended_attributes->count,
            'Extended attributes are not deleted'
        );

        is( $patron->get_extended_attribute( $attr_type2->{code} )->attribute, 'BAR', 'Mapped attribute is BAR' );
        $auth->unmock('update_local');
        $auth->unmock('ldap_entry_2_hash');

        $update               = 0;
        $desired_count_result = 0;    # user auth problem
        $patron->delete;
        reload_ldap_module();
        is(
            C4::Auth_with_ldap::checkpw_ldap( 'hola', password => 'hey' ),
            0,
            'checkpw_ldap returns 0 if user lookup returns 0'
        );

        # test replicate functionality and welcome notice
        $desired_authentication_result = 'success';
        $anonymous_bind                = 1;
        $desired_admin_bind_result     = 'success';
        $desired_search_result         = 'success';
        $desired_count_result          = 1;
        $desired_bind_result           = 'success';
        $replicate                     = 1;
        $welcome                       = 1;
        reload_ldap_module();

        $auth->mock(
            'ldap_entry_2_hash',
            sub {
                return (
                    userid       => 'hola',
                    branchcode   => $branchcode,
                    categorycode => $categorycode,
                    email        => 'me@myemail.com',
                );
            }
        );

        C4::Auth_with_ldap::checkpw_ldap( 'hola', password => 'hey' );
        my $patrons = Koha::Patrons->search( { userid => 'hola' } );
        is( $patrons->count, 1, 'New patron added with "replicate"' );

        $patron = $patrons->next;
        my $queued_notices = Koha::Notice::Messages->search(
            { borrowernumber => $patron->borrowernumber } );
        is( $queued_notices->count, 1,
            "One notice queued when `welcome` is set" );

        my $THE_notice = $queued_notices->next;
        is( $THE_notice->status, 'failed', "The notice was sent immediately" );

        # clean up
        $patron->delete;
        $replicate = 0;
        $welcome   = 0;

        # replicate testing with checkpw
        my $time_now = dt_from_string()->ymd . ' ' . dt_from_string()->hms;
        C4::Auth::checkpw( 'hola', password => 'hey' );
        my $patron_replicated_from_auth = Koha::Patrons->search( { userid => 'hola' } )->next;
        is(
            $patron_replicated_from_auth->updated_on, $time_now,
            "updated_on correctly saved on newly created user"
        );

        $patron_replicated_from_auth->delete;

        $auth->unmock('ldap_entry_2_hash');
        # end replicate testing

        $desired_count_result = 0;
        $desired_bind_result  = 'error';
        reload_ldap_module();

        warning_like {
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
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
            $ret = C4::Auth_with_ldap::checkpw_ldap( 'hola',
                password => 'hey' );
        }
qr/LDAP Auth rejected : invalid password for user 'hola'./,
          'checkpw_ldap prints correct warning if LDAP bind fails';
        is( $ret, -1, 'checkpw_ldap returns -1 if bind fails (Bug 8148)' );

    };

    subtest "'update' config tets" => sub {

        plan tests => 4;

        $schema->storage->txn_begin;

        my $cardnumber = '123456789';
        my $userid     = '987654321';

        # test safety cleanup
        Koha::Patrons->search( [ { cardnumber => $cardnumber }, { userid => $userid } ] )->delete;

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { cardnumber => $cardnumber, userid => $userid },
            }
        );

        # avoid noise
        t::lib::Mocks::mock_preference( 'ExtendedPatronAttributes', 0 );
        $welcome   = 0;
        $replicate = 0;

        # the scenario
        $update = 1;

        $anonymous_bind                = 0;
        $desired_count_result          = 1;
        $desired_authentication_result = 'success';
        $desired_admin_bind_result     = 'success';
        $desired_search_result         = 'success';
        $desired_bind_result           = 'success';

        $attrs = {
            branch        => [ $patron->branchcode ],
            employeetype  => [ $patron->categorycode ],
            givenname     => [ $patron->firstname ],
            mail          => [ $patron->email ],
            postaladdress => [ $patron->address ],
            sn            => [ $patron->surname ],
            uid           => [ $patron->userid ],
            userpassword  => ['some password'],
        };

        reload_ldap_module();

        my ( $ret_val, $ret_cardnumber, $ret_userid ) =
            C4::Auth_with_ldap::checkpw_ldap( $patron->userid, password => 'hey' );

        ok( $ret_val, 'Authentication success returns 1' );
        is( $ret_cardnumber, $cardnumber, "The correct 'cardnumber' is returned" );
        is( $ret_userid,     $userid,     "The correct 'userid' is returned" );

        $patron->discard_changes;
        is( $patron->cardnumber, $cardnumber, 'The cardnumber is not mistakenly changed to userid when not mapped' );

        $schema->storage->txn_rollback;
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

    if ( $param eq 'useldapserver' ) {
        return 1;
    }
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
            welcome        => $welcome,
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

    return C4::Context::_common_config($param, 'config');
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

    my $mocked_entry = Test::MockObject->new( { attrs => $attrs } );
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

