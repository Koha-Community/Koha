print "WARNING: This module (C4::Date) is obsolete.  
Developers should use C4::Dates instead!\n";

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Date');
}

# testing format_date_in_iso
my $format= display_date_format ();
my $date;
my $invaliddate;
if ($format eq 'mm/dd/yyyy'){
   $date = '05/21/1973';
}
elsif ($format eq 'dd/mm/yyyy'){   
   $date = '21/05/1973';
}
elsif ($format eq 'yyyy-mm-dd'){
   $date = '1973-05-21';
}
$date=format_date_in_iso($date);
is($date, '1973-05-21', 'format_date_in_iso');

# test format date
$date=format_date($date);
if ($format eq 'mm/dd/yyyy'){
  is($date, '05/21/1973', 'format_date');
}
elsif ($format eq 'dd/mm/yyyy'){
  is($date, '21/05/1973', 'format_date');
}
elsif ($format eq 'yyyy-mm-dd'){
  is($date, '1973-05-21', 'format_date');
}

# test 4 fixdate

($date,$invaliddate) = fixdate('2007','06','31');
if ($invaliddate){
  ok($invaliddate, 'fixdate');
}
