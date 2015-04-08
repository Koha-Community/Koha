#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2008 LibLime
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

use warnings;
use strict;
use Data::Dumper;
use POSIX;
use CGI;
use CGI::Cookie; # need to check cookies before having CGI parse the POST request

use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Context;
use C4::Dates qw(format_date format_date_in_iso);
# use C4::Koha;
use C4::Output qw(:html :ajax pagination_bar);
use C4::Debug;
use C4::Tags qw(get_tags get_approval_rows approval_counts whitelist blacklist is_approved);

my $script_name = "/cgi-bin/koha/tags/review.pl";
my $needed_flags = { tools => 'moderate_tags' };	# FIXME: replace when more specific permission is created.

sub ajax_auth_cgi ($) {		# returns CGI object
	my $needed_flags = shift;
	my %cookies = fetch CGI::Cookie;
	my $input = CGI->new;
    my $sessid = $cookies{'CGISESSID'}->value;
	my ($auth_status, $auth_sessid) = check_cookie_auth($sessid, $needed_flags);
	$debug and
	print STDERR "($auth_status, $auth_sessid) = check_cookie_auth($sessid," . Dumper($needed_flags) . ")\n";
	if ($auth_status ne "ok") {
		output_with_http_headers $input, undef,
			"window.alert('Your CGI session cookie ($sessid) is not current.  " . 
			"Please refresh the page and try again.');\n", 'js';
		exit 0;
	}
	$debug and print STDERR "AJAX request: " . Dumper($input),
		"\n(\$auth_status,\$auth_sessid) = ($auth_status,$auth_sessid)\n";
	return $input;
}

if (is_ajax()) {
	my $input = &ajax_auth_cgi($needed_flags);
	my $operator = C4::Context->userenv->{'number'};  # must occur AFTER auth
	$debug and print STDERR "op: " . Dumper($operator) . "\n";
	my ($tag, $js_reply);
	if ($tag = $input->param('test')) {
		my $check = is_approved($tag);
		$js_reply = ( $check >=  1 ? 'success' :
					  $check <= -1 ? 'failure' : 'indeterminate' ) . "_test('$tag');\n";
	}
	if ($tag = $input->param('ok')) {
		$js_reply = (   whitelist($operator,$tag) ? 'success' : 'failure') . "_approve('$tag');\n";
	} 
	if ($tag = $input->param('rej')) {
		$js_reply = (   blacklist($operator,$tag) ? 'success' : 'failure')  . "_reject('$tag');\n";
	}
	output_with_http_headers $input, undef, $js_reply, 'js';
	exit;
}

### Below is the sad, boring, necessary non-AJAX HTML code.

my $input = CGI->new;
my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {
        template_name   => "tags/review.tt",
        query           => $input,
        type            => "intranet",
        debug           => 1,
        authnotrequired => 0,
        flagsrequired   => $needed_flags,
    }
);

my ($op, @errors, @tags);

foreach (qw( approve reject test )) {
    $op = $_ if ( $input->param("op-$_") );
}
$op ||= 'none';

@tags = $input->param('tags');

$borrowernumber == 0 and push @errors, {op_zero=>1};
     if ($op eq 'approve') {
	foreach (@tags) {
	 	whitelist($borrowernumber,$_) or push @errors, {failed_ok=>$_};
	}
} elsif ($op eq 'reject' ) {
	foreach (@tags) {
	 	blacklist($borrowernumber,$_) or push @errors, {failed_rej=>$_};
	}
} elsif ($op eq 'test'   ) {
	my $tag = $input->param('test');
	push @tags, $tag;
	my $check = is_approved($tag);
	$template->param(
		test_term => $tag,
		( $check >=  1 ? 'verdict_ok' :
		  $check <= -1 ? 'verdict_rej' : 'verdict_indeterminate' ) => 1,
	);
}

my $counts = &approval_counts;
foreach (keys %$counts) {
	$template->param($_ => $counts->{$_});
}

