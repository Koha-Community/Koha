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

use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Context;
use C4::Debug;
use C4::Output 3.02 qw(:html :ajax pagination_bar);
use C4::Dates qw(format_date);
use C4::Scrubber;
use C4::Biblio;
use C4::Tags qw(add_tag get_approval_rows get_tag_rows remove_tag);

my %newtags = ();
my @deltags = ();
my %counts  = ();
my @errors  = ();

sub ajax_auth_cgi ($) {     # returns CGI object
    my $needed_flags = shift;
	my %cookies = fetch CGI::Cookie;
	my $input = CGI->new;
	my $sessid = $cookies{'CGISESSID'}->value || $input->param('CGISESSID');
	my ($auth_status, $auth_sessid) = check_cookie_auth($sessid, $needed_flags);
	$debug and
	print STDERR "($auth_status, $auth_sessid) = check_cookie_auth($sessid," . Dumper($needed_flags) . ")\n";
	if ($auth_status ne "ok") {
		output_ajax_with_http_headers $input,
		"window.alert('Your CGI session cookie ($sessid) is not current.  " .
		"Please refresh the page and try again.');\n";
		exit 0;
	}
	$debug and print STDERR "AJAX request: " . Dumper($input),
		"\n(\$auth_status,\$auth_sessid) = ($auth_status,$auth_sessid)\n";
	return $input;
}

# The trick here is to support multiple tags added to multiple bilbios in one POST.
# The HTML might not use this, but it makes it more web-servicey from the start.
# So the name of param has to have biblionumber built in.
# For lack of anything more compelling, we just use "newtag[biblionumber]"
# We split the value into tags at comma and semicolon

my $is_ajax = is_ajax();
my $openadds = C4::Context->preference('TagsModeration') ? 0 : 1;
my $query = ($is_ajax) ? &ajax_auth_cgi({}) : CGI->new();
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
my ($template, $loggedinuser, $cookie);
if ($is_ajax) {
	$loggedinuser = C4::Context->userenv->{'number'};  # must occur AFTER auth
	$debug and print STDERR "op: $loggedinuser\n";
} else {
	($template, $loggedinuser, $cookie) = get_template_and_user({
		template_name   => "opac-tags.tmpl",
		query           => $query,
		type            => "opac",
		authnotrequired => ($add_op ? 0 : 1),	# auth required to add tags
		debug           => 1,
	});
}

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
				add_tag($biblionumber,$clean_tag,$loggedinuser,$loggedinuser) : # pre-approved
				add_tag($biblionumber,$clean_tag,$loggedinuser)   ;
			if ($result) {
				$counts{$biblionumber}++;
			} else {
				push @errors, {failed_add_tag=>$clean_tag};
				warn "add_tag($biblionumber,$clean_tag,$loggedinuser...) returned bad result (" . (defined $result ? $result : 'UNDEF') .")";
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

if ($is_ajax) {
	my $sum = 0;
	foreach (values %counts) {$sum += $_;}
	my $js_reply = sprintf("response = {\n\tadded: %d,\n\tdeleted: %d,\n\terrors: %d,",$sum,$dels,scalar @errors);
	my $err_string = '';
	if (scalar @errors) {
		$err_string = "\n\talerts: [";	# open response_function
		foreach (@errors) {
			my $key = (keys %$_)[0];
			$err_string .= "\n\t\t KOHA.Tags.tag_message.$key(\"" . $_->{$key} . '"),';
		}
		$err_string .= "\n\t],\n";	# close response_function
	}
	output_ajax_with_http_headers($query, "$js_reply\n$err_string};");
	exit;
}

my $results = [];
my $my_tags = [];

if ($loggedinuser and not $query->param('hidemytags')) {
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
	my ($arg,$limit);
	my $hardmax = 100;	# you might disagree what this value should be, but there definitely should be a max
	$limit = $query->param('limit') || $hardmax;
	($limit =~ /^\d+$/ and $limit <= $hardmax) or $limit = $hardmax;
	$template->param(limit => $limit);
	if ($arg = $query->param('tag')) {
		$results = get_approval_rows({term => $arg, approved=>1, limit=>$limit, 'sort'=>'-weight_total'});
	} elsif ($arg = $query->param('biblionumber')) {
		$results = get_approval_rows({biblionumber => $arg, approved=>1, limit=>$limit, 'sort'=>'-weight_total'});
	} else {
		$results = get_approval_rows({limit=>$limit, approved=>1, 'sort'=>'-weight_total'});
	}

	my $count = scalar @$results;
	$template->param(TAGLOOP_COUNT => $count);
	# Here we make a halfhearted attempt to separate the tags into "strata" based on weight_total
	# FIXME: code4lib probably has a better algorithm, iirc
	# FIXME: when we get a better algorithm, move to C4
	my $maxstrata = 5;
	my $strata = 1;
	my $previous = 0;
	my $chunk = ($count/$maxstrata)/2;
	my $total = 0;
	my %cloud;
	foreach (reverse @$results) {
		my $current = $_->{weight_total};
		$total++;
		$cloud{$strata}++;
		if ($current == $previous) {
			$_->{cloudweight} = $strata;
			next;
		} 
		if ($strata < $maxstrata and 
			($cloud{$strata} > $chunk or 
			$count-$total <= $maxstrata-$strata)) {
			$strata++;
		}
		$_->{cloudweight} = $strata;
		$previous = $current;
	}
}
$query->param('hidemytags') and $template->param(hidemytags => 1);
(scalar @errors  ) and $template->param(ERRORS  => \@errors);
(scalar @$results) and $template->param(TAGLOOP => $results);
(scalar @$my_tags) and $template->param(MY_TAGS => $my_tags);

output_html_with_http_headers $query, $cookie, $template->output;
__END__

=head1 EXAMPLE AJAX POST PARAMETERS

CGISESSID	7c6288263107beb320f70f78fd767f56
newtag396	fire,+<a+href="foobar.html">foobar</a>,+<img+src="foo.jpg"+/>

So this request is trying to add 3 tags to biblio #396.  The CGISESSID is the same as that the browser would
typically communicate using cookies.  If it is valid, the server will split the value of "newtag396" and 
process the components for addition.  In this case the intended tags are:
	fire
	<a+href="foobar.html">foobar</a>
	<img src="foo.jpg" />

The first tag is acceptable.  The second will be scrubbed of markup, resulting in the tag "foobar".  
The third tag is all markup, and will be rejected.  

=head1 EXAMPLE AJAX JSON response

response = {
	added: 2,
	deleted: 0,
	errors: 2,
	alerts: [
		 KOHA.Tags.tag_message.scrubbed("foobar"),
 		 KOHA.Tags.tag_message.scrubbed_all_bad("1"),
 	],
};

=cut

