#!/usr/bin/perl

#use lib '/usr/local/opus-dev/intranet/modules';
#use C4::Context("/etc/koha-opus-dev.conf");

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use PDF::Report;
use PDF::Create;
use PDF::Labels;
use Acme::Comment;
use Data::Dumper;
warn "-------";

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;

my $pdf = new PDF::Labels(
    $PDF::Labels::PageFormats[1],
    filename   => "$htdocs_path/barcodes/opus.pdf",
    Author     => 'PDF Labelmaker',
    'PageMode' => 'UseOutlines',
    Title      => 'My Labels'
);

warn "$htdocs_path/barcodes/opus.pdf";

my @resultsloop = get_label_items();

#warn Dumper @resultsloop;
warn Dumper $pdf->{'filename'};

$pdf->setlabel(0);    # Start with label 5 on first page

foreach my $result (@resultsloop) {
    warn Dumper $result;
    $pdf->label( $result->{'itemtype'}, $result->{'number'}, 'LAK',
        $result->{'barcode'} );
    $pdf->label( $result->{'itemtype'}, $result->{'dewey'}, 'LAK',
        $result->{'barcode'} );

}
warn "HERE";
$pdf->close();

#--------------------------------------------------

use PDF::Reuse;
prFile("$htdocs_path/barcodes/opus1.pdf");
prDoc("$htdocs_path/barcodes/opus.pdf");
prEnd();

print $cgi->redirect("/intranet-tmpl/barcodes/opus1.pdf");

