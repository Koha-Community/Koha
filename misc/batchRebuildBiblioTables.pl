#!/usr/bin/perl
# Small script that rebuilds the non-MARC DB
# Formerly named rebuildnonmarc.pl

use strict;
#use warnings; FIXME - Bug 2505

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::Record;
use C4::Context;
use C4::Biblio;
use Time::HiRes qw(gettimeofday);

use Getopt::Long;
my ( $input_marc_file, $number) = ('', 0);
my ($help, $confirm, $test_parameter);
my ($updateUpstream, $updateDownstream, $limitedColumns);
GetOptions(
    'c|confirm'    => \$confirm,
    'h|help'       => \$help,
    't|test'       => \$test_parameter,
    'u|upstream'   => \$updateUpstream,
    'd|downstream' => \$updateDownstream,
    'columns:s'    => \$limitedColumns,
);

my $helpText = <<EOF
This script rebuilds the non-MARC DB from the MARC values and vice versa.
You can/must use it when you change your mapping.

Example: you decide to map biblio.title to 200\$a (it was previously mapped to 610\$a).
Run this script or you will have strange results in OPAC !

 -h | --help        This friendly helper!
 -u | --upstream    Update MARC Records from the database columns using "Koha to MARC mappings".
 -d | --downstream  Update database columns from the MARC Records  using "Koha to MARC mappings".
 -c | --confirm     Confirm, that you want to batch modify all of your Bibliographic records.
                    It is better to double check your mappings now since this operation cannot be undone.
                    This will take a long time...
 -t | --test        Test only, change nothing in DB
 --columns          NOT IMPLEMENTED YET! Limit the updates to this list of table
                    columns, instead of updating all "Koha to MARC mappings".
                    Example: --columns "biblioitems.publicationyear, biblioitems.datereceived, biblio.copyrightdate"
                    Only columns for tables biblio and biblioitems are supported.

Syntax:
./batchRebuildBiblioTables.pl --help
./batchRebuildBiblioTables.pl --test --upstream
./batchRebuildBiblioTables.pl --confirm --downstream
EOF
;

if ($help) {
    print $helpText;
    exit();
}
if (not($updateUpstream) && not($updateDownstream)) {
    print $helpText."\n\nyou must choose either --upstream or --downstream !\n";
    exit();
}
if (!$confirm) {
    print $helpText."\n\nRead the help file!\n";
    exit();
}
my @limitedColumns = split(/\s*,\s*/,$limitedColumns);
if ($limitedColumns && scalar(@limitedColumns) == 0) {
    print $helpText."\n\nCouldn't parse --columns '$limitedColumns'!\n";
    exit();
}
elsif (scalar(@limitedColumns)) {
    @limitedColumns = undef;
    #TODO limited columns parsing.
}

my $dbh = C4::Context->dbh;
my $i=0;
my $starttime = time();

$|=1; # flushes output
$starttime = gettimeofday;

#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &GetMarcFromKohaField("items.itemnumber",'');
# $dbh->do("lock tables biblio write, biblioitems write, items write, marc_biblio write, marc_subfield_table write, marc_blob_subfield write, marc_word write, marc_subfield_structure write");
my $sth = $dbh->prepare("SELECT biblionumber FROM biblio");
$sth->execute;

if ($updateUpstream) {
    while (my ($biblionumber) = $sth->fetchrow) {
        DB_ToRecord($biblionumber, \@limitedColumns);
    }
    exit();
}

# my ($biblionumbermax) =  $sth->fetchrow;
# warn "$biblionumbermax <<==";
my @errors;
while (my ($biblionumber)= $sth->fetchrow) {
    #now, parse the record, extract the item fields, and store them in somewhere else.
    my $record = GetMarcBiblio($biblionumber);
    if (not defined $record) {
	push @errors, $biblionumber;
	next;
    }
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
#     print "$biblionumber\n";
    my $frameworkcode = GetFrameworkCode($biblionumber);
    localNEWmodbiblio($dbh,$record,$biblionumber,$frameworkcode) unless $test_parameter;
}
# $dbh->do("unlock tables");
my $timeneeded = time() - $starttime;
print "$i MARC record done in $timeneeded seconds\n";
if (scalar(@errors) > 0) {
    print "Some biblionumber could not be processed though: ", join(" ", @errors);
}

# modified NEWmodbiblio to jump the MARC part of the biblio modif
# highly faster
sub localNEWmodbiblio {
    my ($dbh,$record,$biblionumber,$frameworkcode) =@_;
    $frameworkcode="" unless $frameworkcode;
    my $oldbiblio = TransformMarcToKoha($record,$frameworkcode);
    C4::Biblio::_koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    C4::Biblio::_koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );
    return 1;
}

sub DB_ToRecord {
    my ($biblionumber) = @_;

    my $errors = C4::Biblio::UpdateKohaToMarc($biblionumber);
    print "bn: $biblionumber, $errors\n" if $errors;
}
