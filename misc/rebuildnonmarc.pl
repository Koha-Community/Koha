#!/usr/bin/perl
# small script that rebuilds the non-MARC DB

use strict;

# Koha modules used
# use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version, $confirm,$test_parameter);
GetOptions(
	'c' => \$confirm,
	'h' => \$version,
	't' => \$test_parameter,
);

if ($version || (!$confirm)) {
	print <<EOF
This script rebuilds the non-MARC DB from the MARC values.
You can/must use it when you change your mapping.
For example : you decide to map biblio.title to 200$a (it was previously mapped to 610$a) : run this script or you will have strange
results in OPAC !
syntax :
\t./rebuildnonmarc.pl -h (or without arguments => shows this screen)
\t./rebuildnonmarc.pl -c (c like confirm => rebuild non marc DB (may be long)
\t-t => test only, change nothing in DB
EOF
;
die;
}

my $dbh = C4::Context->dbh;
my $i=0;
my $starttime = time();

$|=1; # flushes output
my $starttime = gettimeofday;

#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.itemnumber",'');
# $dbh->do("lock tables biblio write, biblioitems write, items write, marc_biblio write, marc_subfield_table write, marc_blob_subfield write, marc_word write, marc_subfield_structure write, stopwords write");
my $sth = $dbh->prepare("select bibid from marc_biblio");
$sth->execute;
# my ($bibidmax) =  $sth->fetchrow;
# warn "$bibidmax <<==";
while (my ($bibid)= $sth->fetchrow) {
	#now, parse the record, extract the item fields, and store them in somewhere else.
	my $record = MARCgetbiblio($dbh,$bibid);
	my @fields = $record->field($tagfield);
	my @items;
	my $nbitems=0;
	print ".";
	my $timeneeded = gettimeofday - $starttime;
	print "$i in $timeneeded s\n" unless ($i % 50);
	$i++;
	foreach my $field (@fields) {
		my $item = MARC::Record->new();
		$item->append_fields($field);
		push @items,$item;
		$record->delete_field($field);
		$nbitems++;
	}
# 	print "$bibid\n";
	# now, create biblio and items with NEWnewXX call.
	my $frameworkcode = MARCfind_frameworkcode($dbh,$bibid);
	localNEWmodbiblio($dbh,$record,$bibid,$frameworkcode) unless $test_parameter;
# 	warn 'B=>'.$record->as_formatted;
# 	print "biblio done\n";
	for (my $i=0;$i<=$#items;$i++) {
		my $tmp = MARCmarc2koha($dbh,$items[$i],$frameworkcode) unless $test_parameter; # finds the itemnumber
# 		warn "    I=> ".$items[$i]->as_formatted;
		localNEWmoditem($dbh,$items[$i],$bibid,$tmp->{itemnumber},0) unless $test_parameter;
# 		print "1 item done\n";
	}
}
# $dbh->do("unlock tables");
my $timeneeded = time() - $starttime;
print "$i MARC record done in $timeneeded seconds\n";

# modified NEWmodbiblio to jump the MARC part of the biblio modif
# highly faster
sub localNEWmodbiblio {
	my ($dbh,$record,$bibid,$frameworkcode) =@_;
	$frameworkcode="" unless $frameworkcode;
# 	&MARCmodbiblio($dbh,$bibid,$record,$frameworkcode,0);
	my $oldbiblio = MARCmarc2koha($dbh,$record,$frameworkcode);
	my $oldbiblionumber = C4::Biblio::OLDmodbiblio($dbh,$oldbiblio);
	C4::Biblio::OLDmodbibitem($dbh,$oldbiblio);
	# now, modify addi authors, subject, addititles.
	my ($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"additionalauthors.author",$frameworkcode);
	my @addiauthfields = $record->field($tagfield);
	foreach my $addiauthfield (@addiauthfields) {
		my @addiauthsubfields = $addiauthfield->subfield($tagsubfield);
		foreach my $subfieldcount (0..$#addiauthsubfields) {
			C4::Biblio::OLDmodaddauthor($dbh,$oldbiblionumber,$addiauthsubfields[$subfieldcount]);
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubtitle.subtitle",$frameworkcode);
	my @subtitlefields = $record->field($tagfield);
	foreach my $subtitlefield (@subtitlefields) {
		my @subtitlesubfields = $subtitlefield->subfield($tagsubfield);
		foreach my $subfieldcount (0..$#subtitlesubfields) {
			C4::Biblio::OLDnewsubtitle($dbh,$oldbiblionumber,$subtitlesubfields[$subfieldcount]);
		}
	}
	($tagfield,$tagsubfield) = MARCfind_marc_from_kohafield($dbh,"bibliosubject.subject",$frameworkcode);
	my @subj = $record->field($tagfield);
	my @subjects;
	foreach my $subject (@subj) {
		my @subjsubfield = $subject->subfield($tagsubfield);
		foreach my $subfieldcount (0..$#subjsubfield) {
			push @subjects,$subjsubfield[$subfieldcount];
		}
	}
	C4::Biblio::OLDmodsubject($dbh,$oldbiblionumber,1,@subjects);
	return 1;
}

sub localNEWmoditem {
    my ( $dbh, $record, $bibid, $itemnumber, $delete ) = @_;
# 	warn "NEWmoditem $bibid / $itemnumber / $delete ".$record->as_formatted;
#     &MARCmoditem( $dbh, $record, $bibid, $itemnumber, $delete );
	my $frameworkcode=MARCfind_frameworkcode($dbh,$bibid);
    my $olditem = MARCmarc2koha( $dbh, $record,$frameworkcode );
    C4::Biblio::OLDmoditem( $dbh, $olditem );
}
