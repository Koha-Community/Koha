#!/usr/bin/perl
# Import an iso2709 file into Koha 3

use strict;
# use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# Koha modules used
use MARC::File::USMARC;
# Uncomment the line below and use MARC::File::XML again when it works better.
# -- thd
# use MARC::File::XML;
use MARC::Record;
use MARC::Batch;
use MARC::Charset;

# According to kados, an undocumented feature of setting MARC::Charset to 
# ignore_errors(1) is that errors are not ignored.  Instead of deleting the 
# whole subfield when a character does not translate properly from MARC8 into 
# UTF-8, just the problem characters are deleted.  This should solve at least 
# some of the fixme problems for fMARC8ToUTF8().
# 
# Problems remain if there are MARC 21 records where 000/09 is set incorrectly. 
# -- thd.
# MARC::Charset->ignore_errors(1);

use C4::Context;
use C4::Biblio;
use C4::Items;
use Unicode::Normalize;
use Time::HiRes qw(gettimeofday);
use Getopt::Long;
binmode(STDOUT, ":utf8");

use Getopt::Long;

my ( $input_marc_file, $number) = ('',0);
my ($version, $delete, $test_parameter, $skip_marc8_conversion, $char_encoding, $verbose, $commit, $fk_off);

$|=1;

GetOptions(
    'commit:f'    => \$commit,
    'file:s'    => \$input_marc_file,
    'n:f' => \$number,
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    's' => \$skip_marc8_conversion,
    'c:s' => \$char_encoding,
    'v:s' => \$verbose,
    'fk' => \$fk_off,
);

# FIXME:  Management of error conditions needed for record parsing problems
# and MARC8 character sets with mappings to Unicode not yet included in 
# MARC::Charset.  The real world rarity of these problems is not fully tested.
# Unmapped character sets will throw a warning currently and processing will 
# continue with the error condition.  A fairly trivial correction should 
# address some record parsing and unmapped character set problems but I need 
# time to implement a test and correction for undef subfields and revert to 
# MARC8 if mappings are missing. -- thd
sub fMARC8ToUTF8($$) {
    my ($record) = shift;
    my ($verbose) = shift;
    
    foreach my $field ($record->fields()) {
        if ($field->is_control_field()) {
            ; # do nothing -- control fields should not contain non-ASCII characters
        } else {
            my @subfieldsArray;
            my $fieldName = $field->tag();
            my $indicator1Value = $field->indicator(1);
            my $indicator2Value = $field->indicator(2);
            foreach my $subfield ($field->subfields()) {
                my $subfieldName = $subfield->[0];
                my $subfieldValue = $subfield->[1];
                my $utf8sf = MARC::Charset::marc8_to_utf8($subfieldValue);
                unless (defined $utf8sf) {
                    # For now, we're being very strict about
                    # error during the MARC8 conversion, so return
                    # if there's a problem.
                    return;
                }
                $subfieldValue = NFC($utf8sf); # Normalization Form C to assist
                                               # some browswers (e.g., Firefox on OS X)
                                               # that have issues with decomposed characters
                                               # in certain fonts.
    
                # Alas, MARC::Field::update() does not work correctly.
                ## push (@subfieldsArray, $subfieldName, $subfieldValue);
    
                push @subfieldsArray, [$subfieldName, $subfieldValue];
            }
    
            # Alas, MARC::Field::update() does not work correctly.
            #
            # The first instance in the field of a of a repeated subfield
            # overwrites the content from later instances with the content
            # from the first instance.
            ## $field->update(@subfieldsArray);
    
            foreach my $subfieldRow(@subfieldsArray) {
                my $subfieldName = $subfieldRow->[0];
                $field->delete_subfields($subfieldName);
            }
            foreach my $subfieldRow(@subfieldsArray) {
                $field->add_subfields(@$subfieldRow);
            }
    
            if ($verbose) {
                if ($verbose >= 2) {
                    # Reading the indicator values again is not necessary.
                    # They were not converted.
                    # $indicator1Value = $field->indicator(1);
                    # $indicator2Value = $field->indicator(2);
                    # $indicator1Value =~ s/ /#/;
                    # $indicator2Value =~ s/ /#/;
                    print "\nCONVERTED TO UTF-8:\n" . $fieldName . ' ' .
                            $indicator1Value .
                    $indicator2Value;
                    foreach my $subfield ($field->subfields()) {
                        my $subfieldName = $subfield->[0];
                        my $subfieldValue = $subfield->[1];
                        print " \$" . $subfieldName . ' ' . $subfieldValue;
                    }
                }
            }
            if ($verbose) {
                if ($verbose >= 2) {
                    print "\n" if $verbose;
                }
            }
        }
    }

    # must set Leader/09 to 'a' to indicate that
    # record is now in UTF-8
    my $leader = $record->leader();
    substr($leader, 9, 1) = 'a';
    $record->leader($leader);

    $record->encoding('UTF-8');
    return 1;
}


