#!/usr/bin/perl

# written 10/5/2002 by Paul
# build Subject field using bibliothesaurus table


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
use C4::Context;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Output;

# get all the data ....
my %env;

my $input = new CGI;
my $subject = $input->param('subject');
my $search_string= $input->param('search_string');
my $op = $input->param('op');
my $freelib_text = $input->param('freelib_text');

my $dbh = C4::Context->dbh;

# make the page ...
print $input->header;
if ($op eq "select") {
	$subject = $subject."|$freelib_text";		# FIXME - .=
}
print <<"EOF";
	<html>
	<head>
	<title>Subject builder</title>
	</head>
	<body>
	<form name="f_pop" action="thesaurus_popup.pl" method="post">
	<textarea name="subject" rows=10 cols=60>$subject </textarea></br>
	<p><input type="text" name="search_string" value="$search_string">
	<input type="hidden" name="op" value="search">
	<input type="submit" value="Search"></p>
	</form>
EOF
# /search thesaurus terms starting by search_string
	if ($search_string) {
		print '<form name="f2_pop" action="thesaurus_popup.pl" method="post">';
		print '<select name="freelib_text">';
		my $sti=$dbh->prepare("select freelib,stdlib from bibliothesaurus where freelib like '".$search_string."%'");
		$sti->execute;
		while (my $line=$sti->fetchrow_hashref) {
			print "<option value='$line->{'stdlib'}'>$line->{freelib}</option>";
		}
	print <<"EOF";
		</select>
		<input type="hidden" name="op" value="select">
		<input type="hidden" name="subject" value="$subject">
		<input type="submit" name="OK" value="OK">
		</form>
EOF
	}
	print <<"EOF";
		<form name="f3_pop" onSubmit="javascript:report()">
		<input type="submit" value="END">
		</form>
		<script>
		function report() {
			alert("REPORT");
			opener.document.f.subject.value= document.f_pop.subject.value;
			self.close();
			return false;
		}
		</script>
		</body>
		</html>
EOF
