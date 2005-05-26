#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::Acquisition;

my $input = new CGI;
my $title = $input->param('title');
my $author = $input->param('author');
my $name = $input->param('name');
my $from_placed_on = $input->param('fromplacedon');
my $to_placed_on = $input->param('toplacedon');

my $dbh = C4::Context->dbh;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/histsearch.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
my $order_loop= &histsearch($title,$author,$name,$from_placed_on,$to_placed_on);
$template->param(suggestions_loop => $order_loop,
				title => $title,
				author => $author,
				name => $name,
				from_placed_on =>$from_placed_on,
				to_placed_on =>$to_placed_on
);
output_html_with_http_headers $input, $cookie, $template->output;
