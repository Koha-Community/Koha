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

my $dbh = C4::Context->dbh;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/histsearch.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
my $order_loop= &histsearch($title,$author,$name);
$template->param(suggestions_loop => $order_loop,
				title => $title,
				author => $author,
				name => $name,
);
output_html_with_http_headers $input, $cookie, $template->output;
