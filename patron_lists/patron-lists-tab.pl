#!/usr/bin/perl

# Copyright 2023 Washington County School District
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Patrons;
use Koha::List::Patron qw( GetPatronLists AddPatronsToList DelPatronsFromList );

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => "patron_lists/patron-lists-tab.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => [
            { circulate => 'circulate_remaining_permissions' }, { borrowers => '*' }, { tools => 'manage_patron_lists' }
        ],
    }
);

my $logged_in_user = Koha::Patrons->find( { borrowernumber => $loggedinuser } );
my $patronnumber   = $cgi->param('borrowernumber');
my $patron         = Koha::Patrons->find($patronnumber);
my ( @in_lists, %list_id_lookup, @available_lists );

my $list_id           = $cgi->param('patron_list_id');
my @patrons_to_add    = $cgi->multi_param('patrons_to_add');
my @patrons_to_remove = $cgi->multi_param('patrons_to_remove');

if ( !$logged_in_user->can_see_patron_infos($patron) ) {
    $template->param( 'no_access_to_patron' => 1 );
} else {
    my $has_perms = C4::Auth::haspermission( $logged_in_user->userid, { 'tools' => 'manage_patron_lists' } );
    if ( $list_id && $has_perms ) {
        my ($list) = GetPatronLists( { patron_list_id => $list_id } );

        if (@patrons_to_add) {
            AddPatronsToList( { list => $list, cardnumbers => \@patrons_to_add } );
        }

        if (@patrons_to_remove) {
            DelPatronsFromList( { list => $list, patron_list_patrons => \@patrons_to_remove } );
        }
    }

    if ($patron) {
        @in_lists = $patron->get_lists_with_patron;
        foreach my $list (@in_lists) {
            my @existing = $list->patron_list_patrons;
            for my $plp (@existing) {
                if ( $plp->borrowernumber->borrowernumber == $patronnumber ) {
                    $list_id_lookup{ $list->patron_list_id } = $plp->patron_list_patron_id;
                    last;
                }
            }
        }
    }
    @available_lists = GetPatronLists();
    @available_lists = grep { !$list_id_lookup{ $_->patron_list_id } } @available_lists;
}

$template->param(
    in_lists        => \@in_lists,
    list_id_lookup  => \%list_id_lookup,
    available_lists => \@available_lists,
    borrowernumber  => $patronnumber,
    cardnumber      => $patron->cardnumber,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );
