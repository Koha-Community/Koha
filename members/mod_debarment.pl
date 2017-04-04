#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 ByWater Solutions
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
use Koha::DateUtils;
use Koha::Patron::Debarments;

my $cgi = new CGI;

my ( $loggedinuser, $cookie, $sessionID ) = checkauth( $cgi, 0, { borrowers => 'edit_borrowers' }, 'intranet' );

my $borrowernumber = $cgi->param('borrowernumber');
my $action         = $cgi->param('action');

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find($borrowernumber);

# Ideally we should display a warning on the interface if the patron is not allowed
# to modify a debarment
# But a librarian is not supposed to hack the system
$action = '' unless $logged_in_user->can_see_patron_infos( $patron );

if ( $action eq 'del' ) {
    DelDebarment( scalar $cgi->param('borrower_debarment_id') );
} elsif ( $action eq 'add' ) {
    my $expiration = $cgi->param('expiration');
    if ($expiration) {
        $expiration = dt_from_string($expiration);
        $expiration = $expiration->ymd();
    }

    AddDebarment(
        {   borrowernumber => $borrowernumber,
            type           => 'MANUAL',
            comment        => scalar $cgi->param('comment'),
            expiration     => $expiration,
        }
    );
}

if ( $ENV{HTTP_REFERER} =~ /moremember/ ) {
    print $cgi->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
} else {
    print $cgi->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
}

=head1 author

Kyle M Hall <kyle@bywatersolutions.com>

=cut
