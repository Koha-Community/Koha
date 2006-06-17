#!/usr/bin/perl
use strict;
require Exporter;
use CGI;

use C4::Auth;
use C4::Koha;
use HTML::Template;
use C4::Interface::CGI::Output;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Review;
use C4::Biblio;

my $query = new CGI;
my $biblionumber = $query->param('biblionumber');

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-showreviews.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

my $biblio=bibdata($biblionumber,'opac');
my $reviews=getreviews($biblionumber,1);

$template->param('reviews' => $reviews,
'title' => $biblio->{'title'});

output_html_with_http_headers $query, $cookie, $template->output;

