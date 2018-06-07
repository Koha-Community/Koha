#!/usr/bin/perl

use Modern::Perl;

use Getopt::Long;
use MARC::Field;
use MARC::Record;
use Pod::Usage;
use Time::HiRes qw(gettimeofday);

use C4::Context;
use C4::Biblio;
use C4::Items;

=head1 NAME

batchRebuildBiblioTables.pl - rebuilds the non-MARC DB items table from the MARC values

You can/must use it when you change items mapping.

=head1 SYNOPSIS

batchRebuildItemsTables.pl [ -h ][ -c ][ -t ][ --where ]

 Options:
   -h --help       (or without arguments) shows this help message
   -c              Confirm: rebuild non marc DB (may be long)
   -t              test only, change nothing in DB
   --where         add where condition on default query (eg. --where 'biblio.biblionumber<100')

=cut

my $count      = 0;
my $errorcount = 0;
my $starttime  = gettimeofday;
my @errors;
my ( $confirm, $help, $test_parameter, $where );
GetOptions(
    'c'       => \$confirm,
    'help|h'  => \$help,
    't'       => \$test_parameter,
    'where:s' => \$where,
) or pod2usage(2);

pod2usage(1) if $help || ( !$confirm && !$test_parameter );
print "### Database will not be modified ###\n" if $test_parameter;

#dbh
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;

#sysprefs
C4::Context->disable_syspref_cache() if ( defined( C4::Context->disable_syspref_cache() ) );
my $CataloguingLog = C4::Context->preference('CataloguingLog');
my $mergelimit     = C4::Context->preference('AuthorityMergeLimit');
$dbh->do("UPDATE systempreferences SET value=0 WHERE variable='CataloguingLog'");
$dbh->do("UPDATE systempreferences SET value=0 where variable='AuthorityMergeLimit'");
$dbh->commit() unless $test_parameter;
my ( $itemfield, $itemnumbersubfield ) = &GetMarcFromKohaField( "items.itemnumber", '' );

#dbh query init
my $query =
qq{SELECT biblio.biblionumber AS biblionumber, biblioitems.biblioitemnumber AS biblioitemnumber, biblio.frameworkcode AS frameworkcode FROM biblio JOIN biblioitems ON biblio.biblionumber=biblioitems.biblionumber};
$query .= qq{ WHERE $where } if ($where);

my $sth = $dbh->prepare($query);
$sth->execute();
while ( my ( $biblionumber, $biblioitemnumber, $frameworkcode ) = $sth->fetchrow ) {
    $count++;
    warn $count unless $count % 1000;
    my $record = GetMarcBiblio({
        biblionumber => $biblionumber,
        embed_items   => 1 });
    unless ($record) { push @errors, "bad record biblionumber $biblionumber"; next; }

    unless ($test_parameter) {
        my $rqitemnumber = $dbh->prepare("SELECT itemnumber, biblionumber from items where itemnumber = ? and biblionumber = ?");
        foreach my $itemfield ( $record->field($itemfield) ) {
            my $marcitem = MARC::Record->new();
            $marcitem->encoding('UTF-8');
            $marcitem->append_fields($itemfield);
            my $itemnum;
            my @itemnumbers = $itemfield->subfield($itemnumbersubfield);
            foreach my $itemnumber (@itemnumbers) {
                $rqitemnumber->execute( $itemnumber, $biblionumber );
                if ( my $row = $rqitemnumber->fetchrow_hashref ) { $itemnum = $row->{itemnumber}; }
            }
            eval {
                if ($itemnum) { ModItemFromMarc( $marcitem, $biblionumber, $itemnum ) }
                else          { die("$biblionumber"); }
            };
            if ($@) { warn "Problem with : $biblionumber : $@"; warn $record->as_formatted; }
        }
    }
    unless ($test_parameter) {
        $dbh->commit() unless $count % 1000;
    }
}

my $sthCataloguingLog = $dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='CataloguingLog'");
$sthCataloguingLog->execute($CataloguingLog);
my $sthmergelimit = $dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='AuthorityMergeLimit'");
$sthmergelimit->execute($mergelimit);
$dbh->commit() unless $test_parameter;
my $timeneeded = time() - $starttime;
print "$count MARC record done in $timeneeded seconds\n";
if ( scalar(@errors) > 0 ) {
    print "Some biblionumber could not be processed though: ", join( " ", @errors );
}
