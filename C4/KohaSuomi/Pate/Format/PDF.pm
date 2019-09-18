#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use C4::Letters;
use Data::Dumper;

use PDF::API2;
use PDF::API2::Simple;

use Koha::DateUtils;
use Koha::Libraries;

use constant mm => 25.4 / 72;

sub getNumberOfPages {
   # Count pages in PDF (mainly used for dispatcher)
   my $pdf = PDF::API2->open_scalar(shift);
   return $pdf->pages();
}

sub setMediaboxByPage {
    # Convert the document to raw PDF::API2 object and set mediabox for each
    # individual page. This is needed because suomi.fi doesn't handle document wide
    # mediabox defintion correctly.
    my $pdf = PDF::API2->open_scalar(shift);
    foreach my $page_number ( 1 .. $pdf->pages() ) {
        my $page = $pdf->openpage($page_number);
        $page->mediabox('A4');
    }
    return $pdf->stringify();
}

sub toPDF {
    # Produce SFS-2487 document from the letter in PDF format
    my %hash = @_;

    # I'm tempted to use a bit wider top and right margins (15 mm perhaps)
    my $pdf = PDF::API2::Simple->new( width => 210/mm,
                                      height => 297/mm,
                                      line_height => 13,
                                      margin_left => 20/mm,
                                      margin_top => 13/mm,
                                      margin_right => 13/mm,
                                      margin_bottom => 20/mm );

    $pdf->add_font('Times');
    $pdf->add_page();

    my $font_size="12";

    ### HEADER ####

    # For now we'll put branch information as sender, change later to support combine across branches
    my $branch = Koha::Libraries->find( $hash{'branchcode'} );

    $pdf->text($branch->branchname, autoflow => 'on', font_size=>"$font_size");
    $pdf->text($branch->branchaddress1, autoflow => 'on', font_size=>"$font_size");
    $pdf->text($branch->branchzip . ' ' . $branch->branchcity, autoflow => 'on', font_size=>"$font_size");
    $pdf->text($branch->branchphone, autoflow => 'on', font_size=>"$font_size");

    # Insert date in the correct location
    my $letterdate = output_pref ( { dt => dt_from_string(), dateonly => 1 } );
    $pdf->text( $letterdate,
                x => 112/mm,
                y => $pdf->height - 27/mm,
                autoflow => 'on', font_size=>"$font_size");

    # Three enters after header (might just as well be part of the header)
    $pdf->text('', autoflow => 'on', autoflow => 'on', font_size=>"$font_size") for ( 0..1 );

    ### RECIPIENT ###

    # Get and insert the recipient information
    my $borrower = GetMember( borrowernumber => $hash{'borrowernumber'} );

    $pdf->text(@$borrower{'firstname'} . ' ' . @$borrower{'surname'}, autoflow => 'on', font_size=>"$font_size");
    $pdf->text('', autoflow => 'on', font_size=>"$font_size");
    $pdf->text(@$borrower{'address'}, autoflow => 'on', font_size=>"$font_size");
    $pdf->text(@$borrower{'zipcode'}  . ' ' . @$borrower{'city'}, autoflow => 'on', font_size=>"$font_size");
    $pdf->text(@$borrower{'country'}, autoflow => 'on', font_size=>"$font_size");

    ### CONTENT ###

    # Skip reference, insert some enters after the recipient
    $pdf->text('', autoflow => 'on', autoflow => 'on', font_size=>"$font_size" ) for ( 0..2 );

    # Main heading for the document + one enter before the actual content
    $pdf->text($hash{'subject'}, autoflow => 'on', autoflow => 'on', font_size=>"$font_size");
    $pdf->text('', autoflow => 'on', autoflow => 'on', font_size=>"$font_size");

    # Message body (retain enters). Signatures and such should be in the letter template
    $pdf->text($_, autoflow => 'on', x => 66/mm, autoflow => 'on', font_size=>"$font_size") for ( split /\n/, $hash{'content'} );

    # Return the resulting PDF in a scalar as string
    return $pdf->stringify();
}

1;
