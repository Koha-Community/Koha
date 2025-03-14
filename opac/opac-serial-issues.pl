#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use CGI      qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Serials
    qw( GetFullSubscription GetFullSubscriptionsFromBiblionumber PrepareSerialsData GetSubscription GetSubscriptionsFromBiblionumber );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;

my $query      = CGI->new;
my $op         = $query->param('op');
my $dbh        = C4::Context->dbh;
my $selectview = $query->param('selectview');
$selectview = C4::Context->preference("SubscriptionHistory") unless $selectview;

# my $id;
my ( $template, $loggedinuser, $cookie );
my $biblionumber = $query->param('biblionumber');
if ( $selectview eq "full" ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-full-serial-issues.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
        }
    );
    my $subscriptions           = GetFullSubscriptionsFromBiblionumber($biblionumber);
    my $subscriptioninformation = PrepareSerialsData($subscriptions);

    # PrepareSerialsData does some bogus stuff that the template could handle
    # But at least it sorts the array by the year field so we dont have to
    # find 'manage' if its there
    if ( $subscriptioninformation->[0]->{year} eq 'manage' ) {
        shift @{$subscriptioninformation};
    }

    # now, check is there is an alert subscription for one of the subscriptions
    if ($loggedinuser) {
        foreach (@$subscriptions) {
            my $subscription = Koha::Subscriptions->find( $_->{subscriptionid} );
            my $subscriber   = $subscription->subscribers->find($loggedinuser);
            $_->{hasalert} = 1 if $subscriber;
        }
    }

    my $title   = $subscriptions->[0]->{bibliotitle};
    my $yearmin = $subscriptions->[0]->{year};
    my $yearmax = $subscriptions->[-1]->{year};

    $template->param(
        biblionumber   => scalar $query->param('biblionumber'),
        years          => $subscriptioninformation,
        yearmin        => $yearmin,
        yearmax        => $yearmax,
        bibliotitle    => $title,
        suggestion     => C4::Context->preference("suggestion"),
        virtualshelves => C4::Context->preference("virtualshelves"),
    );

} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-serial-issues.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
        }
    );

    my $subscriptions = GetSubscriptionsFromBiblionumber($biblionumber);

    # now, check is there is an alert subscription for one of the subscriptions
    if ($loggedinuser) {
        foreach (@$subscriptions) {
            my $subscription = Koha::Subscriptions->find( $_->{subscriptionid} );
            my $subscriber   = $subscription->subscribers->find($loggedinuser);
            $_->{hasalert} = 1 if $subscriber;
        }
    }

    my $title = $subscriptions->[0]->{bibliotitle};

    $template->param(
        biblionumber      => scalar $query->param('biblionumber'),
        subscription_LOOP => $subscriptions,
        bibliotitle       => $title,
    );
}
output_html_with_http_headers $query, $cookie, $template->output;
