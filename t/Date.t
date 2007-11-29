print "WARNING: This module (C4::Date) is obsolete.  
Developers should use C4::Dates instead!\n";

BEGIN { $| = 1; print "1..4\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Date;
$loaded = 1;
print "ok 1\n";

# testing format_date_in_iso
my $format= display_date_format ();
my $date;
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
if ($date eq '1973-05-21'){
  print "ok 2\n";
}
else {
  print "not ok 2\n";
}

# test format date
$date=format_date($date);
if ($format eq 'mm/dd/yyyy'){
  if ($date eq '05/21/1973'){
    print "ok 3\n";
  }
  else {
    print "not ok 3\n";
  }
}
elsif ($format eq 'dd/mm/yyyy'){
  if ($date eq '21/05/1973'){
    print "ok 3\n";
  }
  else {
    print "not ok 3\n";
  }
}
elsif ($format eq 'yyyy-mm-dd'){
  if ($date eq '1973-05-21'){
    print "ok 3\n";
  }
  else {
    print "not ok 3\n";
  }
}
else {
  print "not ok3\n";
}

# test 4 fixdate

($date,$invaliddate) = fixdate('2007','06','31');
if ($invaliddate){
  print "ok 4\n";
} else {
  print "not ok 4\n";
}
