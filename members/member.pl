#!/usr/bin/perl


#script to do a borrower enquiry/bring up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


# Copyright 2000-2002 Katipo Communications
# Copyright 2013 BibLibre
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
use C4::Auth;
use C4::Output;
use CGI;
use C4::Branch;
use C4::Category;
use C4::Members qw( GetMember );
use Koha::DateUtils;
use Koha::List::Patron;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 });

my $theme = $input->param('theme') || "default";

my $patron = $input->Vars;
foreach (keys %$patron){
    delete $patron->{$_} unless($patron->{$_});
}

my $searchmember = $input->param('searchmember');
my $quicksearch = $input->param('quicksearch') // 0;

if ( $quicksearch and $searchmember ) {
    my $branchcode;
    if ( C4::Branch::onlymine ) {
        my $userenv = C4::Context->userenv;
        $branchcode = $userenv->{'branch'};
    }
    my $member = GetMember(
        cardnumber => $searchmember,
        ( $branchcode ? ( branchcode => $branchcode ) : () ),
    );
    if( $member ){
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=" . $member->{borrowernumber});
        exit;
    }
}

my $searchfieldstype = $input->param('searchfieldstype') || 'standard';

if ( $searchfieldstype eq "dateofbirth" ) {
    $searchmember = output_pref({dt => dt_from_string($searchmember), dateformat => 'iso', dateonly => 1});
}

my $branches = C4::Branch::GetBranches;
my @branches_loop;
if ( C4::Branch::onlymine ) {
    my $userenv = C4::Context->userenv;
    my $branch = C4::Branch::GetBranchDetail( $userenv->{'branch'} );
    push @branches_loop, {
        value => $branch->{branchcode},
        branchcode => $branch->{branchcode},
        branchname => $branch->{branchname},
        selected => 1
    }
} else {
    foreach ( sort { lc($branches->{$a}->{branchname}) cmp lc($branches->{$b}->{branchname}) } keys %$branches ) {
        my $selected = 0;
        $selected = 1 if($patron->{branchcode} and $patron->{branchcode} eq $_);
        push @branches_loop, {
            value => $_,
            branchcode => $_,
            branchname => $branches->{$_}->{branchname},
            selected => $selected
        };
    }
}

my @categories = C4::Category->all;
if ( $patron->{categorycode} ) {
    foreach my $category ( grep { $_->{categorycode} eq $patron->{categorycode} } @categories ) {
        $category->{selected} = 1;
    }
}

$template->param( 'alphabet' => C4::Context->preference('alphabet') || join ' ', 'A' .. 'Z' );

my $view = $input->request_method() eq "GET" ? "show_form" : "show_results";

$template->param(
    patron_lists => [ GetPatronLists() ],
    searchmember        => $searchmember,
    branchloop          => \@branches_loop,
    categories          => \@categories,
    branchcode          => $patron->{branchcode},
    categorycode        => $patron->{categorycode},
    searchtype          => $input->param('searchtype') || 'start_with',
    searchfieldstype    => $searchfieldstype,
    PatronsPerPage      => C4::Context->preference("PatronsPerPage") || 20,
    view                => $view,
);

output_html_with_http_headers $input, $cookie, $template->output;
