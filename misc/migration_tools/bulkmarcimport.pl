#!/usr/bin/perl
# Import an iso2709 file into Koha 3

use strict;
#use warnings;
#use diagnostics;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# Koha modules used
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Record;
use MARC::Batch;
use MARC::Charset;

use C4::Context;
use C4::Biblio;
use C4::Charset;
use C4::Items;
use Unicode::Normalize;
use Time::HiRes qw(gettimeofday);
use Getopt::Long;
use IO::File;

binmode(STDOUT, ":utf8");

my ( $input_marc_file, $number, $offset) = ('',0,0);
my ($version, $delete, $test_parameter, $skip_marc8_conversion, $char_encoding, $verbose, $commit, $fk_off,$format);
my ($sourcetag,$sourcesubfield,$idmapfl);

$|=1;

GetOptions(
    'commit:f'    => \$commit,
    'file:s'    => \$input_marc_file,
    'n:f' => \$number,
    'o|offset:f' => \$offset,
    'h' => \$version,
    'd' => \$delete,
    't' => \$test_parameter,
    's' => \$skip_marc8_conversion,
    'c:s' => \$char_encoding,
    'v:s' => \$verbose,
    'fk' => \$fk_off,
    'm:s' => \$format,
    'x:s' => \$sourcetag,
    'y:s' => \$sourcesubfield,
    'idmap:s' => \$idmapfl,
);

if ($version || ($input_marc_file eq '')) {
    print <<EOF
Small script to import bibliographic records into Koha.

Parameters:
  h      this version/help screen
  file   /path/to/file/to/dump: the file to import
  v      verbose mode. 1 means "some infos", 2 means "MARC dumping"
  fk     Turn off foreign key checks during import.
  n      the number of records to import. If missing, all the file is imported
  o      file offset before importing, ie number of records to skip.
  commit the number of records to wait before performing a 'commit' operation
  t      test mode: parses the file, saying what he would do, but doing nothing.
  s      skip automatic conversion of MARC-8 to UTF-8.  This option is 
         provided for debugging.
  c      the characteristic MARC flavour. At the moment, only MARC21 and 
         UNIMARC are supported. MARC21 by default.
  d      delete EVERYTHING related to biblio in koha-DB before import. Tables:
         biblio, biblioitems, titems
  m      format, MARCXML or ISO2709 (defaults to ISO2709)
  x      source bib tag for reporting the source bib number
  y      source subfield for reporting the source bib number
  idmap  file for the koha bib and source id
  
IMPORTANT: don't use this script before you've entered and checked your MARC 
           parameters tables twice (or more!). Otherwise, the import won't work 
           correctly and you will get invalid data.

SAMPLE: 
  \$ export KOHA_CONF=/etc/koha.conf
  \$ perl misc/migration_tools/bulkmarcimport.pl -d -commit 1000 \\
    -file /home/jmf/koha.mrc -n 3000
EOF
;#'
exit;
}

if (defined $idmapfl) {
  open(IDMAP,">$idmapfl") or die "cannot open $idmapfl \n";
}

if ((not defined $sourcesubfield) && (not defined $sourcetag)){
  $sourcetag="910";
  $sourcesubfield="a";
}

my $dbh = C4::Context->dbh;

# save the CataloguingLog property : we don't want to log a bulkmarcimport. It will slow the import & 
# will create problems in the action_logs table, that can't handle more than 1 entry per second per user.
my $CataloguingLog = C4::Context->preference('CataloguingLog');
$dbh->do("UPDATE systempreferences SET value=0 WHERE variable='CataloguingLog'");

if ($fk_off) {
	$dbh->do("SET FOREIGN_KEY_CHECKS = 0");
}


if ($delete) {
    print "deleting biblios\n";
    $dbh->do("truncate biblio");
    $dbh->do("truncate biblioitems");
    $dbh->do("truncate items");
    $dbh->do("truncate zebraqueue");
}



if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

my $marcFlavour = C4::Context->preference('marcflavour') || 'MARC21';

