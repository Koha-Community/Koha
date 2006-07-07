#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::Suggestions;
use C4::Biblio;
use C4::SearchMarc;

my $input = new CGI;

my $basketno = $input->param('basketno');
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
my $duplicateNumber = $input->param('duplicateNumber');
my $suggestionid = $input->param('suggestionid');

my $status = 'ACCEPTED';
my $suggestedbyme = -1; # search ALL suggestors
my $op = $input->param('op');
$op = 'else' unless $op;

my $dbh = C4::Context->dbh;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "acqui/suggestion-select.tmpl",
			     type => "intranet",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {acquisition => 1},
			 });

if ($op eq 'connectDuplicate') {
	ConnectSuggestionAndBiblio($suggestionid,$duplicateNumber);
}
my $suggestions_loop= &SearchSuggestion($borrowernumber,$author,$title,$publishercode,$status,$suggestedbyme);
foreach (@$suggestions_loop) {
	unless ($_->{biblionumber}) {
		my (@tags, @and_or, @excluding, @operator, @value, $offset,$length);
		# search on biblio.title
		if ($_->{title}) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblio.title","");
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "contains";
			push @value, $_->{title};
		}
		if ($_->{author}) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblio.author","");
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "contains";
			push @value, $_->{author};
		}
		# ... and on publicationyear.
		if ($_->{publicationyear}) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.publicationyear","");
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $_->{publicationyear};
		}
		# ... and on publisher.
		if ($_->{publishercode}) {
			my ($tag,$subfield) = MARCfind_marc_from_kohafield($dbh,"biblioitems.publishercode","");
			push @tags, "'".$tag.$subfield."'";
			push @and_or, "and";
			push @excluding, "";
			push @operator, "=";
			push @value, $_->{publishercode};
		}
	
		my ($finalresult,$nbresult) = C4::SearchMarc::catalogsearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10);
		# there is at least 1 result => return the 1st one
		if ($nbresult) {
	# 		warn "$nbresult => ".@$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
# 			warn "DUPLICATE ==>".@$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
			$_->{duplicateBiblionumber} = @$finalresult[0]->{biblionumber};
		}
	}
}
$template->param(suggestions_loop => $suggestions_loop,
				title => $title,
				author => $author,
				publishercode => $publishercode,
				status => $status,
				suggestedbyme => $suggestedbyme,
				basketno => $basketno,
				supplierid => $supplierid,
				"op_$op" => 1,
				intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $input, $cookie, $template->output;
