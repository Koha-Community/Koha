#!/usr/bin/perl

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use ZOOM;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($confirm);
GetOptions(
    'c' => \$confirm,
);

unless ($confirm) {
	print <<EOF

Script to create the zebra DB from a Koha DB

EOF
;#'
die;
}

$|=1; # flushes output

my $dbh = C4::Context->dbh;
my $Zconn;
eval {
	$Zconn = new ZOOM::Connection('localhost','2100');
};
if ($@) {
	print "Error ", $@->code()," : ",$@->message()."\n";
	die;
}

# first, drop Zebra DB
eval {
	my $Zpackage = $Zconn->package();
	$Zpackage->option(databaseName => 'Koha');
# 	$Zpackage->send("drop");
};
if ($@) {
	print "Error dropping /CODE:", $@->code()," /MSG: ",$@->message(),"\n";
# 	die;
}
# then recreate it
eval {
	my $Zpackage = $Zconn->package();
	$Zpackage->option(databaseName => 'Koha');
# 	$Zpackage->send("create");
};
if ($@) {
	print "Error creating /CODE:", $@->code(),"\n /MSG:",$@->message(),"\n\n";
# 	die;
}

my $cgidir = C4::Context->intranetdir ."/cgi-bin";
unless (opendir(DIR, "$cgidir")) {
		$cgidir = C4::Context->intranetdir."/";
} 

my $starttime = gettimeofday;
my $sth = $dbh->prepare("select biblionumber from biblio");
$sth->execute;
my $i=0;
while ((my $biblionumber) = $sth->fetchrow) {
	my $record = MARCgetbiblio($dbh,$biblionumber);
# 	my $filename = $cgidir."/zebra/biblios/BIBLIO".$biblionumber."iso2709";
# 	open F,"> $filename";
# 	print F $record->as_usmarc();
# 	close F;
	my $Zpackage = $Zconn->package();
# 	print "=>".$record->as_xml()."\n";
	$Zpackage->option(action => "recordInsert");
	$Zpackage->option(record => $record->as_usmarc());
	eval {
		$Zpackage->send("update");
	};
	if ($@) {
		print "Error updating /CODE:", $@->code()," /MSG:",$@->message(),"\n";
		die;
	}
	$Zpackage->destroy;
	$i++;
	print "\r$i" unless ($i % 100);
}
my $timeneeded = gettimeofday - $starttime;
print "\n$i MARC record done in $timeneeded seconds\n";
