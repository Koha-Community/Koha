#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Labels;
use C4::Context;
use HTML::Template::Pro;

my $dbh =  = C4::Context->dbh;
my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-create-layout.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $data = get_label_options();
my $op =  $query->param('op');
my $layout_id = $query->param('layout_id');

my $active_template = GetActiveLabelTemplate();
my @label_templates = GetAllLabelTemplates();
my @printingtypes = get_printingtypes();
my @layouts       = get_layouts();
my @barcode_types = get_barcode_types();
my @batches = get_batches();

my @barcode_types = get_barcode_types($layout_id);
my @printingtypes = get_printingtypes($layout_id);
my $layout;
$layout = get_layout($layout_id) if($layout_id);

$template->param( guidebox => 1 ) if ( $data->{'guidebox'} );
$template->param( "papertype_$data->{'papertype'}"       => 1 );
$template->param( "$data->{'barcodetype'}_checked" => 1 );
$template->param( "startrow" . $data->{'startrow'} . "_checked" => 1 );

$template->param(
	op => $op,
	active_template => $data->{'active_template'},
	label_templates => \@label_templates,
	barcode_types   => \@barcode_types,
	printingtypes   => \@printingtypes,
	layout_loop     => \@layouts,
	batches         => \@batches,

	id                => $data->{'id'},
	barcodetype       => $data->{'barcodetype'},
	papertype         => $data->{'papertype'},
	tx_author         => $data->{'author'},
	tx_barcode        => $data->{'barcode'},
	tx_title          => $data->{'title'},
	tx_subtitle       => $data->{'subtitle'},
	tx_isbn           => $data->{'isbn'},
	tx_issn           => $data->{'issn'},
	tx_itemtype       => $data->{'itemtype'},
	tx_dewey          => $data->{'dewey'},
	tx_class          => $data->{'class'},
	tx_subclass       => $data->{'subclass'},
	tx_itemcallnumber => $data->{'itemcallnumber'},
	startlabel        => $data->{'startlabel'},

	fontsize => $active_template->{'fontsize'},
);

output_html_with_http_headers $query, $cookie, $template->output;
