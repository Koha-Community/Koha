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
use C4::Catalogue;
use C4::Biblio;
use C4::Search;
use C4::Output;
use C4::Charset;
use HTML::Template;

my $input      = new CGI;
my $isbn       = $input->param('isbn');
my $offset     = $input->param('offset');
my $num        = $input->param('num');
my $showoffset = $offset + 1;
my $total;
my $count;
my @results;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/isbnsearch.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });
if (! $isbn) {
	print $input->redirect('addbooks.pl');
} else {
	if (! $offset) {
		$offset     = 0;
		$showoffset = 1;
	};
	if (! $num) { $num = 10 };
	($count, @results) = isbnsearch($isbn);

	if ($count < ($offset + $num)) {
		$total = $count;
	} else {
		$total = $offset + $num;
	} # else

	my @loop_data = ();
	my $toggle;
	for (my $i = $offset; $i < $total; $i++) {
		if ($i % 2) {
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{toggle} = $toggle;
		$row_data{biblionumber} =$results[$i]->{'biblionumber'};
		$row_data{title} = $results[$i]->{'title'};
		$row_data{author} = $results[$i]->{'author'};
		$row_data{copyrightdate} = $results[$i]->{'copyrightdate'};
		push(@loop_data, \%row_data);
	}
	my @loop_links = ();
	for (my $i = 0; ($i * $num) < $count; $i++) {
		my %row_data;
		$row_data{newoffset} = $i * $num;
		$row_data{shownumber} = $i + 1;
		$row_data{num} = $num;
		push (@loop_links,\%row_data);
	} # for
	$template->param(isbn => $isbn,
							showoffset => $showoffset,
							total => $total,
							offset => $offset,
							loop => \@loop_data,
							loop_links => \@loop_links);

	print $input->header(
	    -type => guesstype($template->output),
	    -cookie => $cookie
	),$template->output;
} # else
