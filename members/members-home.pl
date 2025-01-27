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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Members;
use Koha::Patron::Modifications;
use Koha::Libraries;
use Koha::List::Patron qw( GetPatronLists );
use Koha::Patron::Categories;
use Koha::Patron::Attribute::Types;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "members/member.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { borrowers => [ 'edit_borrowers', 'list_borrowers' ] },
    }
);

my $no_add = 0;
if ( Koha::Libraries->search->count < 1 ) {
    $no_add = 1;
    $template->param( no_branches => 1 );
}

my $categories = Koha::Patron::Categories->search_with_library_limits;
unless ( $categories->count ) {
    $no_add = 1;
    $template->param( no_categories => 1 );
} else {

    # FIXME This does not seem to be used in the template
    $template->param( categories => $categories );
}

my $branch =
    (      C4::Context->preference("IndependentBranchesPatronModifications")
        || C4::Context->preference("IndependentBranches") )
    && !$flags->{'superlibrarian'}
    ? C4::Context->userenv()->{'branch'}
    : undef;

my $pending_borrower_modifications = Koha::Patron::Modifications->pending_count($branch);

$template->param(
    no_add                         => $no_add,
    pending_borrower_modifications => $pending_borrower_modifications,
);

$template->param(
    alphabet           => C4::Context->preference('alphabet') || join( ' ', 'A' .. 'Z' ),
    PatronAutoComplete => C4::Context->preference('PatronAutoComplete'),
    patron_lists       => [ GetPatronLists() ],
    PatronsPerPage     => C4::Context->preference("PatronsPerPage") || 20,
    defer_loading      => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
