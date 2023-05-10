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

use Test::More tests => 5;

use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Illrequest::Workflow::TypeDisclaimer;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

use_ok('Koha::Illrequest::Workflow::TypeDisclaimer');

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

my $type_disclaimer =
  Koha::Illrequest::Workflow::TypeDisclaimer->new( $sorted, 'staff' );

isa_ok( $type_disclaimer, 'Koha::Illrequest::Workflow::TypeDisclaimer' );

is(
    $type_disclaimer->prep_metadata($sorted),
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

# Mock Koha::Illrequest::load_backend (to load Mocked Backend)
my $illreqmodule = Test::MockModule->new('Koha::Illrequest');
$illreqmodule->mock( 'load_backend',
    sub { my $self = shift; $self->{_my_backend} = $backend; return $self } );

# Mock ILLModuleDisclaimerByType with valid YAML
t::lib::Mocks::mock_preference(
    'ILLModuleDisclaimerByType', "all:
 text: |
  <h2>HTML title</h2>
  <p>This is an HTML paragraph</p>
  <p>This is another HTML paragraph</p>
 av_category_code: YES_NO
article:
 text: copyright text for all article type requests
 av_category_code: YES_NO
 bypass: 1"
);

my $req_1 = $builder->build_object(
    {
        class => 'Koha::Illrequests',
        value => {}
    }
);

my $request = $req_1->load_backend('Mock');

is( $type_disclaimer->show_type_disclaimer($request),
    1, 'able to show type disclaimer form' );

# Mock ILLModuleDisclaimerByType with invalid YAML
my $type_disclaimer_module =
  Test::MockModule->new('Koha::Illrequest::Workflow::TypeDisclaimer');
$type_disclaimer_module->mock( '_get_type_disclaimer_sys_pref', {} );

is( $type_disclaimer->show_type_disclaimer($request),
    0, 'not able to show type disclaimer form' );

$schema->storage->txn_rollback;
