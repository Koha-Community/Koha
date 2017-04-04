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

my $query = new CGI;

# FIXME Should be a checkauth call
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "about.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 'edit_borrowers' },
        debug           => 1,
    }
);

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";

my @params = $query->param;

foreach my $param (@params) {
    if ( $param =~ "^modify_" ) {
        my (undef, $borrowernumber) = split( /_/, $param );

        my $patron = Koha::Patrons->find($borrowernumber);
        next unless $logged_in_user->can_see_patron_infos( $patron );

        my $action = $query->param($param);

        if ( $action eq 'approve' ) {
            my $m = Koha::Patron::Modifications->find( { borrowernumber => $borrowernumber } );

            if ($query->param("unset_gna_$borrowernumber")) {
                # Unset gone no address
                ModMember(
                    borrowernumber => $borrowernumber,
                    gonenoaddress  => undef
                );
            }

            $m->approve() if $m;
        }
        elsif ( $action eq 'deny' ) {
            my $m = Koha::Patron::Modifications->find( { borrowernumber => $borrowernumber } );
            $m->delete() if $m;
        }
        # elsif ( $action eq 'ignore' ) { }
    }
}

print $query->redirect("/cgi-bin/koha/members/members-update.pl");
