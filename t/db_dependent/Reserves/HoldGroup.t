#!/usr/bin/perl

# Copyright 2020 Koha Development team
#
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
use Test::More tests => 3;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Reserves    qw( AddReserve ModReserveAffect );
use C4::Circulation qw( AddReturn );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'holds tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
    my $hold_group = $builder->build_object( { class => 'Koha::HoldGroups' } );
    my $hold       = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron->borrowernumber,
                hold_group_id  => $hold_group->hold_group_id,
            }
        }
    );

    my $holds = $hold_group->holds;
    is( ref($holds), 'Koha::Holds', 'Right type' );
    my $hold_from_group = $holds->next;
    is( $hold_from_group->id, $hold->id, 'Right object' );

    $schema->storage->txn_rollback;
};

subtest "target_hold_id tests" => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'DisplayAddHoldGroups', 1 );

    my $patron_category = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type                 => 'P',
                enrolmentfee                  => 0,
                BlockExpiredPatronOpacActions => 'follow_syspref_BlockExpiredPatronOpacActions',
            }
        }
    );

    my $library_1 = $builder->build( { source => 'Branch' } );
    my $library_2 = $builder->build( { source => 'Branch' } );
    my $patron_2  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { branchcode => $library_2->{branchcode}, categorycode => $patron_category->{categorycode} }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library_1->{branchcode},
        }
    );

    my $item_2 = $builder->build_sample_item(
        {
            library => $library_1->{branchcode},
        }
    );

    set_userenv($library_2);
    my $reserve_id = AddReserve(
        {
            branchcode     => $library_2->{branchcode},
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
        }
    );

    my $reserve_2_id = AddReserve(
        {
            branchcode     => $library_2->{branchcode},
            borrowernumber => $patron_2->borrowernumber,
            biblionumber   => $item_2->biblionumber,
            priority       => 1,
        }
    );

    my $hold_group = $patron_2->create_hold_group( [ $reserve_id, $reserve_2_id ] );

    set_userenv($library_1);
    my $do_transfer = 1;
    AddReturn( $item->barcode, $library_1->{branchcode} );
    ModReserveAffect( $item->itemnumber, undef, $do_transfer, $reserve_id );
    my $hold = Koha::Holds->find($reserve_id);
    is( $hold_group->get_from_storage->target_hold_id, $hold->reserve_id, 'target_hold_id is correct' );
    $hold->fill();
    is( $hold_group->get_from_storage, undef, 'hold group no longer exists' );

    $schema->storage->txn_rollback;
};

sub set_userenv {
    my ($library) = @_;
    my $staff = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $staff, branchcode => $library->{branchcode} } );
}
