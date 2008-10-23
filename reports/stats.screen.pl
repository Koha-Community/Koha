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
use C4::Stats;
use C4::Accounts;
use C4::Debug;
use Date::Manip;

my $input = new CGI;
my $time  = $input->param('time');
my $time2 = $input->param('time2');
my $op    = $input->param('submit');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/stats_screen.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { reports => 1 },
        debug           => 1,
    }
);

( $time  = "today" )    if !$time;
( $time2 = "tomorrow" ) if !$time2;

my $date  = ParseDate($time);
my $date2 = ParseDate($time2);
$date  = UnixDate( $date,  '%Y-%m-%d' );
$date2 = UnixDate( $date2, '%Y-%m-%d' );
$debug and warn "MASON: TIME: $time, $time2";
$debug and warn "MASON: DATE: $date, $date2";

# get a list of every payment
my @payments = TotalPaid( $date, $date2 );

my $count = @payments;

$debug and warn "MASON: number of payments=$count\n";

my $i            = 0;
my $totalcharges = 0;
my $totalcredits = 0;
my $totalpaid    = 0;
my $totalwritten = 0;
my @loop1;
my @loop2;

# lets get a a list of all individual item charges paid for by that payment

foreach my $payment (@payments) {

    my @charges;
    if ( $payment->{'type'} ne 'writeoff' ) {

        @charges = getcharges(
            $payment->{'borrowernumber'},
            $payment->{'timestamp'},
            $payment->{'proccode'}
        );
        $totalcharges++;
        my $count = @charges;

   # getting each of the charges and putting them into a array to be printed out
   #this loops per charge per person
        for ( my $i2 = 0 ; $i2 < $count ; $i2++ ) {
            my $hour = substr( $payment->{'timestamp'}, 8,  2 );
            my $min  = substr( $payment->{'timestamp'}, 10, 2 );
            my $sec  = substr( $payment->{'timestamp'}, 12, 2 );
            my $time = "$hour:$min:$sec";
            my $time2 = "$payment->{'date'}";

  #               my $branch=Getpaidbranch($time2,$payment->{'borrowernumber'});
            my $branch = $payment->{'branch'};

            # lets build up a row
            my %rows1 = (
                branch      => $branch,
                datetime    => $payment->{'datetime'},
                surname     => $payment->{'surname'},
                firstname   => $payment->{'firstname'},
                description => $charges[$i2]->{'description'},
                accounttype => $charges[$i2]->{'accounttype'},
                amount      => sprintf( "%.2f", $charges[$i2]->{'amount'} )
                ,    # rounding amounts to 2dp
                type  => $payment->{'type'},
                value => sprintf( "%.2f", $payment->{'value'} )
            );       # rounding amounts to 2dp

            push( @loop1, \%rows1 );

        }
            $totalpaid = $totalpaid + $payment->{'value'};
			$debug and warn "totalpaid = $totalpaid";		
    }
    else {
        ++$totalwritten;
    }

}

#get credits and append to the bottom of payments
my @credits = getcredits( $date, $date2 );

my $count = @credits;
my $i     = 0;

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

    my %rows3 = (
        refundbranch      => $refunds[$i]->{'branchcode'},
        refunddate        => $refunds[$i]->{'datetime'},
        refundsurname     => $refunds[$i]->{'surname'},
        refundfirstname   => $refunds[$i]->{'firstname'},
        refunddescription => $refunds[$i]->{'description'},
        refundaccounttype => $refunds[$i]->{'accounttype'},
        refundamount      => sprintf( "%.2f", $refunds[$i]->{'amount'} )
    );

    push( @loop3, \%rows3 );
    $totalrefunds = $totalrefunds + $refunds[$i]->{'amount'};
    $i++;    #increment the while loop
}

my $totalcash = $totalpaid - $totalrefunds;

if ( $op eq 'To Excel' ) {

    my $csv = Text::CSV_XS->new(
        {
            'quote_char'  => '"',
            'escape_char' => '"',
            'sep_char'    => ',',
            'binary'      => 1
        }
    );

    print $input->header(
        -type       => 'application/vnd.ms-excel',
        -attachment => "stats.csv",
    );
    print
"Branch, Datetime, Surname, Firstnames, Description, Type, Invoice amount, Payment type, Payment Amount\n";

    $DB::single = 1;

    for my $row (@loop1) {
        my @array = (
            $row->{'branch'},      $row->{'datetime'},
            $row->{'surname'},     $row->{'firstname'},
            $row->{'description'}, $row->{'accounttype'},
            $row->{'amount'},      $row->{'type'},
            $row->{'value'}
        );

        $csv->combine(@array);
        my $string = $csv->string(@array);
        print $string, "\n";
    }
    print ",,,,,,,\n";
    print
"Branch, Date/time, Surname, Firstname, Description, Charge Type, Invoice Amount\n";

    for my $row (@loop2) {

        my @array = (
            $row->{'creditbranch'},      $row->{'creditdate'},
            $row->{'creditsurname'},     $row->{'creditfirstname'},
            $row->{'creditdescription'}, $row->{'creditaccounttype'},
            $row->{'creditamount'}
        );

        $csv->combine(@array);
        my $string = $csv->string(@array);
        print $string, "\n";
    }
    print ",,,,,,,\n";
    print
"Branch, Date/time, Surname, Firstname, Description, Charge Type, Invoice Amount\n";

    for my $row (@loop3) {
        my @array = (
            $row->{'refundbranch'},      $row->{'refunddate'},
            $row->{'refundsurname'},     $row->{'refundfirstname'},
            $row->{'refunddescription'}, $row->{'refundaccounttype'},
            $row->{'refundamount'}
        );

        $csv->combine(@array);
        my $string = $csv->string(@array);
        print $string, "\n";

    }

    print ",,,,,,,\n";
    print ",,,,,,,\n";
    print ",,Total Amount Paid, $totalpaid\n";
    print ",,Total Number Written, $totalwritten\n";
    print ",,Total Amount Credits, $totalcredits\n";
    print ",,Total Amount Refunds, $totalrefunds\n";
}
else {
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
        totalcash    => $totalcash,
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

