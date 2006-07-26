#!/usr/bin/perl

#----------------------------------------------------------------------
# this script is really divided into 2 differenvt section,

# the first section creates, and defines the new PDF file the barcodes
# using PDF::Reuse::Barcode, then saves the file to disk.

# the second section then opens the pdf file off disk, and places the spline label
# text in the left-most column of the page. then save the file again.

# the reason for this goofyness, it that i couldnt find a single perl package that handled both barcodes and decent text placement.

#use lib '/usr/local/opus-import/intranet/modules';
#use C4::Context("/etc/koha-opus-import.conf");

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use PDF::Report;
use POSIX;

#use Data::Dumper;
#use Acme::Comment;

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

# dimensions of gaylord paper
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = 612;
my $upperRightY = 792;

# setting up the pdf doc
#remove the file before write, for testing
unlink "$htdocs_path/barcodes/new.pdf";
prFile("$htdocs_path/barcodes/new.pdf");
prLogDir("$htdocs_path/barcodes");
prMbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );
prFont('Times-Roman');    # Just setting a font
prFontSize(10);

my $margin       = 36;
my $label_height = 90;
my $spine_width  = 72;
my $circ_width   = 207;
my $colspace     = 27;
my $x_pos_spine  = 36;
my $x_pos_circ1  = 135;
my $x_pos_circ2  = 369;
my $pageheight   = 792;

#warn "STARTROW = $startrow\n";

my $y_pos_initial = ( ( $pageheight - $margin ) - $label_height );
my $y_pos_initial_startrow =
  ( ( $pageheight - $margin ) - ( $label_height * $startrow ) );
my $y_pos = $y_pos_initial_startrow;

#warn "Y POS INITAL : $y_pos_initial";
#warn "Y POS : $y_pos";
#warn "Y START ROW = $y_pos_initial_startrow";

my $rowspace         = 36;
my $page_break_count = $startrow;
my $codetype         = 'Code39';

# do border---------------
my $str = "q\n";    # save the graphic state
$str .= "4 w\n";                # border color red
$str .= "0.0 0.0 0.0  RG\n";    # border color red
$str .= "1 1 1 rg\n";           # fill color blue
$str .= "0 0 612 792 re\n";     # a rectangle
$str .= "B\n";                  # fill (and a little more)
$str .= "Q\n";                  # save the graphic state

# do border---------------

prAdd($str);
my $item;

# for loop
my $i2 = 1;
foreach $item (@resultsloop) {
    if ( $i2 == 1 && $guidebox == 1 ) {
        draw_boundaries(
            $x_pos_spine, $x_pos_circ1,  $x_pos_circ2, $y_pos,
            $spine_width, $label_height, $circ_width
        );
    }

    #warn Dumper $item->{'itemtype'};
    #warn "COUNT = $cnt1";

    #building up spine text
    my $line        = 75;
    my $line_spacer = 16;

    #warn
    "COUNT=$i2, PBREAKCNT=$page_break_count, X,Y POS x=$x_pos_circ1, y=$y_pos";
    if ( $printingtype eq 'barcode' || $printingtype eq 'both' ) {
        build_circ_barcode( $x_pos_circ1, $y_pos, $item->{'barcode'},
            $conf_data->{'barcodetype'}, \$item );
        build_circ_barcode( $x_pos_circ2, $y_pos, $item->{'barcode'},
            $conf_data->{'barcodetype'}, \$item );
    }

# added for xpdf compat. doesnt use type3 fonts., but increases filesize from 20k to 200k
# i think its embedding extra fonts in the pdf file.
#	mode => 'graphic',

    $y_pos = ( $y_pos - $label_height );

    # the gaylord labels have 8 rows per sheet, this pagebreaks after 8 rows
    if ( $page_break_count == 8 ) {
        prPage();
        $page_break_count = 0;
        $i2               = 0;
        $y_pos            = $y_pos_initial;
    }
    $page_break_count++;
    $i2++;
}
############## end of loop
prEnd();

#----------------------------------------------------------------------------
# this second section of the script uses a diff perl class than the previous section
# it opens the 'new.pdf' file that the previous section has just saved

if ( $printingtype eq 'spine' || $printingtype eq 'both' ) {
    my $font        = 'Courier';
    my $text_height = 90;
    my $file        = "$htdocs_path/barcodes/new.pdf";
    my $pdf         = new PDF::Report( File => $file );

    #$pdf->newpage($nopage);
    my $pagenumber = 1;
    $pdf->openpage($pagenumber);
    my ( $pagewidth, $pageheight ) = $pdf->getPageDimensions();

    #warn "PAGE DIM = $pagewidth, $pageheight";
    #warn "Y START ROW = $y_pos_initial_startrow";
    $pdf->setAlign('left');
    $pdf->setFont($font);
    $pdf->setSize(9);
    my $fontname         = $pdf->getFont();
    my $fontsize         = $pdf->getSize();
    my $page_break_count = $startrow;

    #warn "INIT PAGEBREAK COUNT = $page_break_count";
    #warn "INIT VPOS = $vPos, hPos = $hPos";
    my $vPosSpacer     = 10;
    my $start_text_pos = 39;   # ( 36 - 5 = 31 ) 5 is an inside border for text.
    my $spine_label_text_with = 67;
    my $y_pos                 = ( $y_pos_initial_startrow + 90 );

    #warn "Y POS = $y_pos";
    foreach $item (@resultsloop) {

        # add your printable fields manually in here
        my @fields =
          qw (dewey isbn classification itemtype subclass itemcallnumber);
        my $vPos = $y_pos;
        my $hPos = 36;
        foreach my $field (@fields) {

            # if the display option for this field is selected in the DB,
            # and the item record has some values for this field, display it.
            if ( $conf_data->{"$field"} && $item->{"$field"} ) {

                # chop the string up into 12 char's per line
                $str = $item->{"$field"};
                my $strlen    = length($str);
                my $num_lines = ceil( $strlen / 12 );
                my $start_pos = 0;
                my $len       = 12;

                # then loop for each string line
                for ( 1 .. $num_lines ) {
                    $pdf->setAddTextPos( $hPos, $vPos - 10 );
                    my $chop_str = substr( $str, $start_pos, $len );
                    my ( $h, $v ) = $pdf->getAddTextPos();

                    # using '1000' width, so that addText wont use it's
                    # own internal wordwrap, (as it doesnt work so well)
                    $pdf->addText( $chop_str, 10, 1000, 90 );

                    $start_pos = $start_pos + $len;
                    $vPos      = $vPos - 10;
                }
            }    # if field is valid
        }    #foreach feild
        $y_pos = ( $y_pos - $label_height );

        if ( $page_break_count == 8 ) {
            $pagenumber++;
            $pdf->openpage($pagenumber);
            $page_break_count = 0;
            $i2               = 0;
            $y_pos            = ( $y_pos_initial + 90 );
        }    # end if
        $page_break_count++;
        $i2++;
    }    # end of foreach result loop
    $pdf->saveAs($file);
}
print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");
