#!/usr/bin/perl

# This script is intended for testing RecordProcessor filters. To use it
# run the script like so:
# > perl process_record_through_filter.pl ${BIBLIONUMBER} ${FILTER}

use strict;
use warnings;

use Koha::Script;
use Koha::Biblios;
use Koha::RecordProcessor;

my $biblio = Koha::Biblios->find( $ARGV[0] );
unless ($biblio) {
    print "Bibliographic record not found\n";
    exit;
}
my $record = $biblio->metadata->record;

print "Before: " . $record->as_formatted() . "\n";
my $processor = Koha::RecordProcessor->new( { filters => ( $ARGV[1] ) } );
$record = $processor->process($record);
print "After : " . $record->as_formatted() . "\n";
