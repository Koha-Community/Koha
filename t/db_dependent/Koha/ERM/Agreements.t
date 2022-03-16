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

use Test::More tests => 2;

use Koha::ERM::Agreements;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'periods' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $agreement =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );
    is( $agreement->periods->count, 0, "no period yet" );

    my $today   = dt_from_string;
    my $periods = [
        {
            started_on            => $today->ymd,
            ended_on              => $today->clone->add( days => 1 )->ymd,
            cancellation_deadline => $today->clone->add( years => 1 )->ymd,
            notes                 => 'just some notes'
        },
        {
            started_on            => $today->ymd,
            ended_on              => undef,
            cancellation_deadline => undef,
            notes                 => undef,
        },

    ];
    $agreement->periods($periods);

    my $retrieved_periods = $agreement->periods;
    is( ref($retrieved_periods), 'Koha::ERM::Agreement::Periods' );
    $retrieved_periods =
      [ map { delete $_->{agreement_id}; delete $_->{agreement_period_id}; $_ }
          @{ $retrieved_periods->unblessed } ];
    is_deeply( $retrieved_periods, $periods );
    $agreement->periods( [] );
    is( $agreement->periods->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'user_role' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $agreement =
      $builder->build_object( { class => 'Koha::ERM::Agreements' } );
    is( $agreement->user_roles->count, 0, "no user yet" );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $role = 'TEST_ROLE';
    $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'ERM_AGREEMENT_USER_ROLES',
                authorised_value => 'TEST_ROLE',
                lib              => 'a role for testing'
            }
        }
    );

    my $user_roles = [
        {
            user_id => $patron->borrowernumber,
            role    => $role
        }
    ];
    $agreement->user_roles($user_roles);

    my $retrieved_user_roles = $agreement->user_roles;
    is( ref($retrieved_user_roles), 'Koha::ERM::Agreement::UserRoles' );
    $retrieved_user_roles =
      [ map { delete $_->{agreement_id}; $_ }
          @{ $retrieved_user_roles->unblessed } ];
    is_deeply( $retrieved_user_roles, $user_roles );
    $agreement->user_roles( [] );
    is( $agreement->user_roles->count, 0 );

    $schema->storage->txn_rollback;
};
