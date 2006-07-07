#!/usr/bin/perl
# script that correct the marcxml  from in biblioitems 
#  Written by TG on 10/04/2006
use strict;

# Koha modules used

use C4::Context;
use C4::Biblio;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Batch;
use Time::HiRes qw(gettimeofday);
use Getopt::Long;
my ( $input_marc_file);

GetOptions(
    'file:s'    => \$input_marc_file, 
);

if ($input_marc_file eq '') {
	print <<EOF
small script to import an iso2709 file into Koha biblioitems Useful when upgrading.
Warning assumes hardcode 090$c for  biblionumber
parameters :

\tfile /path/to/file/to/import : the file to import


SAMPLE : ./importintobiblioitems.pl -file /home/neu/koha.dev/local/iso2709.mrc
EOF
;#'
die;
}
my $starttime = gettimeofday;
my $timeneeded;
my $dbh = C4::Context->dbh;

my $sth2=$dbh->prepare("update biblioitems  set marc=? where biblionumber=?");
my $i=0;

my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
while ( my $record = $batch->next() ) {
### WARNING biblionumber is harcoded for 090$c
my $biblionumber=$record->field('090')->subfield('c');
$i++;
$sth2->execute($record->as_usmarc,$biblionumber) if $biblionumber;
print "$biblionumber \n";
}

$timeneeded = gettimeofday - $starttime ;
	print "$i records in $timeneeded s\n" ;

END;
