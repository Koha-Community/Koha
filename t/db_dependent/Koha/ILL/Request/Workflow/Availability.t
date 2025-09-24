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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;

use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ILL::Request::Workflow::Availability;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

use_ok('Koha::ILL::Request::Workflow::Availability');

my $metadata = {
    title  => 'This is a title',
    author => 'This is an author'
};

# Because hashes can reorder themselves, we need to make sure ours is in a
# predictable order
my $sorted = {};
foreach my $key ( keys %{$metadata} ) {
    $sorted->{$key} = $metadata->{$key};
}

my $availability = Koha::ILL::Request::Workflow::Availability->new( $sorted, 'staff' );

isa_ok( $availability, 'Koha::ILL::Request::Workflow::Availability' );

is(
    $availability->prep_metadata($sorted),
    'eyJhdXRob3IiOiJUaGlzIGlzIGFuIGF1dGhvciIsInRpdGxlIjoiVGhpcyBpcyBhIHRpdGxlIn0%3D%0A',
    'prep_metadata works'
);

# Mock ILLBackend (as object)
my $backend = Test::MockObject->new;
$backend->set_isa('Koha::Illbackends::Mock');
$backend->set_always( 'name',         'Mock' );
$backend->set_always( 'capabilities', sub { return can_create_request => 1 } );
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
$backend->mock( 'status_graph', sub { }, );

# Mock Koha::ILL::Request::load_backend (to load Mocked Backend)
my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
$illreqmodule->mock(
    'load_backend',
    sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
);

# Mock ILLModuleDisclaimerByType with valid YAML
t::lib::Mocks::mock_preference( 'ILLCheckAvailability', 1 );

# Mock not empty availability services
my $availability_module = Test::MockModule->new('Koha::ILL::Request::Workflow::Availability');
$availability_module->mock( 'get_services', [ { name => 'service' } ] );

my $req_1 = $builder->build_object(
    {
        class => 'Koha::ILL::Requests',
        value => {}
    }
);

my $request = $req_1->load_backend('Mock');

is(
    $availability->show_availability($request),
    1, 'able to show availability search'
);

# Mock empty availability services
$availability_module->mock( 'get_services', [] );

is(
    $availability->show_availability($request),
    0, 'unable to show type disclaimer form'
);

$schema->storage->txn_rollback;
