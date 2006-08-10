#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

# $Id$

=head1 NAME
newordersuggestion.pl

=head1 DESCRIPTION
this script allow to add an order from a existing suggestion.

=head1 CGI PARAMETERS

=over 4

=item basketno
the number of this basket.

=item booksellerid
the bookseller who sells this record.

=item title
the title of this record suggested.

=item author
the author of this suggestion.

=item note
this param allow to enter a note with this suggestion.

=item copyrightdate
the copyright date for this suggestion.

=item publishercode

=item volumedesc

=item publicationyear
the publication year of this record.

=item place

=item isbn
the isbn of this suggestion.

=item duplicateNumber
is the biblionumber to put to the new suggestion.

=item suggestionid
the id of the suggestion to select.

=item op
can be equal to
    * connectDuplicate :
        then call to the function : ConnectSuggestionAndBiblio.
        i.e set the biblionumber of this suggestion.
    * else :
        is the default value.
=back

=cut

use strict;
require Exporter;
use CGI;
use HTML::Template;
use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::Suggestions;
use C4::Biblio;
use C4::Search;

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

my $status = 'ACCEPTED'; # the suggestion had to be accepeted before to order it.
my $suggestedbyme = -1; # search ALL suggestors
my $op = $input->param('op');
$op = 'else' unless $op;

my $dbh = C4::Context->dbh;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "acqui/newordersuggestion.tmpl",
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
	
		my ($finalresult,$nbresult) = catalogsearch($dbh,\@tags,\@and_or,\@excluding,\@operator,\@value,0,10);

		# there is at least 1 result => return the 1st one
		if ($nbresult) {
	 		#warn "$nbresult => ".@$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
 			#warn "DUPLICATE ==>".@$finalresult[0]->{biblionumber},@$finalresult[0]->{bibid},@$finalresult[0]->{title};
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
