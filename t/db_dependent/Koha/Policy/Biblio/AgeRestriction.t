#!/usr/bin/env perl

# This file is part of Koha.
#
# Copyright 2015 Koha Development Team
# Copyright 2026 Theke Solutions
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

use Test::More tests => 3;
use Test::NoWarnings;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Policy::Biblio::AgeRestriction;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

subtest 'Koha::Biblio->age_restriction' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $biblio_fsk = $builder->build_sample_biblio;
    $biblio_fsk->biblioitem->agerestriction('FSK 16')->store;
    is( $biblio_fsk->age_restriction, 16, 'FSK 16 returns 16' );

    my $biblio_pegi = $builder->build_sample_biblio;
    $biblio_pegi->biblioitem->agerestriction('PEGI 16')->store;
    is( $biblio_pegi->age_restriction, 16, 'PEGI 16 returns 16' );

    my $biblio_pegi_no_space = $builder->build_sample_biblio;
    $biblio_pegi_no_space->biblioitem->agerestriction('PEGI16')->store;
    is( $biblio_pegi_no_space->age_restriction, 16, 'PEGI16 returns 16' );

    my $biblio_age = $builder->build_sample_biblio;
    $biblio_age->biblioitem->agerestriction('Age 16')->store;
    is( $biblio_age->age_restriction, 16, 'Age 16 returns 16' );

    my $biblio_k = $builder->build_sample_biblio;
    $biblio_k->biblioitem->agerestriction('K16')->store;
    is( $biblio_k->age_restriction, 16, 'K16 returns 16' );

    my $biblio_none = $builder->build_sample_biblio;
    $biblio_none->biblioitem->agerestriction(undef)->store;
    is( $biblio_none->age_restriction, undef, 'No restriction returns undef' );

    my $biblio_empty = $builder->build_sample_biblio;
    $biblio_empty->biblioitem->agerestriction('')->store;
    is( $biblio_empty->age_restriction, undef, 'Empty restriction returns undef' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Policy::Biblio::AgeRestriction->check' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    $biblio->biblioitem->agerestriction('FSK 16')->store;

    my $young_patron = $builder->build_object( { class => 'Koha::Patrons', value => { dateofbirth => '2016-01-01' } } );
    my $adult_patron = $builder->build_object( { class => 'Koha::Patrons', value => { dateofbirth => '1990-01-01' } } );
    my $no_dob_patron = $builder->build_object( { class => 'Koha::Patrons', value => { dateofbirth => undef } } );

    my $result = Koha::Policy::Biblio::AgeRestriction->check( $biblio, $young_patron );
    ok( defined $result && !$result, 'Young patron is restricted' );
    is( $result->messages->[0]->message,                    'age_restricted', 'Message is age_restricted' );
    is( $result->messages->[0]->payload->{restriction_age}, 16,               'Restriction age in message payload' );

    $result = Koha::Policy::Biblio::AgeRestriction->check( $biblio, $adult_patron );
    ok( $result, 'Adult patron is not restricted' );

    $result = Koha::Policy::Biblio::AgeRestriction->check( $biblio, $no_dob_patron );
    ok( $result, 'No date of birth returns true (permissive)' );

    my $biblio_no_restriction = $builder->build_sample_biblio;
    $result = Koha::Policy::Biblio::AgeRestriction->check( $biblio_no_restriction, $young_patron );
    ok( $result, 'No restriction returns true (permissive)' );

    $schema->storage->txn_rollback;
};
