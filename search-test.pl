#!/usr/bin/perl 

# simple script to test cql searching
# written by chris@katipo.co.nz 17/2/06

use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;

use CGI;
use Smart::Comments;
use strict;
use warnings;

my $input = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "search-test.tmpl",
        type            => "opac",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $cql=$input->param('cql');
if ($cql){
    my %search;
    $search{'cql'} = $cql;
    my $results = search( \%search, 'CQL' , 10);
    $template->param(CQL => 'yes'       
    );
    $template->param(results => $results);
}
#my $record = get_record($result);



 

output_html_with_http_headers $input, $cookie, $template->output;
