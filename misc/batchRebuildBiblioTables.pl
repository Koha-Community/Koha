#!/usr/bin/perl
# small script that rebuilds the non-MARC DB

use strict;
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
$starttime = gettimeofday;

#1st of all, find item MARC tag.
my ($tagfield,$tagsubfield) = &GetMarcFromKohaField("items.itemnumber",'');
# $dbh->do("lock tables biblio write, biblioitems write, items write, marc_biblio write, marc_subfield_table write, marc_blob_subfield write, marc_word write, marc_subfield_structure write, stopwords write");
my $sth = $dbh->prepare("SELECT biblionumber FROM biblio");
$sth->execute;
# my ($biblionumbermax) =  $sth->fetchrow;
# warn "$biblionumbermax <<==";
while (my ($biblionumber)= $sth->fetchrow) {
    #now, parse the record, extract the item fields, and store them in somewhere else.
    my $record = GetMarcBiblio($biblionumber);
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

# modified NEWmodbiblio to jump the MARC part of the biblio modif
# highly faster
sub localNEWmodbiblio {
    my ($dbh,$record,$biblionumber,$frameworkcode) =@_;
    $frameworkcode="" unless $frameworkcode;
    my $oldbiblio = TransformMarcToKoha($dbh,$record,$frameworkcode);
    C4::Biblio::_koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    C4::Biblio::_koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );
    return 1;
}
