#!/usr/bin/perl
use strict;
use HTML::Template;
require Exporter;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Output;    # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Export;

my $query      = new CGI;
my $format     = $query->param("op");
my $start_date = $query->param("from");
my $end_date   = $query->param("to");

my $start_date = '2006-08-30';
my $end_date   = '2006-08-31';
my $filename   = "export.$format";

if ($format) {

    export_bibs_by_date_to_file( $start_date, $end_date, $format, $filename );
}
else {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "export/export-holdings.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { parameters => 1, management => 1, tools => 1 }
            ,    #NOT NEEDED??
            debug => 1,
        }
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}

