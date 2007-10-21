#!/usr/bin/perl
# small script that import an iso2709 file into koha 2.0

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($confirm);
GetOptions(
    'c' => \$confirm,
);

unless ($confirm) {
	print <<EOF

script to write files for zebra DB reindexing. Once it's done, run zebraidx update biblios

run the script with -c to confirm the reindexing.

EOF
;#'
die;
}

$|=1; # flushes output

my $dbh = C4::Context->dbh;
my $cgidir = C4::Context->intranetdir."/";

my $starttime = gettimeofday;
my $sth = $dbh->prepare("select biblionumber from biblio");
$sth->execute;
my $i=0;
while ((my $biblionumber) = $sth->fetchrow) {
	my $record = GetMarcBiblio($biblionumber);
	my $filename = $cgidir."/tmp/BIBLIO".$biblionumber.".iso2709";
	open F,"> $filename";
	print F $record->as_usmarc();
	close F;
	$i++;
	print "\r$i" unless ($i % 100);
}
my $timeneeded = gettimeofday - $starttime;
print "\n$i MARC record done in $timeneeded seconds\n";
