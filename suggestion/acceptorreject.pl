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
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "suggestion/acceptorreject.tmpl",
			     type => "intranet",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });
if ($op eq "aorr_confirm") {
	my @suggestionlist = $input->param("aorr");
	foreach my $suggestion (@suggestionlist) {
		if ($suggestion =~ /(A|R)(.*)/) {
			my ($newstatus,$suggestionid) = ($1,$2);
			$newstatus="REJECTED" if $newstatus eq "R";
			$newstatus="ACCEPTED" if $newstatus eq "A";
			changestatus($suggestionid,$newstatus,$loggedinuser);
		}
	}
	$op="else";
}

if ($op eq "delete_confirm") {
	my @delete_field = $input->param("delete_field");
	foreach my $delete_field (@delete_field) {
		&delsuggestion($loggedinuser,$delete_field);
	}
	$op='else';
}

my $suggestions_loop= &searchsuggestion("","","","",'ASKED',"");
$template->param(suggestions_loop => $suggestions_loop,
				"op_$op" => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;
