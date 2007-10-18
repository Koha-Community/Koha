#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Bookfund;

my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/acqui-search.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 1 },
        debug           => 1,
    }
);

# budget
my $dbh     = C4::Context->dbh;
my $sthtemp =
  $dbh->prepare(
    "Select flags, branchcode from borrowers where borrowernumber = ?");
$sthtemp->execute($loggedinuser);
my ( $flags, $homebranch ) = $sthtemp->fetchrow;
my @results = GetBookFunds($homebranch);
my $count   = scalar(@results);

my $classlist   = '';
my $total       = 0;
my $totspent    = 0;
my $totcomtd    = 0;
my $totavail    = 0;
my @loop_budget = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my ( $spent, $comtd ) =
      GetBookFundBreakdown( $results[$i]->{'bookfundid'} );
    my $avail = $results[$i]->{'budgetamount'} - ( $spent + $comtd );
    my %line;
    $line{bookfundname} = $results[$i]->{'bookfundname'};
    $line{budgetamount} = $results[$i]->{'budgetamount'};
    $line{spent}        = sprintf( "%.2f", $spent );
    $line{comtd}        = sprintf( "%.2f", $comtd );
    $line{avail}        = sprintf( "%.2f", $avail );
    push @loop_budget, \%line;
    $total    += $results[$i]->{'budgetamount'};
    $totspent += $spent;
    $totcomtd += $comtd;
    $totavail += $avail;
}

#currencies
my @rates = GetCurrencies();
my $count = scalar @rates;

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    push @loop_currency, \%line;
}
$template->param(
    classlist     => $classlist,
    type          => 'intranet',
    loop_budget   => \@loop_budget,
    loop_currency => \@loop_currency,
    total         => sprintf( "%.2f", $total ),
    totspent      => sprintf( "%.2f", $totspent ),
    totcomtd      => sprintf( "%.2f", $totcomtd ),
    totavail      => sprintf( "%.2f", $totavail )
);

output_html_with_http_headers $query, $cookie, $template->output;
