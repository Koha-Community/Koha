#!/usr/bin/perl


#written 14/1/2000
#script to display reports

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
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use Date::Manip;
use C4::Stats;
use C4::Debug;

use vars qw($debug);

my $input = new CGI;
my $time  = $input->param('time') || '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/stats.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 1 },
        debug           => 1,
    }
);

my $date;
my $date2;
if ( $time eq 'yesterday' ) {
    $date  = ParseDate('yesterday');
    $date2 = ParseDate('today');
}
elsif ( $time eq 'today' ) {
    $date  = ParseDate('today');
    $date2 = ParseDate('tomorrow');
}
elsif ( $time eq 'daybefore' ) {
    $date  = ParseDate('2 days ago');
    $date2 = ParseDate('yesterday');
}
elsif ( $time eq 'month' ) {
    $date  = ParseDate('1 month ago');
    $date2 = ParseDate('today');
}
elsif ( $time =~ /\// ) {
    $date  = ParseDate($time);
    $date2 = ParseDateDelta('+ 1 day');
    $date2 = DateCalc( $date, $date2 );
} else {
    $template->param(notime => '1');    # TODO: add error feedback if time sent, but unrecognized
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

$debug and warn "d : $date // d2 : $date2";
$date  = UnixDate( $date,  '%Y-%m-%d' );
$date2 = UnixDate( $date2, '%Y-%m-%d' );
$debug and warn "d : $date // d2 : $date2";
my @payments = TotalPaid( $date, $date2 );
my $count    = @payments;
my $total    = 0;
my $totalw   = 0;
my $oldtime;
my @loop;
my %row;
my $i = 0;

while ( $i < $count ) {
    $debug and warn " pay : " . $payments[$i]{'timestamp'};
    my $time     = $payments[$i]{'datetime'};
    my $payments = $payments[$i]{'value'};
    my $charge   = 0;
    my @temp     = split(/ /, $payments[$i]{'datetime'});
    my $date     = $temp[0];
    my @charges  =
      getcharges( $payments[$i]{'borrowernumber'}, $payments[$i]{'timestamp'} );
    my $count        = @charges;
    my $temptotalf   = 0;
    my $temptotalr   = 0;
    my $temptotalres = 0;
    my $temptotalren = 0;
    my $temptotalw   = 0;

    # FIXME: way too much logic to live only here in a report script
    for ( my $i2 = 0 ; $i2 < $count ; $i2++ ) {
        $charge += $charges[$i2]->{'amount'};
        %row = (
            name   => $charges[$i2]->{'description'},
            type   => $charges[$i2]->{'accounttype'},
            time   => $charges[$i2]->{'timestamp'},
            amount => $charges[$i2]->{'amount'},
            branch => $charges[$i2]->{'amountoutstanding'}
        );
        push( @loop, \%row );
        if ( $payments[$i]{'accountytpe'} ne 'W' ) {
            if ( $charges[$i2]->{'accounttype'} eq 'Rent' ) {
                $temptotalr +=
                  $charges[$i2]->{'amount'} -
                  $charges[$i2]->{'amountoutstanding'};
            }
            if (   $charges[$i2]->{'accounttype'} eq 'F'
                || $charges[$i2]->{'accounttype'} eq 'FU'
                || $charges[$i2]->{'accounttype'} eq 'FN' )
            {
                $temptotalf +=
                  $charges[$i2]->{'amount'} -
                  $charges[$i2]->{'amountoutstanding'};
            }
            if ( $charges[$i2]->{'accounttype'} eq 'Res' ) {
                $temptotalres +=
                  $charges[$i2]->{'amount'} -
                  $charges[$i2]->{'amountoutstanding'};
            }
            if ( $charges[$i2]->{'accounttype'} eq 'R' ) {
                $temptotalren +=
                  $charges[$i2]->{'amount'} -
                  $charges[$i2]->{'amountoutstanding'};
            }
        }
    }
    my $time2 = $payments[$i]{'date'};
    my $branch = Getpaidbranch( $time2, $payments[$i]{'borrowernumber'} );
    my $borrowernumber = $payments[$i]{'borrowernumber'};
    my $oldtime        = $payments[$i]{'timestamp'};
    my $oldtype        = $payments[$i]{'accounttype'};

    while ($borrowernumber eq $payments[$i]{'borrowernumber'}
        && $oldtype == $payments[$i]{'accounttype'}
        && $oldtime eq $payments[$i]{'timestamp'} )
    {
        my $xtime2 = $payments[$i]{'date'};
        my $branch = Getpaidbranch( $xtime2, $payments[$i]{'borrowernumber'} );
        if ( $payments[$i]{'accounttype'} eq 'W' ) {
            $totalw += $payments[$i]{'amount'};
        }
        else {
            $payments[$i]{'amount'} = $payments[$i]{'amount'} * -1;
            $total += $payments[$i]{'amount'};
        }

        #FIXME: display layer HTML
        %row = (
            name => "<b>"
              . $payments[$i]{'firstname'}
              . $payments[$i]{'surname'} . "</b>",
            type   => $payments[$i]{'accounttype'},
            time   => $payments[$i]{'date'},
            amount => $payments[$i]{'amount'},
            branch => $branch
        );
        push( @loop, \%row );
        $oldtype        = $payments[$i]{'accounttype'};
        $oldtime        = $payments[$i]{'timestamp'};
        $borrowernumber = $payments[$i]{'borrowernumber'};
        $i++;
    }
}

$template->param(
    loop1  => \@loop,
    totalw => $totalw,
    total  => $total
);

output_html_with_http_headers $input, $cookie, $template->output;

