#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Id$

=head1 label-print-pdf.pl

 this script is really divided into 2 differenvt section,

 the first section creates, and defines the new PDF file the barcodes
 using PDF::Reuse::Barcode, then saves the file to disk.

 the second section then opens the pdf file off disk, and places the spline label
 text in the left-most column of the page. then save the file again.

 the reason for this goofyness, it that i couldnt find a single perl package that handled both barcodes and decent text placement.

=cut

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;

use PDF::Reuse;
use PDF::Reuse::Barcode;
use POSIX;
use C4::Labels;
use Acme::Comment;


my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;
my $spine_text  = "";

# get the printing settings
my $template     = GetActiveLabelTemplate();
my $conf_data    = get_label_options();
my @resultsloop  = get_label_items();
my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};
my $guidebox     = $conf_data->{'guidebox'};
my $start_label  = $conf_data->{'startlabel'};
my $fontsize     = $template->{'fontsize'};
my $units        = $template->{'units'};

warn "UNITS $units";
warn "fontsize = $fontsize";

my $unitvalue = GetUnitsValue($units);
warn $unitvalue;
warn $units;

my $tmpl_code = $template->{'tmpl_code'};
my $tmpl_desc = $template->{'tmpl_desc'};

my $page_height  = ( $template->{'page_height'} * $unitvalue );
my $page_width   = ( $template->{'page_width'} * $unitvalue );
my $label_height = ( $template->{'label_height'} * $unitvalue );
my $label_width  = ( $template->{'label_width'} * $unitvalue );
my $spine_width  = ( $template->{'label_width'} * $unitvalue );
my $circ_width   = ( $template->{'label_width'} * $unitvalue );
my $top_margin   = ( $template->{'topmargin'} * $unitvalue );
my $left_margin  = ( $template->{'leftmargin'} * $unitvalue );
my $colspace     = ( $template->{'colgap'} * $unitvalue );
my $rowspace     = ( $template->{'rowgap'} * $unitvalue );

my $label_cols = $template->{'cols'};
my $label_rows = $template->{'rows'};

my $text_wrap_cols = GetTextWrapCols( $fontsize, $label_width );

warn $label_cols, $label_rows;

# set the paper size
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = $page_width;
my $upperRightY = $page_height;

prInitVars();
$| = 1;
print STDOUT "Content-Type: application/pdf \r\n\r\n";
prFile();

prMbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

# later feature, change the font-type and size?
prFont('C');    # Just setting a font
prFontSize($fontsize);

my $margin           = $top_margin;
my $left_text_margin = 3;

my $str;

#warn "STARTROW = $startrow\n";

#my $page_break_count = $startrow;
my $codetype = 'Code39';

#do page border
#drawbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

my $item;
my ( $i, $i2 );    # loop counters

# big row loop

warn " $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY";
warn "$label_rows, $label_cols\n";
warn "$label_height, $label_width\n";
warn "$page_height, $page_width\n";

my ( $rowcount, $colcount, $x_pos, $y_pos, $rowtemp, $coltemp );

if ( $start_label eq 1 ) {
    $rowcount = 1;
    $colcount = 1;
    $x_pos    = $left_margin;
    $y_pos    = ( $page_height - $top_margin - $label_height );
}

else {
    $rowcount = ceil( $start_label / $label_cols );
    $colcount = ( $start_label - ( ( $rowcount - 1 ) * $label_cols ) );

    $x_pos = $left_margin + ( $label_width * ( $colcount - 1 ) ) +
      ( $colspace * ( $colcount - 1 ) );

    $y_pos = $page_height - $top_margin - ( $label_height * $rowcount ) -
      ( $rowspace * ( $rowcount - 1 ) );

}

warn "ROW COL $rowcount, $colcount";

#my $barcodetype = 'Code39';

foreach $item (@resultsloop) {

    warn "-----------------";
    if ($guidebox) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height );
    }

    if ( $printingtype eq 'spine' || $printingtype eq 'both' ) {
        if ($guidebox) {
            drawbox( $x_pos, $y_pos, $label_width, $label_height );
        }

        DrawSpineText( $y_pos, $label_height, $fontsize, $x_pos,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data );
        CalcNextLabelPos();
    }

    if ( $printingtype eq 'barcode' || $printingtype eq 'both' ) {
        if ($guidebox) {
            drawbox( $x_pos, $y_pos, $label_width, $label_height );
        }

        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width,
            $item->{'barcode'}, $barcodetype );
        CalcNextLabelPos();
    }

}    # end for item loop
prEnd();

print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");

sub CalcNextLabelPos {
    if ( $colcount lt $label_cols ) {

        #        warn "new col";
        $x_pos = ( $x_pos + $label_width + $colspace );
        $colcount++;
    }

    else {
        $x_pos = $left_margin;
        if ( $rowcount eq $label_rows ) {

            #            warn "new page";
            prPage();
            $y_pos    = ( $page_height - $top_margin - $label_height );
            $rowcount = 1;
        }
        else {

            #            warn "new row";
            $y_pos = ( $y_pos - $rowspace - $label_height );
            $rowcount++;
        }
        $colcount = 1;
    }
}

