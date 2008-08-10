#!/usr/bin/perl

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Biblio;
use Text::CSV_XS;

my $DEBUG = 0;
my $DEBUG_LPT = 0;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $cgi         = new CGI;


# get the printing settings
my $template    = GetActiveLabelTemplate();
my $conf_data   = get_label_options();

my $batch_id =   $cgi->param('batch_id');
my $exportname = 'koha_label_' . $batch_id . '.csv';

print $cgi->header(-type => 'application/vnd.sun.xml.calc',
                            -encoding    => 'utf-8',
                            -attachment => $exportname,
                            -filename => $exportname );

my $batch_type   = $conf_data->{'type'};
my $barcodetype  = $conf_data->{'barcodetype'};
my $printingtype = $conf_data->{'printingtype'};

my @resultsloop = GetLabelItems($batch_id);
my $csv = Text::CSV_XS->new();
my @str_fields = get_text_fields($conf_data->{'id'}, 'codes' );
for my $item (@resultsloop) {
    my $record = GetMarcBiblio($item->{biblionumber});
    my @datafields = map { C4::Labels::GetBarcodeData($_->{'code'},$item,$record) } @str_fields ;
	my $csvout ;
	if($csv->combine(@datafields)) {
		$csvout = $csv->string();
		print "$csvout\n";
	} else {
		warn "CSV ERROR: " . $csv->error_input;
	}

}    # end for item loop

exit(1);
# is that the right way to do this ?



