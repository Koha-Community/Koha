#!/usr/bin/perl
# small script that import an iso2709 file into koha 2.0

use strict;

# Koha modules used
use MARC::File::USMARC;
use MARC::Record;
use MARC::Batch;
use C4::Context;
use C4::Biblio;

use Getopt::Long;
my ( $input_marc_file, $number) = ('',0);
my ($version, $delete, $test_parameter,$char_encoding);
GetOptions(
    'file:s'    => \$input_marc_file,
    'n' => \$number,
    'v' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    'c:s' => \$char_encoding,
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
small script to import an iso2709 file into Koha.
parameters :
\tv : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tn : the number of the record to import. If missing, all the file is imported
\tt : test mode : parses the file, saying what he would do, but doing nothing.
\tc : the char encoding. At the moment, only USMARC and UNIMARC supported. USMARC by default.
\d : delete EVERYTHING related to biblio in koha-DB before import  :tables :
\t\tbiblio, \t\tbiblioitems, \t\tsubjects,\titems
\t\tadditionalauthors, \tbibliosubtitles, \tmarc_biblio,
\t\tmarc_subfield_table, \tmarc_word, \t\tmarc_blob_subfield
IMPORTANT : don't use this script before you've entered and checked twice (or more) your  MARC parameters tables.
If you fail this, the import won't work correctly and you will get invalid datas.

SAMPLE : ./bulkmarcimport.pl -file /home/paul/koha.dev/local/npl -n 1
EOF
;#'
die;
}

my $dbh = C4::Context->dbh;

if ($delete) {
	print "deleting biblios\n";
	$dbh->do("delete from biblio");
	$dbh->do("delete from biblioitems");
	$dbh->do("delete from items");
	$dbh->do("delete from bibliosubject");
	$dbh->do("delete from additionalauthors");
	$dbh->do("delete from bibliosubtitle");
	$dbh->do("delete from marc_biblio");
	$dbh->do("delete from marc_subfield_table");
	$dbh->do("delete from marc_word");
	$dbh->do("delete from marc_blob_subfield");
}
if ($test_parameter) {
	print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}
$char_encoding = 'USMARC' unless ($char_encoding);
print "CHAR : $char_encoding\n";
my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=1;
#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.itemnumber");

while ( my $record = $batch->next() ) {
	$i++;
	#now, parse the record, extract the item fields, and store them in somewhere else.
	$record = MARC::File::USMARC::decode(char_decode($record->as_usmarc(),$char_encoding));
	my @fields = $record->field($tagfield);
	print "biblio $i";
	my @items;
	my $nbitems;

	foreach my $field (@fields) {
		my $item = MARC::Record->new();
		$item->append_fields($field);
		push @items,$item;
		$record->delete_field($field);
		$nbitems++;
	}
	print " : $nbitems items found\n";
	# now, create biblio and items with NEWnewXX call.
	unless ($test_parameter) {
		my ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$record);
		warn "ADDED biblio NB $bibid in DB\n";
		for (my $i=0;$i<=$#items;$i++) {
			NEWnewitem($dbh,$items[$i],$bibid);
		}
	}
}