#!/usr/bin/perl

use C4::Context;
use PDF::API2;
use PDF::Table;

my $pdftable = new PDF::Table;
my $pdf      = PDF::API2->new();

#$pdf->mediabox(612,792);
my $fnt  = $pdf->corefont('Helvetica-Bold');
my $page = $pdf->page;                         # returns the last page
my $txt  = $page->text;
$txt->{' font'} = $fnt;
$text_to_place = "moo moo";

( $width_of_last_line, $ypos_of_last_line, $left_over_text ) =
  $pdftable->text_block(
    $txt,
    $text_to_place,
    -x => 100,
    -y => 300,
    -w => 50,
    -h => 40,

    # 	-lead     => 13,
    #	-font_size => 12,
    # -parspace => 0,
    #   -align    => "left",
    #   -hang     => 1,
  );

$pdf->saveas("$htdocs_path/barcodes/foo.pdf");
