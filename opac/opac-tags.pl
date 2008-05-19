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

C4::Scrubber is used to remove all markup content from the sumitted text.

=cut

use strict;
use warnings;
use CGI;
use CGI::Cookie; # need to check cookies before having CGI parse the POST request

use C4::Auth;
use C4::Context;
use C4::Debug;
use C4::Output 3.02 qw(:html :ajax pagination_bar);
use C4::Dates qw(format_date);
use C4::Scrubber;
use C4::Biblio;
use C4::Tags qw(add_tag get_tags get_tag_rows remove_tag);

my %newtags = ();
my @deltags = ();
my %counts  = ();
my @errors  = ();

# The trick here is to support multiple tags added to multiple bilbios in one POST.
# The HTML might not use this, but it makes it more web-servicey from the start.
# So the name of param has to have biblionumber built in.
# For lack of anything more compelling, we just use "newtag[biblionumber]"
# We split the value into tags at comma and semicolon

my $openadds = C4::Context->preference('TagsModeration') ? 0 : 1;
my $query = new CGI;
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
		push @errors, {+'login' => 1 };
		%newtags=();	# zero out any attempted additions
		@deltags=();	# zero out any attempted deletions
	}
}

my $scrubber;
my @newtags_keys = (keys %newtags);
if (scalar @newtags_keys) {
	$scrubber = C4::Scrubber->new();
	foreach my $biblionumber (@newtags_keys) {
		my @values = split /[;,]/, $newtags{$biblionumber};
		foreach (@values) {
			s/^\s*(.+)\s*$/$1/;
			my $clean_tag = $scrubber->scrub($_);
			unless ($clean_tag eq $_) {
				if ($clean_tag =~ /\S/) {
					push @errors, {scrubbed=>$clean_tag};
				} else {
					push @errors, {scrubbed_all_bad=>1};
					next;	# we don't add it if there's nothing left!
				}
			}
			my $result = ($openadds) ?
				add_tag($biblionumber,$clean_tag,$loggedinuser,0) : # pre-approved
				add_tag($biblionumber,$clean_tag,$loggedinuser)   ;
			if ($result) {
				$counts{$biblionumber}++;
			} else {
				warn "add_tag($biblionumber,$clean_tag,$loggedinuser...) returned bad result ($result)";
			}
		}
	}
}
my $dels = 0;
foreach (@deltags) {
	if (remove_tag($_,$loggedinuser)) {
		$dels++;
	} else {
		push @errors, {failed_delete=>$_};
	}
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
$template->param(tagsview => 1,);
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

