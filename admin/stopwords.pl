#!/usr/bin/perl

#script to administer the stopwords table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;

sub StringSearch  {
	my $sth = C4::Context->dbh->prepare("
		SELECT word FROM stopwords WHERE (word LIKE ?) ORDER BY word
	");
	$sth->execute((shift || '') . "%");
	return $sth->fetchall_arrayref({});
}

my $input = new CGI;
my $searchfield = $input->param('searchfield');
my $offset      = $input->param('offset') || 0;
my $script_name = "/cgi-bin/koha/admin/stopwords.pl";

my $pagesize = 20;
my $op = $input->param('op') || '';

my ($template, $loggedinuser, $cookie) 
    = get_template_and_user({template_name => "admin/stopwords.tt",
    query => $input,
    type => "intranet",
    flagsrequired => {parameters => 'parameters_remaining_permissions'},
    authnotrequired => 0,
    debug => 1,
    });

$template->param(script_name => $script_name,
		 searchfield => $searchfield);

my $dbh = C4::Context->dbh;
if ($op eq 'add_form') {
	$template->param(add_form => 1);
} elsif ($op eq 'add_validate') {
	$template->param(add_validate => 1);
	my @tab = split / |,/, $input->param('word');
	my $sth=$dbh->prepare("INSERT INTO stopwords (word) VALUES (?)");
	foreach my $insert_value (@tab) {
		$sth->execute($insert_value);
	}
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);
} elsif ($op eq 'delete_confirmed') {
	$template->param(delete_confirmed => 1);
	my $sth=$dbh->prepare("delete from stopwords where word=?");
	$sth->execute($searchfield);
} else { # DEFAULT
	$template->param(else => 1);
    my $results = StringSearch($searchfield);
    my $count = scalar(@$results);
	my @loop;
    # FIXME: limit and offset should get to the SQL query
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		push @loop, {word => $results->[$i]{'word'}};
	}
	$template->param(loop => \@loop);
	if ($offset > 0) {
		$template->param(offsetgtzero => 1,
				 prevpage => $offset-$pagesize);
	}
	if ($offset+$pagesize < scalar(@$results)) {
		$template->param(ltcount => 1,
				 nextpage => $offset+$pagesize);
	}
}

output_html_with_http_headers $input, $cookie, $template->output;

