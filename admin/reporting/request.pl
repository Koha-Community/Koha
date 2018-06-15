#!/usr/bin/perl

use Modern::Perl;

use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Form::MessagingPreferences;
use C4::Members;
use JSON;
use Data::Dumper;
use Koha::Reporting::Report::Factory;
use Encode qw(encode_utf8);

my $query = new CGI;
my $requestJson = $query->param('request_json');
my $message;

if($requestJson){
    my $reportRequest = decode_json(encode_utf8($requestJson));
    if($reportRequest && defined $reportRequest->{name}){
        my $rows;
        my $headerRows;
        my @dataRows;
        my $reportFactory = new Koha::Reporting::Report::Factory();
        my $report = $reportFactory->getReportByName($reportRequest->{name});
        if($report){
           $report->initRenderer();
           $report->initFromRequest($reportRequest);
           @dataRows = $report->load();
           if(@dataRows){
               if($report->getUseDataColumn()){
                   $report->getRenderer()->addColumn($report->getFactTable()->getDataColumn());
               }
               ($headerRows, $rows) = $report->getRenderer()->generateRows(\@dataRows, $report);

               if(@$rows){
                   if(defined $reportRequest->{selectedReportType} && $reportRequest->{selectedReportType} eq 'html'){
                       my ( $template, $borrowernumber, $cookie ) = get_template_and_user({
                           template_name   => "admin/reporting/report_html.tt",
                           query           => $query,
                           type            => "intranet",
                           authnotrequired => 1,
                           debug           => 1,
                       });
                       $template->param('header_rows' => $headerRows);
                       $template->param('rows' => $rows);
                       output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
                   }
                   else{
                       my $fileName = $report->getReportFileName();
                       print $query->header(
                            -type => 'application/download',
                            -'Content-Transfer-Encoding' => 'binary',
                            -attachment=>"$fileName",
                            -Pragma        => 'no-cache',
                            -Cache_Control => join(', ', qw(
                                no-store
                                no-cache
                            must-revalidate
                            post-check=0
                            pre-check=0
                       )),
                       );
                       print $report->getRenderer()->generateCsv($headerRows, $rows);
                   }
               }
               else{
                   die Dumper "no rows";
               }
           }
           else{
               my ( $template, $borrowernumber, $cookie ) = get_template_and_user({
                   template_name   => "admin/reporting/report_no_data.tt",
                   query           => $query,
                   type            => "intranet",
                   authnotrequired => 1,
                   debug           => 1,
               });
               output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
           }
        }

    }
}
