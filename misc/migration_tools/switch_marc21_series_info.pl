#!/usr/bin/perl

use strict;
use warnings;

# Script to switch the MARC21 440$anv and 490$av information

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Biblio;
use C4::Context;
use Getopt::Long;

my $commit;
my $update_frameworks;
my $show_help;
my $verbose;
my $result = GetOptions(
    'c'      => \$commit,
    'm'      => \$update_frameworks,
    'h|help' => \$show_help,
    'v'      => \$verbose,
    );

if ( ! $result || $show_help ) {
    print_usage();
    exit 0;
}

my $dbh = C4::Context->dbh;

my $count_sth = $dbh->prepare( 'SELECT COUNT(biblionumber) FROM biblio CROSS JOIN biblioitems USING (biblionumber) WHERE ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="a"]\') OR ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="v"]\') OR ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="n"]\') OR ExtractValue(marcxml,\'//datafield[@tag="490"]/subfield[@code="a"]\') OR ExtractValue(marcxml,\'//datafield[@tag="490"]/subfield[@code="v"]\')' );

my $bibs_sth = $dbh->prepare( 'SELECT biblionumber FROM biblio CROSS JOIN biblioitems USING (biblionumber) WHERE ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="a"]\') OR ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="v"]\') OR ExtractValue(marcxml,\'//datafield[@tag="440"]/subfield[@code="n"]\') OR ExtractValue(marcxml,\'//datafield[@tag="490"]/subfield[@code="a"]\') OR ExtractValue(marcxml,\'//datafield[@tag="490"]/subfield[@code="v"]\')' );

unless ( $commit ) {
    print_usage();
}

print "Examining MARC records...\n";
$count_sth->execute();
my ( $num_records ) = $count_sth->fetchrow;

unless ( $commit ) {
    if ( $num_records ) {
        print "This action would change $num_records MARC records\n";
    }
    else {
        print "There appears to be no series information to change\n";
    }
    exit 0;
}

print "Changing $num_records MARC records...\n";

$bibs_sth->execute();
while ( my ( $biblionumber ) = $bibs_sth->fetchrow ) {
    my $framework = GetFrameworkCode( $biblionumber ) || '';
    my ( @newfields );

    #  MARC21 specific
    my ( $series1_t, $series1_f ) = ( '440', 'a' );
    my ( $volume1_t, $volume1_f ) = ( '440', 'v' );
    my ( $number1_t, $number1_f ) = ( '440', 'n' );

    my ( $series2_t, $series2_f ) = ( '490', 'a' );
    my ( $volume2_t, $volume2_f ) = ( '490', 'v' );

    # Get biblio marc
    my $biblio = GetMarcBiblio( $biblionumber );

    foreach my $field ( $biblio->field( $series1_t ) ) {
        my @newsubfields;
        my @series1 = $field->subfield( $series1_f );
        my @volume1 = $field->subfield( $volume1_f );
        my @number1 = $field->subfield( $number1_f );
        my $i = 0;
        foreach my $num ( @number1 ) {
            $volume1[$i] .= " " if ( $volume1[$i] );
            $volume1[$i++] .= $num if ( $num );
        }

        while ( @series1 || @volume1 ) {
            if ( @series1 ) {
                push @newsubfields, ( $series2_f, shift @series1 );
            }
            if ( @volume1 ) {
                push @newsubfields, ( $volume2_f, shift @volume1 );
            }
        }

        my $new_field = MARC::Field->new( $series2_t, '', '',
                                          @newsubfields );

        $biblio->delete_fields( $field );
        push @newfields, $new_field;
    }

    foreach my $field ( $biblio->field( $series2_t ) ) {
        my @newsubfields;
        my @series2 = $field->subfield( $series2_f );
        my @volume2 = $field->subfield( $volume2_f );

        while ( @series2 || @volume2 ) {
            if ( @series2 ) {
                push @newsubfields, ( $series1_f, shift @series2 );
            }
            if ( @volume2 ) {
                push @newsubfields, ( $volume1_f, shift @volume2 );
            }
        }

        my $new_field = MARC::Field->new( $series1_t, '', '',
                                          @newsubfields );

        $biblio->delete_fields( $field );
        push @newfields, $new_field;
    }
    $biblio->insert_fields_ordered( @newfields );

    ModBiblioMarc( $biblio, $biblionumber, $framework );
    if ( $verbose ) {
        print "Changing MARC for biblio number $biblionumber.\n";
    }
    else {
        print ".";
    }
}
print "\n";

if ( $update_frameworks ) {
    print "Updating Koha to MARC mappings for seriestitle and volume\n";

    # set new mappings for koha fields
    $dbh->do(
"UPDATE marc_subfield_structure SET kohafield='seriestitle'
  WHERE tagfield='490' AND tagsubfield='a'"
    );
    $dbh->do(
"UPDATE marc_subfield_structure SET kohafield='volume'
  WHERE tagfield='490' AND tagsubfield='v'"
    );

    # empty old koha fields
    $dbh->do(
"UPDATE marc_subfield_structure SET kohafield=''
  WHERE kohafield='seriestitle' AND tagfield='440' AND tagsubfield='a'"
        );
    $dbh->do(
"UPDATE marc_subfield_structure SET kohafield=''
  WHERE kohafield='volume' AND tagfield='440' AND tagsubfield='v'"
        );
}

sub print_usage {
    print <<_USAGE_;
$0: switch MARC21 440 tag and 490 tag contents

Parameters:
    -c            Commit the changes to the marc records

    -m            Also update the Koha field to MARC framework mappings for the
                  seriestitle and volume Koha fields.

    --help or -h  show this message.

_USAGE_
}
