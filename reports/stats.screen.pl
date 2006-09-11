#!/usr/bin/perl

use strict;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::Stats;
&Date_Init("DateFormat=non-US"); # set non-USA date, eg:19/08/2005

my $input=new CGI;
my $time=$input->param('time');
my $date=$input->param('from');
my $date2=$input->param('to');
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "reports/stats.screen.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                             flagsrequired => {borrowers => 1},
                             debug => 1,
                             });


#get a list of every payment
my @payments=TotalPaid($date,$date2);

my $count=@payments;
# warn "number of payments=$count\n";

my $i=0;
my $totalcharges=0;
my $totalcredits=0;
my $totalpaid=0;
my $totalwritten=0;
my $totalwrittenamount=0;
my $totalinvoicesamount=0;
my $totalinvoices=0;
my @loop1;
my @loop2;
my @loop3;

# lets get a a list of all individual item charges paid for by that payment
while ($i<$count ){

       my $count;
       my @charges;

       if ($payments[$i]->{'accounttype'} ne 'W'){         # lets ignore writeoff payments!.
           @charges=getcharges($payments[$i]{'borrowernumber'}, $payments[$i]{'offset'}, $payments[$i]{'accountno'});
           $totalcharges++;
           $count=@charges;

           # getting each of the charges and putting them into a array to be printed out
           #this loops per charge per person
           for (my $i2=0;$i2<$count;$i2++){
              
               my $time2="$payments[$i]{'date'}";
#               my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});

               # lets build up a row
               my %rows1 = ( datetime => $payments[$i]->{'timestamp'},
                            surname => $payments[$i]->{'surname'},
                            firstname => $payments[$i]->{'firstname'},
                            description => $payments[$i]->{'description'},
                            accounttype => $charges[$i2]->{'accounttype'},
                            amount => sprintf("%.2f",  $charges[$i2]->{'amount'}), # rounding amounts to 2dp
                            type => $payments[$i]->{'accounttype'},
                            value => sprintf("%.2f", $payments[$i]->{'amount'}*(-1))); # rounding amounts to 2dp

               push (@loop1, \%rows1);
  $totalpaid = sprintf("%.2f",$totalpaid + $payments[$i]->{'amount'}*(-1));
           }
       } else {
$totalwrittenamount= sprintf("%.2f",$totalwrittenamount + $payments[$i]->{'amount'}*(-1));
         ++$totalwritten;
       }
      
     
 $i++; #increment the while loop
}

#get credits and append to the bottom of payments
my @credits=getcredits($date,$date2);

my $count=@credits;
my $i=0;

while ($i<$count ){

       my %rows2 = (creditdate          => format_date($credits[$i]->{'date'}),
                    creditsurname       => $credits[$i]->{'surname'},
                    creditfirstname     => $credits[$i]->{'firstname'},
                    creditdescription   => $credits[$i]->{'description'},
                    creditaccounttype   => $credits[$i]->{'accounttype'},
                    creditamount        => sprintf("%.2f",$credits[$i]->{'amount'}*(-1)));

       push (@loop2, \%rows2);
    
       $totalcredits =sprintf("%.2f", $totalcredits + $credits[$i]->{'amount'});
         $i++; #increment the while loop

}


#takes off first char minus sign "-100.00"
$totalcredits = substr($totalcredits, 1);

my @invoices=getinvoices($date,$date2);
my $count=@invoices;
my $i=0;

while ($i<$count ){

       my %rows3 = (invoicesdate          => format_date($invoices[$i]->{'date'}),
                   invoicessurname       => $invoices[$i]->{'surname'},
                   invoicesfirstname     => $invoices[$i]->{'firstname'},
                    invoicesdescription   => $invoices[$i]->{'description'},
                    invoicesaccounttype   => $invoices[$i]->{'accounttype'},
                    invoicesamount        => sprintf("%.2f",$invoices[$i]->{'amount'}),
	invoicesamountremaining=>sprintf("%.2f",$invoices[$i]->{'amountoutstanding'}));
       push (@loop3, \%rows3);
         $totalinvoicesamount =sprintf("%.2f", $totalinvoicesamount + $invoices[$i]->{'amountoutstanding'});
       $totalinvoices =sprintf("%.2f", $totalinvoices + $invoices[$i]->{'amount'});
         $i++; #increment the while loop

}
$template->param( loop1               => \@loop1,
                  loop2               => \@loop2,
		 loop3               => \@loop3,
                  totalpaid           => $totalpaid,
                  totalcredits        => $totalcredits,
		totalcreditsamount        => sprintf("%.2f",$totalcredits-$totalwrittenamount),
	totalwrittenamount        => $totalwrittenamount,
                  totalwritten        => $totalwritten ,
	totalinvoices=>$totalinvoices, totalinvoicesamount=>$totalinvoicesamount	);

output_html_with_http_headers $input, $cookie, $template->output;
