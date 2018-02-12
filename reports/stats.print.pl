#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Output;

use C4::Auth;
use C4::Context;
use Date::Manip;
use C4::Stats;
use Text::CSV_XS;
&Date_Init("DateFormat=non-US"); # set non-USA date, eg:19/08/2005

my $csv = Text::CSV_XS->new(
    {
        'quote_char'  => '"',
        'escape_char' => '"',
        'sep_char'    => ',',
        'binary'      => 1
    }
);

my $input=new CGI;
my $time=$input->param('time');
my $time2=$input->param('time2');

my @loop1;
my @loop2;
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

if ($time eq ''){
        $date=ParseDate('today');
        $date2=ParseDate('tomorrow');
}

if ($time2 ne ''){
            $date=ParseDate($time);
            $date2=ParseDate($time2);
}

$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');

#warn "MASON: DATE: $date, $date2";

#get a list of every payment
my @payments=TotalPaid($date,$date2);

my $count=@payments;
# print "MASON: number of payments=$count\n";

my $i = 0;
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
#               my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});
	       my $branch=$payments[$i]{'branch'};

               my @rows1 = ($branch,          # lets build up a row
                            $payments[$i]->{'datetime'},
                            $payments[$i]->{'surname'},
                            $payments[$i]->{'firstname'},
                            $charges[$i2]->{'description'},
                            $charges[$i2]->{'accounttype'},
   # rounding amounts to 2dp and adding dollar sign to make excel read it as currency format
                            "\$".sprintf("%.2f", $charges[$i2]->{'amount'}), 
                            $payments[$i]->{'type'},
                            "\$".$payments[$i]->{'value'});

               push (@loop1, \@rows1);
	       $totalpaid = $totalpaid + $payments[$i]->{'value'};
           }
       } else {
         ++$totalwritten;
       }

       $i++; #increment the while loop
}

#get credits and append to the bottom of payments
my @credits=getcredits($date,$date2);

$count=@credits;
$i=0;

while ($i<$count ){

       my @rows2 = ($credits[$i]->{'branchcode'},
                    $credits[$i]->{'date'},
                    $credits[$i]->{'surname'},
                    $credits[$i]->{'firstname'},
                    $credits[$i]->{'description'},
                    $credits[$i]->{'accounttype'},
                    "\$".$credits[$i]->{'amount'});

       push (@loop2, \@rows2);
       $totalcredits = $totalcredits + $credits[$i]->{'amount'};
       $i++;
}

#takes off first char minus sign "-100.00"
$totalcredits = substr($totalcredits, 1);

print $input->header(
    -type       => 'application/vnd.ms-excel',
    -attachment => "stats.csv",
);
print "Branch, Datetime, Surname, Firstnames, Description, Type, Invoice amount, Payment type, Payment Amount\n";


for my $row ( @loop1 ) {

    $csv->combine(@$row);
    my $string = $csv->string;
    print $string, "\n";
}

print ",,,,,,,\n";

for my $row ( @loop2 ) {

    $csv->combine(@$row);
    my $string = $csv->string;
    print $string, "\n";
}

print ",,,,,,,\n";
print ",,,,,,,\n";
print ",,Total Amount Paid, $totalpaid\n";
print ",,Total Number Written, $totalwritten\n";
print ",,Total Amount Credits, $totalcredits\n";

