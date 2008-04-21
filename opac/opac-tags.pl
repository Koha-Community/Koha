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


=head1 

TODO :: Description here

=cut

use strict;
use warnings;
use C4::Auth;
use C4::Context;
use C4::Debug;
use C4::Output;
use C4::Dates qw(format_date);
use CGI;
use C4::Biblio;
use C4::Tags qw(add_tag get_tags get_tag_rows remove_tag);

my $query = new CGI;
my %newtags = ();
my @deltags = ();
my %counts  = ();
my @errors  = ();

# The trick here is to support multiple tags added to multiple bilbios in one POST.
# So the name of param has to have biblionumber built in.
# For lack of anything more compelling, we just use "newtag[biblionumber]"
# We split the value into tags at comma and semicolon

my $openadds = C4::Context->preference('TagsModeration') ? 0 : 1;

unless (C4::Context->preference('TagsEnabled')) {
	push @errors, {+ tagsdisabled=>1 };
} else {
	foreach ($query->param) {
		if (/^newtag(.*)/) {
			my $biblionumber = $1;
			unless ($biblionumber =~ /^\d+$/) {
				$debug and warn "$_ references non numerical biblionumber '$biblionumber'";
				push @errors, {+'badparam' => $_ };
				next;
			}
			$newtags{$biblionumber} = $query->param($_);
		} elsif (/^del(\d+)$/) {
			push @deltags, $1;
		}
	}
}

my $add_op = (scalar(keys %newtags) + scalar(@deltags)) ? 1 : 0;
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name   => "opac-tags.tmpl",
	query           => $query,
	type            => "opac",
	authnotrequired => ($add_op ? 0 : 1),	# auth required to add tags
	debug           => 1,
});

if ($add_op) {
	unless ($loggedinuser) {
		push @errors, {+'login' => $_ };
		%newtags=();	# zero out any attempted additions
		@deltags=();	# zero out any attempted deletions
	}
}
foreach my $biblionumber (keys %newtags) {
	my @values = split /[;,]/, $newtags{$biblionumber};
	foreach (@values) {
		s/^\s*(.+)\s*$/$1/;
		my $result;
		if ($openadds) {
			$result = add_tag($biblionumber,$_,$loggedinuser,0); # pre-approved
		} else {
			$result = add_tag($biblionumber,$_,$loggedinuser);
		}
		if ($result) {
			$counts{$biblionumber}++;
		} else {
			warn "add_tag($biblionumber,$_,$loggedinuser...) returned $result";
		}
	}
}
my $dels = 0;
foreach (@deltags) {
	remove_tag($_) and $dels++;
}

my $results = [];
my $my_tags = [];

if ($loggedinuser) {
	$my_tags = get_tag_rows({borrowernumber=>$loggedinuser});
	foreach (@$my_tags) {
		my $biblio = GetBiblioData($_->{biblionumber});
		$_->{bib_summary} = $biblio->{title}; 
		($biblio->{author}) and $_->{bib_summary} .= " by " . $biblio->{author};
		my $date = $_->{date_created} || '';
		$date =~ /\s+(\d{2}\:\d{2}\:\d{2})/;
		$_->{time_created_display} = $1;
		$_->{date_created_display} = format_date($_->{date_created});
	}
}

if ($add_op) {
	my $adds = 0;
	for (values %counts) {$adds += $_;}
	$template->param(
		add_op => 1,
		added_count => $adds,
		deleted_count => $dels,
	);
} else {
	my ($arg,$limit,$tmpresults);
	my $hardmax = 100;	# you might disagree what this value should be, but there definitely should be a max
	$limit = $query->param('limit') || $hardmax;
	($limit =~ /^\d+$/ and $limit <= $hardmax) or $limit = $hardmax;
	if ($arg = $query->param('tag')) {
		$tmpresults = get_tags({term => $arg, limit=>$limit, 'sort'=>'-weight'});
	} elsif ($arg = $query->param('biblionumber')) {
		$tmpresults = get_tags({biblionumber => $arg, limit=>$limit, 'sort'=>'-weight'});
	} else {
		$tmpresults = get_tags({limit=>$limit, 'sort'=>'-weight'});
	}
	my %uniq;
	foreach (@$tmpresults) {
		$uniq{$_->{term}}++ and next;
		push @$results, $_;
	}
}
(scalar @errors  ) and $template->param(ERRORS  => \@errors);
(scalar @$results) and $template->param(TAGLOOP => $results);
(scalar @$my_tags) and $template->param(MY_TAGS => $my_tags);

output_html_with_http_headers $query, $cookie, $template->output;

