# Basic compile test only at this stage, needs to be fleshed out

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use C4::Amazon;
$loaded = 1;
print "ok 1\n";
