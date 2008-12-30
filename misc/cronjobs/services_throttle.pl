#!/usr/bin/perl
# run nightly -- resets the xisbn services throttle

use strict;
use warnings;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
my $fixit="UPDATE services_throttle SET service_count=0 WHERE service_type='xisbn'";
my $sth = C4::Context->dbh->prepare($fixit);
my $res = $sth->execute() or die "cannot execute query: $fixit";

# There is no need to return anything if we succeeded, 
# and the die message (or other more internal Context/mysql error) 
# will get emailed to the cron user if we didn't.
