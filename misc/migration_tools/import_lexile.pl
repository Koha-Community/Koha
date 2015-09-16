#!/usr/bin/perl
#-----------------------------------
# Copyright 2015 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-----------------------------------

=head1 NAME

import_lexile.pl  Import lexile scores for records from csv.

=cut

use utf8;

use Modern::Perl;

use Getopt::Long;
use Text::CSV;

use C4::Context;
use C4::Biblio;
use C4::Koha qw( GetVariationsOfISBN );
use Koha::Database;

binmode STDOUT, ':encoding(UTF-8)';

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

my $help;
my $confirm;
my $test;
my $file;
my $verbose;
my $start;
my $end;
my $field_number                  = "521";
my $subfield_target_audience_note = "a";
my $subfield_source               = "b";
my $subfield_source_value         = "Lexile";

GetOptions(
    'h|help'                 => \$help,
    'c|confirm'              => \$confirm,
    't|test'                 => \$test,
    'f|file=s'               => \$file,
    'v|verbose+'             => \$verbose,
    's|start=s'              => \$start,
    'e|end=s'                => \$end,
    'field=s'                => \$field_number,
    'target-audience-note=s' => $subfield_target_audience_note,
    'source=s'               => $subfield_source,
    'source-value=s'         => $subfield_source_value,
);

my $usage = << 'ENDUSAGE';
import_lexile.pl: Import lexile scores for records from csv.

import_lexile.pl -f /path/to/LexileTitles.txt

This script takes the following parameters :

    -h --help               Display this help
    -c --confirm            Confirms you want to really run this script ( otherwise print help )
    -t --test               Runs the script in test mode ( no changes will be made to your database )
    -f --file               CSV file of lexile scores ( acquired from Lexile.com )
    -v --verbose            Print data on found matches. Use -v -v for more data, and -v -v -v will give the most data.
    --field                 Defines the field number for the Lexile data ( default: 521 )
    --target-audience-note  Defines the subfield for the lexile score ( default: a )
    --source                Defines the "Source" subfield ( default: b )
    --source-value          Defines the value to put stored in the "Source" subfield ( default: "Lexile" )

    The CSV file must have the following columns ( with the first line being the column headers ) in tab delimited format:
    Title, Author, ISBN, ISBN13, Lexile

ENDUSAGE

if ( $help || !$file || !$confirm ) {
    say $usage;
    exit(1);
}

my $schema = Koha::Database->new()->schema();

my $csv = Text::CSV->new( { binary => 1, sep_char => "\t" } )
  or die "Cannot use CSV: " . Text::CSV->error_diag();

open my $fh, "<:encoding(utf8)", $file or die "test.csv: $!";

my $column_names = $csv->getline($fh);
$csv->column_names(@$column_names);

my $counter = 0;
my $i       = 0;
while ( my $row = $csv->getline_hr($fh) ) {
    $i++;

    next if ( $start && $i < $start );
    last if ( $end   && $i >= $end );

    if ( $verbose > 1 ) {
        say "Searching for matching record for row $i...";
        say "Title: " . $row->{Title};
        say "Author: " . $row->{Author};
        say "ISBN10: " . $row->{ISBN};
        say "ISBN13: " . $row->{ISBN13};
        say q{};
    }

    # Match by ISBN
    my @isbns;
    for ( 'ISBN', 'ISBN13' ) {
        if ( $row->{$_} && $row->{$_} ne "None" ) {
            push( @isbns, $row->{$_} );
            eval { push( @isbns, GetVariationsOfISBN( $row->{$_} ) ) };
        }
    }
    @isbns = grep( $_, @isbns );
    next unless @isbns;

    say "Searching for ISBNs: " . join( ' : ', @isbns ) if ( $verbose > 2 );

    my @likes = map { { isbn => { like => '%' . $_ . '%' } } } @isbns;

    my @biblionumbers =
      $schema->resultset('Biblioitem')->search( { -or => \@likes } )
      ->get_column('biblionumber')->all();

    say "Found matching records! Biblionumbers: " . join( " ,", @biblionumbers )
      if ( @biblionumbers && $verbose > 2 );

    foreach my $biblionumber (@biblionumbers) {
        $counter++;
        my $record = GetMarcBiblio($biblionumber);

        if ($verbose) {
            say "Found matching record! Biblionumber: $biblionumber";

            if ( $verbose > 2 ) {
                my $biblio = GetBiblioData($biblionumber);
                say "Title from record: " . $biblio->{title}
                  if ( $biblio->{title} );
                say "Author from record: " . $biblio->{author}
                  if ( $biblio->{author} );
                say "ISBN from record: " . $biblio->{isbn}
                  if ( $biblio->{isbn} );
            }
            say "Title: " . $row->{Title};
            say "Author: " . $row->{Author};
            say "ISBN10: " . $row->{ISBN};
            say "ISBN13: " . $row->{ISBN13};
            say q{};
        }

        # Check for existing embedded lexile score
        my $lexile_score_field;
        for my $field ( $record->field($field_number) ) {
            if ( defined( $field->subfield($subfield_source) )
                && $field->subfield($subfield_source) eq
                $subfield_source_value )
            {
                $lexile_score_field = $field;
                last;    # Each item can only have one lexile score
            }
        }

        if ($lexile_score_field) {
            $lexile_score_field->update(
                ind1                           => '8',
                ind2                           => '#',
                $subfield_target_audience_note => $row->{Lexile},
                $subfield_source               => $subfield_source_value,
            );
        }
        else {
            my $field = MARC::Field->new(
                $field_number, '8', '#',
                $subfield_target_audience_note => $row->{Lexile},
                $subfield_source               => $subfield_source_value,
            );
            $record->append_fields($field);
        }

        ModBiblio( $record, $biblionumber ) unless ( $test );
    }

}
say "Update $counter records" if $verbose;