if ($version || ($input_marc_file eq '')) {
    print <<EOF
small script to import an iso2709 file into Koha.
parameters :
\th : this version/help screen
\tfile /path/to/file/to/dump : the file to import
\tv : verbose mode. 1 means "some infos", 2 means "MARC dumping"
\tfk : Turn off foreign key checks during import.
\tn : the number of records to import. If missing, all the file is imported
\tcommit : the number of records to wait before performing a 'commit' operation
\tt : test mode : parses the file, saying what he would do, but doing nothing.
\ts : skip automatic conversion of MARC-8 to UTF-8.  This option is 
\t    provided for debugging.
\tc : the characteristic MARC flavour. At the moment, only MARC21 and UNIMARC 
\tsupported. MARC21 by default.
\td : delete EVERYTHING related to biblio in koha-DB before import  :tables :
\t\tbiblio, \tbiblioitems,\titems
IMPORTANT : don't use this script before you've entered and checked your MARC parameters tables twice (or more!).
Otherwise, the import won't work correctly and you will get invalid data.

SAMPLE : 
\t\$ export KOHA_CONF=/etc/koha.conf
\t\$ perl misc/migration_tools/bulkmarcimport.pl -d -commit 1000 -file /home/jmf/koha.mrc -n 3000
EOF
;#'
exit;
}

my $dbh = C4::Context->dbh;

# save the CataloguingLog property : we don't want to log a bulkmarcimport. It will slow the import & 
# will create problems in the action_logs table, that can't handle more than 1 entry per second per user.
my $CataloguingLog = C4::Context->preference('CataloguingLog');
$dbh->do("UPDATE systempreferences SET value=0 WHERE variable='CataloguingLog'");

if ($delete) {
    print "deleting biblios\n";
    $dbh->do("truncate biblio");
    $dbh->do("truncate biblioitems");
    $dbh->do("truncate items");
    $dbh->do("truncate zebraqueue");
}
if ($fk_off) {
	$dbh->do("SET FOREIGN_KEY_CHECKS = 0");
}
if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

my $marcFlavour = C4::Context->preference('marcflavour') || 'MARC21';

print "Characteristic MARC flavour: $marcFlavour\n" if $verbose;
my $starttime = gettimeofday;
my $batch = MARC::Batch->new( 'USMARC', $input_marc_file );
$batch->warnings_off();
$batch->strict_off();
my $i=0;
my $commitnum = 50;

if ($commit) {

$commitnum = $commit;

}

my $dbh = C4::Context->dbh();
$dbh->{AutoCommit} = 0;
RECORD: while ( my $record = $batch->next() ) {
    $i++;
    print ".";
    print "\r$i" unless $i % 100;

    if ($record->encoding() eq 'MARC-8' and not $skip_marc8_conversion) {
        unless (fMARC8ToUTF8($record, $verbose)) {
            warn "ERROR: failed to perform character conversion for record $i\n";
            next RECORD;            
        }
    }

    unless ($test_parameter) {
        my ( $bibid, $oldbibitemnum, $itemnumbers_ref, $errors_ref );
        eval { ( $bibid, $oldbibitemnum, $itemnumbers_ref, $errors_ref ) = AddBiblioAndItems( $record, '' ); };
        if ( $@ ) {
            warn "ERROR: Adding biblio and or items $bibid failed: $@\n";
        } 
        if ($#{ $errors_ref } > -1) { 
            report_item_errors($bibid, $errors_ref);
        }

        $dbh->commit() if (0 == $i % $commitnum);
    }
    last if $i == $number;
}
$dbh->commit();


if ($fk_off) {
	$dbh->do("SET FOREIGN_KEY_CHECKS = 1");
}

# restore CataloguingLog
$dbh->do("UPDATE systempreferences SET value=$CataloguingLog WHERE variable='CataloguingLog'");

my $timeneeded = gettimeofday - $starttime;
print "$i MARC records done in $timeneeded seconds\n";

exit 0;

sub report_item_errors {
    my $bibid = shift;
    my $errors_ref = shift;

    foreach my $error (@{ $errors_ref }) {
        my $msg = "Item not added (bib $bibid, item tag #$error->{'item_sequence'}, barcode $error->{'item_barcode'}): ";
        my $error_code = $error->{'error_code'};
        $error_code =~ s/_/ /g;
        $msg .= "$error_code $error->{'error_information'}";
        print $msg, "\n";
    }
}
