#!/usr/bin/perl

#----------------------------------------------------------------------
# this script is really divided into 2 differenvt section,

# the first section creates, and defines the new PDF file the barcodes
# using PDF::Reuse::Barcode, then saves the file to disk.

# the second section then opens the pdf file off disk, and places the spline label
# text in the left-most column of the page. then save the file again.

# the reason for this goofyness, it that i couldnt find a single perl package that handled both barcodes and decent text placement.

#use lib '/usr/local/hlt/intranet/modules';
#use C4::Context("/etc/koha-hlt.conf");

#use strict;
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
use Data::Dumper;

#use Acme::Comment;
#use Data::Dumper;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;

my $spine_text = "";

# get the printing settings

my $conf_data   = get_label_options();
my @resultsloop = get_label_items();

warn Dumper $conf_data;


my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};
my $guidebox  = $conf_data->{'guidebox'};
my $startrow     = $conf_data->{'startrow'};

if (!$printingtype) {
	$printingtype = 'both';
}

warn $printingtype;
warn $guidebox;


#warn Dumper @resultsloop;

# dimensions of gaylord paper
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = 612;
my $upperRightY = 792;

#----------------------------------
# setting up the pdf doc

#remove the file before write, for testing
unlink "$htdocs_path/barcodes/new.pdf";

prFile("$htdocs_path/barcodes/new.pdf");
prLogDir("$htdocs_path/barcodes");

#prMbox ( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );
prMbox( 0, 0, 612, 792 );

prFont('Times-Roman');    # Just setting a font
prFontSize(10);

my $margin = 36;

my $label_height = 90;
my $spine_width  = 72;
my $circ_width   = 207;
my $colspace     = 27;

my $x_pos_spine = 36;
my $x_pos_circ1 = 135;
my $x_pos_circ2 = 369;

my $pageheight = 792;

warn "STARTROW = $startrow\n";

#my $y_pos_initial = ( ( 792 - 36 ) - 90 );
my $y_pos_initial = ( ( $pageheight - $margin ) - $label_height );
my $y_pos_initial_startrow =
  ( ( $pageheight - $margin ) - ( $label_height * $startrow ) );

my $y_pos = $y_pos_initial_startrow;

warn "Y POS INITAL : $y_pos_initial";
warn "Y POS : $y_pos";
warn "Y START ROW = $y_pos_initial_startrow";

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
    if ( $i2 == 1  && $guidebox  == 1) {
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

    $DB::single = 1;

    warn
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

        #warn "############# PAGEBREAK ###########";
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

    $file = "$htdocs_path/barcodes/new.pdf";

    my $pdf = new PDF::Report( File => $file );

    # my $pdf = new PDF::Report(PageSize => "letter",
    #                                  PageOrientation => "Landscape");

    #$pdf->newpage($nopage);
    my $pagenumber = 1;
    $pdf->openpage($pagenumber);

    ( $pagewidth, $pageheight ) = $pdf->getPageDimensions();

    #warn "PAGE DIM = $pagewidth, $pageheight";
    #warn "Y START ROW = $y_pos_initial_startrow";
    my $y_pos = ( $y_pos_initial_startrow + 90 );

    #my $y_pos = ( $y_pos_initial_startrow  );
    #warn "Y POS = $y_pos";

    # now needed now we are using centerString().
    #$pdf->setAlign('left');
    
    # SET THE FONT SIZE
    $pdf->setSize(9);

    my $page_break_count = $startrow;

    #warn "INIT PAGEBREAK COUNT = $page_break_count";

    #warn "#----------------------------------\n";
    #warn "INIT VPOS = $vPos, hPos = $hPos";

    my $vPosSpacer     = 15;
    my $start_text_pos = 39;   # ( 36 - 5 = 31 ) 5 is an inside border for text.
    my $spine_label_text_with = 67;

    foreach $item (@resultsloop) {

        #warn Dumper $item;
        #warn "START Y_POS=$y_pos";
        my $firstrow = 0;

        $pdf->setAddTextPos( $start_text_pos, ( $y_pos - 20 ) )
          ;                    # INIT START POS
        ( $hPos, $vPos ) = $pdf->getAddTextPos();

        my $hPosEnd = ( $hPos + $spine_label_text_with );    # 72
        if ( $conf_data->{'dewey'} && $item->{'dewey'} ) {
            ( $hPos, $vPos1 ) = $pdf->getAddTextPos();
            $pdf->centerString( $hPos, $hPosEnd, $vPos, $item->{'dewey'} );
            $vPos = $vPos - $vPosSpacer;
        }

        if ( $conf_data->{'isbn'} && $item->{'isbn'} ) {
            ( $hPos, $vPos1 ) = $pdf->getAddTextPos();
            $pdf->centerString( $hPos, $hPosEnd, $vPos, $item->{'isbn'} );
            $vPos = $vPos - $vPosSpacer;
        }

        if ( $conf_data->{'class'} && $item->{'classification'} ) {
            ( $hPos, $vPos1 ) = $pdf->getAddTextPos();
            $pdf->centerString( $hPos, $hPosEnd, $vPos,
                $item->{'classification'} );
            $vPos = $vPos - $vPosSpacer;
        }

        if ( $conf_data->{'itemtype'} && $item->{'itemtype'} ) {
            ( $hPos, $vPos1 ) = $pdf->getAddTextPos();
            $pdf->centerString( $hPos, $hPosEnd, $vPos, $item->{'itemtype'} );
            $vPos = $vPos - $vPosSpacer;
        }

        #$pdf->drawRect(
        #    $x_pos_spine, $y_pos,
        #    ( $x_pos_spine + $spine_width ),
        #    ( $y_pos - $label_height )
        #);

        $y_pos = ( $y_pos - $label_height );

        #warn "END LOOP Y_POS =$y_pos";
        #    warn "PAGECOUNT END LOOP=$page_break_count";
        if ( $page_break_count == 8 ) {
            $pagenumber++;
            $pdf->openpage($pagenumber);

            #warn "############# PAGEBREAK ###########";
            $page_break_count = 0;
            $i2               = 0;
            $y_pos            = ( $y_pos_initial + 90 );
        }

        $page_break_count++;
        $i2++;

        #warn "#----------------------------------\n";

    }
    $DB::single = 1;
    $pdf->saveAs($file);
}

#------------------------------------------------

print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");
