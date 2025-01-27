#!/usr/bin/perl
# Small script that rebuilds the non-MARC DB
# Formerly named rebuildnonmarc.pl

use strict;

#use warnings; FIXME - Bug 2505

# Koha modules used
use Koha::Script;
use MARC::Record;
use C4::Charset;
use C4::Context;
use C4::Biblio qw(
    GetXmlBiblio
    TransformMarcToKoha
);
use Time::HiRes qw( gettimeofday );

use Getopt::Long qw( GetOptions );

my ( $version, $confirm );
GetOptions(
    'c' => \$confirm,
    'h' => \$version
);

if ( $version || ( !$confirm ) ) {
    print <<EOF
This script rebuilds the non-MARC fields from the MARC values.
You can/must use it when you change your mapping.

Example: you decide to map biblio.title to 200\$a (it was previously mapped to 610\$a).
Run this script or you will have strange results in the UI!

Syntax:
\t./batchRebuildBiblioTables.pl -h (or without arguments => show this screen)
\t./batchRebuildBiblioTables.pl -c (c like confirm => rebuild non-MARC fields (may take long)
EOF
        ;
    exit;
}

$| = 1;    # non-buffered output

my $dbh         = C4::Context->dbh;
my $i           = 0;
my $starttime   = gettimeofday;
my $marcflavour = C4::Context->preference('marcflavour');
my $sth         = $dbh->prepare('SELECT biblionumber, frameworkcode FROM biblio');
$sth->execute();

my @errors;
while ( my ( $biblionumber, $frameworkcode ) = $sth->fetchrow ) {
    my $marcxml = GetXmlBiblio($biblionumber);
    if ( not defined $marcxml ) {
        push @errors, $biblionumber;
        next;
    }

    $marcxml = C4::Charset::StripNonXmlChars($marcxml);
    my $record = eval { MARC::Record::new_from_xml( $marcxml, 'UTF-8', $marcflavour ); };
    if ($@) {
        push @errors, $biblionumber;
        next;
    }

    my $biblio = TransformMarcToKoha( { record => $record } );
    C4::Biblio::_koha_modify_biblio( $dbh, $biblio, $frameworkcode );
    C4::Biblio::_koha_modify_biblioitem_nonmarc( $dbh, $biblio );

    $i++;
    printf( "%lu records processed in %.2f seconds\n", $i, gettimeofday() - $starttime ) unless ( $i % 100 );
}

printf( "\n%lu records processed in %.2f seconds\n", $i, gettimeofday() - $starttime );
if ( scalar(@errors) > 0 ) {
    print "Some records could not be processed though: ", join( ' ', @errors );
}
