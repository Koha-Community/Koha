#!/usr/bin/perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 4;
use Test::NoWarnings;
use File::Temp qw|tempfile|;
use MARC::Field;
use MARC::File::XML;
use MARC::Record;
use t::lib::Mocks;

BEGIN {
    use_ok( 'C4::ImportBatch', qw( RecordsFromISO2709File RecordsFromMARCXMLFile ) );
}

t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

subtest 'RecordsFromISO2709File' => sub {
    plan tests => 4;

    my ( $errors, $recs );
    my $file = create_file( { whitespace => 1, format => 'marc' } );
    ( $errors, $recs ) = C4::ImportBatch::RecordsFromISO2709File( $file, 'biblio', 'UTF-8' );
    is( @$recs, 0, 'No records from empty marc file' );

    $file = create_file( { garbage => 1, format => 'marc' } );
    ( $errors, $recs ) = C4::ImportBatch::RecordsFromISO2709File( $file, 'biblio', 'UTF-8' );
    is( @$recs, 1, 'Garbage returns one record' );
    my @fields = @$recs ? $recs->[0]->fields : ();
    is( @fields, 0, 'That is an empty record' );

    $file = create_file( { two => 1, format => 'marc' } );
    ( $errors, $recs ) = C4::ImportBatch::RecordsFromISO2709File( $file, 'biblio', 'UTF-8' );
    is( @$recs, 2, 'File contains 2 records' );

};

subtest 'RecordsFromMARCXMLFile' => sub {
    plan tests => 3;

    my ( $errors, $recs );
    my $file = create_file( { whitespace => 1, format => 'marcxml' } );
    {
        # Ignore the following warning
        # Use of uninitialized value in concatenation (.) or string at /usr/share/perl5/MARC/File/XML.pm line 399, <__ANONIO__> chunk 1.
        # We do not want to expect it (using Test::Warn): it is a bug from MARC::File::XML
        local $SIG{__WARN__} = sub { };
        my $dup_err;
        local *STDERR;
        open STDERR, ">>", \$dup_err;
        ( $errors, $recs ) = C4::ImportBatch::RecordsFromMARCXMLFile( $file, 'UTF-8' );
        close STDERR;
    }
    is( @$recs, 0, 'No records from empty marcxml file' );

    $file = create_file( { garbage => 1, format => 'marcxml' } );
    {
        local $SIG{__WARN__} = sub { };
        my $dup_err;
        local *STDERR;
        open STDERR, ">>", \$dup_err;
        ( $errors, $recs ) = C4::ImportBatch::RecordsFromMARCXMLFile( $file, 'UTF-8' );
        close STDERR;
    }
    is( @$recs, 0, 'Garbage returns no records' );

    $file = create_file( { two => 1, format => 'marcxml' } );
    ( $errors, $recs ) = C4::ImportBatch::RecordsFromMARCXMLFile( $file, 'UTF-8' );
    is( @$recs, 2, 'File has two records' );

};

sub create_file {
    my ($params) = @_;
    my ( $fh, $name ) = tempfile( SUFFIX => '.' . $params->{format} );
    if ( $params->{garbage} ) {
        print $fh "Just some garbage\n\nAnd another line";
    } elsif ( $params->{whitespace} ) {
        print $fh "  ";
    } elsif ( $params->{two} ) {
        my $rec1 = MARC::Record->new;
        my $rec2 = MARC::Record->new;
        my $fld1 = MARC::Field->new( '245', '', '', 'a', 'Title1' );
        my $fld2 = MARC::Field->new( '245', '', '', 'a', 'Title2' );
        $rec1->append_fields($fld1);
        $rec2->append_fields($fld2);
        if ( $params->{format} eq 'marcxml' ) {
            my $str = $rec1->as_xml;

            # remove ending collection tag
            $str =~ s/<\/collection>//;
            print $fh $str;
            $str = $rec2->as_xml_record;    # no collection tag
                                            # remove <?xml> line from 2nd record, add collection
            $str =~ s/<\?xml.*\n//;
            $str .= '</collection>';
            print $fh $str;
        } else {
            print $fh $rec1->as_formatted, "\x1D", $rec2->as_formatted;
        }
    }
    close $fh;
    return $name;
}
