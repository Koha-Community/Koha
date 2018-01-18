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
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Reserves;
use C4::Circulation;
use C4::Members;
use C4::Auth qw/checkauth/;
use Koha::Patrons;

my $input = CGI->new();

checkauth($input, 0, { reserveforothers => 'place_holds' }, 'intranet');

my @bibitems       = $input->multi_param('biblioitem');
my @reqbib         = $input->multi_param('reqbib');
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

my $borrower = Koha::Patrons->find( $borrowernumber );
$borrower = $borrower->unblessed if $borrower;

my $multi_hold = $input->param('multi_hold');
my $biblionumbers = $multi_hold ? $input->param('biblionumbers') : ($biblionumber . '/');
my $bad_bibs = $input->param('bad_bibs');
my $holds_to_place_count = $input->param('holds_to_place_count') || 1;

my %bibinfos = ();
my @biblionumbers = split '/', $biblionumbers;
foreach my $bibnum (@biblionumbers) {
    my %bibinfo = ();
    $bibinfo{title} = $input->param("title_$bibnum");
    $bibinfo{rank} = $input->param("rank_$bibnum");
    $bibinfos{$bibnum} = \%bibinfo;
}

my $found;

# if we have an item selectionned, and the pickup branch is the same as the holdingbranch
# of the document, we force the value $rank and $found .
if (defined $checkitem && $checkitem ne ''){
    $holds_to_place_count = 1;
    $rank[0] = '0' unless C4::Context->preference('ReservesNeedReturns');
    my $item = $checkitem;
    $item = GetItem($item);
    if ( $item->{'holdingbranch'} eq $branch ){
        $found = 'W' unless C4::Context->preference('ReservesNeedReturns');
    }
}

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

        if ( defined $checkitem && $checkitem ne '' ) {
            my $item = GetItem($checkitem);
            if ( $item->{'biblionumber'} ne $biblionumber ) {
                $biblionumber = $item->{'biblionumber'};
            }
        }

        if ($multi_hold) {
            my $bibinfo = $bibinfos{$biblionumber};
            AddReserve($branch,$borrower->{'borrowernumber'},$biblionumber,[$biblionumber],
                       $bibinfo->{rank},$startdate,$expirationdate,$notes,$bibinfo->{title},$checkitem,$found);
        } else {
            # place a request on 1st available
            for ( my $i = 0 ; $i < $holds_to_place_count ; $i++ ) {
                AddReserve( $branch, $borrower->{'borrowernumber'},
                    $biblionumber, \@realbi, $rank[0], $startdate, $expirationdate, $notes, $title,
                    $checkitem, $found, $itemtype );
            }
        }
    }

    if ($multi_hold) {
        if ($bad_bibs) {
            $biblionumbers .= $bad_bibs;
        }
        print $input->redirect("request.pl?biblionumbers=$biblionumbers&multi_hold=1");
    }
    else {
        print $input->redirect("request.pl?biblionumber=$biblionumber");
    }
}
elsif ( $borrowernumber eq '' ) {
    print $input->header();
    print "Invalid borrower number please try again";

    # Not sure that Dump() does HTML escaping. Use firebug or something to trace
    # instead.
    #print $input->Dump;
}