sub pagination_calc ($;$) {
	my $query = shift or return undef;	
	my $hardlimit = (@_) ? shift : 100;	# hardcoded, could be another syspref
	my $pagesize = $query->param('limit' ) || $hardlimit;
	my $page     = $query->param('page'  ) || 1;
	my $offset   = $query->param('offset') || 0;
	($pagesize <= $hardlimit) or $pagesize = $hardlimit;
	if ($page > 1) {
		$offset = ($page-1)*$pagesize;
	} else {
		$page = 1;
	}
	return ($pagesize,$page,$offset);
}

my ($pagesize,$page,$offset) = pagination_calc($input,100);

my %filters = (
	limit => $offset ? "$offset,$pagesize" : $pagesize,
	 sort => 'approved,-weight_total,+term',
);
my ($filter,$date_from,$date_to);
if (defined $input->param('approved')) { # 0 is valid value, must check defined
	$filter = $input->param('approved');
} else {
	$filter = 0;
}
if ($filter eq 'all') {
	$template->param(filter_approved_all => 1);
} elsif ($filter =~ /-?[01]/) {
	$filters{approved} = $filter;
	$template->param(
		($filter == 1  ? 'filter_approved_ok'      : 
		 $filter == 0  ? 'filter_approved_pending' :
		 $filter == -1 ? 'filter_approved_rej'     :
		'filter_approved') => 1
	);
}

# my $q_count = get_approval_rows({limit=>$pagesize, sort=>'approved,-weight_total,+term', count=>1});
if ($filter = $input->param('tag')) {
	$template->param(filter_tag=>$filter);
	$filters{term} = $filter;
}
if ($filter = $input->param('from')) {
	if ($date_from = format_date_in_iso($filter)) {
		$template->param(filter_date_approved_from=>$filter);
		$filters{date_approved} = ">=$date_from";
	} else {
		push @errors, {date_from=>$filter};
	}
}
if ($filter = $input->param('to')) {
	if ($date_to = format_date_in_iso($filter)) {
		$template->param(filter_date_approved_to=>$filter);
		$filters{date_approved} = "<=$date_to";
	} else {
		push @errors, {date_to=>$filter};
	}
}
if ($filter = $input->param('approver')) {		# name (or borrowernumber) from input box
	if ($filter =~ /^\d+$/ and $filter > 0) {
		# $filter=get borrowernumber from name
		# FIXME: get borrowernumber from name not implemented.
		$template->param(filter_approver=>$filter);
		$filters{approved_by} = $filter;
	} else {
		push @errors, {approver=>$filter};
	}
}
if ($filter = $input->param('approved_by')) {	# borrowernumber from link
	if ($filter =~ /^\d+$/ and $filter > 0) {
		$template->param(filter_approver=>$filter);
		$filters{approved_by} = $filter;
	} else {
		push @errors, {approved_by=>$filter};
	}
}
$debug and print STDERR "filters: " . Dumper(\%filters);
my $tagloop = get_approval_rows(\%filters);
my $qstring = $input->query_string;
$qstring =~ s/([&;])*\blimit=\d+//;		# remove pagination var
$qstring =~ s/^;+//;					# remove leading delims
$qstring = "limit=$pagesize" . ($qstring ? '&amp;' . $qstring : '');
$debug and print STDERR "number of approval_rows: " . scalar(@$tagloop) . "rows\n";
(scalar @errors) and $template->param(message_loop=>\@errors);
$template->param(
	offset => $offset,	# req'd for EXPR
	op => $op,
	op_count => scalar(@tags),
	script_name => $script_name,
	approved => 0,		# dummy value (also EXPR)
	tagloop => $tagloop,
	pagination_bar => pagination_bar(
		"$script_name?$qstring\&amp;",
		ceil($counts->{approved_total}/$pagesize),	# $page, 'page'
	)
);

output_html_with_http_headers $input, $cookie, $template->output;
__END__

=head1 AUTHOR

Joe Atzberger
atz AT liblime.com

=cut
