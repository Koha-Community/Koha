#!/usr/bin/perl

use Modern::Perl;

use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use YAML::XS;
use JSON;
use Koha::Reporting::View;
use Koha::Reporting::Import::Abstract;
use Encode qw(encode_utf8);

my $query = new CGI;

my $view = new Koha::Reporting::View;
my $reportData = $view->createReportsViewJson();
my $reportsJson = to_json($reportData);

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/reporting/generate.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
);

$template->param( report_data => $reportsJson);
output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
