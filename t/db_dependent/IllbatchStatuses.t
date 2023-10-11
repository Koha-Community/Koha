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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use File::Basename qw/basename/;
use Koha::Database;
use Koha::IllbatchStatus;
use Koha::IllbatchStatuses;
use Koha::Patrons;
use Koha::Libraries;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockObject;
use Test::MockModule;

use Test::More tests => 13;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
use_ok('Koha::IllbatchStatus');
use_ok('Koha::IllbatchStatuses');

$schema->storage->txn_begin;

Koha::IllbatchStatuses->search->delete;

# Keep track of whether our CRUD logging side-effects are happening
my $effects = {
    batch_status_create => 0,
    batch_status_update => 0,
    batch_status_delete => 0
};

# Mock a logger so we can check it is called
my $logger = Test::MockModule->new('Koha::Illrequest::Logger');
$logger->mock(
    'log_something',
    sub {
        my ( $self, $to_log ) = @_;
        $effects->{ $to_log->{actionname} }++;
    }
);

# Create a batch status
my $status = $builder->build(
    {
        source => 'IllbatchStatus',
        value  => {
            name      => "Feeling the call to the Dark Side",
            code      => "OH_NO",
            is_system => 1
        }
    }
);

my $status_obj = Koha::IllbatchStatuses->find( { code => $status->{code} } );
isa_ok( $status_obj, 'Koha::IllbatchStatus' );

# Try to delete the status, it's a system status, so this should fail
$status_obj->delete_and_log;
my $status_obj_del = Koha::IllbatchStatuses->find( { code => $status->{code} } );
isa_ok( $status_obj_del, 'Koha::IllbatchStatus' );

## Status create

# Try creating a duplicate status
my $status2 = Koha::IllbatchStatus->new(
    {
        name      => "Obi-wan",
        code      => $status->{code},
        is_system => 0
    }
);
is_deeply(
    $status2->create_and_log,
    { error => "Duplicate status found" },
    "Creation of statuses with duplicate codes prevented"
);

# Create a non-duplicate status and ensure that the logger is called
my $status3 = Koha::IllbatchStatus->new(
    {
        name      => "Kylo",
        code      => "DARK_SIDE",
        is_system => 0
    }
);
$status3->create_and_log;
is(
    $effects->{'batch_status_create'},
    1,
    "Creation of status calls log_something"
);

# Try creating a system status and ensure it's not created
my $cannot_create_system = Koha::IllbatchStatus->new(
    {
        name      => "Jar Jar Binks",
        code      => "GUNGAN",
        is_system => 1
    }
);
$cannot_create_system->create_and_log;
my $created_but_not_system = Koha::IllbatchStatuses->find( { code => "GUNGAN" } );
is( $created_but_not_system->{is_system}, undef, "is_system statuses cannot be created" );

## Status update

# Ensure only name can be updated
$status3->update_and_log(
    {
        name      => "Rey",
        code      => "LIGHT_SIDE",
        is_system => 1
    }
);

# Get our updated status, if we can get it by it's code, we know that hasn't changed
my $not_updated = Koha::IllbatchStatuses->find( { code => "DARK_SIDE" } )->unblessed;
is( $not_updated->{is_system}, 0,     "is_system cannot be changed" );
is( $not_updated->{name},      "Rey", "name can be changed" );

# Ensure the logger is called
is(
    $effects->{'batch_status_update'},
    1,
    "Update of status calls log_something"
);

## Status delete
my $cannot_delete = Koha::IllbatchStatus->new(
    {
        name      => "Palapatine",
        code      => "SITH",
        is_system => 1
    }
)->store;
my $can_delete = Koha::IllbatchStatus->new(
    {
        name      => "Windu",
        code      => "JEDI",
        is_system => 0
    }
);
$cannot_delete->delete_and_log;
my $not_deleted = Koha::IllbatchStatuses->find( { code => "SITH" } );
isa_ok( $not_deleted, 'Koha::IllbatchStatus', "is_system statuses cannot be deleted" );
$can_delete->create_and_log;
$can_delete->delete_and_log;

# Ensure the logger is called following a successful delete
is(
    $effects->{'batch_status_delete'},
    1,
    "Delete of status calls log_something"
);

# Create a system "UNKNOWN" status
my $status_unknown = Koha::IllbatchStatus->new(
    {
        name      => "Unknown",
        code      => "UNKNOWN",
        is_system => 1
    }
);
$status_unknown->create_and_log;

# Create a batch and assign it a status
my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
my $library = $builder->build_object( { class => 'Koha::Libraries' } );
my $status5 = Koha::IllbatchStatus->new(
    {
        name      => "Plagueis",
        code      => "DEAD_SITH",
        is_system => 0
    }
);
$status5->create_and_log;
my $batch = Koha::Illbatch->new(
    {
        name       => "My test batch",
        patron_id  => $patron->borrowernumber,
        library_id => $library->branchcode,
        backend    => "TEST",
        status_code => $status5->code
    }
);
$batch->create_and_log;

# Delete the batch status and ensure the batch's status has been changed
# to UNKNOWN
$status5->delete_and_log;
my $updated_code = Koha::Illbatches->find( { status_code => "UNKNOWN" } );
is( $updated_code->status_code, "UNKNOWN", "batches attached to deleted status have status changed to UNKNOWN" );

$schema->storage->txn_rollback;
