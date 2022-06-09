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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Reserves qw( CanItemBeReserved AddReserve CanBookBeReserved );
use C4::Auth qw( checkauth );

use Koha::Items;
use Koha::Patrons;

my $input = CGI->new();

checkauth($input, 0, { reserveforothers => 'place_holds' }, 'intranet');

my @bibitems       = $input->multi_param('biblioitem');
my @reqbib         = $input->multi_param('reqbib');
my @holdable_bibs  = $input->multi_param('holdable_bibs');
my $biblionumber   = $input->param('biblionumber');
my $borrowernumber = $input->param('borrowernumber');
my $notes          = $input->param('notes');
my $branch         = $input->param('pickup');
my $startdate      = $input->param('reserve_date') || '';
my @rank           = $input->multi_param('rank-request');
my $type           = $input->param('type');
my $title          = $input->param('title');
my $checkitem      = $input->param('checkitem');
my $expirationdate = $input->param('expiration_date');
my $itemtype       = $input->param('itemtype') || undef;
my $non_priority   = $input->param('non_priority');

my $borrower = Koha::Patrons->find( $borrowernumber );
$borrower = $borrower->unblessed if $borrower;

my $biblionumbers = $input->param('biblionumbers');
$biblionumbers ||= $biblionumber . '/';

my $holds_to_place_count = $input->param('holds_to_place_count') || 1;

my %bibinfos = ();
my @biblionumbers = split '/', $biblionumbers;
foreach my $bibnum (@biblionumbers) {
    my %bibinfo = ();
    $bibinfo{title}  = $input->param("title_$bibnum");
    $bibinfo{rank}   = $input->param("rank_$bibnum");
    $bibinfo{pickup} = $input->param("pickup_$bibnum");
    $bibinfos{$bibnum} = \%bibinfo;
}

my $found;

if ( $type eq 'str8' && $borrower ) {

    foreach my $biblionumber ( keys %bibinfos ) {
        my $count = @bibitems;
        @bibitems = sort @bibitems;
        my $i2 = 1;
        my @realbi;
        $realbi[0] = $bibitems[0];
        for ( my $i = 1 ; $i < $count ; $i++ ) {
            my $i3 = $i2 - 1;
            if ( $realbi[$i3] ne $bibitems[$i] ) {
                $realbi[$i2] = $bibitems[$i];
                $i2++;
            }
        }

        my $can_override = C4::Context->preference('AllowHoldPolicyOverride');
        if ( defined $checkitem && $checkitem ne '' ) {

            my $item_pickup_location = $input->param("item_pickup_$checkitem");

            my $item = Koha::Items->find($checkitem);

            if ( $item->biblionumber ne $biblionumber ) {
                $biblionumber = $item->biblionumber;
            }

            my $can_item_be_reserved = CanItemBeReserved($borrower->{'borrowernumber'}, $item->itemnumber, $item_pickup_location)->{status};

            if ( $can_item_be_reserved eq 'OK' || ( $can_item_be_reserved ne 'itemAlreadyOnHold' && $can_override ) ) {
                AddReserve(
                    {
                        branchcode       => $item_pickup_location,
                        borrowernumber   => $borrower->{'borrowernumber'},
                        biblionumber     => $biblionumber,
                        priority         => $rank[0],
                        reservation_date => $startdate,
                        expiration_date  => $expirationdate,
                        notes            => $notes,
                        title            => $title,
                        itemnumber       => $checkitem,
                        found            => $found,
                        itemtype         => $itemtype,
                        non_priority     => $non_priority,
                    }
                );

            }

        } elsif (@biblionumbers > 1) {
            my $bibinfo = $bibinfos{$biblionumber};
            if ( $can_override || CanBookBeReserved($borrower->{'borrowernumber'}, $biblionumber)->{status} eq 'OK' ) {
                AddReserve(
                    {
                        branchcode       => $bibinfo->{pickup},
                        borrowernumber   => $borrower->{'borrowernumber'},
                        biblionumber     => $biblionumber,
                        priority         => $bibinfo->{rank},
                        reservation_date => $startdate,
                        expiration_date  => $expirationdate,
                        notes            => $notes,
                        title            => $bibinfo->{title},
                        itemnumber       => $checkitem,
                        found            => $found,
                        itemtype         => $itemtype,
                        non_priority     => $non_priority,
                    }
                );
            }
        } else {
            # place a request on 1st available
            for ( my $i = 0 ; $i < $holds_to_place_count ; $i++ ) {
                if ( $can_override || CanBookBeReserved($borrower->{'borrowernumber'}, $biblionumber)->{status} eq 'OK' ) {
                    AddReserve(
                        {
                            branchcode       => $branch,
                            borrowernumber   => $borrower->{'borrowernumber'},
                            biblionumber     => $biblionumber,
                            priority         => $rank[0],
                            reservation_date => $startdate,
                            expiration_date  => $expirationdate,
                            notes            => $notes,
                            title            => $title,
                            itemnumber       => $checkitem,
                            found            => $found,
                            itemtype         => $itemtype,
                            non_priority     => $non_priority,
                        }
                    );
                }
            }
        }
    }

    print $input->redirect("request.pl?biblionumbers=$biblionumbers");
}
elsif ( $borrowernumber eq '' ) {
    print $input->header();
    print "Invalid borrower number please try again";

    # Not sure that Dump() does HTML escaping. Use firebug or something to trace
    # instead.
    #print $input->Dump;
}
