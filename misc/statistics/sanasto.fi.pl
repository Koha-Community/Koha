#!/usr/bin/perl

# Copyright Koha-Suomi 2017
#
# This file is part of Koha.
#


use 5.18.0;
use utf8;

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Text::CSV;
use Getopt::Long;
use DateTime;

use C4::Biblio;
use C4::Context;
use C4::Charset;

use Koha::Exception::Search;

my $help;
my $verbose;
my $kohaOrganization = 'KohaLand';
my $year = DateTime->now(time_zone => C4::Context->tz)->subtract(years => 1)->year();
my $testk;
my $limit = 9999999999999; #Rather unlimited

GetOptions(
    'h|help'           => \$help,
    'v|verbose'        => \$verbose,
    'o|organization:s' => \$kohaOrganization,
    'y|year:s'         => \$year,
    't|test'           => \$testk,
    'l|limit:i'        => \$limit,
);
my $usage = << 'ENDUSAGE';

This script generates a .csv-file requested by Sanasto.fi on year 2017.
See the git commit for the spec.

This script has the following parameters :

    -h --help       This message

    -v --verbose    More chatty script.

    -y --year       Which year we run these statistics for? Defaults to last year.

    -o --organization Which organization's Sanasto.fi -report this is? Will be prepended
                    to the report's filename.
                    eg. vaara.sanasto.fi.2017.csv

    -t --test       Run with selected test biblios

    -l --limit      Work through this many biblios

EXAMPLES:

    misc/statistics/sanasto.fi.pl -o vaara -y 2017
    misc/statistics/sanasto.fi.pl -l 10

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}




