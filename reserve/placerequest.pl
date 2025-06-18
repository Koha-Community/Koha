#!/usr/bin/perl

#script to place reserves/requests
#written 2/1/00 by chris@katipo.oc.nz

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use URI;
use C4::Reserves qw( CanItemBeReserved AddReserve CanBookBeReserved );
use C4::Auth     qw( checkauth );

use Koha::Items;
use Koha::Patrons;

my $input = CGI->new();

checkauth( $input, 0, { reserveforothers => 'place_holds' }, 'intranet' );

my @reqbib         = $input->multi_param('reqbib');
my @biblionumbers  = $input->multi_param('biblionumber');
my @holdable_bibs  = $input->multi_param('holdable_bibs');
my $borrowernumber = $input->param('borrowernumber');
my $notes          = $input->param('notes');
my $branch         = $input->param('pickup');
my $startdate      = $input->param('reserve_date') || '';
my @rank           = $input->multi_param('rank-request');
my $title          = $input->param('title');
my @checkitems     = $input->multi_param('checkitem');
my $item_group_id  = $input->param('item_group_id');
my $expirationdate = $input->param('expiration_date');
my $itemtype       = $input->param('itemtype') || undef;
my $non_priority   = $input->param('non_priority');
my $op             = $input->param('op') || q{};
my $multi_holds    = $input->param('multi_holds');

my $patron = Koha::Patrons->find($borrowernumber);

my $holds_to_place_count = $input->param('holds_to_place_count') || 1;

my %bibinfos = ();
foreach my $bibnum (@holdable_bibs) {
    my %bibinfo = ();
    $bibinfo{title}    = $input->param("title_$bibnum");
    $bibinfo{rank}     = $input->param("rank_$bibnum");
    $bibinfo{pickup}   = $input->param("pickup_$bibnum");
    $bibinfos{$bibnum} = \%bibinfo;
}

if ( $op eq 'cud-placerequest' && $patron ) {
    my %failed_holds;
    foreach my $biblionumber ( keys %bibinfos ) {

        my $can_override = C4::Context->preference('AllowHoldPolicyOverride');
        if (@checkitems) {

            my $hold_priority = $rank[0];

            for ( my $i = 0 ; $i < scalar @checkitems ; $i++ ) {
                my $checkitem = $checkitems[$i];
                if ( my $item_pickup_location = $input->param("item_pickup_$checkitem") ) {

                    my $item = Koha::Items->find($checkitem);

                    if ( $item->biblionumber ne $biblionumber ) {
                        $biblionumber = $item->biblionumber;
                    }

                    my $can_item_be_reserved = CanItemBeReserved( $patron, $item, $item_pickup_location )->{status};

                    if ( $can_item_be_reserved eq 'OK'
                        || ( $can_item_be_reserved ne 'itemAlreadyOnHold' && $can_override ) )
                    {
                        AddReserve(
                            {
                                branchcode       => $item_pickup_location,
                                borrowernumber   => $patron->borrowernumber,
                                biblionumber     => $biblionumber,
                                priority         => $hold_priority,
                                reservation_date => $startdate,
                                expiration_date  => $expirationdate,
                                notes            => $notes,
                                title            => $title,
                                itemnumber       => $checkitem,
                                found            => undef,
                                itemtype         => $itemtype,
                                non_priority     => $non_priority,
                            }
                        );

                        $hold_priority++;

                    } else {
                        $failed_holds{$can_item_be_reserved} = 1;
                    }
                }
            }

        } elsif ( @biblionumbers > 1 || $multi_holds ) {
            my $bibinfo = $bibinfos{$biblionumber};
            if ( $can_override || CanBookBeReserved( $patron->borrowernumber, $biblionumber )->{status} eq 'OK' ) {
                AddReserve(
                    {
                        branchcode       => $bibinfo->{pickup},
                        borrowernumber   => $patron->borrowernumber,
                        biblionumber     => $biblionumber,
                        priority         => $bibinfo->{rank},
                        reservation_date => $startdate,
                        expiration_date  => $expirationdate,
                        notes            => $notes,
                        title            => $bibinfo->{title},
                        itemnumber       => undef,
                        found            => undef,
                        itemtype         => $itemtype,
                        non_priority     => $non_priority,
                    }
                );
            }
        } else {

            # place a request on 1st available
            for ( my $i = 0 ; $i < $holds_to_place_count ; $i++ ) {
                if ( $can_override || CanBookBeReserved( $patron->borrowernumber, $biblionumber )->{status} eq 'OK' ) {
                    AddReserve(
                        {
                            branchcode       => $branch,
                            borrowernumber   => $patron->borrowernumber,
                            biblionumber     => $biblionumber,
                            priority         => $rank[0],
                            reservation_date => $startdate,
                            expiration_date  => $expirationdate,
                            notes            => $notes,
                            title            => $title,
                            itemnumber       => undef,
                            found            => undef,
                            itemtype         => $itemtype,
                            non_priority     => $non_priority,
                            item_group_id    => $item_group_id,
                        }
                    );
                }
            }
        }
    }

    my $redirect_url     = URI->new("request.pl");
    my @failed_hold_msgs = ();

    #NOTE: Deduplicate failed hold reason statuses/codes
    foreach my $msg ( keys %failed_holds ) {
        push( @failed_hold_msgs, $msg );
    }
    $redirect_url->query_form( biblionumber => [@biblionumbers], failed_holds => \@failed_hold_msgs );
    print $input->redirect($redirect_url);
} elsif ( $borrowernumber eq '' ) {
    print $input->header();
    print "Invalid borrower number please try again";

    # Not sure that Dump() does HTML escaping. Use firebug or something to trace
    # instead.
    #print $input->Dump;
}
