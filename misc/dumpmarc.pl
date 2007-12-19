#!/usr/bin/perl
# small script that dumps an iso2709 file.


use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;

use Getopt::Long;
my ( $input_marc_file,$number,$nowarning) = ('',0);
my $version;
GetOptions(
    'file:s'    => \$input_marc_file,
    'n:s' => \$number,
    'v' => \$version,
    'w' => \$nowarning,
);

warn "NUM : $number\n";
if ($version || ($input_marc_file eq '')) {
	print <<EOF
small script to dump an iso2709 file.
parameters :
\tv : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tn : the number of the record to dump. If missing, all the file is dumped
\tw : warning and strict off. If your dump fail, try -w option. It it works, then, the file is iso2709, but a buggy one !
SAMPLE : ./dumpmarc.pl -file /home/paul/koha.dev/local/npl -n 1
EOF
;
die;
}

my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off() unless $nowarning;
$batch->strict_off() unless $nowarning;
my $i=1;
while ( my $record = $batch->next() ) {
	print "\nNUMBER $i =>\n".$record->as_formatted() if ($i eq $number || $number eq 0);
	$i++;
}
print "\n==================\n$i record parsed\n";