print "Characteristic MARC flavour: $marcFlavour\n" if $verbose;
my $starttime = gettimeofday;
my $batch;
my $fh = IO::File->new($input_marc_file); # don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
if ($format =~ /XML/i) {
    # ugly hack follows -- MARC::File::XML, when used by MARC::Batch,
    # appears to try to convert incoming XML records from MARC-8
    # to UTF-8.  Setting the BinaryEncoding key turns that off
    # TODO: see what happens to ISO-8859-1 XML files.
    # TODO: determine if MARC::Batch can be fixed to handle
    #       XML records properly -- it probably should be
    #       be using a proper push or pull XML parser to
    #       extract the records, not using regexes to look
    #       for <record>.*</record>.
    $MARC::File::XML::_load_args{BinaryEncoding} = 'utf-8';
    $batch = MARC::Batch->new( 'XML', $fh );
} else {
    $batch = MARC::Batch->new( 'USMARC', $fh );
}
$batch->warnings_off();
$batch->strict_off();
my $i=0;
my $commitnum = $commit ? $commit : 50;


# Skip file offset
if ( $offset ) {
    print "Skipping file offset: $offset records\n";
    $batch->next() while ($offset--);
}

$dbh->{AutoCommit} = 0;
RECORD: while (  ) {
    my $record;
    eval { $record = $batch->next() };
    if ( $@ ) {
        print "Bad MARC record: skipped\n";
        # FIXME - because MARC::Batch->next() combines grabbing the next
        # blob and parsing it into one operation, a correctable condition
        # such as a MARC-8 record claiming that it's UTF-8 can't be recovered
        # from because we don't have access to the original blob.  Note
        # that the staging import can deal with this condition (via
        # C4::Charset::MarcToUTF8Record) because it doesn't use MARC::Batch.
        next;
    }
    last unless ( $record );
    $i++;
    print ".";
    print "\r$i" unless $i % 100;
    
    if ($record->encoding() eq 'MARC-8' and not $skip_marc8_conversion) {
        # FIXME update condition
        my ($guessed_charset, $charset_errors);
        ($record, $guessed_charset, $charset_errors) = MarcToUTF8Record($record, $marcFlavour);
        if ($guessed_charset eq 'failed') {
            warn "ERROR: failed to perform character conversion for record $i\n";
            next RECORD;            
        }
    }

    unless ($test_parameter) {
        my ( $biblionumber, $biblioitemnumber, $itemnumbers_ref, $errors_ref );
        eval { ( $biblionumber, $biblioitemnumber ) = AddBiblio($record, '', { defer_marc_save => 1 }) };
        if ( $@ ) {
            warn "ERROR: Adding biblio $biblionumber failed: $@\n";
            next RECORD;
        } 
        if (defined $idmapfl) {
          if ($sourcetag < "010"){
            if ($record->field($sourcetag)){
              my $source = $record->field($sourcetag)->data();
              printf(IDMAP "%s|%s\n",$source,$biblionumber);
            }
          } else {
            my $source=$record->subfield($sourcetag,$sourcesubfield);
            printf(IDMAP "%s|%s\n",$source,$biblionumber);
          }
       }
       
        eval { ( $itemnumbers_ref, $errors_ref ) = AddItemBatchFromMarc( $record, $biblionumber, $biblioitemnumber, '' ); };
        if ( $@ ) {
            warn "ERROR: Adding items to bib $biblionumber failed: $@\n";
            # if we failed because of an exception, assume that 
            # the MARC columns in biblioitems were not set.
            ModBiblioMarc( $record, $biblionumber, '' );
            next RECORD;
        } 
        if ($#{ $errors_ref } > -1) { 
            report_item_errors($biblionumber, $errors_ref);
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
print "\n$i MARC records done in $timeneeded seconds\n";

exit 0;

sub report_item_errors {
    my $biblionumber = shift;
    my $errors_ref = shift;

    foreach my $error (@{ $errors_ref }) {
        my $msg = "Item not added (bib $biblionumber, item tag #$error->{'item_sequence'}, barcode $error->{'item_barcode'}): ";
        my $error_code = $error->{'error_code'};
        $error_code =~ s/_/ /g;
        $msg .= "$error_code $error->{'error_information'}";
        print $msg, "\n";
    }
}
