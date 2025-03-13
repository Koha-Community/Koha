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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use t::lib::TestBuilder;

use Koha::Database;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'library() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object({ class => 'Koha::Libraries' });
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                branchcode => $library->branchcode
            }
        }
    );

    is( ref($checkout->library), 'Koha::Library', 'Object type is correct' );
    is( $checkout->library->branchcode, $library->branchcode, 'Right library linked' );

    $schema->storage->txn_rollback;
};

subtest 'renewals() tests' => sub {

    plan tests => 2;
    $schema->storage->txn_begin;

    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts'
        }
    );
    my $renewal1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => $checkout->issue_id }
        }
    );
    my $renewal2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => { checkout_id => $checkout->issue_id }
        }
    );

    is( ref($checkout->renewals), 'Koha::Checkouts::Renewals', 'Object set type is correct' );
    is( $checkout->renewals->count, 2, "Count of renewals is correct" );

    $schema->storage->txn_rollback;
};

subtest 'public_read_list() tests' => sub {

    $schema->storage->txn_begin;

    my @all_attrs = Koha::Checkouts->columns();
    my $public_attrs =
        { map { $_ => 1 } @{ Koha::Checkout->public_read_list() } };
    my $mapping = Koha::Checkout->to_api_mapping;

    plan tests => scalar @all_attrs * 2;

    # Create a sample checkout
    my $checkout = $builder->build_object( { class => 'Koha::Checkouts' } );

    my $unprivileged_representation = $checkout->to_api( { public => 1 } );
    my $privileged_representation   = $checkout->to_api;

    foreach my $attr (@all_attrs) {
        my $mapped = exists $mapping->{$attr} ? $mapping->{$attr} : $attr;
        if ( defined($mapped) ) {
            ok(
                exists $privileged_representation->{$mapped},
                "Attribute '$attr' is present when privileged"
            );
            if ( exists $public_attrs->{$attr} ) {
                ok(
                    exists $unprivileged_representation->{$mapped},
                    "Attribute '$attr' is present when public"
                );
            } else {
                ok(
                    !exists $unprivileged_representation->{$mapped},
                    "Attribute '$attr' is not present when public"
                );
            }
        } else {
            ok(
                !exists $privileged_representation->{$attr},
                "Unmapped attribute '$attr' is not present when privileged"
            );
            ok(
                !exists $unprivileged_representation->{$attr},
                "Unmapped attribute '$attr' is not present when public"
            );
        }
    }

    $schema->storage->txn_rollback;
};
