#!/usr/bin/perl

#----------------------------------------------------------------------
# this script is really divided into 2 differenvt section,

# the first section creates, and defines the new PDF file the barcodes
# using PDF::Reuse::Barcode, then saves the file to disk.

# the second section then opens the pdf file off disk, and places the spline label
# text in the left-most column of the page. then save the file again.

# the reason for this goofyness, it that i couldnt find a single perl package that handled both barcodes and decent text placement.

use lib '/usr/local/opus-import/intranet/modules';
use C4::Context("/etc/koha-opus-import.conf");

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
use Text::Wrap;

#use Data::Dumper;
#use Acme::Comment;

$Text::Wrap::columns   = 15;
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
prFont('courier');    # Just setting a font
prFontSize(9);

my $margin       = 36;
my $top_text_margin  = 10;
my $left_text_margin  = 3;
my $label_height = 90;
my $spine_width  = 72;
my $circ_width   = 207;
my $colspace     = 27;
my $x_pos_spine  = 36;
my $x_pos_circ1  = 135;
my $x_pos_circ2  = 369;
my $pageheight   = 792;
my $line_spacer  = 10;
my $label_rows = 8;

my $str;

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

DrawBorder ( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

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
    if ( $printingtype eq 'barcode' || $printingtype eq 'both' ) {

        warn
"COUNT=$i2, PBREAKCNT=$page_break_count, X,Y POS x=$x_pos_circ1, y=$y_pos";

        build_circ_barcode( $x_pos_circ1, $y_pos, $item->{'barcode'},
            $conf_data->{'barcodetype'} );
        build_circ_barcode( $x_pos_circ2, $y_pos, $item->{'barcode'},
            $conf_data->{'barcodetype'} );

    }

    #-----------------draw spine text
    if ( $printingtype eq 'spine' || $printingtype eq 'both' ) {
        warn "PRINTTYPE = $printingtype";

        # add your printable fields manually in here
        my @fields =
          qw (dewey isbn classification itemtype subclass itemcallnumber);
        my $vPos = ( $y_pos + ( $label_height - $top_text_margin ) );
        my $hPos = ( $x_pos_spine + $left_text_margin );
        foreach my $field (@fields) {

            # if the display option for this field is selected in the DB,
            # and the item record has some values for this field, display it.
            if ( $conf_data->{"$field"} && $item->{"$field"} ) {

warn "CONF_TYPE = $field";

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
        }    #foreach feild
    }
        $y_pos = ( $y_pos - $label_height );

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

print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");

sub DrawBorder {
    my ( $llx, $lly, $urx, $ury ) = @_;
    $str = "q\n";    # save the graphic state
    $str .= "4 w\n";                       # border color red
    $str .= "0.0 0.0 0.0  RG\n";           # border color red
    $str .= "1 1 1 rg\n";                  # fill color blue
    $str .= "$llx $lly $urx $ury re\n";    # a rectangle
    $str .= "B\n";                         # fill (and a little more)
    $str .= "Q\n";                         # save the graphic state
    prAdd($str);

}

