#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use C4::Labels;     # GetActiveLabelTemplate get_label_options GetAssociatedProfile 
# GetPatronCardItems GetLabelItems GetUnitsValue...
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Branch;
use HTML::Template::Pro;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use POSIX;  # ceil
use Data::Dumper;

my $DEBUG = 0;
my $DEBUG_LPT = 0;

my $cgi         = new CGI;

#### Tons of Initialization ####
# get the printing settings
my $template    = GetActiveLabelTemplate();
my $conf_data   = get_label_options() or die "get_label_options failed";
my $profile     = GetAssociatedProfile($template->{'tmpl_id'});

my $batch_id =   $cgi->param('batch_id');
my @resultsloop;

my $batch_type   = $conf_data->{'type'};
my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'} or die "No printingtype in conf_data";
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

my $unitvalue      = GetUnitsValue($units);
my $prof_unitvalue = GetUnitsValue($profile->{'unit'});

warn "Template units: $units which converts to $unitvalue PostScript Points" if $DEBUG;
warn "Profile units: $profile->{'unit'} which converts to $prof_unitvalue PostScript Points" if $DEBUG;

my $tmpl_code = $template->{'tmpl_code'};
my $tmpl_desc = $template->{'tmpl_desc'};

my $page_height  = ( $template->{'page_height'}  * $unitvalue );
my $page_width   = ( $template->{'page_width'}   * $unitvalue );
my $label_height = ( $template->{'label_height'} * $unitvalue );
my $label_width  = ( $template->{'label_width'}  * $unitvalue );
my $spine_width  = ( $template->{'label_width'}  * $unitvalue );
my $circ_width   = ( $template->{'label_width'}  * $unitvalue );
my $top_margin   = ( $template->{'topmargin'}    * $unitvalue );
my $left_margin  = ( $template->{'leftmargin'}   * $unitvalue );
my $colspace     = ( $template->{'colgap'}       * $unitvalue );
my $rowspace     = ( $template->{'rowgap'}       * $unitvalue );

warn "Converted dimensions are:" if $DEBUG;
warn "pghth=$page_height, pgwth=$page_width, lblhth=$label_height, lblwth=$label_width, spinwth=$spine_width, circwth=$circ_width, tpmar=$top_margin, lmar=$left_margin, colsp=$colspace, rowsp=$rowspace" if $DEBUG;

my $label_cols = $template->{'cols'};
my $label_rows = $template->{'rows'};

my $margin           = $top_margin;
my $left_text_margin = 3;       # FIXME: This value should not be hardcoded
my $str;

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
my $codetype; # = 'Code39';

warn "Active profile: " . ($profile->{prof_id} || "None") if $DEBUG;

#### PRINT PRELIMINARY DATA ####
print $cgi->header( -type => 'application/pdf', -attachment => 'barcode.pdf' ); 
    # Don't print header until very last possible moment
    # That way if error or die occurs, fatals_to_browser will still work.
    # After we print this header, there is no way back to HTML.  All we can do is deliver PDF.
prInitVars();
$| = 1;
prFile();   # No args means to STDOUT
prCompress(1);  # turn on zip compression which dramatically reduces file size
prMbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );

# drawbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );  #do page border
# draw margin box for alignment page
drawbox($left_margin, $top_margin, $page_width-(2*$left_margin), $page_height-(2*$top_margin)) if $DEBUG_LPT;


#### TWEAKS and DEBUGGING ###
# Adjustments for image position and creep -fbcit
# NOTE: *All* of these factor in to image position and creep. Keep this in mind when makeing adjustments.
# Suggested proceedure: Adjust margins until both top and left margins are correct. Then adjust the label
# height and width to correct label creep across and down page. Units are PostScript Points (72 per inch).

sub debug_drop {
    my $title = @_ || "";
    warn "-------------------------$title-----------------------------\n"
     . "  top margin = $top_margin points\n" 
     . " left margin = $left_margin points\n"
     . "label height = $label_height points\n"
     . "label width  = $label_width points\n";
}

debug_drop('INITIAL VALUES') if ($DEBUG);

if ( $profile->{'prof_id'} ) {
    $top_margin   += ($profile->{'offset_vert'} * $prof_unitvalue);    # controls vertical offset
    $label_height += ($profile->{'creep_vert'}  * $prof_unitvalue);    # controls vertical creep
    $left_margin  += ($profile->{'offset_horz'} * $prof_unitvalue);    # controls horizontal offset
    $label_width  += ($profile->{'creep_horz'}  * $prof_unitvalue);    # controls horizontal creep
}

if ($DEBUG) {
    if ($profile->{'prof_id'}) {
        debug_drop('ADJUSTED VALUES');
    } else {
        warn "No profile associated so no adjustment applied.";
    }
}

