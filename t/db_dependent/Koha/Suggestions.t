#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 4;

use Koha::Suggestion;
use Koha::Suggestions;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder           = t::lib::TestBuilder->new;
my $biblio_1          = $builder->build( { source => 'Biblio' } );
my $biblio_2          = $builder->build( { source => 'Biblio' } );
my $patron            = $builder->build( { source => 'Borrower' } );
my $nb_of_suggestions = Koha::Suggestions->search->count;
my $new_suggestion_1  = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_1->{biblionumber},
    }
)->store;
my $new_suggestion_2 = Koha::Suggestion->new(
    {   suggestedby  => $patron->{borrowernumber},
        biblionumber => $biblio_2->{biblionumber},
    }
)->store;

like( $new_suggestion_1->suggestionid, qr|^\d+$|, 'Adding a new suggestion should have set the suggestionid' );
is( Koha::Suggestions->search->count, $nb_of_suggestions + 2, 'The 2 suggestions should have been added' );

my $retrieved_suggestion_1 = Koha::Suggestions->find( $new_suggestion_1->suggestionid );
is( $retrieved_suggestion_1->biblionumber, $new_suggestion_1->biblionumber, 'Find a suggestion by id should return the correct suggestion' );

$retrieved_suggestion_1->delete;
is( Koha::Suggestions->search->count, $nb_of_suggestions + 1, 'Delete should have deleted the suggestion' );

$schema->storage->txn_rollback;

1;
