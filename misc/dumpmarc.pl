#!/usr/bin/perl
# small script that dumps an iso2709 file.


use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;

use Getopt::Long;
my ( $input_marc_file,$number) = ('',0);
my $version;
GetOptions(
    'file:s'    => \$input_marc_file,
    'n' => \$number,
    'v' => \$version
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
small script to dump an iso2709 file.
parameters :
\tv : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tn : the number of the record to dump. If missing, all the file is dumped
SAMPLE : ./dumpmarc.pl -file /home/paul/koha.dev/local/npl -n 1
EOF
;
die;
}

my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=1;
while ( my $record = $batch->next() ) {
	print "\n".$record->as_formatted() if ($i eq $number || $number eq 0);
	$i++;
}
print "\n==================\n$i record parsed\n";