#warn " $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY";
#warn "$label_rows, $label_cols\n";
#warn "$label_height, $label_width\n";
#warn "$page_height, $page_width\n";

my ($rowcount, $colcount, $x_pos, $y_pos, $rowtemp, $coltemp);

if ( $start_label and $start_label == 1 ) {
    $rowcount = 1;
    $colcount = 1;
    $x_pos    = $left_margin;
    $y_pos    = ( $page_height - $top_margin - $label_height );
} else {
    $rowcount = ceil( $start_label / $label_cols );
    $colcount = ( $start_label - ( ( $rowcount - 1 ) * $label_cols ) );
    $x_pos = $left_margin + ( $label_width * ( $colcount - 1 ) ) +
      ( $colspace * ( $colcount - 1 ) );
    $y_pos = $page_height - $top_margin - ( $label_height * $rowcount ) -
      ( $rowspace * ( $rowcount - 1 ) );
    $DEBUG and warn "Start label: $start_label. Beginning in row $rowcount, column $colcount\n"
        . "(X,Y) positions = ($x_pos,$y_pos)\n"
        . "Rowspace = $rowspace, Label height = $label_height";
}

#
#### main foreach loop #### 
#

foreach my $item (@resultsloop) {
    warn "Label parameters: xpos=$x_pos, ypos=$y_pos, lblwid=$label_width, lblhig=$label_height" if $DEBUG;

    drawbox($x_pos, $y_pos, $label_width, $label_height) if $guidebox;  # regardless of printingtype

    if ( $printingtype eq 'BAR' ) {
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $item->{'barcode'}, $barcodetype );
    }
    elsif ( $printingtype eq 'BARBIB' ) {
        # reposoitioning barcode up the top of label
        my $barcode_height = ($label_height / 1.5 );    ## scaling voodoo
        my $text_height    = $label_height / 2;
        my $barcode_y      = $y_pos + ( $label_height / 2.5  );   ## scaling voodoo

        DrawBarcode( $x_pos, $barcode_y, $barcode_height, $label_width, $item->{'barcode'}, $barcodetype );
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype );
    }    # correct
    elsif ( $printingtype eq 'BIBBAR' ) {
        my $barcode_height = $label_height / 2;
        DrawBarcode( $x_pos, $y_pos, $barcode_height, $label_width, $item->{'barcode'}, $barcodetype );
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype );
    }
    elsif ( $printingtype eq 'ALT' ) {
        DrawBarcode( $x_pos, $y_pos, $label_height, $label_width, $item->{'barcode'}, $barcodetype );
        CalcNextLabelPos();
        drawbox( $x_pos, $y_pos, $label_width, $label_height ) if $guidebox;
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype );
    }
    elsif ( $printingtype eq 'BIB' ) {
        DrawSpineText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, \$item, \$conf_data, $printingtype );
    }
    elsif ( $printingtype eq 'PATCRD' ) {
        my $patron_data = $item;
        #FIXME: This needs to be paramatized and passed in from the user...
        #Each element of this hash is a separate line on the patron card. Keys are the text to print and the associated data is the point size.
        my $text = {        
            $patron_data->{'description'}  => $fontsize,
            $patron_data->{'branchname'}   => ($fontsize + 3),
        };
        $DEBUG and warn "Generating patron card for cardnumber $patron_data->{'cardnumber'}";
        my $barcode_height = $label_height / 2.75; #FIXME: Scaling barcode height; this needs to be a user parameter.
        DrawBarcode( $x_pos, $y_pos, $barcode_height, $label_width, $patron_data->{'cardnumber'}, $barcodetype );
        DrawPatronCardText( $x_pos, $y_pos, $label_height, $label_width, $fontname, $fontsize,
            $left_text_margin, $text_wrap_cols, $text, $printingtype );
    }
    else {
        die "CANNOT PRINT: Unknown printingtype '$printingtype'";
    }

    CalcNextLabelPos();     # regardless of printingtype
}    # end for item loop
prEnd();

sub CalcNextLabelPos {
    if ($colcount < $label_cols) {
        # warn "new col";
        $x_pos = ( $x_pos + $label_width + $colspace );
        $colcount++;
    } else {
        $x_pos = $left_margin;
        if ($rowcount == $label_rows) {
            # warn "new page";
            prPage();
            $y_pos    = ( $page_height - $top_margin - $label_height );
            $rowcount = 1;
        } else {
            # warn "new row";
            $y_pos = ( $y_pos - $rowspace - $label_height );
            $rowcount++;
        }
        $colcount = 1;
    }
}

