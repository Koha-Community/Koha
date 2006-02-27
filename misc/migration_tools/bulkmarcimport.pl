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
my ($version, $delete, $test_parameter,$char_encoding, $verbose, $commit);

GetOptions(
	'commit:f'	=> \$commit,
    'file:s'    => \$input_marc_file,
    'n:f' => \$number,
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    'c:s' => \$char_encoding,
    'v:s' => \$verbose,
);

if ($version || ($input_marc_file eq '')) {
	print <<EOF
small script to import an iso2709 file into Koha.
parameters :
\th : this version/help screen
\tfile /path/to/file/to/dump : the file to dump
\tv : verbose mode. 1 means "some infos", 2 means "MARC dumping"
\tn : the number of records to import. If missing, all the file is imported
\tcommit : the number of records to wait before performing a 'commit' operation
\tt : test mode : parses the file, saying what he would do, but doing nothing.
\tc : the char encoding. At the moment, only MARC21 and UNIMARC supported. MARC21 by default.
\td : delete EVERYTHING related to biblio in koha-DB before import  :tables :
\t\tbiblio, \t\tbiblioitems, \t\tsubjects,\titems
\t\tadditionalauthors, \tbibliosubtitles, \tmarc_biblio,
\t\tmarc_subfield_table, \tmarc_word, \t\tmarc_blob_subfield
IMPORTANT : don't use this script before you've entered and checked your MARC parameters tables twice (or more!).
Otherwise, the import won't work correctly and you will get invalid data.

SAMPLE : 
\t\$ export KOHA_CONF=/etc/koha.conf
\t\$ perl misc/migration_tools/bulkmarcimport.pl -d -commit 1000 -file /home/jmf/koha.mrc -n 3000
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

$char_encoding = 'MARC21' unless ($char_encoding);
print "CHAR : $char_encoding\n" if $verbose;
my $starttime = gettimeofday;
my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
my $commitnum = 50;

if ($commit) {

$commitnum = $commit;

}

#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.itemnumber",'');
# $dbh->do("lock tables biblio write, biblioitems write, items write, marc_biblio write, marc_subfield_table write, marc_blob_subfield write, marc_word write, marc_subfield_structure write, stopwords write");
while ( my $record = $batch->next() ) {
warn "I:".$i;
warn "NUM:".$number;
	$i++;

	if ($i==$number) {
		z3950_extended_services('commit',set_service_options('commit'));
		print "COMMIT OPERATION SUCCESSFUL\n";

		my $timeneeded = gettimeofday - $starttime;
		die "$i MARC records imported in $timeneeded seconds\n";
	}
	# perform the commit operation ever so often
	if ($i==$commit) {
		z3950_extended_services('commit',set_service_options('commit'));
		$commit+=$commitnum;
		print "COMMIT OPERATION SUCCESSFUL\n";
	}
	#now, parse the record, extract the item fields, and store them in somewhere else.

    ## create an empty record object to populate
    my $newRecord = MARC::Record->new();
	$newRecord->leader($record->leader());

    # go through each field in the existing record
    foreach my $oldField ( $record->fields() ) {

	# just reproduce tags < 010 in our new record
	if ( $oldField->tag() < 10 ) {
	    $newRecord->append_fields( $oldField );
	    next();
	}

	# store our new subfield data in this list
	my @newSubfields = ();

	# go through each subfield code/data pair
	foreach my $pair ( $oldField->subfields() ) { 
		#$pair->[1] =~ s/\<//g;
		#$pair->[1] =~ s/\>//g;
		push( @newSubfields, $pair->[0], $pair->[1] ); #char_decode($pair->[1],$char_encoding) );
	}

	# add the new field to our new record
	my $newField = MARC::Field->new(
	    $oldField->tag(),
	    $oldField->indicator(1),
	    $oldField->indicator(2),
	    @newSubfields
	);

	$newRecord->append_fields( $newField );

    }

	warn "$i ==>".$newRecord->as_formatted() if $verbose eq 2;
	my @fields = $newRecord->field($tagfield);
	my @items;
	my $nbitems=0;

	foreach my $field (@fields) {
		my $item = MARC::Record->new();
		$item->append_fields($field);
		push @items,$item;
		$newRecord->delete_field($field);
		$nbitems++;
	}
	print "$i : $nbitems items found\n" if $verbose;
	# now, create biblio and items with NEWnewXX call.
	unless ($test_parameter) {
		my ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$newRecord,'');
		warn "ADDED biblio NB $bibid in DB\n" if $verbose;
		for (my $i=0;$i<=$#items;$i++) {
			NEWnewitem($dbh,$items[$i],$bibid);
		}
	}
}
# final commit of the changes
z3950_extended_services('commit',set_service_options('commit'));
print "COMMIT OPERATION SUCCESSFUL\n";

my $timeneeded = gettimeofday - $starttime;
print "$i MARC records done in $timeneeded seconds\n";
