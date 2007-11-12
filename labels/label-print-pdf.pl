#!/usr/bin/perl

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Output;
use C4::Context;
use HTML::Template;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use POSIX;
#use C4::Labels;
#use Smart::Comments;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;
print $cgi->header( -type => 'application/pdf', -attachment => 'barcode.pdf' );

my $spine_text = "";

#warn "label-print-pdf ***";

# get the printing settings
my $template    = GetActiveLabelTemplate();
my $conf_data   = get_label_options();

my $batch_id =   $cgi->param('batch_id');
my @resultsloop = get_label_items($batch_id);

#$DB::single = 1;

my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};
my $guidebox     = $conf_data->{'guidebox'};
my $start_label  = $conf_data->{'startlabel'};
my $fontsize     = $template->{'fontsize'};
my $units        = $template->{'units'};

### $printingtype;

=c
################### defaults for testing
my $barcodetype  = 'CODE39';
my $printingtype = 'BARBIB';
my $guidebox     = 1;
my $start_label  = 1;
my $units        = 'POINTS'
=cut

#my $fontsize = 3;

#warn "UNITS $units";
#warn "fontsize = $fontsize";
#warn Dumper $template;

my $unitvalue = GetUnitsValue($units);

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

#warn $label_cols, $label_rows;

# set the paper size
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = $page_width;
my $upperRightY = $page_height;

prInitVars();
$| = 1;
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
my $codetype; # = 'Code39';

#do page border
#drawbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

my $item;
my ( $i, $i2 );    # loop counters

# big row loop

#warn " $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY";
#warn "$label_rows, $label_cols\n";
#warn "$label_height, $label_width\n";
#warn "$page_height, $page_width\n";

my ( $rowcount, $colcount, $x_pos, $y_pos, $rowtemp, $coltemp );

if ( $start_label eq 1 ) {
    $rowcount = 1;
    $colcount = 1;
    $x_pos    = $left_margin;
    $y_pos    = ( $page_height - $top_margin - $label_height );
}

else {

    #eval {
    $rowcount = ceil( $start_label / $label_cols );

    #} ;
    #$rowcount = 1 if $@;

    $colcount = ( $start_label - ( ( $rowcount - 1 ) * $label_cols ) );

    $x_pos = $left_margin + ( $label_width * ( $colcount - 1 ) ) +
      ( $colspace * ( $colcount - 1 ) );

    $y_pos = $page_height - $top_margin - ( $label_height * $rowcount ) -
      ( $rowspace * ( $rowcount - 1 ) );

}

#warn "ROW COL $rowcount, $colcount";

#my $barcodetype; # = 'Code39';

#
#    main foreach loop
#

foreach $item (@resultsloop) {
#    warn "$x_pos, $y_pos, $label_width, $label_height";
    my $barcode = $item->{'barcode'};
    if ( $printingtype eq 'BAR' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $barcode,
            $barcodetype );
        CalcNextLabelPos();
    }
    elsif ( $printingtype eq 'BARBIB' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;

        # reposoitioning barcode up the top of label
        my $barcode_height = ($label_height / 1.5 );    ## scaling voodoo
        my $text_height    = $label_height / 2;
        my $barcode_y      = $y_pos + ( $label_height / 2.5  );   ## scaling voodoo

        DrawBarcode( $x_pos, $barcode_y, $barcode_height, $label_width,
            $barcode, $barcodetype );
        DrawSpineText( $y_pos, $text_height, $fontsize, $x_pos,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data );

        CalcNextLabelPos();

    }    # correct
    elsif ( $printingtype eq 'BIBBAR' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        my $barcode_height = $label_height / 2;
        DrawBarcode( $x_pos, $y_pos, $barcode_height, $label_width, $barcode,
            $barcodetype );
        DrawSpineText( $y_pos, $label_height, $fontsize, $x_pos,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data );

        CalcNextLabelPos();
    }

    elsif ( $printingtype eq 'ALT' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $barcode,
            $barcodetype );
        CalcNextLabelPos();
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawSpineText( $y_pos, $label_height, $fontsize, $x_pos,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data );

        CalcNextLabelPos();
    }


    elsif ( $printingtype eq 'BIB' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawSpineText( $y_pos, $label_height, $fontsize, $x_pos,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data );
        CalcNextLabelPos();
    }











}    # end for item loop
prEnd();

#
#
#
#
#
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

