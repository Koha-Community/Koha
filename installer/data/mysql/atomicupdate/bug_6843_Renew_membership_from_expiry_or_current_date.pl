#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do(<<ENDOFRENEWAL);
INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES('BorrowerRenewalPeriodBase', 'now', 'Set whether the borrower renewal date should be counted from the dateexpiry or from the current date ','dateexpiry|now','Choice');
ENDOFRENEWAL
print "Upgrade done (Added a system preference to allow renewal of Patron account either from todays date or from existing expiry date in the patrons account.)\n";
