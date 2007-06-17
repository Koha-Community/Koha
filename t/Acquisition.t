BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Acquisition;
$loaded = 1;
print "ok 1\n";

$basketno=NewBasket(1,1);
if ($basketno){
  print "ok 2\n";
}
else {
  print "not ok 2\n";
}

if ($basket=GetBasket($basketno)){
  print "ok 3\n";
}
else {
  print "not ok 3\n";
}
