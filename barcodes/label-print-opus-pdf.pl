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
use Text::Wrap;


$Text::Wrap::columns   = 39;
$Text::Wrap::separator = "\n";

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;
my $spine_text  = "";

# get the printing settings
my $conf_data    = get_label_options();
my @resultsloop  = get_label_items();
my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};
my $guidebox     = $conf_data->{'guidebox'};
my $startrow     = $conf_data->{'startrow'};

# if none selected, then choose 'both'
if ( !$printingtype ) {
    $printingtype = 'both';
}

# opus paper dims. in *millimeters*
# multiply values by '2.83465', to find their value in Postscript points.

# $xmargin           = 12;
# $label_height     = 34;
# $label_width      = 74;
# $x_pos_spine      = 12;
# $pageheight       = 304;
# $pagewidth       = 174;
# $line_spacer      = 10;
# $label_rows       = 8;

# sheet dimensions in PS points.

my $top_margin       = 7;
my $left_margin      = 34;
my $top_text_margin  = 20;
my $left_text_margin = 10;
my $label_height     = 96;
my $spine_width      = 210;
my $colspace         = 9;
my $rowspace         = 11;
my $x_pos_spine      = 36;
my $pageheight       = 861;
my $pagewidth        = 493;
my $line_spacer      = 10;
my $label_rows       = 8;

# setting up the pdf doc
#remove the file before write, for testing
#unlink "$htdocs_path/barcodes/new.pdf";
#prFile("$htdocs_path/barcodes/new.pdf");
#prLogDir("$htdocs_path/barcodes");

# fix, no longer writes to temp dir
prInitVars();    # To initiate ALL global variables and tables
$| = 1;
print STDOUT "Content-Type: application/pdf \n\n";
prFile();

prMbox( 0, 0, $pagewidth, $pageheight );
prFont('courier');    # Just setting a font
prFontSize(9);

my $str;

my $y_pos_initial = ( ( $pageheight - $top_margin ) - $label_height );
my $y_pos_initial_startrow =
  ( ( $pageheight - $top_margin ) - ( $label_height * $startrow ) );
my $y_pos = $y_pos_initial_startrow;

my $page_break_count = $startrow;
my $codetype         = 'Code39';

#do page border
# commented out coz it was running into the side-feeds of the paper.
# drawbox( 0, 0 , $pagewidth, $pageheight );

my $item;

# for loop
my $i2 = 1;

foreach $item (@resultsloop) {
    my $x_pos_spine_tmp = $x_pos_spine;

    for ( 1 .. 2 ) {

        if ( $guidebox == 1 ) {
            warn
"COUNT1, PBREAKCNT=$page_break_count,  y=$y_pos, labhght = $label_height";
            drawbox( $x_pos_spine_tmp, $y_pos, $spine_width, $label_height );
        }

        #-----------------draw spine text
        if ( $printingtype eq 'spine' || $printingtype eq 'both' ) {

            #warn "PRINTTYPE = $printingtype";

            # add your printable fields manually in here
            my @fields = qw (itemtype dewey isbn classification);
            my $vPos   = ( $y_pos + ( $label_height - $top_text_margin ) );
            my $hPos   = ( $x_pos_spine_tmp + $left_text_margin );
            foreach my $field (@fields) {

               # if the display option for this field is selected in the DB,
               # and the item record has some values for this field, display it.
                if ( $conf_data->{"$field"} && $item->{"$field"} ) {

                    #warn "CONF_TYPE = $field";

                    # get the string
                    $str = $item->{"$field"};

                    # strip out naughty existing nl/cr's
                    $str =~ s/\n//g;
                    $str =~ s/\r//g;

                    # chop the string up into _upto_ 12 chunks
                    # and seperate the chunks with newlines

                    $str = wrap( "", "", "$str" );
                    $str = wrap( "", "", "$str" );

                    # split the chunks between newline's, into an array
                    my @strings = split /\n/, $str;

                    # then loop for each string line
                    foreach my $str (@strings) {

                        warn "HPOS ,  VPOS $hPos, $vPos ";
                        prText( $hPos, $vPos, $str );
                        $vPos = $vPos - $line_spacer;
                    }
                }    # if field is valid
            }    # foreach   @field
        }    #if spine

        $x_pos_spine_tmp = ( $x_pos_spine_tmp + $spine_width + $colspace );
    }    # for 1 ..2
    warn " $y_pos - $label_height - $rowspace";
    $y_pos = ( $y_pos - $label_height - $rowspace );
    warn " $y_pos - $label_height - $rowspace";

    #-----------------draw spine text

    # the gaylord labels have 8 rows per sheet, this pagebreaks after 8 rows
    if ( $page_break_count == $label_rows ) {
        prPage();
        $page_break_count = 0;
        $i2               = 0;
        $y_pos            = $y_pos_initial;
    }
    $page_break_count++;
    $i2++;
}
prEnd();

#print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");

