#!/usr/bin/perl

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
use C4::Output;
use C4::Auth;
use C4::Context;
use Date::Manip;
use C4::Stats;

&Date_Init("DateFormat=non-US");    # set non-USA date, eg:19/08/2005

my $input = new CGI;
my $time  = $input->param('time');
my $time2 = $input->param('time2');

if (   $input->param('submit') eq "To Excel"
    || $input->param('submit_x') eq "To Excel" )
{
    print $input->redirect(
        "/cgi-bin/koha/stats.print.pl?time=$time&time2=$time2");
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "stats_screen.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 1,
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
if ( $time eq 'today' ) {
    $date  = ParseDate('today');
    $date2 = ParseDate('tomorrow');
}
if ( $time eq 'daybefore' ) {
    $date  = ParseDate('2 days ago');
    $date2 = ParseDate('yesterday');
}
if ( $time eq 'month' ) {
    $date  = ParseDate('1 month ago');
    $date2 = ParseDate('today');

}
if ( $time =~ /\// ) {
    $date  = ParseDate($time);
    $date2 = ParseDateDelta('+ 1 day');
    $date2 = DateCalc( $date, $date2 );
}

# if time is blank
if ( $time eq '' ) {
    $date  = ParseDate('today');
    $date2 = ParseDate('tomorrow');
}

# if script is called with a start and finsh date range...
if ( $time ne '' && $time2 ne '' ) {
    $date  = ParseDate($time);
    $date2 = ParseDate($time2);
}

$date  = UnixDate( $date,  '%Y-%m-%d' );
$date2 = UnixDate( $date2, '%Y-%m-%d' );

# warn "MASON: TIME: $time, $time2";
# warn "MASON: DATE: $date, $date2";

# get a list of every payment
my @payments = TotalPaid( $date, $date2, 0 );

my $count = @payments;

# print "MASON: number of payments=$count\n";

my $i            = 0;
my $totalcharges = 0;
my $totalcredits = 0;
my $totalpaid    = 0;
my $totalwritten = 0;
my @loop1;
my @loop2;

# lets get a a list of all individual item charges paid for by that payment
while ( $i < $count ) {

    my $count;
    my @charges;

    if ( $payments[$i]{'type'} ne 'writeoff' ) {

        @charges = getcharges(
            $payments[$i]{'borrowernumber'},
            $payments[$i]{'timestamp'},
            $payments[$i]{'proccode'}
        );
        $totalcharges++;
        $count = @charges;

   # getting each of the charges and putting them into a array to be printed out
   #this loops per charge per person
        for ( my $i2 = 0 ; $i2 < $count ; $i2++ ) {
            my $hour = substr( $payments[$i]{'timestamp'}, 8,  2 );
            my $min  = substr( $payments[$i]{'timestamp'}, 10, 2 );
            my $sec  = substr( $payments[$i]{'timestamp'}, 12, 2 );
            my $time = "$hour:$min:$sec";
            my $time2 = "$payments[$i]{'date'}";

#               my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});
            my $branch = $payments[$i]{'branch'};

#	       if ($payments[$i]{'borrowernumber'} == 18265){
#               warn "$payments[$i]{'branch'} $branch $payments[$i]{'borrowernumber'}";#
#		   }
# lets build up a row
            my %rows1 = (
                branch      => $branch,
                datetime    => $payments[$i]->{'datetime'},
                surname     => $payments[$i]->{'surname'},
                firstname   => $payments[$i]->{'firstname'},
                description => $charges[$i2]->{'description'},
                accounttype => $charges[$i2]->{'accounttype'},
                amount      => sprintf( "%.2f", $charges[$i2]->{'amount'} )
                ,    # rounding amounts to 2dp
                type  => $payments[$i]->{'type'},
                value => sprintf( "%.2f", $payments[$i]->{'value'} )
            );       # rounding amounts to 2dp

            push( @loop1, \%rows1 );
            $totalpaid = $totalpaid + $payments[$i]->{'value'};
        }
    }
    else {
        ++$totalwritten;
    }

    $i++;            #increment the while loop
}

#get credits and append to the bottom of payments
my @credits = getcredits( $date, $date2 );

$count = @credits;
$i     = 0;

while ( $i < $count ) {

    my %rows2 = (
        creditbranch      => $credits[$i]->{'branchcode'},
        creditdate        => $credits[$i]->{'date'},
        creditsurname     => $credits[$i]->{'surname'},
        creditfirstname   => $credits[$i]->{'firstname'},
        creditdescription => $credits[$i]->{'description'},
        creditaccounttype => $credits[$i]->{'accounttype'},
        creditamount      => sprintf( "%.2f", $credits[$i]->{'amount'} )
    );

    push( @loop2, \%rows2 );
    $totalcredits = $totalcredits + $credits[$i]->{'amount'};
    $i++;    #increment the while loop
}

#takes off first char minus sign "-100.00"
$totalcredits = substr( $totalcredits, 1 );

my $totalrefunds = 0;
my @loop3;
my @refunds = getrefunds( $date, $date2 );
$count = @refunds;
$i     = 0;

while ( $i < $count ) {

    my %rows2 = (
        refundbranch      => $refunds[$i]->{'branchcode'},
        refunddate        => $refunds[$i]->{'date'},
        refundsurname     => $refunds[$i]->{'surname'},
        refundfirstname   => $refunds[$i]->{'firstname'},
        refunddescription => $refunds[$i]->{'description'},
        refundaccounttype => $refunds[$i]->{'accounttype'},
        refundamount      => sprintf( "%.2f", $refunds[$i]->{'amount'} )
    );

    push( @loop3, \%rows2 );
    $totalrefunds = $totalrefunds + $refunds[$i]->{'amount'};
    $i++;    #increment the while loop
}

my $totalcash = $totalpaid - $totalrefunds;

$template->param(
    date         => $time,
    date2        => $time2,
    loop1        => \@loop1,
    loop2        => \@loop2,
    loop3        => \@loop3,
    totalpaid    => $totalpaid,
    totalcredits => $totalcredits,
    totalwritten => $totalwritten,
    totalrefund  => $totalrefunds,
    totalcash    => $totalcash
);

output_html_with_http_headers $input, $cookie, $template->output;

