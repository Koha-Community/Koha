#!/usr/bin/perl
# small script that dumps an iso2709 file.

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;

use Getopt::Long;
my ( $input_marc_file);
GetOptions(
    'file:s'    => \$input_marc_file
);

my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();

while ( my $record = $batch->next() ) {
	print $record->as_formatted();
}