{
package Sanasto;

my %report; #Store reports here grouped by the host record biblionumber

sub runReport {
    my $biblionumbersAndCounts = getCirculatedBibliosAndTotals();
    my $counterTotal = @$biblionumbersAndCounts;
    my $counter = 1;
    foreach my $tuple (@$biblionumbersAndCounts) {
        print $counter++." / $counterTotal\n";
        #Get host record
        my $r = GetMarcBiblio($tuple->[0]);
        unless ($r) {
            warn "Missing record for biblionumber: ".$tuple->[0];
            next;
        }

        setColumns($r, $tuple->[1]);

        #Get component records
        eval {
            my $componentRecords = getComponentParts($r);
            foreach my $cr (@$componentRecords) {
                setColumns($cr, $tuple->[1], $r);
            }
        };
        if ($@) {
            warn $@;
        }
    }
    writeToCsv(\%report);
}

sub setColumns {
    my ($r, $totalCirculation, $hostRecord) = @_;
    my $biblionumber = $r->subfield('999','c');
    print "bn: '$biblionumber' - setColumn()\n" if $verbose;

=head2    Tyyppi
    Tietueen tyypi:
    1 = Varsinainen lainattu nimeke (teoksen ilmentymä)
    2 = Lainatun nimekkeen osakohde, esim musiikki-cd:n raita, kirjan kappale.
=cut
    my $type = ($r->subfield('773','w')) ? 2 : 1;
    $type = 2 if ($hostRecord);

=head2 Aineistokoodi
MARC-standardin ylimmän tason aineistolajijaottelu MARC-tietueen positiosta 6. Aineistolajit on listattu taulukon alapuolella.
=cut
    my $typeOfRecord = substr($r->leader(), 6, 1);

=head2 Kohde
MARC-standardin mukainen tietueen bibliografinen taso tietueen nimiön positiosta 7. Listaus arvoista taulukon jälkeen.
Periaatteessa osakohteella pitäisi olla ’a’ tai ’b’. Jos tässä on ristiriitaa, niin tietueen tyyppi ensimmäisessä sarakkeessa on määräävämpi.
=cut
    my $bibliographicLevel = substr($r->leader(), 7, 1);
    $bibliographicLevel = 'a' if ($type == 2 && $bibliographicLevel !~ /^[ab]$/);

=head2 Emotunnus
Lainautun nimekkeen tunnus
=cut
    my $hostDatabaseIdentifier;
    if ($type == 2) {
        eval {
            $hostDatabaseIdentifier = $hostRecord->subfield('999','c');
        };
        if ($@) {
            warn "Component part bn: '".$r->subfield('999','c')."' has Items and is checked out?";
            $hostDatabaseIdentifier = $r->subfield('999','c');
        }
    }
    else {
        $hostDatabaseIdentifier = $r->subfield('999','c');
    }

=head2 Tunnus
Samakuin emotunnus jos emonimeke, muutoin osakohteen tunnus. Osakohderiveillä on myös lainamäärä, vaikka kyseessä ei ole itsessään lainattavissa oleva yksikkö.
=cut
    my $databaseIdentifier = $r->subfield('999','c');

=head2 Vuosi
Vuosi, jonka lainoista on kyse
=cut
    my $year = $year;

=head2 Nimeke
Nimeketieto kentästä 245, ellei kyseessä ole yhtenäistetty nimeke
=cut
    my $title = _sanitate(C4::Biblio::GetMarcTitle($r));

=head2 Tunnisteet
ISBN- ja ISSN-tunnisteet kentistä 020 ja 022.
Myös muut tunnisteet kentästä 024 ja 028.
Mikäli mahdollista, tunnisteissa ei olisi muita merkintöjä kuin itse tunnisteet.
=cut
    my $stdid = _mashFields($r, '020', '022', '024', '028');

=head2 Päätekijä
MARC 100, 110 ja 111
=cut
    my $author = _mashFields($r, '100', '110', '111');

=head2 Kääntäjä
MARC 110, 110, 700, 710 tai 711
=cut
    my $translator = _mashFields($r, '110', '700', '710', '711');

=head2 Muut tekijät
MARC 700, 710 tai 711
=cut
    my $otherAuthors = _mashFields($r, '700', '710', '711');

=head2 Luokka
MARC 084
=cut
    my $callNumber = _mashFields($r, '084');

=head2 Kustantaja
MARC 260b
=cut
    my $publisher = _sanitate($r->subfield($r, '260c'));

=head2 Asiasanasto
MARC 650, mikäli sanastona YSA
=cut
    my $subjectAddedEntries = _mashFields($r, '650');

=head2 Lainamäärä
Nimekkeen lainamäärä
=cut
    my $totalCirc = $totalCirculation;


    my $reportRow = [
        $type, $typeOfRecord, $bibliographicLevel, $hostDatabaseIdentifier, $databaseIdentifier, $year, $title, $stdid, $author, $translator, $otherAuthors, $callNumber, $publisher, $subjectAddedEntries, $totalCirc
    ];
    print "bn: '$biblionumber' - setColumn() \$reportRow '@$reportRow'\n" if $verbose;
    #Store the host record information
    $report{$hostDatabaseIdentifier}->{host} = $reportRow if $type == 1;
    $report{$hostDatabaseIdentifier}->{children}->{$databaseIdentifier} = $reportRow if $type == 2;
}

sub _mashFields {
    my ($r, @fieldTags) = @_;

    my @datas;
    foreach my $fieldTag (@fieldTags) {
        my @fieldRepetitions = $r->field($fieldTag);
        foreach my $field (@fieldRepetitions) {
            my @subfields = $field->subfields();
            foreach my $sf (@subfields) {
                $sf->[1] = _sanitate($sf->[1]);
                push(@datas, $fieldTag.$sf->[0].' '.$sf->[1]);
            }
        }
    }
    return join(';', @datas);
}

sub _sanitate {
    my ($string) = @_;
    $string =~ s/;/:/;
    $string =~ s/"/'/;
    return $string;
}

=head2 getCirculatedBibliosAndTotals

@RETURNS ArrayRef of ArrayRefs, list of [biblionumber, totalCirculation] -tuples

=cut

sub getCirculatedBibliosAndTotals {
    my $dbh = C4::Context->dbh;
    print "getCirculatedBibliosAndTotals() is starting. This will take 2 minutes.\n" if $verbose;

    if ($testk) {
        return [
            [346554, 54],
            [355211, 23],
            [233234, 12],
        ];
    }

    my $sth = $dbh->prepare("SELECT i.biblionumber, count(s.type) FROM statistics s LEFT JOIN items i ON s.itemnumber = i.itemnumber WHERE type IN ('issue', 'renew') AND YEAR(datetime) = ? GROUP BY i.biblionumber LIMIT ?;");
    $sth->execute($year, $limit);
    my $rows = $sth->fetchall_arrayref();
    my $err = $sth->err;
    die $err if $err;

    print "getCirculatedBibliosAndTotals() is returning '".scalar(@$rows)."' rows without crashing.\n" if $verbose;
    return $rows;
}

sub getComponentParts {
    my ($r) = @_;
    my ($parentsField001, $parentsField003, $parentrecord, $error, $componentPartRecordXMLs, $resultSetSize) = C4::Biblio::_getComponentParts($r->field('001')->data(), $r->field('003')->data());

    my $marcflavour = C4::Context->preference('marcflavour');

    my @marcRecords;
    if ($resultSetSize && !$error) {
        foreach my $componentRecordXML (@$componentPartRecordXMLs) {
            my $marcRecord = MARC::Record->new_from_xml( $componentRecordXML, 'UTF-8', $marcflavour );
            push @marcRecords, $marcRecord;
        }
    }
    die $error if $error;
    print "bn: '".$r->subfield('999', 'c')."' - getComponentParts() has '".scalar(@marcRecords)."' component parts\n" if $verbose;
    return \@marcRecords;
}


sub writeToCsv {
    my ($report) = @_;

    my $headerCols = [
        'Tyyppi',
        'Aineistokoodi',
        'Kohde',
        'Emotunnus',
        'Tunnus',
        'Vuosi',
        'Nimeke',
        'Tunnisteet',
        'Päätekijä',
        'Kääntäjä',
        'Muut tekijät',
        'Luokka',
        'Kustantaja',
        'Asiasanasto',
        'Lainamäärä',
    ];

    my $csv = Text::CSV->new({eol => "\n",
                              sep_char => "\t",
                              always_quote => 'true',
                             });
    my $filename = "$kohaOrganization.sanasto.fi.$year.csv";
    open(my $fh, ">:encoding(utf8)", $filename) or die "$filename: $!";

    $csv->print($fh, $headerCols);

    while(my($biblionumber, $reportCell) = each(%$report)) {
        $csv->print($fh, $reportCell->{host});
        if ($reportCell->{children}) {
            while(my($componentBiblionumber, $componentRecordData) = each(%{$reportCell->{children}})) {
                eval {
                    $csv->print($fh, $componentRecordData);
                };
                if ($@) {
                    warn "bn: $biblionumber - writeToCsv() Component record '$componentBiblionumber' had an error printing to .csv:\n$@";
                }
            }
        }
    }

    close $fh or die "$filename: $!";
}

sub GetMarcBiblio {
    my $biblionumber = shift;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare("SELECT metadata FROM biblio_metadata WHERE biblionumber=? ");
    $sth->execute($biblionumber);
    my $row     = $sth->fetchrow_hashref;
    unless ($row) {
        $sth          = $dbh->prepare("SELECT metadata FROM deletedbiblio_metadata WHERE biblionumber=? ");
        $sth->execute($biblionumber);
        $row     = $sth->fetchrow_hashref;
    }
    return undef unless $row;
    my $marcxml = C4::Charset::StripNonXmlChars( $row->{'metadata'} );
    MARC::File::XML->default_record_format( C4::Context->preference('marcflavour') );
    my $record = MARC::Record->new();

    if ($marcxml) {
        $record = eval { MARC::Record::new_from_xml( $marcxml, "utf8", C4::Context->preference('marcflavour') ) };
        if ($@) { warn " problem with :$biblionumber : $@ \n$marcxml"; }
        return unless $record;

        C4::Biblio::_koha_marc_update_bib_ids($record, '', $biblionumber, $biblionumber);

        return $record;
    } else {
        return;
    }
}

} #EOF package Sanasto;



Sanasto::runReport();
