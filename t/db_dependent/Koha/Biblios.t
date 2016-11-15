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

use Test::More tests => 1;

use C4::Reserves;

use Koha::Biblios;
use Koha::Patrons;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron = $builder->build( { source => 'Borrower' } );
$patron = Koha::Patrons->find( $patron->{borrowernumber} );

my $biblio = Koha::Biblio->new()->store();

my $biblioitem = $schema->resultset('Biblioitem')->new(
    {
        biblionumber => $biblio->id
    }
)->insert();

subtest 'holds' => sub {
    plan tests => 3;
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber );
    my $holds = $biblio->holds;
    is( ref($holds), 'Koha::Holds', '->holds should return a Koha::Holds object' );
    is( $holds->count, 1, '->holds should only return 1 hold' );
    is( $holds->next->borrowernumber, $patron->borrowernumber, '->holds should return the correct hold' );
};

$schema->storage->txn_rollback;

1;
