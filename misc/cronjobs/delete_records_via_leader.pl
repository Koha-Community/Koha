#!/usr/bin/perl

#-----------------------------------
# Copyright 2013 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-----------------------------------

use Modern::Perl;

binmode( STDOUT, ":encoding(UTF-8)" );

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Getopt::Long;

use C4::Biblio;
use C4::Items;
use Koha::Database;

my $delete_items;
my $confirm;
my $test;
my $verbose;
my $help;

GetOptions(
    'i|di|delete-items' => \$delete_items,
    'c|confirm'         => \$confirm,
    't|test'            => \$test,
    'v|verbose'         => \$verbose,
    'h|help'            => \$help,
);

if ( $help || !$confirm ) {
    say qq{
delete_records_via_leader.pl - Attempt to delete any MARC records where the leader character 5 equals 'd'
usage: delete_records_via_leader.pl --confirm --verbose [--test]
This script has the following parameters :
    -h --help: Prints this message
    -c --confirm: Script will do nothing without this parameter
    -v --verbose: Be verbose
    -t --test: Test mode, does not delete records.
               Test mode cannot determine if a record/item will be deleted successfully,
               it will only tell you what records and items the script will attempt to delete.
    -i --delete-items: Try deleting items before deleting record.
                       Records with items cannot be deleted.
};
    exit();
}

my $schema = Koha::Database->new()->schema();
my @biblioitems = # Should be replaced by a call to C4::Search on zebra index
                  # Record-status when bug 15537 will be pushed
  $schema->resultset('Biblioitem')->search( { marcxml => { LIKE => '%<leader>_____d%' } } );

my $total_records_count   = @biblioitems;
my $deleted_records_count = 0;
my $total_items_count     = 0;
my $deleted_items_count   = 0;

foreach my $biblioitem (@biblioitems) {
    my $biblionumber = $biblioitem->get_column('biblionumber');

    say "RECORD: $biblionumber" if $verbose;

    if ($delete_items) {
        my $deleted_count = 0;
        foreach my $item ( $biblioitem->items() ) {
            my $itemnumber = $item->itemnumber();

            my $error = $test ? "Test mode enabled" : DelItemCheck( $biblionumber, $itemnumber );
            $error = undef if $error eq '1';

            if ($error) {
                say "ERROR DELETING ITEM $itemnumber: $error";
            }
            else {
                say "DELETED ITEM $itemnumber" if $verbose;
                $deleted_items_count++;
            }

            $total_items_count++;
        }

    }

    my $error = $test ? q{Test mode enabled} : DelBiblio($biblionumber);
    if ( $error ) {
        say "ERROR DELETING BIBLIO $biblionumber: $error";
    } else {
        say "DELETED BIBLIO $biblionumber" if $verbose;
        $deleted_records_count++;
    }

    say q{};
}

if ( $verbose ) {
    say "DELETED $deleted_records_count OF $total_records_count RECORDS";
    say "DELETED $deleted_items_count OF $total_items_count ITEMS" if $delete_items;
}
