#!/usr/bin/perl

#things to do

# First sort by branch
#Then sort by surname

#_Branch_:  Could we have Levin displaying as L, please, not C__

#_Totals_ :
#*Total Paid *
#*Total written off*
#*Total credits (which will include manual credits and credits for lost books returned*

#use strict;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use Date::Manip;
use C4::Stats;
use Data::Dumper;

use Text::CSV_XS;

my $csv = Text::CSV_XS->new(
    {
        'quote_char'   => '"',
        'escape_char'  => '"',
        'sep_char'     => ',',
        'binary'       => 1,
        'always_quote' => 1,
    }
);

my $input=new CGI;


my $input=new CGI;
my $time=$input->param('time');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "stats.screen.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 1,
                             flagsrequired => {borrowers => 1},
                             debug => 1,
                             });



#my $time=$input->param('time');
#my $time="month";
#my $time="today";

my $date;
my $date2;
if ($time eq 'yesterday'){
        $date=ParseDate('yesterday');
        $date2=ParseDate('today');
}
if ($time eq 'today'){
        $date=ParseDate('today');
        $date2=ParseDate('tomorrow');
}
if ($time eq 'daybefore'){
        $date=ParseDate('2 days ago');
        $date2=ParseDate('yesterday');
}
if ($time eq 'month') {
        $date = ParseDate('1 month ago');
        $date2 = ParseDate('today');

}
if ($time=~ /\//){
        $date=ParseDate($time);
        $date2=ParseDateDelta('+ 1 day');
        $date2=DateCalc($date,$date2);
}

#my $date=UnixDate($date,'%Y-%m-%d');
#my $date2=UnixDate($date2,'%Y-%m-%d');

my $date="2005-08-19";
my $date2="2005-08-20";

#my $date="2005-01-05";
#my $date2="2005-01-06";

#get a list of every payment
my @payments=TotalPaid($date,$date2);

my $count=@payments;
# print "MASON: number of payments=$count\n";

my $i=0;
my $totalcharges=0;
my $totalcredits=0;
my $totalpaid=0;
my $totalwritten=0;

# lets get a a list of all individual item charges paid for by that payment
while ($i<$count ){

       my $count;
       my @charges;

       if ($payments[$i]{'type'} ne 'writeoff'){         # lets ignore writeoff payments!.
           @charges=getcharges($payments[$i]{'borrowernumber'}, $payments[$i]{'timestamp'}, $payments[$i]{'proccode'});
           $totalcharges++;
           $count=@charges;
           # getting each of the charges and putting them into a array to be printed out
           #this loops per charge per person
           for (my $i2=0;$i2<$count;$i2++){
               my $hour=substr($payments[$i]{'timestamp'},8,2);
               my $min=substr($payments[$i]{'timestamp'},10,2);
               my $sec=substr($payments[$i]{'timestamp'},12,2);
               my $time="$hour:$min:$sec";
               my $time2="$payments[$i]{'date'}";
               my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});


               my $fullname = join ' ', $payments[$i]->{'firstname'}, $payments[$i]->{'surname'};

               # lets build up a row
               my %rows1 = (branch => $branch,
                            datetime => $payments[$i]->{'datetime'},
                            surname => $payments[$i]->{'surname'},
                            firstname => $payments[$i]->{'firstname'},
                            description => $charges[$i2]->{'description'},
                            accounttype => $charges[$i2]->{'accounttype'},
                            amount => sprintf("%.2f", $charges[$i2]->{'amount'}), # rounding amounts to 2dp
                            type => $payments[$i]->{'type'},
                            value => sprintf("%.2f", $charges[$i2]->{'type'})); # rounding amounts to 2dp

               push (@loop1, \%rows1);
           }
       } else {
         ++$totalwritten;
       }
       $i++; #increment the while loop
       $totalpaid = $totalpaid + $payments[$i]->{'value'};
}



#get credits and append to the bottom of payments
my @credits=getcredits($date,$date2);

#print Dumper(@credits);

my $count=@credits;
my $i=0;

while ($i<$count ){

       my %rows2 = (creditbranch        => $credits[$i]->{'branchcode'},
                    creditdate          => $credits[$i]->{'date'},
                    creditsurname       => $credits[$i]->{'surname'},
                    creditfirstname     => $credits[$i]->{'firstname'},
                    creditdescription   => $credits[$i]->{'description'},
                    creditaccounttype   => $credits[$i]->{'accounttype'},
                    creditamount        => $credits[$i]->{'amount'});

       push (@loop2, \%rows2);
       $i++; #increment the while loop
       $totalcredits = $totalcredits + $credits[$i]->{'amount'};
       ;

}
#takes off first char minus sign "-100.00"


$totalcredits = substr($totalcredits, 1);

$template->param( loop1               => \@loop1,
                  loop2               => \@loop2,
                  totalpaid           => $totalpaid,
                  totalcredits        => $totalcredits,
                  totalwritten        => $totalwritten );

output_html_with_http_headers $input, $cookie, $template->output;


