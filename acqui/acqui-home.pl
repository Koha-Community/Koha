#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use C4::Suggestions;
use HTML::Template;
use C4::Acquisition;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/acqui-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
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

my ( $count, @results ) = bookfunds($homebranch);
my $classlist   = '';
my $total       = 0;
my $totspent    = 0;
my $totcomtd    = 0;
my $totavail    = 0;
my @loop_budget = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {

    if ( $toggle eq 0 ) {
        $toggle = 1;
    }
    else {
        $toggle = 0;
    }
    my ( $spent, $comtd ) = bookfundbreakdown( $results[$i]->{'bookfundid'} );
    my $avail = $results[$i]->{'budgetamount'} - ( $spent + $comtd );
    my %line;

    $line{bookfundname} = $results[$i]->{'bookfundname'};
    $line{budgetamount} = $results[$i]->{'budgetamount'};
    $line{spent}        = sprintf( "%.2f", $spent );
    $line{comtd}        = sprintf( "%.2f", $comtd );
    $line{avail}        = sprintf( "%.2f", $avail );
    $line{'toggle'}     = $toggle;
    push @loop_budget, \%line;
    $total    += $results[$i]->{'budgetamount'};
    $totspent += $spent;
    $totcomtd += $comtd;
    $totavail += $avail;
}

#currencies
my $rates;
( $count, $rates ) = getcurrencies();
my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates->[$i]->{'currency'};
    $line{rate}     = $rates->[$i]->{'rate'};
    push @loop_currency, \%line;
}

# suggestions ?
my $suggestion = countsuggestion("ASKED");
$template->param(
    classlist     => $classlist,
    type          => 'intranet',
    loop_budget   => \@loop_budget,
    loop_currency => \@loop_currency,
    total         => sprintf( "%.2f", $total ),
    suggestion    => $suggestion,
    totspent      => sprintf( "%.2f", $totspent ),
    totcomtd      => sprintf( "%.2f", $totcomtd ),
    totavail      => sprintf( "%.2f", $totavail ),
    nobudget      => $#results == -1 ? 1 : 0
);

output_html_with_http_headers $query, $cookie, $template->output;
