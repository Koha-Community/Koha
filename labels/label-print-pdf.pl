#!/usr/bin/perl

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Branch;
use HTML::Template::Pro;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use POSIX;
use Data::Dumper;
#use Smart::Comments;

my $DEBUG = 0;
my $DEBUG_LPT = 0;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;
print $cgi->header( -type => 'application/pdf', -attachment => 'barcode.pdf' );

my $spine_text = "";

#warn "label-print-pdf ***";

# get the printing settings
my $template    = GetActiveLabelTemplate();
my $conf_data   = get_label_options();
my $profile     = GetAssociatedProfile($template->{'tmpl_id'});

my $batch_id =   $cgi->param('batch_id');
my @resultsloop;

#$DB::single = 1;

my $batch_type   = $conf_data->{'type'};
my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};
my $guidebox     = $conf_data->{'guidebox'};
my $start_label  = $conf_data->{'startlabel'};
if ($cgi->param('startlabel')) {
        $start_label = $cgi->param('startlabel');       # A bit of a hack to allow setting the starting label from the address bar... -fbcit
    }
warn "Starting on label #$start_label" if $DEBUG;
my $units        = $template->{'units'};

if ($printingtype eq 'PATCRD') {
    @resultsloop = GetPatronCardItems($batch_id);
} else {
    @resultsloop = GetLabelItems($batch_id);
}

#warn "UNITS $units";
#warn "fontsize = $fontsize";
#warn Dumper $template;

my $unitvalue = GetUnitsValue($units);
my $prof_unitvalue = GetUnitsValue($profile->{'unit'});

warn "Template units: $units which converts to $unitvalue PostScript Points" if $DEBUG;
warn "Profile units: $profile->{'unit'} which converts to $prof_unitvalue PostScript Points" if $DEBUG;

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

warn "Converted dimensions are:" if $DEBUG;
warn "pghth=$page_height, pgwth=$page_width, lblhth=$label_height, lblwth=$label_width, spinwth=$spine_width, circwth=$circ_width, tpmar=$top_margin, lmar=$left_margin, colsp=$colspace, rowsp=$rowspace" if $DEBUG;

my $label_cols = $template->{'cols'};
my $label_rows = $template->{'rows'};

my $margin           = $top_margin;
my $left_text_margin = 3;       # FIXME: This value should not be hardcoded
my $str;

prInitVars();
$| = 1;
prFile();

# Some peritent notes from PDF::Reuse regarding prFont()...
# If a font wasn't found, Helvetica will be set.
# These names are always recognized: Times-Roman, Times-Bold, Times-Italic, Times-BoldItalic, Courier, Courier-Bold,
#   Courier-Oblique, Courier-BoldOblique, Helvetica, Helvetica-Bold, Helvetica-Oblique, Helvetica-BoldOblique
# They can be abbreviated: TR, TB, TI, TBI, C, CB, CO, CBO, H, HB, HO, HBO

my $fontsize    = $template->{'fontsize'};
my $fontname    = $template->{'font'};

my $text_wrap_cols = GetTextWrapCols( $fontname, $fontsize, $label_width, $left_text_margin );

#warn $label_cols, $label_rows;

# set the paper size
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = $page_width;
my $upperRightY = $page_height;

prMbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

#warn "STARTROW = $startrow\n";

#my $page_break_count = $startrow;
my $codetype; # = 'Code39';

#do page border
# drawbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

# draw margin box for alignment page
drawbox( ($left_margin), ($top_margin), ($page_width-(2*$left_margin)), ($page_height-(2*$top_margin)) ) if $DEBUG_LPT;

# Adjustments for image position and creep -fbcit
# NOTE: *All* of these factor in to image position and creep. Keep this in mind when makeing adjustments.
# Suggested proceedure: Adjust margins until both top and left margins are correct. Then adjust the label
# height and width to correct label creep across and down page. Units are PostScript Points (72 per inch).

warn "Active profile: " . ($profile->{'prof_id'}?$profile->{'prof_id'}:"None") if $DEBUG;

if ( $DEBUG ) {
    warn "-------------------------INITIAL VALUES-----------------------------";
    warn "top margin = $top_margin points\n";
    warn "left margin = $left_margin points\n";
    warn "label height = $label_height points\n";
    warn "label width = $label_width points\n";
}

if ( $profile->{'prof_id'} ) {
    $top_margin = $top_margin + ($profile->{'offset_vert'} * $prof_unitvalue);    #  controls vertical offset
    $label_height = $label_height + ($profile->{'creep_vert'} * $prof_unitvalue);    # controls vertical creep
    $left_margin = $left_margin + ($profile->{'offset_horz'} * $prof_unitvalue);    # controls horizontal offset
    $label_width = $label_width + ($profile->{'creep_horz'} * $prof_unitvalue);    # controls horizontal creep
}

if ( $DEBUG && $profile->{'prof_id'} ) {
    warn "-------------------------ADJUSTED VALUES-----------------------------";
    warn "top margin = $top_margin points\n";
    warn "left margin = $left_margin points\n";
    warn "label height = $label_height points\n";
    warn "label width = $label_width points\n";
} elsif ( $DEBUG ) {
    warn "No profile associated so no adjustment applied.";
}

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

    warn "Start label specified: $start_label Beginning in row $rowcount, column $colcount" if $DEBUG;
    warn "X position = $x_pos Y position = $y_pos" if $DEBUG;
    warn "Rowspace = $rowspace Label height = $label_height" if $DEBUG;
}

#warn "ROW COL $rowcount, $colcount";

#my $barcodetype; # = 'Code39';

#
#    main foreach loop
#

foreach $item (@resultsloop) {
    warn "Label parameters: xpos=$x_pos, ypos=$y_pos, lblwid=$label_width, lblhig=$label_height" if $DEBUG;
    if ( $printingtype eq 'BAR' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $item->{'barcode'},
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
            $item->{'barcode'}, $barcodetype );
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype, '1' );

        CalcNextLabelPos();

    }    # correct
    elsif ( $printingtype eq 'BIBBAR' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        my $barcode_height = $label_height / 2;
        DrawBarcode( $x_pos, $y_pos, $barcode_height, $label_width, $item->{'barcode'},
            $barcodetype );
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype, '1' );

        CalcNextLabelPos();
    }

    elsif ( $printingtype eq 'ALT' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $item->{'barcode'},
            $barcodetype );
        CalcNextLabelPos();
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype, '1' );

        CalcNextLabelPos();
    }


    elsif ( $printingtype eq 'BIB' ) {
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype, '0' );
        CalcNextLabelPos();
    }

    elsif ( $printingtype eq 'PATCRD' ) {
        my $patron_data = $item;

        #FIXME: This needs to be paramatized and passed in from the user...
        #Each element of this hash is a separate line on the patron card. Keys are the text to print and the associated data is the point size.
        my $text = {        
            $patron_data->{'description'}  => $fontsize,
            $patron_data->{'branchname'}   => ($fontsize + 3),
        };

        warn "Generating patron card for cardnumber $patron_data->{'cardnumber'}";

        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        my $barcode_height = $label_height / 2.75; #FIXME: Scaling barcode height; this needs to be a user parameter.
        DrawBarcode( $x_pos, $y_pos, $barcode_height, $label_width, $patron_data->{'cardnumber'},
            $barcodetype );
        DrawPatronCardText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, $text, $printingtype );
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

