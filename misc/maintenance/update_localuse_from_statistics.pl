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

my ($params);
GetOptions(
    'c|confirm' => \$params->{confirm},
    'v|verbose' => \$params->{verbose},
    'help'      => \$params->{help},
);
if ( $params->{help} ) {
    pod2usage( -verbose => 2 );
    exit;
}

my $updated;

if ( $params->{confirm} ) {
    $updated = update_localuse( { verbose => $params->{verbose} } );
}

print "Updated $updated items.\n";

sub update_localuse {
    my $params  = shift;
    my $verbose = $params->{verbose};

    my $dbh = C4::Context->dbh;

    my $items   = Koha::Items->search();
    my $updated = 0;

    # Loop through each item and update it with statistics info
    while ( my $item = $items->next ) {
        my $itemnumber = $item->itemnumber;

        my $localuse_count = Koha::Statistics->search( { itemnumber => $itemnumber, type => 'localuse' } )->count;
        my $item_localuse  = $item->localuse // 0;
        next if $item_localuse == $localuse_count;
        $item->localuse($localuse_count);
        $item->store( { skip_record_index => 1, skip_holds_queue => 1 } );
        $updated++;

        print "Updated item $itemnumber with localuse statistics info. Was $item_localuse, now $localuse_count\n"
            if $verbose;
    }
    return $updated;
}

=head1 NAME

update_local_use_from_statistics.pl

=head1 SYNOPSIS

  update_localuse_from_statistics.pl
  update_localuse_from_statistics.pl --help
  update_localuse_from_statistics.pl --confirm
  update_localuse_from_statistics.pl --verbose

=head1 DESCRIPTION

This script updates the items.localuse column with data from the statistics table to make sure the two tables are congruent.
NOTE: If you have mapped the items.localuse field in your search engine you must reindex your records after running this script.

=head1 OPTIONS

=over

=item B<-h--help>

Prints this help message

=item B<-c|--confirm>

    Confirm to run the script.

=item B<-v|--verbose>

    Add verbosity to output.

=back

=cut
