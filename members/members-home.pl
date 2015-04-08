#!/usr/bin/perl

# Parts Copyright Biblibre 2010
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

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Branch;
use C4::Category;
use Koha::Borrower::Modifications;

my $query = new CGI;
my $branch = $query->param('branchcode');

$branch = q{} unless defined $branch;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tt",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 debug => 1,
                 });

my $branches = GetBranches;
my @branchloop;
if ( C4::Branch::onlymine ) {
    my $userenv = C4::Context->userenv;
    my $branch = C4::Branch::GetBranchDetail( $userenv->{'branch'} );
    push @branchloop, {
        value => $branch->{branchcode},
        branchcode => $branch->{branchcode},
        branchname => $branch->{branchname},
        selected => 1
    }
} else {
    foreach (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %{$branches}) {
        my $selected = 0;
        $selected = 1 if $branch and $branch eq $_;
        push @branchloop, {
            value => $_,
            branchcode => $_,
            branchname => $branches->{$_}->{branchname},
            selected => $selected
        };
    }
}

my @categories;
my $no_categories;
my $no_add = 0;
if(scalar(@branchloop) < 1){
    $no_add = 1;
    $template->param(no_branches => 1);
} 
else {
    $template->param(branchloop=>\@branchloop);
}

@categories=C4::Category->all;
if(scalar(@categories) < 1){ 
    $no_categories = 1; 
}

if($no_categories && C4::Context->preference("AddPatronLists")=~/code/){
    $no_add = 1;
    $template->param(no_categories => 1);
} 
else {
    $template->param(categories=>\@categories);
}


my $pending_borrower_modifications =
  Koha::Borrower::Modifications->GetPendingModificationsCount( $branch );

$template->param( 
        no_add => $no_add,
        pending_borrower_modifications => $pending_borrower_modifications,
            );

$template->param(
    alphabet => C4::Context->preference('alphabet') || join (' ', 'A' .. 'Z'),
    PatronsPerPage => C4::Context->preference("PatronsPerPage") || 20,
);

output_html_with_http_headers $query, $cookie, $template->output;
