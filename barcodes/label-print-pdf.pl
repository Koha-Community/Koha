#!/usr/bin/perl

#----------------------------------------------------------------------
# this script is really divided into 2 differenvt section,

# the first section creates, and defines the new PDF file the barcodes 
# using PDF::Reuse::Barcode, then saves the file to disk.

# the second section then opens the pdf file off disk, and places the spline label 
# text in the left-most column of the page. then save the file again.

# the reason for this goofyness, is that i couldnt find a single perl PDF package that handled both barcodes and decent text placement. 

#use lib '/usr/local/opus-dev/intranet/modules';
#use C4::Context("/etc/koha-opus-dev.conf");

#use strict;
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use PDF::Report;
#use Acme::Comment;
#use Data::Dumper;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;

my $spine_text = "";

# get the printing settings

my $dbh    = C4::Context->dbh;
my $query2 = " SELECT * FROM labels_conf LIMIT 1 ";
my $sth    = $dbh->prepare($query2);
$sth->execute();

my $conf_data = $sth->fetchrow_hashref;

# get barcode type from $conf_data
my $barcodetype = $conf_data->{'barcodetype'};
my $startrow    = $conf_data->{'startrow'};

#warn Dumper $conf_data;
#warn Dumper $barcodetype;
$sth->finish;

# get the actual items to be printed.
my @data;
my $query3 = " Select * from labels ";
my $sth    = $dbh->prepare($query3);
$sth->execute();
my @resultsloop;
my $cnt = $sth->rows;
my $i1  = 1;
while ( my $data = $sth->fetchrow_hashref ) {

    # lets get some summary info from each item
    my $query1 =
      " select * from biblio, biblioitems, items where itemnumber = ? and
                                items.biblioitemnumber=biblioitems.biblioitemnumber and
                                biblioitems.biblionumber=biblio.biblionumber";

    my $sth1 = $dbh->prepare($query1);
    $sth1->execute( $data->{'itemnumber'} );
    my $data1 = $sth1->fetchrow_hashref();

    push( @resultsloop, $data1 );
    $sth1->finish;

    $i1++;
}
$sth->finish;

# dimensions of gaylord paper
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = 612;
my $upperRightY = 792;

#----------------------------------
# setting up the pdf doc

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

#warn "STARTROW = $startrow\n";

my $y_pos_initial = ( ( $pageheight - $margin ) - $label_height );
my $y_pos_initial_startrow =
  ( ( $pageheight - $margin ) - ( $label_height * $startrow ) );

my $y_pos_initial = ( ( 792 - 36 ) - 90 );

#warn "Y POS INITAL : $y_pos_initial";
warn "Y START ROW = $y_pos_initial_startrow";

my $y_pos = $y_pos_initial_startrow;

#my $y_pos            = $y_pos_initial;
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
    if ( $i2 == 1 ) {
#        draw_boxes();
    }

    #warn Dumper $item->{'itemtype'};
    #warn "COUNT = $cnt1";

    #building up spine text
    my $line        = 75;
    my $line_spacer = 16;

    $DB::single = 1;

    #warn
    "COUNT=$i2, PBREAKCNT=$page_break_count, X,Y POS x=$x_pos_circ1, y=$y_pos";

    build_circ_barcode( $x_pos_circ1, $y_pos, $item->{'barcode'},
        $conf_data->{'barcodetype'} );
    build_circ_barcode( $x_pos_circ2, $y_pos, $item->{'barcode'},
        $conf_data->{'barcodetype'} );

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

$file = '/usr/local/opus-dev/intranet/htdocs/intranet-tmpl/barcodes/new.pdf';

my $pdf = new PDF::Report( File => $file );

# my $pdf = new PDF::Report(PageSize => "letter",
#                                  PageOrientation => "Landscape");

#$pdf->newpage($nopage);
my $pagenumber = 1;
$pdf->openpage($pagenumber);

( $pagewidth, $pageheight ) = $pdf->getPageDimensions();
warn "PAGE DIM = $pagewidth, $pageheight";
warn "Y START ROW = $y_pos_initial_startrow";
my $y_pos = ( $y_pos_initial_startrow + 90 );
warn "Y POS = $y_pos";
$pdf->setAlign('left');
$pdf->setSize(11);

my $page_break_count = $startrow;
warn "INIT PAGEBREAK COUNT = $page_break_count";

warn "#----------------------------------\n";
warn "INIT VPOS = $vPos, hPos = $hPos";

my $vPosSpacer     = 15;
my $start_text_pos = 39;    # ( 36 - 5 = 31 ) 5 is an inside border for text.
my $spine_label_text_with = 67;

