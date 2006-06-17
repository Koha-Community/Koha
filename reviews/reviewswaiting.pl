#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Review;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reviews/reviewswaiting.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op       = $query->param('op');
my $reviewid = $query->param('reviewid');

if ( $op eq 'approve' ) {
    approvereview($reviewid);
}
elsif ( $op eq 'delete' ) {
    deletereview($reviewid);
}

my $reviews = getallreviews(0);
$template->param( reviews => $reviews );

output_html_with_http_headers $query, $cookie, $template->output;
