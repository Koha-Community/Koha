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
use Test::More tests => 3;
use Test::Exception;

use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'usage_count() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );

    is( $source->usage_count, 0, q{Unused record source has a count of 0} );

    foreach ( 1 .. 3 ) {
        my $biblio = $builder->build_sample_biblio();
        $biblio->metadata->record_source_id( $source->id )->store();
    }

    is( $source->usage_count, 3, q{3 records linked, count is 3} );

    $schema->storage->txn_rollback;
};

subtest 'library_groups() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources', value => { is_system => 0 } } );

    is( $source->library_groups->count, 0, 'No library groups linked initially' );

    my $root_group_value = { parent_id => undef, branchcode => undef, ft_record_source_editing => 1 };
    my $group            = $builder->build_object( { class => 'Koha::Library::Groups', value => $root_group_value } );
    my $other_group      = $builder->build_object( { class => 'Koha::Library::Groups', value => $root_group_value } );

    $source->library_groups( [ { library_group_id => $group->id } ] );
    is( $source->library_groups->count,    1,          'One library group linked' );
    is( $source->library_groups->next->id, $group->id, 'The right group is linked' );

    $source->library_groups( [ { library_group_id => $group->id }, { library_group_id => $other_group->id } ] );
    is( $source->library_groups->count, 2, 'Linked groups are replaced wholesale' );

    $other_group->delete;
    is( $source->library_groups->count, 1, 'Deleting a group removes its link' );

    $source->library_groups( [] );
    is( $source->library_groups->count, 0, 'Empty arrayref clears the links' );

    my $unflagged_group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { parent_id => undef, branchcode => undef, ft_record_source_editing => 0 }
        }
    );
    throws_ok { $source->library_groups( [ { library_group_id => $unflagged_group->id } ] ) }
    'Koha::Exceptions::BadParameter', 'Group without the feature flag is rejected';

    my $child_group = $builder->build_object(
        {
            class => 'Koha::Library::Groups',
            value => { parent_id => $group->id, branchcode => undef, ft_record_source_editing => 1 }
        }
    );
    throws_ok { $source->library_groups( [ { library_group_id => $child_group->id } ] ) }
    'Koha::Exceptions::BadParameter', 'Non-root group is rejected';

    my $deleted_group    = $builder->build_object( { class => 'Koha::Library::Groups', value => $root_group_value } );
    my $deleted_group_id = $deleted_group->id;
    $deleted_group->delete;
    throws_ok { $source->library_groups( [ { library_group_id => $deleted_group_id } ] ) }
    'Koha::Exceptions::BadParameter', 'Nonexistent group is rejected';

    $source->library_groups( [ { library_group_id => $group->id } ] );
    my $source_id = $source->id;
    $source->delete;
    is(
        $schema->resultset('RecordSourcesLibraryGroup')->search( { record_source_id => $source_id } )->count,
        0, 'Deleting a source removes its links'
    );

    $schema->storage->txn_rollback;
};
