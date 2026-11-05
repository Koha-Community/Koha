#!/usr/bin/perl

# This file is part of Koha
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
use Test::More tests => 4;

use Koha::ActionLogs;
use Koha::Database;
use Koha::MarcModificationTemplate;
use Koha::MarcModificationTemplates;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'record_source() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $template = $builder->build_object(
        { class => 'Koha::MarcModificationTemplates', value => { record_source_id => undef } } );

    is( $template->record_source, undef, 'undef returned when the template has no record source' );

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    $template->set( { record_source_id => $source->id } )->store;

    is( $template->record_source->id, $source->id, 'Related record source returned' );

    $schema->storage->txn_rollback;
};

subtest 'record_source_id_for() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $source   = $builder->build_object( { class => 'Koha::RecordSources' } );
    my $template = $builder->build_object(
        { class => 'Koha::MarcModificationTemplates', value => { record_source_id => $source->id } } );

    is(
        Koha::MarcModificationTemplates->record_source_id_for( $template->id ),
        $source->id, 'Record source id returned for a template with a source'
    );

    $template->set( { record_source_id => undef } )->store;

    is(
        Koha::MarcModificationTemplates->record_source_id_for( $template->id ),
        undef, 'undef returned for a template without a source'
    );

    is(
        Koha::MarcModificationTemplates->record_source_id_for(undef),
        undef, 'undef returned when no template id is given'
    );

    $schema->storage->txn_rollback;
};

subtest 'action logs tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'MarcModificationTemplatesLog', 0 );

    my $unlogged = Koha::MarcModificationTemplate->new( { name => 'Unlogged template' } )->store;
    is(
        Koha::ActionLogs->search( { module => 'MARC_MOD_TEMPLATES', object => $unlogged->id } )->count,
        0, 'Nothing logged when the preference is disabled'
    );

    t::lib::Mocks::mock_preference( 'MarcModificationTemplatesLog', 1 );

    my $template = Koha::MarcModificationTemplate->new( { name => 'Logged template' } )->store;
    my $logs     = Koha::ActionLogs->search( { module => 'MARC_MOD_TEMPLATES', object => $template->id } );
    is( $logs->search( { action => 'CREATE' } )->count, 1, 'Creation logged' );

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );
    $template->set( { record_source_id => $source->id } )->store;
    is( $logs->search( { action => 'MODIFY' } )->count, 1, 'Modification logged' );

    my $modify_log = $logs->search( { action => 'MODIFY' } )->next;
    like( $modify_log->info, qr/record_source_id/, 'Modification log carries the changed field' );

    $template->delete;
    is( $logs->search( { action => 'DELETE' } )->count, 1, 'Deletion logged' );

    $schema->storage->txn_rollback;
};
