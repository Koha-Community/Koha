#!/usr/bin/perl

# script to log clicks on links to external urls

# Copyright 2012 Catalyst IT
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use C4::Context;
use C4::Auth qw(checkauth);
use CGI;

my $trackinglinks = C4::Context->preference('TrackClicks');

my $cgi = new CGI;
my $uri = $cgi->param('uri') || '';

if ($uri) {
    if ( $trackinglinks eq 'track' || $trackinglinks eq 'anonymous' ) {
        my $borrowernumber = 0;

        # we have a uri and we want to track
        if ( $trackinglinks eq 'track' ) {
            my ( $user, $cookie, $sessionID, $flags ) =
              checkauth( $cgi, 1, {}, 'opac' );
            my $userenv = C4::Context->userenv;

            if (   defined($userenv)
                && ref($userenv) eq 'HASH'
                && $userenv->{number} )
            {
                $borrowernumber = $userenv->{number};
            }

            # get borrower info
        }
        my $biblionumber = $cgi->param('biblionumber') || 0;
        my $itemnumber   = $cgi->param('itemnumber')   || 0;

        trackclick( $uri, $biblionumber, $borrowernumber, $itemnumber );
        print $cgi->redirect($uri);
    }
    else {

        # We have a valid url, but we shouldn't track it, just redirect
        print $cgi->redirect($uri);
    }
}
else {

    # we shouldn't be here, bail out
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");    # escape early
    exit;
}

sub trackclick {
    my ( $uri, $biblionumber, $borrowernumber, $itemnumber ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query = "INSERT INTO linktracker (biblionumber,itemnumber,borrowernumber
    ,url,timeclicked) VALUES (?,?,?,?,now())";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $itemnumber, $borrowernumber, $uri );

}
