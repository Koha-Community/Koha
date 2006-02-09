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
# eval {
# 	my $Zpackage = $Zconn->package();
# 	$Zpackage->option(databaseName => 'Koha');
# # 	$Zpackage->send("drop");
# };

eval {
	my $Zpackage = $Zconn->package();
	$Zpackage->option(databaseName => 'Koha');
	$Zpackage->send("create");
};
my $cgidir = C4::Context->intranetdir ."/cgi-bin";
unless (opendir(DIR, "$cgidir")) {
		$cgidir = C4::Context->intranetdir."/";
} 
my $starttime = gettimeofday;
my $sth = $dbh->prepare("select biblionumber from biblio");
$sth->execute;
my $i=0;
while ((my $biblionumber) = $sth->fetchrow) {
	my $record = XMLgetbiblio($dbh,$biblionumber);
# 	warn "\n==============\n$record\n==================\n";
	my $Zpackage = $Zconn->package();
	$Zpackage->option(databaseName => 'Koha');
	$Zpackage->option(action => "specialUpdate");
# 	$Zpackage->option(recordIdNumber => $biblionumber);
	$Zpackage->option(record => $record);
	$Zpackage->send("update");
# 	$Zpackage->destroy;
	$i++;
	print '.';
	print "$i\r" unless ($i % 100);
# 	exit if $i>100;
}
my $Zpackage = $Zconn->package();
$Zpackage->option(databaseName => 'Koha');
$Zpackage->send("commit");
my $timeneeded = gettimeofday - $starttime;
print "\n\n$i MARC record done in $timeneeded seconds\n";
