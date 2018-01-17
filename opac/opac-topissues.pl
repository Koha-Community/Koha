#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
# Parts Copyright Catalyst IT 2011
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

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Languages;
use C4::Search;
use C4::Output;
use C4::Koha;
use C4::Circulation;
use Date::Manip;

=head1 NAME

plugin that shows a stats on borrowers

=head1 DESCRIPTION

=cut

my $input = new CGI;

# if OpacTopissue is disabled, leave immediately
if ( ! C4::Context->preference('OpacTopissue') ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {
        template_name   => 'opac-topissues.tt',
        query           => $input,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        debug           => 1,
    }
);
my $dbh = C4::Context->dbh;
# Displaying results
my $do_it = $input->param('do_it') || 0; # as form been posted
my $limit = $input->param('limit');
$limit = 10 unless ($limit && $limit =~ /^\d+$/); # control user input for SQL query
$limit = 100 if $limit > 100;
my $branch = $input->param('branch') || '';
if (!$do_it && C4::Context->userenv && C4::Context->userenv->{'branch'} ) {
    $branch = C4::Context->userenv->{'branch'}; # select user branch by default
}
my $itemtype = $input->param('itemtype') || '';
my $timeLimit = $input->param('timeLimit') || 3;
my $advanced_search_types = C4::Context->preference('AdvancedSearchTypes');
my @advanced_search_types = split /\|/, $advanced_search_types;

my $params = {
    count => $limit,
    branch => $branch,
    newness => $timeLimit < 999 ? $timeLimit * 30 : undef,
};

@advanced_search_types = grep /^(ccode|itemtypes)$/, @advanced_search_types;
foreach my $type (@advanced_search_types) {
    if ($type eq 'itemtypes') {
        $type = 'itemtype';
    }
    $params->{$type} = $input->param($type);
    $template->param('selected_' . $type => scalar $input->param($type));
}

my @results = GetTopIssues($params);

$template->param(
    limit => $limit,
    branch => $branch,
    timeLimit => $timeLimit,
    results => \@results,
);

output_html_with_http_headers $input, $cookie, $template->output;
