#s!/usr/bin/perl

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

use Koha::ActionLogs;
use Koha::Database;
use Koha::ILL::Batch;
use Koha::ILL::Batches;
use Koha::ILL::Requests;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;

use Test::NoWarnings;
use Test::More tests => 13;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::ILL::Batch');
use_ok('Koha::ILL::Batches');

$schema->storage->txn_begin;

# Create a patron
my $patron = $builder->build( { source => 'Borrower' } );

# Create a librarian
my $librarian = $builder->build(
    {
        source => 'Borrower',
        value  => { firstname => "Grogu" }
    }
);

# Create a branch
my $branch = $builder->build( { source => 'Branch' } );

# Create a batch
my $illbatch = $builder->build_object(
    {
        class => 'Koha::ILL::Batches',
        value => {
            name       => "My test batch",
            backend    => "Mock",
            patron_id  => $librarian->{borrowernumber},
            library_id => $branch->{branchcode}
        }
    }
);

# Create an ILL request in the batch
my $illrq = $builder->build(
    {
        source => 'Illrequest',
        value  => {
            borrowernumber => $patron->{borrowernumber},
            batch_id       => $illbatch->id
        }
    }
);
my $illrq_obj = Koha::ILL::Requests->find( $illrq->{illrequest_id} );

# Check patron
my $batch_patron = $illbatch->patron;
isa_ok( $batch_patron, 'Koha::Patron' );
is( $batch_patron->firstname, "Grogu", "patron returns correctly" );

# Check branch
my $batch_branch = $illbatch->library;
isa_ok( $batch_branch, 'Koha::Library' );
is( $batch_branch->branchcode, $branch->{branchcode}, "branch returns correctly" );

t::lib::Mocks::mock_preference( 'IllLog', 1 );

my $ill_batch = Koha::ILL::Batch->new(
    {
        name       => "Logging test batch",
        backend    => "Mock",
        patron_id  => $patron->{borrowernumber},
        library_id => $branch->{branchcode},
    }
);

$ill_batch->create_and_log;
my $create_log =
    Koha::ActionLogs->search( { module => 'ILL_BATCHES', action => 'batch_create', object => $ill_batch->id } )->next;
ok( $create_log, 'create_and_log writes an action log entry' );
is( $create_log->module, 'ILL_BATCHES', 'create_and_log logs under ILL_BATCHES module' );

$ill_batch->update_and_log( { name => "Updated logging test batch" } );
my $update_log =
    Koha::ActionLogs->search( { module => 'ILL_BATCHES', action => 'batch_update', object => $ill_batch->id } )->next;
ok( $update_log, 'update_and_log writes an action log entry' );
is( $update_log->module, 'ILL_BATCHES', 'update_and_log logs under ILL_BATCHES module' );

$ill_batch->delete_and_log;
my $delete_log =
    Koha::ActionLogs->search( { module => 'ILL_BATCHES', action => 'batch_delete', object => $ill_batch->id } )->next;
ok( $delete_log, 'delete_and_log writes an action log entry' );
is( $delete_log->module, 'ILL_BATCHES', 'delete_and_log logs under ILL_BATCHES module' );

$illrq_obj->delete;
$schema->storage->txn_rollback;
