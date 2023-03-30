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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 1;

use Test::MockModule;
use Test::MockObject;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AuthorisedValueCategories;
use Koha::Illrequests;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 16;

    # Mock Illrequest::Config (as module)
    my $illconfig_module = Test::MockModule->new('Koha::Illrequest::Config');

    # Start with no backends installed
    $illconfig_module->mock( 'available_backends', sub { () } );

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name',         'Mock' );
    $backend->set_always( 'capabilities', sub { return 'bar'; } );
    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                ID    => $rq->illrequest_id,
                Title => $rq->patron->borrowernumber
            };
        }
    );

    #Add a backend-specific status
    $backend->mock(
        'status_graph',
        sub {
            return {
                READY => {
                    prev_actions   => [ 'NEW', 'ERROR' ],
                    id             => 'READY',
                    name           => 'Request ready',
                    ui_method_name => 'Mark request as ready',
                    method         => 'ready',
                    next_actions   => [],
                    ui_method_icon => 'fa-check',
                }
            };
        }
    );

    # Mock Koha::Illrequest::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::Illrequest');
    $illreqmodule->mock( 'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;

    # create an authorized user
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    # create an unauthorized user
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Make sure the ILL_STATUS_ALIAS authorised value category is defined
    unless (
        Koha::AuthorisedValueCategories->search(
            { category_name => 'ILL_STATUS_ALIAS' }
        )->count > 0
      )
    {
        $builder->build_object(
            {
                class => 'Koha::AuthorisedValueCategories',
                value => { category_name => 'ILL_STATUS_ALIAS' }
            }
        );
    }

    my $tag     = "Print copy";
    my $av_code = "print_copy";
    my $av      = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'ILL_STATUS_ALIAS',
                authorised_value => $av_code,
                lib              => $tag,
            }
        }
    );

    # No backends, expect empty
    $t->get_ok("//$userid:$password@/api/v1/ill/backends")->status_is(200)
      ->json_is( [] );

    # Mock one existing backend
    $illconfig_module->mock( 'available_backends', sub { ["Mock"] } );

    #One backend exists, expect that
    $t->get_ok("//$userid:$password@/api/v1/ill/backends")->status_is(200)
      ->json_has( '/0/ill_backend_id', 'Mock' );

    # Prepare status
    my $backend_status = {
        code => "READY",
        str  => "Request ready"
    };
    my $core_status = {
        code => "COMP",
        str  => "Completed"
    };

    my $alias_status = {
        code => $av_code,
        str  => $tag,
    };

    # Create some ILL requests
    my $backend_status_req = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value =>
              { status => $backend_status->{code}, backend => $backend->name }
        }
    );
    my $core_status_req = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value =>
              { status => $core_status->{code}, backend => $backend->name }
        }
    );
    my $alias_status_req = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                status       => $core_status->{code},
                backend      => $backend->name,
                status_alias => $av->authorised_value
            }
        }
    );

    #Check for backend existing statuses
    $t->get_ok("//$userid:$password@/api/v1/ill/backends/Mock/statuses")
      ->status_is(200)
      ->json_is( [ $backend_status, $core_status, $alias_status ] );

    #Check for backend existing statuses of a backend that doesn't exist
    $t->get_ok("//$userid:$password@/api/v1/ill/backends/GhostBackend/statuses")
      ->status_is(200)
      ->json_is( [] );

    # Unauthorized attempt to list
    $t->get_ok("//$unauth_userid:$password@/api/v1/ill/backends")
      ->status_is(403);

    # DELETE method not supported
    $t->delete_ok("//$unauth_userid:$password@/api/v1/ill/backends")
      ->status_is(404);

    $schema->storage->txn_rollback;
};
