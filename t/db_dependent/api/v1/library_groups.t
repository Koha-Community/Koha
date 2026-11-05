#!/usr/bin/env perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 3;
use Test::Mojo;
use Mojo::JSON qw( encode_json false true );
use Mojo::Parameters;
use Test::Warn;
use Test::NoWarnings;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Library::Groups;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $root_group1 = Koha::Library::Group->new(
        {
            title => "LibGroup1",
        }
    )->store();

    my $lg1groupA =
        Koha::Library::Group->new( { parent_id => $root_group1->id, title => 'LibGroup1 SubGroupA' } )->store();
    my $lg1groupA1 =
        Koha::Library::Group->new( { parent_id => $lg1groupA->id, title => 'LibGroup1 SubGroupA SubGroup1' } )->store();
    my $lg1groupA2 =
        Koha::Library::Group->new( { parent_id => $lg1groupA->id, title => 'LibGroup1 SubGroupA SubGroup2' } )->store();
    my $lg1groupB =
        Koha::Library::Group->new( { parent_id => $root_group1->id, title => 'LibGroup1 SubGroupB' } )->store();

    ## Unauthorized user tests
    # catalogue permission is not enough, manage_libraries is required (as in admin/library_groups.pl)
    $t->get_ok("//$unauth_userid:$password@/api/v1/library_groups")->status_is(403);

    ## Authorized user tests
    # Make sure we are returned with the correct amount of libraries
    $t->get_ok("//$userid:$password@/api/v1/library_groups")->status_is( 200, 'SWAGGER3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };
    my $expected_count = Koha::Library::Groups->count;
    is( $response_count, $expected_count, 'Results count is as expected' );

    $schema->storage->txn_rollback;
};

subtest 'list() q filter tests' => sub {
    my %flags = (
        hide_patron_info               => 'ft_hide_patron_info',
        limit_item_editing             => 'ft_limit_item_editing',
        limit_report_access            => 'ft_reports',
        is_opac_search_group           => 'ft_search_groups_opac',
        is_staff_search_group          => 'ft_search_groups_staff',
        is_local_hold_group            => 'ft_local_hold_group',
        is_local_float_group           => 'ft_local_float_group',
        is_record_source_editing_group => 'ft_record_source_editing',
    );

    plan tests => 3 * 2 * scalar( keys %flags ) + 3;

    $schema->storage->txn_begin;

    my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $search = sub {
        my ($query) = @_;
        my $q = Mojo::Parameters->new( q => encode_json($query) )->to_string;
        $t->get_ok("//$userid:$password@/api/v1/library_groups?$q")->status_is(200);
        return [ map { $_->{title} } @{ $t->tx->res->json // [] } ];
    };

    # The attributes are filtered with q, including the booleans: the values read back from the
    # API (true and false) can be used as they are
    foreach my $api_name ( sort keys %flags ) {
        my $column = $flags{$api_name};

        Koha::Library::Groups->search->delete;
        Koha::Library::Group->new( { title => 'on',  $column => 1 } )->store;
        Koha::Library::Group->new( { title => 'off', $column => 0 } )->store;

        is_deeply( $search->( { $api_name => true } ),  ['on'],  "q $api_name true lists the 'on' group" );
        is_deeply( $search->( { $api_name => false } ), ['off'], "q $api_name false lists the 'off' group" );
    }

    $t->get_ok("//$userid:$password@/api/v1/library_groups?_per_page=1")->status_is(200);
    is( scalar @{ $t->tx->res->json }, 1, '_per_page is honoured' );

    $schema->storage->txn_rollback;
};
