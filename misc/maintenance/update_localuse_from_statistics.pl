#!/usr/bin/perl
#
# Copyright (C) 2023 ByWater Solutions
#
# This file is part of Koha.
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

use strict;
use warnings;

use Koha::Script;
use C4::Context;
use Koha::Items;
use Koha::Statistics;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

sub update_localuse {

    my $dbh = C4::Context->dbh;

    my $items = Koha::Items->search();

    # Loop through each item and update it with statistics info
    while ( my $item = $items->next ) {
        my $itemnumber = $item->itemnumber;

        my $localuse_count = Koha::Statistics->search( { itemnumber => $itemnumber, type => 'localuse' } )->count;
        $item->localuse($localuse_count);
        $item->store;

        print "Updated item $itemnumber with localuse statistics info.\n";
    }
}

my ($help);
my $result = GetOptions(
    'help|h' => \$help,
);

usage() if $help;

update_localuse();

=head1 NAME

update_local_use_from_statistics.pl

=head1 SYNOPSIS

  update_localuse_from_statistics.pl
  update_localuse_from_statistics.pl --help

=head1 DESCRIPTION

This script updates the items.localuse column with data from the statistics table to make sure the two tables are congruent.

=over 8

=item B<--help>

Prints this help

=back

=cut
