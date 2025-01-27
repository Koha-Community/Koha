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

use CGI   qw ( -utf8 );
use POSIX qw( ceil );

use C4::Context;
use C4::Output      qw( output_html_with_http_headers );
use C4::Auth        qw( get_template_and_user );
use C4::Acquisition qw/GetOrdersByBiblionumber/;
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Baskets;

my $input             = CGI->new;
my $startdate         = $input->param('from');
my $enddate           = $input->param('to');
my $ratio             = $input->param('ratio');
my $include_ordered   = $input->param('include_ordered');
my $include_suspended = $input->param('include_suspended');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/reserveratios.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $booksellerid = $input->param('booksellerid') // '';
my $basketno     = $input->param('basketno')     // '';
if ( $booksellerid && $basketno ) {
    $template->param( booksellerid => $booksellerid, basketno => $basketno );
}

my $effective_create_items = q{};
if ($basketno) {
    my $basket = Koha::Acquisition::Baskets->find($basketno);
    if ($basket) {
        $effective_create_items = $basket->effective_create_items;
    } else {
        $effective_create_items = C4::Context->preference('AcqCreateItem');
    }
}

my $todaysdate = dt_from_string;

#    A default of the prior years's holds is a reasonable way to pull holds
$enddate   = $todaysdate                                unless $enddate;
$startdate = $todaysdate->clone->subtract( years => 1 ) unless $startdate;

if ( !defined($ratio) ) {
    $ratio = C4::Context->preference('HoldRatioDefault');
}

# Force to be a number
$ratio += 0;
if ( $ratio <= 0 ) {
    $ratio = 1;    # prevent division by zero
}

my $dbh          = C4::Context->dbh;
my $sqldatewhere = "";
my @query_params = ();

$sqldatewhere .= " AND reservedate >= ?";
push @query_params, $startdate;
$sqldatewhere .= " AND reservedate <= ?";
push @query_params, $enddate;

my $include_aqorders_qty =
    $effective_create_items eq 'receiving'
    ? '+ COALESCE(aqorders.quantity, 0) - COALESCE(aqorders.quantityreceived, 0)'
    : q{};

my $include_aqorders_qty_join =
    $effective_create_items eq 'receiving'
    ? 'LEFT JOIN aqorders ON reserves.biblionumber=aqorders.biblionumber'
    : q{};

my $nfl_comparison = $include_ordered   ? '<=' : '=';
my $sus_comparison = $include_suspended ? '<=' : '<';
my $strsth         = "SELECT reservedate,
        reserves.borrowernumber as borrowernumber,
        reserves.biblionumber,
        reserves.branchcode as branch,
        items.holdingbranch,
        items.itemcallnumber,
        items.itemnumber,
        GROUP_CONCAT(DISTINCT items.itemcallnumber 
            ORDER BY items.itemnumber SEPARATOR '|') as listcall,
        GROUP_CONCAT(DISTINCT homebranch
            ORDER BY items.itemnumber SEPARATOR '|') as homebranch_list,
        GROUP_CONCAT(DISTINCT holdingbranch 
            ORDER BY items.itemnumber SEPARATOR '|') as holdingbranch_list,
        GROUP_CONCAT(DISTINCT items.location 
            ORDER BY items.itemnumber SEPARATOR '|') as l_location,
        GROUP_CONCAT(DISTINCT items.itype 
            ORDER BY items.itemnumber SEPARATOR '|') as l_itype,
        GROUP_CONCAT(DISTINCT items.ccode
            ORDER BY items.ccode SEPARATOR '|') as l_ccode,

        reserves.found,
        biblio.title,
        biblio.subtitle,
        biblio.medium,
        biblio.part_number,
        biblio.part_name,
        biblio.author,
        count(DISTINCT reserves.borrowernumber) as reservecount, 
        count(DISTINCT items.itemnumber) $include_aqorders_qty as itemcount
 FROM  reserves
 LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
 LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
 $include_aqorders_qty_join
 WHERE
 notforloan $nfl_comparison 0 AND damaged = 0 AND itemlost = 0 AND withdrawn = 0
 AND suspend $sus_comparison 1
 $sqldatewhere
";

if ( C4::Context->preference('IndependentBranches') ) {
    $strsth .= " AND items.holdingbranch=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}

$strsth .= " GROUP BY reserves.biblionumber ORDER BY reservecount DESC";

$template->param( sql => $strsth );
my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

my @reservedata;
while ( my $data = $sth->fetchrow_hashref ) {
    my $thisratio     = $data->{reservecount} / $data->{itemcount};
    my $copies_to_buy = ceil( $data->{reservecount} / $ratio - $data->{itemcount} );
    $thisratio >= $ratio or next;    # TODO: tighter targeting -- get ratio limit into SQL using HAVING clause
    push(
        @reservedata,
        {
            reservedate        => $data->{reservedate},
            priority           => $data->{priority},
            name               => $data->{borrower},
            title              => $data->{title},
            subtitle           => $data->{subtitle},
            medium             => $data->{medium},
            part_number        => $data->{part_number},
            part_name          => $data->{part_name},
            author             => $data->{author},
            itemnum            => $data->{itemnumber},
            biblionumber       => $data->{biblionumber},
            holdingbranch      => $data->{holdingbranch},
            homebranch_list    => [ split( '\|', $data->{homebranch_list} ) ],
            holdingbranch_list => [ split( '\|', $data->{holdingbranch_list} ) ],
            branch             => $data->{branch},
            itemcallnumber     => $data->{itemcallnumber},
            location           => [ split( '\|', $data->{l_location} ) ],
            itype              => [ split( '\|', $data->{l_itype} ) ],
            ccode              => [ split( '\|', $data->{l_ccode} ) ],
            reservecount       => $data->{reservecount},
            itemcount          => $data->{itemcount},
            copies_to_buy      => sprintf( "%d",   $copies_to_buy ),
            thisratio          => sprintf( "%.2f", $thisratio ),
            thisratio_atleast1 => ( $thisratio >= 1 ) ? 1 : 0,
            listcall           => [ split( '\|', $data->{listcall} ) ]
        }
    );
}

for my $rd (@reservedata) {
    next unless $rd->{biblionumber};
    $rd->{pendingorders} = CountPendingOrdersByBiblionumber( $rd->{biblionumber} );
}

$template->param(
    todaysdate        => $todaysdate,
    from              => $startdate,
    to                => $enddate,
    ratio             => $ratio,
    include_ordered   => $include_ordered,
    include_suspended => $include_suspended,
    reserveloop       => \@reservedata,
);

output_html_with_http_headers $input, $cookie, $template->output;

sub CountPendingOrdersByBiblionumber {
    my $biblionumber = shift;
    my @orders       = GetOrdersByBiblionumber($biblionumber);
    my $cnt          = 0;
    if ( scalar(@orders) ) {
        for my $order (@orders) {
            next if $order->{datecancellationprinted};
            my $onum = $order->{quantity}         // 0;
            my $rnum = $order->{quantityreceived} // 0;
            next if $rnum >= $onum;
            $cnt += ( $onum - $rnum );
        }
    }
    return $cnt;
}
