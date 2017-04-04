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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use Koha::Patron::Modifications;
use Koha::Libraries;
use Koha::List::Patron;
use Koha::Patron::Categories;

my $query = new CGI;

my ($template, $loggedinuser, $cookie, $flags)
    = get_template_and_user({template_name => "members/member.tt",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 'edit_borrowers'},
                 debug => 1,
                 });

my $no_add = 0;
if( Koha::Libraries->search->count < 1){
    $no_add = 1;
    $template->param(no_branches => 1);
}

my @categories = Koha::Patron::Categories->search_limited;
if(scalar(@categories) < 1){
    $no_add = 1;
    $template->param(no_categories => 1);
}
else {
    $template->param(categories=>\@categories);
}

my $branch =
  (      C4::Context->preference("IndependentBranchesPatronModifications")
      || C4::Context->preference("IndependentBranches") )
  && !$flags->{'superlibrarian'}
  ? C4::Context->userenv()->{'branch'}
  : undef;

my $pending_borrower_modifications = Koha::Patron::Modifications->pending_count( $branch );

$template->param( 
        no_add => $no_add,
        pending_borrower_modifications => $pending_borrower_modifications,
            );

$template->param(
    alphabet => C4::Context->preference('alphabet') || join (' ', 'A' .. 'Z'),
    patron_lists => [ GetPatronLists() ],
    PatronsPerPage => C4::Context->preference("PatronsPerPage") || 20,
);

output_html_with_http_headers $query, $cookie, $template->output;
