#!/usr/bin/perl

# Copyright 2016 Koha Development team
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

use Test::More tests => 3;

use Koha::MarcSubfieldStructure;
use Koha::MarcSubfieldStructures;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_fields = Koha::MarcSubfieldStructures->search->count;
my $framework = $builder->build({ source => 'BiblioFramework' });
my $new_field_1 = Koha::MarcSubfieldStructure->new({
    frameworkcode => $framework->{frameworkcode},
    tagfield => 200,
    tagsubfield => 'a',
})->store;
my $new_field_2 = Koha::MarcSubfieldStructure->new({
    frameworkcode => $framework->{frameworkcode},
    tagfield => 245,
    tagsubfield => 'a',
})->store;

is( Koha::MarcSubfieldStructures->search->count, $nb_of_fields + 2, 'The 2 fields should have been added' );

my $retrieved_fields = Koha::MarcSubfieldStructures->search({ frameworkcode => $framework->{frameworkcode}, tagfield => 200, tagsubfield => 'a' });
is( $retrieved_fields->count, 1, 'Search for a field by frameworkcode, tagfield and tagsubfield should return the field' );

$retrieved_fields->next->delete;
is( Koha::MarcSubfieldStructures->search->count, $nb_of_fields + 1, 'Delete should have deleted the field' );

$schema->storage->txn_rollback;

1;
