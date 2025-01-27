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

=head1 NAME

subscription-renew.pl

=head1 DESCRIPTION

this script renew an existing subscription.

=head1 Parameters

=over 4

=item op
op use to know the operation to do on this template.
 * renew : to renew the subscription.

Note that if op = modsubscription there are a lot of other parameters.

=item subscriptionid
Id of the subscription this script has to renew

=back

=cut

use Modern::Perl;

use CGI  qw ( -utf8 );
use Carp qw( carp );
use C4::Koha;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_and_exit output_html_with_http_headers );
use C4::Serials     qw( GetSubscription GetSubscriptionLength NewSubscription ReNewSubscription );
use Koha::DateUtils qw( dt_from_string output_pref );

my $query = CGI->new;
my $dbh   = C4::Context->dbh;

my $op              = $query->param('op') || 'display';
my @subscriptionids = $query->multi_param('subscriptionid');
my $branchcode      = $query->param('branchcode');
my $sublength       = $query->param('sublength');
my $subtype         = $query->param('subtype');
my ( $numberlength, $weeklength, $monthlength );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "serials/subscription-renew.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { serials => 'renew_subscription' },
    }
);
if ( $op eq "cud-renew" ) {

    # Do not use this script with op=renew and @subscriptionids > 1!
    my $subscriptionid = $subscriptionids[0];

    # Make sure the subscription exists
    my $subscription = GetSubscription($subscriptionid);
    output_and_exit( $query, $cookie, $template, 'unknown_subscription' ) unless $subscription;

    if ( $subscription->{cannotedit} ) {
        carp "Attempt to renew subscription $subscriptionid by " . C4::Context->userenv->{'id'} . " not allowed";
        print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }

    my $startdate = output_pref( { str => scalar $query->param('startdate'), dateonly => 1, dateformat => 'iso' } );
    ( $numberlength, $weeklength, $monthlength ) = GetSubscriptionLength( $subtype, $sublength );
    ReNewSubscription(
        {
            subscriptionid => $subscriptionid,
            user           => $loggedinuser,
            startdate      => $startdate,
            numberlength   => $numberlength,
            weeklength     => $weeklength,
            monthlength    => $monthlength,
            note           => scalar $query->param('note'),
            branchcode     => $branchcode
        }
    );
} elsif ( $op eq 'cud-multi_renew' ) {
    for my $subscriptionid (@subscriptionids) {
        my $subscription = GetSubscription($subscriptionid);
        next unless $subscription;
        next if $subscription->{cannotedit};
        ReNewSubscription(
            {
                subscriptionid => $subscriptionid,
                user           => $loggedinuser,
                startdate      => $subscription->{enddate},
                numberlength   => $subscription->{numberlength},
                weeklength     => $subscription->{weeklength},
                monthlength    => $subscription->{monthlength},
            }
        );
    }
} elsif ( $op eq 'multi_renew' ) {
    my @subscriptions;
    for my $subscriptionid (@subscriptionids) {
        my $subscription = GetSubscription($subscriptionid);
        next unless $subscription;
        next if $subscription->{cannotedit};
        push @subscriptions, $subscription;
    }

    $template->param(
        subscriptions => \@subscriptions,
    );
} else {
    my $subscriptionid = $subscriptionids[0];
    my $subscription   = GetSubscription($subscriptionid);
    output_and_exit( $query, $cookie, $template, 'unknown_subscription' ) unless $subscription;
    if ( $subscription->{'cannotedit'} ) {
        carp "Attempt to renew subscription $subscriptionid by " . C4::Context->userenv->{'id'} . " not allowed";
        print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
    }

    my $newstartdate = output_pref( { str => $subscription->{enddate}, dateonly => 1 } )
        or output_pref( { dt => dt_from_string, dateonly => 1 } );

    $template->param(
        startdate    => $newstartdate,
        subscription => $subscription,
    );
}

$template->param(
    op => $op,
);

output_html_with_http_headers $query, $cookie, $template->output;
