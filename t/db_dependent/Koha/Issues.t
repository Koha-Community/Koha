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

use Koha::Issue;
use Koha::Issues;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder      = t::lib::TestBuilder->new;
my $patron       = $builder->build( { source => 'Borrower' } );
my $item_1       = $builder->build( { source => 'Item' } );
my $item_2       = $builder->build( { source => 'Item' } );
my $nb_of_issues = Koha::Issues->search->count;
my $new_issue_1  = Koha::Issue->new(
    {   borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_1->{itemnumber},
    }
)->store;
my $new_issue_2 = Koha::Issue->new(
    {   borrowernumber => $patron->{borrowernumber},
        itemnumber     => $item_2->{itemnumber},
    }
)->store;

like( $new_issue_1->issue_id, qr|^\d+$|, 'Adding a new issue should have set the issue_id' );
is( Koha::Issues->search->count, $nb_of_issues + 2, 'The 2 issues should have been added' );

my $retrieved_issue_1 = Koha::Issues->find( $new_issue_1->issue_id );
is( $retrieved_issue_1->itemnumber, $new_issue_1->itemnumber, 'Find a issue by id should return the correct issue' );

$retrieved_issue_1->delete;
is( Koha::Issues->search->count, $nb_of_issues + 1, 'Delete should delete the issue' );

$schema->storage->txn_rollback;

1;
