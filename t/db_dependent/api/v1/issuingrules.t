#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 1;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;

use Koha::Auth::PermissionManager;
use Koha::Database;
use Koha::IssuingRules;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'get_effective() tests' => sub {

    plan tests => 27;

    $schema->storage->txn_begin;

    # Empty current issuign rules and create two random issuing rules
    Koha::IssuingRules->search->delete;

    my $context1 = create_test_context();
    my $context2 = create_test_context();
    my $context3 = create_test_context();

    create_issuing_rule({
        categorycode => '*',
        itemtype => '*',
        branchcode => '*'
    });
    create_issuing_rule();
    create_issuing_rule();
    create_issuing_rule({
        categorycode => $context1->{patron}->{categorycode},
        itemtype => $context1->{item}->{itype},
        branchcode => '*'
    });
    create_issuing_rule({
        categorycode => $context2->{patron}->{categorycode},
        itemtype => $context2->{item}->{itype},
        branchcode => $context2->{patron}->{branchcode}
    });
    create_issuing_rule({
        categorycode => $context3->{patron}->{categorycode},
        itemtype => $context3->{item}->{itype},
        branchcode => $context3->{item}->{homebranch}
    });
    create_issuing_rule({
        categorycode => $context3->{patron}->{categorycode},
        itemtype => $context3->{item}->{itype},
        branchcode => $context3->{item}->{holdingbranch}
    });
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 0 } );

    my $tx = $t->ua->build_tx( GET => '/api/v1/issuingrules/effective' );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(401);

    $tx = $t->ua->build_tx( GET => '/api/v1/issuingrules/effective' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $path = '/api/v1/issuingrules/effective';
    my $params = {};

    $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/branchcode' => '*')
      ->json_is('/categorycode' => '*')
      ->json_is('/itemtype' => '*');

    $params = {
        branchcode => '',
        categorycode => '',
        itemtype => ''
    };
    $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/branchcode' => '*')
      ->json_is('/categorycode' => '*')
      ->json_is('/itemtype' => '*');

    $params = { itemtype => $context1->{item}->{itype} };
    $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/branchcode' => '*')
      ->json_is('/categorycode' => '*')
      ->json_is('/itemtype' => '*');

    $params = {
        categorycode => $context1->{patron}->{categorycode},
        itemtype => $context1->{item}->{itype}
    };
    $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/branchcode' => '*')
      ->json_is('/categorycode' => $context1->{patron}->{categorycode})
      ->json_is('/itemtype' => $context1->{item}->{itype});

    subtest 'CircControl = ItemHomeLibrary' => sub {
        plan tests => 15;

        t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
        t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'homebranch');

        create_issuing_rule({
            categorycode => $context3->{patron}->{categorycode},
            itemtype => $context3->{item}->{itype},
            branchcode => '*'
        });

        $params = {
            cardnumber => $context3->{patron}->{cardnumber},
            barcode => $context3->{item}->{barcode}
        };
        # Test exact match, item's homebranch
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => $context3->{item}->{homebranch})
          ->json_is('/categorycode' => $context3->{patron}->{categorycode})
          ->json_is('/itemtype' => $context3->{item}->{itype});

        t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'holdingbranch');
        $params = {
            cardnumber => $context3->{patron}->{cardnumber},
            barcode => $context3->{item}->{barcode}
        };
        # Test exact match, holdingbranch
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => $context3->{item}->{holdingbranch})
          ->json_is('/categorycode' => $context3->{patron}->{categorycode})
          ->json_is('/itemtype' => $context3->{item}->{itype});

        # Test custom branch
        $params->{'branchcode'} = $context2->{patron}->{branchcode};
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => '*')
          ->json_is('/categorycode' => $context3->{patron}->{categorycode})
          ->json_is('/itemtype' => $context3->{item}->{itype});
    };

    subtest 'CircControl = PatronLibrary' => sub {
        plan tests => 10;

        t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');
        create_issuing_rule({
            categorycode => $context2->{patron}->{categorycode},
            itemtype => $context2->{item}->{itype},
            branchcode => '*'
        });
        $params = {
            itemnumber => $context2->{item}->{itemnumber},
            borrowernumber => $context2->{patron}->{borrowernumber}
        };
        # Test exact match
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => $context2->{patron}->{branchcode})
          ->json_is('/categorycode' => $context2->{patron}->{categorycode})
          ->json_is('/itemtype' => $context2->{item}->{itype});

        # Test custom branchcode
        $params->{'branchcode'} = $context3->{patron}->{branchcode};
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => '*')
          ->json_is('/categorycode' => $context2->{patron}->{categorycode})
          ->json_is('/itemtype' => $context2->{item}->{itype});
    };

    subtest 'CircControl = PickupLibrary' => sub {
        plan tests => 15;

        t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');
        my $patron = Koha::Patrons->find($borrowernumber);
        create_issuing_rule({
            categorycode => $context2->{patron}->{categorycode},
            itemtype => $context2->{item}->{itype},
            branchcode => $patron->branchcode
        });
        $params = {
            cardnumber => $context2->{patron}->{cardnumber},
            barcode => $context2->{item}->{barcode}
        };
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => $patron->branchcode)
          ->json_is('/categorycode' => $context2->{patron}->{categorycode})
          ->json_is('/itemtype' => $context2->{item}->{itype});

        $params = {
            cardnumber => $context2->{patron}->{cardnumber},
            barcode => $context2->{item}->{barcode},
            branchcode => '',
        };
        # Test all branches
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => '*')
          ->json_is('/categorycode' => $context2->{patron}->{categorycode})
          ->json_is('/itemtype' => $context2->{item}->{itype});

        # Test another branch, should still return rule for all branches because
        # there is no exact match to that branchcode
        $params->{branchcode} = $context1->{patron}->{branchcode};
        $tx = $t->ua->build_tx( GET => _query_params($path, $params) );
        $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/branchcode' => '*')
          ->json_is('/categorycode' => $context2->{patron}->{categorycode})
          ->json_is('/itemtype' => $context2->{item}->{itype});
    };

    $schema->storage->txn_rollback;
};