foreach $item (@resultsloop) {

    #warn Dumper $item;
    warn "START Y_POS=$y_pos";
    my $firstrow = 0;

    $pdf->setAddTextPos( $start_text_pos, ( $y_pos - 20 ) );    # INIT START POS
    ( $hPos, $vPos ) = $pdf->getAddTextPos();

    my $hPosEnd = ( $hPos + $spine_label_text_with );           # 72
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
        $pdf->centerString( $hPos, $hPosEnd, $vPos, $item->{'classification'} );
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
    warn "#----------------------------------\n";

}
$DB::single = 1;
$pdf->saveAs($file);

#------------------------------------------------

print $cgi->redirect("/intranet-tmpl/barcodes/new.pdf");

# draw boxes------------------
sub draw_boxes {

    #    warn "IN DRAW_BOXES\in";
    my $y_pos_initial = ( ( 792 - 36 ) - 90 );
    my $y_pos         = $y_pos_initial;
    my $i             = 1;

    for ( $i = 1 ; $i <= 8 ; $i++ ) {

        &drawbox( $x_pos_spine, $y_pos, ($spine_width), ($label_height) );

   #warn "OLD BOXES  x=$x_pos_spine, y=$y_pos, w=$spine_width, h=$label_height";
        &drawbox( $x_pos_circ1, $y_pos, ($circ_width), ($label_height) );
        &drawbox( $x_pos_circ2, $y_pos, ($circ_width), ($label_height) );

        $y_pos = ( $y_pos - $label_height );

    }
}

# draw boxes------------------

#-----------------------------

# this is pretty ugly too.

sub build_circ_barcode {
    my ( $x_pos_circ, $y_pos, $value, $barcodetype ) = @_;

    #warn "value = $value\n";

    #$DB::single = 1;

    if ( $barcodetype eq 'EAN13' ) {

        #testing EAN13 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 12 );

        #warn $value;
        eval {
            PDF::Reuse::Barcode::EAN13(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #            prolong => 2.96,
                #            xSize   => 1.5,

                # ySize   => 1.2,

# added for xpdf compat. doesnt use type3 fonts., but increases filesize from 20k to 200k
# i think its embedding extra fonts in the pdf file.
#  mode => 'graphic',
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "EAN13BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'Code39' ) {

        eval {
            PDF::Reuse::Barcode::Code39(
                x     => ( $x_pos_circ + 9 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #           prolong => 2.96,
                xSize => .85,

                ySize => 1.3,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "CODE39BARCODE $value FAILED:$@";
        }

        #warn $barcodetype;

    }

    elsif ( $barcodetype eq 'Matrix2of5' ) {
        warn "MATRIX ELSE:";

        #testing MATRIX25  barcodes hack
        #    $value = $value.'000000000';
        $value =~ s/-//;

        #    $value = substr( $value, 0, 12 );
        #warn $value;

        eval {
            PDF::Reuse::Barcode::Matrix2of5(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #        prolong => 2.96,
                #       xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }

    elsif ( $barcodetype eq 'EAN8' ) {

        #testing ean8 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 8 );

        #warn $value;

        warn "EAN8 ELSEIF";
        eval {
            PDF::Reuse::Barcode::EAN8(
                x       => ( $x_pos_circ + 42 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }

    elsif ( $barcodetype eq 'UPC-E' ) {
        eval {
            PDF::Reuse::Barcode::UPCE(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'NW7' ) {
        eval {
            PDF::Reuse::Barcode::NW7(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'ITF' ) {
        eval {
            PDF::Reuse::Barcode::ITF(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'Industrial2of5' ) {
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'IATA2of5' ) {
        eval {
            PDF::Reuse::Barcode::IATA2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }

    elsif ( $barcodetype eq 'COOP2of5' ) {
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }
    elsif ( $barcodetype eq 'UPC-A' ) {

        eval {
            PDF::Reuse::Barcode::UPCA(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            warn "BARCODE FAILED:$@";
        }

        warn $barcodetype;

    }

}

#-----------------------------

sub drawbox {
    my ( $llx, $lly, $urx, $ury ) = @_;

    my $str = "q\n";    # save the graphic state
    $str .= "1.0 0.0 0.0  RG\n";           # border color red
    $str .= "1 1 1  rg\n";                 # fill color blue
    $str .= "$llx $lly $urx $ury re\n";    # a rectangle
    $str .= "B\n";                         # fill (and a little more)
    $str .= "Q\n";                         # save the graphic state

    prAdd($str);

}

