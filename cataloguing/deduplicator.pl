#!/usr/bin/perl


# Copyright 2014-2015 Koha-community
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;
use C4::Output;
use C4::Auth;

use C4::Matcher qw(GetMatcherList);

use Koha::Deduplicator;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/deduplicator.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
    }
);

my $matcher_id = $input->param('matcher_id');
my $op = $input->param('op');
my $param_limit = $input->param('limit');
$template->param(   limit => $param_limit   ) if $param_limit;
my $param_offset = $input->param('offset');
$template->param(   offset => $param_offset   ) if $param_offset;
my $param_biblionumber = $input->param('biblionumber');
$template->param(   biblionumber => $param_biblionumber   ) if $param_biblionumber;


#Get the matchers list and set the selected matcher as selected.
my @matchers = C4::Matcher::GetMatcherList( $matcher_id );
foreach (@matchers) {
    if ($matcher_id && $_->{matcher_id} == $matcher_id) {
        $_->{selected} = 1;
        last();
    }
}
$template->param(   matchers => \@matchers   );

if ($op && $op eq 'deduplicate') {
    #We can set a high $maxMatchCountThreshold here because this doesnt do automatic merging.
    my ($deduplicator, $initErrors) = Koha::Deduplicator->new($matcher_id, $param_limit, $param_offset, $param_biblionumber, 100, 0);
    if ($initErrors) {
        $template->param(   errors => join('<br/>', @$initErrors)   );
    }
    else {
        my $duplicates = $deduplicator->deduplicate();
        $template->param(   duplicates => $duplicates   ) if scalar(@$duplicates) > 0;
        $template->param(   no_duplicates => 1   ) unless scalar(@$duplicates) > 0;
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
