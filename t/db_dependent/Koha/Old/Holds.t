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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 1;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Old::Holds;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'anonymize() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    is( $patron->old_holds->count, 0, 'Patron has no old holds' );
    is( $patron->old_holds->anonymize + 0, 0, 'Anonymizing an empty resultset returns 0' );

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value =>
              { borrowernumber => $patron->id, timestamp => dt_from_string() }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 1 )
            }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 2 )
            }
        }
    );
    my $hold_4 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 3 )
            }
        }
    );

    is( $patron->old_holds->count, 4, 'Patron has 4 completed holds' );
    # filter them so only the older two are part of the resultset
    my $holds = $patron->old_holds->search({ timestamp => { '<=' => dt_from_string()->subtract( days => 2 ) } });
    # Anonymize them
    my $anonymized_count = $holds->anonymize();
    is( $anonymized_count, 2, 'update() tells 2 rows were updated' );

    is( $patron->old_holds->count, 2, 'Patron has 2 completed holds' );

    $schema->storage->txn_rollback;
};
