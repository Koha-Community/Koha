#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::Suggestions;

my $input = new CGI;

my $basketid = $input->param('basket');
my $supplierid = $input->param('booksellerid');

my $title = $input->param('title');
my $author = $input->param('author');
my $note = $input->param('note');
my $copyrightdate =$input->param('copyrightdate');
my $publishercode = $input->param('publishercode');
my $volumedesc = $input->param('volumedesc');
my $publicationyear = $input->param('publicationyear');
my $place = $input->param('place');
my $isbn = $input->param('isbn');
my $status = $input->param('status');
my $suggestedbyme = $input->param('suggestedbyme');
my $op = $input->param('op');
$op = 'else' unless $op;

my $dbh = C4::Context->dbh;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "acqui/suggestion-select.tmpl",
			     type => "intranet",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });

my $suggestions_loop= &searchsuggestion($borrowernumber,$author,$title,$publishercode,$status,$suggestedbyme);
$template->param(suggestions_loop => $suggestions_loop,
				title => $title,
				author => $author,
				publishercode => $publishercode,
				status => $status,
				suggestedbyme => $suggestedbyme,
				basket => $basketid,
				supplierid => $supplierid,
				"op_$op" => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;
