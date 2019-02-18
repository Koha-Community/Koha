package Koha::Util::OpenDocument;

# Copyright 2019 Biblibre
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

use Modern::Perl;

use Encode qw( decode );
use File::Temp;
use File::Basename qw( dirname );
use OpenOffice::OODoc;

use parent qw( Exporter );

our @EXPORT = qw(
  generate_ods
);

=head1 NAME

Koha::Util::OpenDocument - utility class to manage filed in Open Document Format aka OpenDocument

=head1 METHODS

=head2 generate_ods

Generate an Open Document Sheet

Arguments are file path and content as an arrayref of lines containing arrayrefs of cells.

=cut


sub generate_ods {
    my ( $filepath, $content ) = @_;

    unless ( $filepath && $content ) {
        return;
    }
    my @input_rows = @$content;
    my $nb_rows    = scalar @input_rows;
    my $nb_cols;
    if ($nb_rows) {
        $nb_cols= scalar @{ $input_rows[0] };
    }

    # Create document
    my $wdir = dirname($filepath);
    odfWorkingDirectory($wdir);
    my $odf_doc = odfDocument( file => $filepath, create => 'spreadsheet' );

    if ($nb_rows) {
        # Prepare sheet
        my $odf_sheet = $odf_doc->expandTable( 0, $nb_rows + 1, $nb_cols );
        my @odf_rows = $odf_doc->getTableRows($odf_sheet);

        # Writing
        for ( my $i = 0 ; $i < $nb_rows ; $i++ ) {
            for ( my $j = 0 ; $j < $nb_cols ; $j++ ) {
                my $cellval = $input_rows[$i][$j];
                $odf_doc->cellValue( $odf_rows[$i], $j, $cellval );
            }
        }
    }

    # Done
    $odf_doc->save();

    return $odf_doc;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Fridolin Somers <fridolin.somers@biblibre.com>

=cut
