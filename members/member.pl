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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use CGI qw( -utf8 );
use Koha::List::Patron qw( GetPatronLists );
use Koha::Patrons;
use Koha::Patron::Attribute::Types;

my $input = CGI->new;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tt",
                 query => $input,
                 type => "intranet",
                 flagsrequired => {borrowers => 'edit_borrowers'},
                 });

my $theme = $input->param('theme') || "default";

my $searchmember = $input->param('searchmember');
my $quicksearch = $input->param('quicksearch') // 0;
my $circsearch = $input->param('circsearch') // 0;

if ( $quicksearch and $searchmember && !$circsearch ) {
    my $branchcode;
    if ( C4::Context::only_my_library ) {
        my $userenv = C4::Context->userenv;
        $branchcode = $userenv->{'branch'};
    }
    my $patron = Koha::Patrons->find( { cardnumber => $searchmember } );
    if (
        $patron
        and (  ( $branchcode and $patron->branchcode eq $branchcode )
            or ( not $branchcode ) )
      )
    {
        print $input->redirect( "/cgi-bin/koha/members/moremember.pl?borrowernumber=" . $patron->borrowernumber );
        exit;
    }
}

my $searchfieldstype = $input->param('searchfieldstype') || 'standard';

$template->param( 'alphabet' => C4::Context->preference('alphabet') || join ' ', 'A' .. 'Z' );

my $defer_loading = $input->request_method() eq "GET"  && !$circsearch ? 1 : 0;

$template->param(
    patron_lists => [ GetPatronLists() ],
    searchmember        => $searchmember,
    branchcode_filter   => scalar $input->param('branchcode_filter'),
    categorycode_filter => scalar $input->param('categorycode_filter'),
    searchfieldstype    => $searchfieldstype,
    PatronsPerPage      => C4::Context->preference("PatronsPerPage") || 20,
    do_not_defer_loading => !$defer_loading,
    circsearch          => $circsearch,
    attribute_type_codes => ( C4::Context->preference('ExtendedPatronAttributes')
        ? [ Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->get_column('code') ]
        : [] ),
);

output_html_with_http_headers $input, $cookie, $template->output;
