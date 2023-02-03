#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::More tests => 5;

use Koha::Database;
use Koha::Statistics;
use C4::Context;
use C4::Stats qw( UpdateStats );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $library = $builder->build_object( { class => 'Koha::Libraries' } );
my $item    = $builder->build_sample_item;
my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
C4::Stats::UpdateStats(
    {
        type           => 'issue',
        branch         => $library->branchcode,
        itemnumber     => $item->itemnumber,
        borrowernumber => $patron->borrowernumber,
        itemtype       => $item->effective_itemtype,
        location       => $item->location,
        ccode          => $item->ccode,
        interface      => C4::Context->interface
    }
);

my $stat =
  Koha::Statistics->search( { itemnumber => $item->itemnumber } )->next;
is( $stat->borrowernumber, $patron->borrowernumber, 'Patron is there' );
is( $stat->branch,         $library->branchcode,    'Library is there' );
is( ref( $stat->item ), 'Koha::Item', '->item returns a Koha::Item object' );
is( $stat->item->itemnumber, $item->itemnumber, '->item works great' );
is( $stat->interface, 'opac', 'Interface is recorded successfully' );

$schema->storage->txn_rollback;
