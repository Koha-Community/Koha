#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Z3950;
use C4::Search;
use HTML::Template;
use MARC::File::USMARC;

use vars qw( $tagslib );
use vars qw( $is_a_modif );


my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error = $input->param('error');
my $bibid=$input->param('bibid');
my $title = $input->param('title');
my $author = $input->param('author');
my $isbn = $input->param('isbn');
my $issn = $input->param('issn');
my $random = $input->param('random');
my @results;
my $count;
my $toggle;

my $record;
my $oldbiblio;
if ($bibid > 0) {
	$record = MARCgetbiblio($dbh,$bibid);
	$oldbiblio = MARCmarc2koha($dbh,$record);
}
my $errmsg;
unless ($random) { # if random is a parameter => we're just waiting for the search to end, it's a refresh.
	if ($isbn) {
		$random =rand(1000000000);
		$errmsg = addz3950queue($isbn, "isbn", $random, 'CHECKED');
	} elsif ($author) {
		$random =rand(1000000000);
		$errmsg = addz3950queue($author, "author", $random, 'CHECKED');
	} elsif ($title) {
		$random =rand(1000000000);
		$errmsg = addz3950queue($title, "title", $random, 'CHECKED');
	}
}
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "z3950/searchresult.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

# fill with books in breeding farm
($count, @results) = breedingsearch($title,$isbn,$random);
my $numberpending= &checkz3950searchdone($random);
my @breeding_loop = ();
for (my $i=0; $i <= $#results; $i++) {
	my %row_data;
	if ($i % 2) {
		$toggle="#ffffcc";
	} else {
		$toggle="white";
	}
	$row_data{toggle} = $toggle;
	$row_data{id} = $results[$i]->{'id'};
	$row_data{isbn} = $results[$i]->{'isbn'};
	$row_data{file} = $results[$i]->{'file'};
	$row_data{title} = $results[$i]->{'title'};
	$row_data{author} = $results[$i]->{'author'};
	push (@breeding_loop, \%row_data);
}

$template->param(isbn => $isbn,
						title => $title,
						author => $author,
						breeding_loop => \@breeding_loop,
						refresh => ($numberpending eq 0 ? 0 : "search.pl?bibid=$bibid&random=$random"),
						numberpending => $numberpending,
						oldbiblionumber => $oldbiblio->{'biblionumber'},
						);

print $input->header(
-type => guesstype($template->output),
-cookie => $cookie
),$template->output;
