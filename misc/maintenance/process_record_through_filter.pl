#!/usr/bin/perl

# This script is intended for testing RecordProcessor filters. To use it
# run the script like so:
# > perl process_record_through_filter.pl ${BIBLIONUMBER} ${FILTER}

use strict;
use warnings;
use Koha::RecordProcessor;
use Data::Dumper;
use C4::Biblio;

my $record = GetMarcBiblio($ARGV[0]);

print "Before: " . $record->as_formatted() . "\n";
my $processor = Koha::RecordProcessor->new( { filters => ( $ARGV[1] ) });
$record = $processor->process($record);
print "After : " . $record->as_formatted() . "\n";
