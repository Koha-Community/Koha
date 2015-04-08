#!/usr/bin/perl

# Copyright 2013 Michael Hafen <mdhafen@tech.washk12.org>
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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
my $add_links;
my $update_frameworks;
my $show_help;
my $verbose;
my $result = GetOptions(
    'c'      => \$commit,
    'l'      => \$add_links,
    'f'      => \$update_frameworks,
    'h|help' => \$show_help,
    'v'      => \$verbose,
    );

# warn and exit if we're running UNIMARC
if (C4::Context->preference('MARCFLAVOUR') eq 'UNIMARC') {
    print "This script is useless when you're running UNIMARC\n";
    exit 0;
}
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
    print "Please run this again with the '-c' option to change the records\n";
    exit 0;
}

print "Changing $num_records MARC records...\n";

#  MARC21 specific
my %fields = (
    '440' => {
        'a' => 'title',
        'n' => 'number',
        'p' => 'part',
        'v' => 'volume',
        'x' => 'issn',
        '6' => 'link',
        '8' => 'ln',
        'w' => 'control',
        '0' => 'auth',
    },
    '490' => {
        'a' => 'title',
        'v' => 'volume',
        'x' => 'issn',
        '6' => 'link',
        '8' => 'ln',
    },
    );

$bibs_sth->execute();
while ( my ( $biblionumber ) = $bibs_sth->fetchrow ) {
    my $framework = GetFrameworkCode( $biblionumber ) || '';
    my ( @newfields );

    # Get biblio marc
    my $biblio = GetMarcBiblio( $biblionumber );

    foreach my $field ( $biblio->field( '440' ) ) {
        my @newsubfields;
        my @linksubfields;
        my $has_links = '0';
        foreach my $subfield ( sort keys %{ $fields{'440'} } ) {
            my @values = $field->subfield( $subfield );

            if ( $add_links && @values ) {
                if ( $subfield eq 'w' || $subfield eq '0' ) {
                    $has_links = '1';
                }
                foreach my $v ( @values ) {
                    push @linksubfields, ( $subfield, $v );
                }
            }

            if ( $subfield eq 'a' ) {
                my @numbers = $field->subfield( 'n' );
                my @parts = $field->subfield( 'p' );
                my $i = 0;
                while ( $i < @numbers || $i < @parts ) {
                    my @strings = grep {$_} ( $values[$i], $numbers[$i], $parts[$i] );
                    $values[$i] = join ' ', @strings;
                    $i++;
                }
            }

            if ( $fields{'490'}{$subfield} ) {
                foreach my $v ( @values ) {
                    push @newsubfields, ( $subfield, $v );
                }
            }
        }

        if ( $has_links && @linksubfields ) {
            my $link_field = MARC::Field->new(
                '830',
                $field->indicator(1), $field->indicator(2),
                @linksubfields
                );
            push @newfields, $link_field;
        }

        if ( @newsubfields ) {
            my $new_field = MARC::Field->new( '490', $has_links, '',
                                              @newsubfields );
            push @newfields, $new_field;
        }

        $biblio->delete_fields( $field );
    }

    foreach my $field ( $biblio->field( '490' ) ) {
        my @newsubfields;
        foreach my $subfield ( sort keys %{ $fields{'490'} } ) {
            my @values = $field->subfield( $subfield );

            if ( $fields{'440'}{$subfield} ) {
                foreach my $v ( @values ) {
                    push @newsubfields, ( $subfield, $v );
                }
            }
        }

        if ( @newsubfields ) {
            my $new_field = MARC::Field->new( '440', '', '',
                                              @newsubfields );
            push @newfields, $new_field;
        }

        $biblio->delete_fields( $field );
    }
    $biblio->insert_fields_ordered( @newfields );

    if ( $verbose ) {
        print "Changing MARC for biblio number $biblionumber.\n";
    }
    else {
        print ".";
    }
    ModBiblioMarc( $biblio, $biblionumber, $framework );
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
    -c            Commit the changes to the marc records.

    -l            Add 830 tags with authority information from 440.  Otherwise
                  this information will be ignored.

    -f            Also update the Koha field to MARC framework mappings for the
                  seriestitle and volume Koha fields.

    -v            Show more information as the records are being changed.

    --help or -h  show this message.

_USAGE_
}
