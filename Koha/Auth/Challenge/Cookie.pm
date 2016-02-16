package Koha::Auth::Challenge::Cookie;

# Copyright 2015 Vaara-kirjastot
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

use C4::Context;
use C4::Auth;
use Koha::AuthUtils;
use Koha::Patrons;

use Koha::Exception::LoginFailed;

use base qw(Koha::Auth::Challenge);

=head challenge
STATIC

    Koha::Auth::Challenge::Cookie::challenge($cookieValue);

Checks if the given authentication cookie value matches a session, and checks if
the session is still active.
@PARAM1 String, hashed session key identifying a session in koha.sessions
@RETURNS Koha::Patron matching the verified and active session
@THROWS Koha::Exception::LoginFailed, if no session is found,
                                      if the session has expired,
                                      if the session IP address changes,
                                      if no borrower was found for the session
=cut

sub challenge {
    my ($cookie, $originIps) = @_;

    my $session = C4::Auth::get_session($cookie);
    Koha::Exception::LoginFailed->throw(error => "No session matching the given session identifier '$session'.") unless $session;

    # See if the given session is timed out
    if (isSessionExpired($session)) {
        Koha::Exception::clearUserEnvironment($session, {});
        Koha::Exception::LoginFailed->throw(error => "Session expired, please login again.");
    }
    # Check if we still access using the same IP than when the session was initialized.
    elsif ( C4::Context->preference('SessionRestrictionByIP')) {

        my $sameIpFound = grep {$session->param('ip') eq $_} @$originIps;

        unless ($sameIpFound) {
            Koha::Exception::clearUserEnvironment($session, {});
            Koha::Exception::LoginFailed->throw(error => "Session's client address changed, please login again.");
        }
    }

    #Get the Borrower-object
    my $userid   = $session->param('id');
    my $borrower = Koha::AuthUtils::checkKohaSuperuserFromUserid($userid);
    $borrower = Koha::Patrons->find({userid => $userid}) if not($borrower) && $userid;
    Koha::Exception::LoginFailed->throw(error => "Cookie authentication succeeded, but no borrower found with userid '".($userid || '')."'.")
            unless $borrower;

    $session->param( 'lasttime', time() );
    return $borrower;
}

sub isSessionExpired {
    my ($session) = @_;

    if ( ($session->param('lasttime') || 0) < (time()- C4::Auth::_timeout_syspref()) ) {
        return 1;
    }
    return 0;
}

1;
