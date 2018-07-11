#!/usr/bin/perl

# script to log clicks on links to external urls

# Copyright 2012 Catalyst IT
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
use C4::Auth qw(checkauth);
use C4::Biblio;
use Koha::Items;
use Koha::Linktracker;
use CGI qw ( -utf8 );

my $cgi = new CGI;
my $uri = $cgi->param('uri') || '';

my $tracker = Koha::Linktracker->new(
    { trackingmethod => C4::Context->preference('TrackClicks') } );

if ($uri) {
    if (   $tracker->trackingmethod() eq 'track'
        || $tracker->trackingmethod() eq 'anonymous' )
    {
        my $borrowernumber = 0;

        # we have a uri and we want to track
        if ( $tracker->trackingmethod() eq 'track' ) {
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

        my $record = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
        my $marc_urls = C4::Biblio::GetMarcUrls($record, C4::Context->preference('marcflavour'));
        if ( ( grep { $_ eq $uri } map { $_->{MARCURL} } @$marc_urls )
            || Koha::Items->search( { itemnumber => $itemnumber, uri => $uri } )->count )
        {
            $tracker->trackclick(
                {
                    uri            => $uri,
                    biblionumber   => $biblionumber,
                    borrowernumber => $borrowernumber,
                    itemnumber     => $itemnumber
                }
            );
            print $cgi->redirect($uri);
            exit;
        }
    }
    else {

        # We have a valid url, but we shouldn't track it, just redirect
        print $cgi->redirect($uri);
        exit;
    }
}

print $cgi->redirect("/cgi-bin/koha/errors/404.pl");    # escape early
exit;
