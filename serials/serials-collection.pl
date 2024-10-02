#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Biblibre
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
use CGI      qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Serials
    qw( ModSerialStatus GetSubscription GetNextExpected GetNextSeq GetNextDate NewIssue HasSubscriptionExpired abouttoexpire check_routing GetFullSubscription PrepareSerialsData CountSubscriptionFromBiblionumber GetSubscriptionsFromBiblionumber GetFullSubscriptionsFromBiblionumber );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Context;
use Koha::Serial::Items;

use Koha::DateUtils qw( dt_from_string );

use List::MoreUtils qw( uniq );

my $query               = CGI->new;
my $op                  = $query->param('op') || q{};
my $nbissues            = $query->param('nbissues');
my $date_received_today = $query->param('date_received_today') || 0;
my $dbh                 = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "serials/serials-collection.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { serials => '*' },
    }
);
my $biblionumber   = $query->param('biblionumber');
my @subscriptionid = $query->multi_param('subscriptionid');
my $skip_issues    = $query->param('skip_issues') || 0;
my $count_forward  = $skip_issues + 1;

@subscriptionid = uniq @subscriptionid;
@subscriptionid = sort @subscriptionid;
my $subscriptiondescs;
my $subscriptions;

if ( $op eq 'cud-gennext' && @subscriptionid ) {
    my $subscriptionid = $subscriptionid[0];
    my $sth            = $dbh->prepare( "
        SELECT publisheddate, publisheddatetext, serialid, serialseq,
            planneddate, notes, routingnotes
        FROM serial
        WHERE status = 1 AND subscriptionid = ?
    " );
    my $status = defined($nbissues) ? 2 : 3;
    $nbissues ||= 1;
    for ( my $i = 0 ; $i < $nbissues ; $i++ ) {
        $sth->execute($subscriptionid);

        # modify actual expected issue, to generate the next
        if ( my $issue = $sth->fetchrow_hashref ) {
            my $planneddate = $date_received_today ? dt_from_string : $issue->{planneddate};
            ModSerialStatus(
                $issue->{serialid},          $issue->{serialseq},
                $planneddate,                $issue->{publisheddate},
                $issue->{publisheddatetext}, $status, $issue->{notes}, $count_forward
            );
        } else {
            require C4::Serials::Numberpattern;
            my $subscription = GetSubscription($subscriptionid);
            my $pattern   = C4::Serials::Numberpattern::GetSubscriptionNumberpattern( $subscription->{numberpattern} );
            my $frequency = C4::Serials::Frequency::GetSubscriptionFrequency( $subscription->{periodicity} );
            my $expected  = GetNextExpected($subscriptionid);

            ## We generate the next publication date
            my $nextpublisheddate = GetNextDate( $subscription, $expected->{publisheddate}, $frequency, 1 );

            my (
                $newserialseq,  $newlastvalue1, $newlastvalue2, $newlastvalue3,
                $newinnerloop1, $newinnerloop2, $newinnerloop3
                )
                = GetNextSeq(
                $subscription, $pattern, $frequency, $expected->{publisheddate}, $nextpublisheddate,
                $count_forward
                );

            my $planneddate = $date_received_today ? dt_from_string : $nextpublisheddate;
            ## Creating the new issue
            NewIssue(
                $newserialseq,   $subscriptionid, $subscription->{'biblionumber'},
                1,               $planneddate,    $nextpublisheddate, undef,
                $issue->{notes}, $issue->{routingnotes}
            );

            ## Updating the subscription seq status
            my $squery =
                "UPDATE subscription SET lastvalue1=?, lastvalue2=?, lastvalue3=?, innerloop1=?, innerloop2=?, innerloop3=?
                         WHERE  subscriptionid = ?";
            my $seqsth = $dbh->prepare($squery);
            $seqsth->execute(
                $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1,
                $newinnerloop2, $newinnerloop3, $subscriptionid
            );

        }
        last if $nbissues == 1;
        last if HasSubscriptionExpired($subscriptionid) > 0;
    }
    print $query->redirect( '/cgi-bin/koha/serials/serials-collection.pl?subscriptionid=' . $subscriptionid );
    exit;
}

my $countitems     = 0;
my @serialsid      = $query->multi_param('serialid');
my $subscriptionid = $subscriptionid[0];

if ( $op eq 'delete_confirm' ) {
    foreach my $serialid (@serialsid) {
        $countitems += Koha::Serial::Items->search( { serialid => $serialid } )->count();
    }
} elsif ( $op eq 'cud-delete_confirmed' ) {
    if ( $query->param('delitems') eq "Yes" ) {
        my @itemnumbers;
        foreach my $serialid (@serialsid) {
            my @ids = Koha::Serial::Items->search( { serialid => $serialid } )->get_column('itemnumber');
            push( @itemnumbers, @ids );
        }
        my $items = Koha::Items->search( { itemnumber => \@itemnumbers } );
        while ( my $item = $items->next ) {
            my $deleted = $item->safe_delete;
            $template->param( error_delitem => 1 )
                unless $deleted;
        }
    }
    for my $serialid (@serialsid) {
        my $serial = Koha::Serials->find($serialid);
        ModSerialStatus(
            $serialid, $serial->serialseq, $serial->planneddate, $serial->publisheddate,
            $serial->publisheddatetext, 6, ""
        );
    }
}

my $subscriptioncount;
my ( $location, $callnumber );
if (@subscriptionid) {
    my @subscriptioninformation = ();
    my $closed                  = 0;
    foreach my $subscriptionid (@subscriptionid) {
        my $subs = GetSubscription($subscriptionid);
        next unless $subs;
        $closed = 1 if $subs->{closed};

        ##these are display information
        $subs->{'abouttoexpire'}       = abouttoexpire( $subs->{'subscriptionid'} );
        $subs->{'subscriptionexpired'} = HasSubscriptionExpired( $subs->{'subscriptionid'} );
        $subs->{'subscriptionid'}      = $subscriptionid;       # FIXME - why was this lost ?
        $location                      = $subs->{'location'};
        $callnumber                    = $subs->{callnumber};
        my $frequency     = C4::Serials::Frequency::GetSubscriptionFrequency( $subs->{periodicity} );
        my $numberpattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern( $subs->{numberpattern} );
        $subs->{frequency}     = $frequency;
        $subs->{numberpattern} = $numberpattern;
        $subs->{'hasRouting'}  = check_routing($subscriptionid);
        push @$subscriptiondescs, $subs;
        my $tmpsubscription = GetFullSubscription($subscriptionid);
        @subscriptioninformation = ( @$tmpsubscription, @subscriptioninformation );
    }

    output_and_exit( $query, $cookie, $template, 'unknown_subscription' ) unless @subscriptioninformation;

    $template->param( closed => $closed );
    $subscriptions     = PrepareSerialsData( \@subscriptioninformation, 1 );
    $subscriptioncount = CountSubscriptionFromBiblionumber( $subscriptiondescs->[0]{'biblionumber'} );
} else {
    $subscriptiondescs = GetSubscriptionsFromBiblionumber($biblionumber);
    foreach my $s (@$subscriptiondescs) {
        my $frequency     = C4::Serials::Frequency::GetSubscriptionFrequency( $s->{periodicity} );
        my $numberpattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern( $s->{numberpattern} );
        $s->{frequency}     = $frequency;
        $s->{numberpattern} = $numberpattern;
    }
    my $subscriptioninformation = GetFullSubscriptionsFromBiblionumber($biblionumber);
    $subscriptions = PrepareSerialsData( $subscriptioninformation, 1 );
}

my $title = $subscriptiondescs->[0]{bibliotitle};
my $yearmax =
    ( $subscriptions->[0]{year} eq "manage" && scalar(@$subscriptions) > 1 )
    ? $subscriptions->[1]{year}
    : $subscriptions->[0]{year};
my $yearmin            = $subscriptions->[ scalar(@$subscriptions) - 1 ]{year};
my $subscriptionidlist = "";
foreach my $subscription (@$subscriptiondescs) {
    $subscriptionidlist .= $subscription->{'subscriptionid'} . ",";
    $biblionumber = $subscription->{'bibnum'} unless ($biblionumber);
    $subscription->{'hasRouting'} = check_routing( $subscription->{'subscriptionid'} );
}

my $subscription = $subscriptionid ? Koha::Subscriptions->find($subscriptionid) : "";

chop $subscriptionidlist;
$template->param(
    subscription                                 => $subscription,
    subscriptionidlist                           => $subscriptionidlist,
    biblionumber                                 => $biblionumber,
    subscriptions                                => $subscriptiondescs,
    years                                        => $subscriptions,
    yearmin                                      => $yearmin,
    yearmax                                      => $yearmax,
    bibliotitle                                  => $title,
    suggestion                                   => C4::Context->preference("suggestion"),
    virtualshelves                               => C4::Context->preference("virtualshelves"),
    routing                                      => C4::Context->preference("RoutingSerials"),
    subscr                                       => scalar $query->param('subscriptionid'),
    subscriptioncount                            => $subscriptioncount,
    cannotedit                                   => ( not C4::Serials::can_edit_subscription($subscriptionid) ),
    location                                     => $location,
    callnumber                                   => $callnumber,
    uc( C4::Context->preference("marcflavour") ) => 1,
    serialsadditems                              => $subscriptiondescs->[0]{'serialsadditems'},
    delete                                       => ( $op eq 'delete_confirm' ),
    subscriptionid                               => $subscriptionid,
    countitems                                   => $countitems,
    serialnumber                                 => scalar @serialsid,
    serialsid                                    => \@serialsid,
);

output_html_with_http_headers $query, $cookie, $template->output;
