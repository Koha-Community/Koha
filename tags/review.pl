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

use Modern::Perl;
use POSIX qw( ceil );
use CGI   qw ( -utf8 );
use CGI::Cookie;    # need to check cookies before having CGI parse the POST request
use URI::Escape qw( uri_escape_utf8 uri_unescape );
use C4::Auth    qw( check_cookie_auth get_template_and_user );
use C4::Context;
use C4::Output qw( output_with_http_headers is_ajax pagination_bar output_html_with_http_headers );
use C4::Tags   qw(
    approval_counts
    blacklist
    get_approval_rows
    is_approved
    whitelist
);

my $script_name  = "/cgi-bin/koha/tags/review.pl";
my $needed_flags = { tools => 'moderate_tags' };     # FIXME: replace when more specific permission is created.

sub ajax_auth_cgi {    # returns CGI object
    my $needed_flags  = shift;
    my %cookies       = CGI::Cookie->fetch;
    my $input         = CGI->new;
    my $sessid        = $cookies{'CGISESSID'}->value;
    my ($auth_status) = check_cookie_auth( $sessid, $needed_flags );
    if ( $auth_status ne "ok" ) {
        output_with_http_headers $input, undef,
            "window.alert('Your CGI session cookie ($sessid) is not current.  "
            . "Please refresh the page and try again.');\n", 'js';
        exit 0;
    }
    return $input;
}

if ( is_ajax() ) {
    my $input    = &ajax_auth_cgi($needed_flags);
    my $operator = C4::Context->userenv->{'number'};    # must occur AFTER auth
    my $js_reply;
    my $op  = $input->param('op') || q{};
    my $tag = $input->param('tag');
    if ( $op eq 'test' ) {
        $tag = uri_unescape($tag);
        my $check = is_approved($tag);
        $js_reply =
              ( $check >= 1 ? 'success' : $check <= -1 ? 'failure' : 'indeterminate' )
            . "_test('"
            . uri_escape_utf8($tag) . "');\n";
    } elsif ( $op eq 'cud-approve' ) {
        $js_reply =
            ( whitelist( $operator, $tag ) ? 'success' : 'failure' ) . "_approve('" . uri_escape_utf8($tag) . "');\n";
    } elsif ( $op eq 'cud-reject' ) {
        $js_reply =
            ( blacklist( $operator, $tag ) ? 'success' : 'failure' ) . "_reject('" . uri_escape_utf8($tag) . "');\n";
    }
    output_with_http_headers $input, undef, $js_reply, 'js';
    exit;
}

### Below is the sad, boring, necessary non-AJAX HTML code.

my $input = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "tags/review.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => $needed_flags,
    }
);

my ( @errors, @tags );

my $op = $input->param('op') || q{};

@tags = $input->multi_param('tags');

if ( $op eq 'cud-approve' ) {
    foreach (@tags) {
        whitelist( $borrowernumber, $_ ) or push @errors, { failed_ok => $_ };
    }
} elsif ( $op eq 'cud-reject' ) {
    foreach (@tags) {
        blacklist( $borrowernumber, $_ ) or push @errors, { failed_rej => $_ };
    }
} elsif ( $op eq 'test' ) {
    my $tag = $input->param('test');
    push @tags, $tag;
    my $check = is_approved($tag);
    $template->param(
        test_term => $tag,
        (
              $check >= 1  ? 'verdict_ok'
            : $check <= -1 ? 'verdict_rej'
            :                'verdict_indeterminate'
        ) => 1,
    );
}

my $counts = &approval_counts;
foreach ( keys %$counts ) {
    $template->param( $_ => $counts->{$_} );
}

sub pagination_calc {
    my $query     = shift or return;
    my $hardlimit = (@_) ? shift : 100;    # hardcoded, could be another syspref
    my $pagesize  = $query->param('limit')  || $hardlimit;
    my $page      = $query->param('page')   || 1;
    my $offset    = $query->param('offset') || 0;
    ( $pagesize <= $hardlimit ) or $pagesize = $hardlimit;
    if ( $page > 1 ) {
        $offset = ( $page - 1 ) * $pagesize;
    } else {
        $page = 1;
    }
    return ( $pagesize, $page, $offset );
}

my ( $pagesize, $page, $offset ) = pagination_calc( $input, 100 );

my %filters = (
    limit => $offset ? "$offset,$pagesize" : $pagesize,
    sort  => 'approved,-weight_total,+term',
);
my ( $filter, $date_from, $date_to );
if ( defined $input->param('approved') ) {    # 0 is valid value, must check defined
    $filter = $input->param('approved');
} else {
    $filter = 0;
}
if ( $filter eq 'all' ) {
    $template->param( filter_approved_all => 1 );
} elsif ( $filter =~ /-?[01]/ ) {
    $filters{approved} = $filter;
    $template->param(
        (
              $filter == 1  ? 'filter_approved_ok'
            : $filter == 0  ? 'filter_approved_pending'
            : $filter == -1 ? 'filter_approved_rej'
            :                 'filter_approved'
        ) => 1
    );
}

# my $q_count = get_approval_rows({limit=>$pagesize, sort=>'approved,-weight_total,+term', count=>1});
if ( $filter = $input->param('tag') ) {
    $template->param( filter_tag => $filter );
    $filters{term} = $filter;
}
if ( $filter = $input->param('from') ) {
    $date_from = $filter;
    $template->param( filter_date_approved_from => $filter );
    $filters{date_approved} = ">=$date_from";
}
if ( $filter = $input->param('to') ) {
    $date_to = $filter;
    $template->param( filter_date_approved_to => $filter );
    $filters{date_approved} = "<=$date_to";
}
if ( $filter = $input->param('approver') ) {    # name (or borrowernumber) from input box
    if ( $filter =~ /^\d+$/ and $filter > 0 ) {

        # $filter=get borrowernumber from name
        # FIXME: get borrowernumber from name not implemented.
        $template->param( filter_approver => $filter );
        $filters{approved_by} = $filter;
    } else {
        push @errors, { approver => $filter };
    }
}
if ( $filter = $input->param('approved_by') ) {    # borrowernumber from link
    if ( $filter =~ /^\d+$/ and $filter > 0 ) {
        $template->param( filter_approver => $filter );
        $filters{approved_by} = $filter;
    } else {
        push @errors, { approved_by => $filter };
    }
}
my $tagloop = get_approval_rows( \%filters );
my $qstring = $input->query_string;
$qstring =~ s/([&;])*\blimit=\d+//;                # remove pagination var
$qstring =~ s/^;+//;                               # remove leading delims
$qstring = "limit=$pagesize" . ( $qstring ? '&amp;' . $qstring : '' );
( scalar @errors ) and $template->param( message_loop => \@errors );
$template->param(
    offset         => $offset,                     # req'd for EXPR
    op             => $op,
    op_count       => scalar(@tags),
    approved       => 0,                           # dummy value (also EXPR)
    tagloop        => $tagloop,
    pagination_bar => pagination_bar(
        "$script_name?$qstring\&amp;",
        ceil( $counts->{approved_total} / $pagesize ),    # $page, 'page'
    )
);

output_html_with_http_headers $input, $cookie, $template->output;
__END__

=head1 AUTHOR

Joe Atzberger
atz AT liblime.com

=cut
