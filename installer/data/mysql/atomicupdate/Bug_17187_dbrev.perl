#!/usr/bin/perl

use Modern::Perl;
use C4::Context;

my $dbh = C4::Context->dbh;
my $DBversion = 'XXX';

# @RM: Copy from here

#if ( CheckVersion($DBversion) ) {
if ( 1 ) { #FIXME
    my $pref = C4::Context->preference('timeout');
    if( !$pref || $pref eq '12000000' ) {
        # update if pref is null or equals old default value
        $dbh->do(q|
UPDATE systempreferences SET value = '1d', type = 'Free'
WHERE variable = 'timeout'
        |);
        print "Upgrade to $DBversion done (Bug 17187)\nNote: Pref value for timeout has been adjusted.\n";
    } else {
        # only update pref type
        $dbh->do(q|
UPDATE systempreferences SET type = 'Free'
WHERE variable = 'timeout'
        |);
        print "Upgrade to $DBversion done (Bug 17187)\nNote: Pref value for timeout has not been adjusted.\n";
    }
    #SetVersion($DBversion); #FIXME
}
