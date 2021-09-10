#!/usr/bin/perl

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
use C4::Output;
use C4::Members;

use Koha::Patron::Categories;

my $input = CGI->new;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "common/patron_search.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { suggestions => 'suggestions_manage' },
    }
);

my $q = $input->param('q') || '';
my $op = $input->param('op') || '';
my $selection_type = $input->param('selection_type') || 'add';

my $referer = $input->referer();

# The patrons to return should be superlibrarian or have the suggestions_manage flag
my $permissions = $input->param('permissions');
my $search_patrons_with_suggestion_perm_only =
    ( $permissions && $permissions eq 'suggestions.suggestions_manage' )
        ? 1 : 0;

my $patron_categories = Koha::Patron::Categories->search_with_library_limits({}, {order_by => ['description']});;
$template->param(
    patrons_with_suggestion_perm_only => $search_patrons_with_suggestion_perm_only,
    view => ( $input->request_method() eq "GET" ) ? "show_form" : "show_results",
    callback => scalar $input->param('callback'),
    columns => ['cardnumber', 'name', 'branch', 'category', 'action'],
    json_template => 'acqui/tables/members_results.tt',
    selection_type => $selection_type,
    alphabet        => ( C4::Context->preference('alphabet') || join ' ', 'A' .. 'Z' ),
    categories      => $patron_categories,
    aaSorting       => 1,
);
output_html_with_http_headers( $input, $cookie, $template->output );
