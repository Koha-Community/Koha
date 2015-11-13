#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 BibLibre
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
use C4::Branch qw( GetBranches );
use C4::Category;
use C4::Output;
use C4::Members;

my $input = new CGI;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "common/patron_search.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

my $q = $input->param('q') || '';
my $op = $input->param('op') || '';

my $referer = $input->referer();

# If this script is called by acqui/basket.pl
# the patrons to return should be superlibrarian or have the order_manage
# acquisition flag.
my $search_patrons_with_acq_perm_only =
    ( $referer =~ m|acqui/basket.pl| )
        ? 1 : 0;

my $onlymine = C4::Branch::onlymine;
my $branches = C4::Branch::GetBranches( $onlymine );

$template->param(
    patrons_with_acq_perm_only => $search_patrons_with_acq_perm_only,
    view => ( $input->request_method() eq "GET" ) ? "show_form" : "show_results",
    columns => ['cardnumber', 'name', 'branch', 'category', 'action'],
    json_template => 'acqui/tables/members_results.tt',
    selection_type => 'add',
    alphabet        => ( C4::Context->preference('alphabet') || join ' ', 'A' .. 'Z' ),
    categories      => [ C4::Category->all ],
    branches        => [ map { { branchcode => $_->{branchcode}, branchname => $_->{branchname} } } values %$branches ],
    aaSorting       => 1,
);
output_html_with_http_headers( $input, $cookie, $template->output );
