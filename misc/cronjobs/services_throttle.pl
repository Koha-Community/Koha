#!/usr/bin/perl
#run nightly -- resets the services throttle

use strict; use warnings;

use C4::Context;
my $dbh=C4::Context->dbh;
my $fixit="UPDATE services_throttle SET service_count=0 WHERE service_type='xisbn'";
my $sth=$dbh->prepare($fixit);
my $res = $sth->execute() or die "can't execute";
print "$res\n"; #did it work?
$dbh->disconnect();