sub create_test_context {
    my $itemtype = $builder->build({ source => 'Itemtype'});
    my $library = $builder->build({ source => 'Branch' });
    my $library2 = $builder->build({ source => 'Branch' });
    my $biblio = $builder->build({ source => 'Biblio' });
    my $biblioitem = $builder->build({
        source => 'Biblioitem',
        value => {
            biblionumber => $biblio->{biblionumber},
            itemtype => $itemtype->{itemtype},
        }
    });
    my $item = $builder->build({
        source => 'Item',
        value => {
            biblionumber => $biblio->{biblionumber},
            biblioitemnumber => $biblioitem->{biblioitemnumber},
            itype => $itemtype->{itemtype},
            homebranch => $library->{branchcode},
            holdingbranch => $library2->{branchcode},
        }
    });
    my $category = $builder->build({ source => 'Category' });
    my $patron = $builder->build({
        source => 'Borrower',
        value => {
            categorycode => $category->{categorycode}
        }
    });

    return {
        biblio => $biblio,
        biblioitem => $biblioitem,
        category => $category,
        item => $item,
        itemtype => $itemtype,
        library => $library,
        library_two => $library2,
        patron => $patron,
    };
}

sub create_issuing_rule {
    my ($params) = @_;

    $params->{categorycode} ||= '*';
    $params->{itemtype} ||= '*';
    $params->{branchcode} ||= '*';
    $params->{ccode} ||= '*';
    $params->{permanent_location} ||= '*';
    $params->{sub_location} ||= '*';
    $params->{genre} ||= '*';
    $params->{circulation_level} ||= '*';
    $params->{reserve_level} ||= '*';

    my $rule = $builder->build({
        source => 'Issuingrule',
        value => $params
    });

    return $rule;
}
sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                lost  => 0,
            }
        }
    );

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    if ( $args->{authorized} ) {
        my $patron = Koha::Patrons->find($user->{borrowernumber});
        Koha::Auth::PermissionManager->grantPermission($patron, 'parameters',
                                        'parameters_remaining_permissions');
    }

    return ( $user->{borrowernumber}, $session->id );
}

sub _query_params {
    my ($path, $params) = @_;

    $path .= '?';
    foreach my $param (keys %$params) {
        $path .= $param.'='.$params->{$param}.'&';
    }
    $path =~ s/\&$//;
    return $path;
}
1;
