#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz


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

use strict;
use warnings;

use CGI;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Reserves;
use C4::Circulation;
use C4::Members;
use C4::Auth qw/checkauth/;

my $input = CGI->new();

checkauth($input, 0, { reserveforothers => 'place_holds' }, 'intranet');

my @bibitems=$input->param('biblioitem');
# FIXME I think reqbib does not exist anymore, it's used in line 82, to AddReserve of contraint type 'o'
#       I bet it's a 2.x feature, reserving a given biblioitem, that is useless in Koha 3.0
#       we can remove this line, the AddReserve of constrainttype 'o',
#       and probably remove the reserveconstraint table as well, I never could fill anything in this table.
my @reqbib=$input->param('reqbib'); 
my $biblionumber=$input->param('biblionumber');
my $borrowernumber=$input->param('borrowernumber');
my $notes=$input->param('notes');
my $branch=$input->param('pickup');
my $startdate=$input->param('reserve_date') || '';
my @rank=$input->param('rank-request');
my $type=$input->param('type');
my $title=$input->param('title');
my $borrower=GetMember('borrowernumber'=>$borrowernumber);
my $checkitem=$input->param('checkitem');
my $expirationdate = $input->param('expiration_date');

my $multi_hold = $input->param('multi_hold');
my $biblionumbers = $multi_hold ? $input->param('biblionumbers') : ($biblionumber . '/');
my $bad_bibs = $input->param('bad_bibs');

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
if ($checkitem ne ''){
    $rank[0] = '0' unless C4::Context->preference('ReservesNeedReturns');
    my $item = $checkitem;
    $item = GetItem($item);
    if ( $item->{'holdingbranch'} eq $branch ){
        $found = 'W' unless C4::Context->preference('ReservesNeedReturns');
    }
}

if ($type eq 'str8' && $borrower){

    foreach my $biblionumber (keys %bibinfos) {
        my $count=@bibitems;
        @bibitems=sort @bibitems;
        my $i2=1;
        my @realbi;
        $realbi[0]=$bibitems[0];
        for (my $i=1;$i<$count;$i++) {
            my $i3=$i2-1;
            if ($realbi[$i3] ne $bibitems[$i]) {
                $realbi[$i2]=$bibitems[$i];
                $i2++;
            }
        }
        my $const;

	if ($checkitem ne ''){
		my $item = GetItem($checkitem);
        	if ($item->{'biblionumber'} ne $biblionumber) {
                	$biblionumber = $item->{'biblionumber'};
        	}
	}



        if ($multi_hold) {
            my $bibinfo = $bibinfos{$biblionumber};
            AddReserve($branch,$borrower->{'borrowernumber'},$biblionumber,'a',[$biblionumber],
                       $bibinfo->{rank},$startdate,$expirationdate,$notes,$bibinfo->{title},$checkitem,$found);
        } else {
            if ($input->param('request') eq 'any'){
                # place a request on 1st available
                AddReserve($branch,$borrower->{'borrowernumber'},$biblionumber,'a',\@realbi,$rank[0],$startdate,$expirationdate,$notes,$title,$checkitem,$found);
            } elsif ($reqbib[0] ne ''){
                # FIXME : elsif probably never reached, (see top of the script)
                # place a request on a given item
                AddReserve($branch,$borrower->{'borrowernumber'},$biblionumber,'o',\@reqbib,$rank[0],$startdate,$expirationdate,$notes,$title,$checkitem, $found);
            } else {
                AddReserve($branch,$borrower->{'borrowernumber'},$biblionumber,'a',\@realbi,$rank[0],$startdate,$expirationdate,$notes,$title,$checkitem, $found);
            }
        }
    }

    if ($multi_hold) {
        if ($bad_bibs) {
            $biblionumbers .= $bad_bibs;
        }
        print $input->redirect("request.pl?biblionumbers=$biblionumbers&multi_hold=1");
    } else {
        print $input->redirect("request.pl?biblionumber=$biblionumber");
    }
} elsif ($borrower eq ''){
	print $input->header();
	print "Invalid borrower number please try again";
# Not sure that Dump() does HTML escaping. Use firebug or something to trace
# instead.
#	print $input->Dump;
}
