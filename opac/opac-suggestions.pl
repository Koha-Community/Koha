#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::Suggestions;

my $input = new CGI;
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
    = get_template_and_user({template_name => "opac-suggestions.tmpl",
			     type => "opac",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });
if ($op eq "add_confirm") {
	&newsuggestion($borrowernumber,$title,$author,$publishercode,$note,$copyrightdate,$volumedesc,$publicationyear,$place,$isbn,'');
	# empty fields, to avoid filter in "searchsuggestion"
	$title='';
	$author='';
	$publishercode='';
	$copyrightdate ='';
	$volumedesc = '';
	$publicationyear = '';
	$place = '';
	$isbn = '';
	$op='else';
}

if ($op eq "delete_confirm") {
	my @delete_field = $input->param("delete_field");
	foreach my $delete_field (@delete_field) {
		&delsuggestion($borrowernumber,$delete_field);
	}
	$op='else';
}

my $suggestions_loop= &searchsuggestion($borrowernumber,$author,$title,$publishercode,$status,$suggestedbyme);
$template->param(suggestions_loop => $suggestions_loop,
				title => $title,
				author => $author,
				publishercode => $publishercode,
				status => $status,
				suggestedbyme => $suggestedbyme,
				"op_$op" => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;
