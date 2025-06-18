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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;
use C4::Auth qw( checkauth );
use C4::Biblio;
use C4::Output qw( output_error );
use Koha::Biblios;
use Koha::Items;
use Koha::Linktracker;
use CGI             qw ( -utf8 );
use List::MoreUtils qw( any );

my $cgi          = CGI->new;
my $uri          = $cgi->param('uri') || '';
my $biblionumber = $cgi->param('biblionumber');
my $itemnumber   = $cgi->param('itemnumber');
$uri =~ s/^\s+|\s+$//g if $uri;    # trim

my $tracking_method = C4::Context->preference('TrackClicks');
unless ($tracking_method) {
    output_error( $cgi, '404' );
    exit;
}
my $tracker = Koha::Linktracker->new( { trackingmethod => $tracking_method } );
if ( $uri && ( $biblionumber || $itemnumber ) ) {
    my $borrowernumber;

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

    my $biblio      = Koha::Biblios->find($biblionumber);
    my $record      = eval { $biblio->metadata->record };
    my $marc_urls   = $record ? C4::Biblio::GetMarcUrls( $record, C4::Context->preference('marcflavour') ) : [];
    my $search_crit = { uri => { -like => "%$uri%" } };
    if ($itemnumber) {    # itemnumber is leading over biblionumber
        $search_crit->{itemnumber} = $itemnumber;
    } elsif ($biblionumber) {
        $search_crit->{biblionumber} = $biblionumber;
    }
    if ( ( any { $_ eq $uri } map { $_->{MARCURL} } @$marc_urls )
        || Koha::Items->search($search_crit)->count )
    {
        $tracker->trackclick(
            {
                uri            => $uri,
                biblionumber   => $biblionumber,
                borrowernumber => $borrowernumber,
                itemnumber     => $itemnumber
            }
        ) if ( $tracker->trackingmethod() eq 'track' || $tracker->trackingmethod() eq 'anonymous' );
        print $cgi->redirect($uri);
        exit;
    }
}

output_error( $cgi, '404' );
exit;
