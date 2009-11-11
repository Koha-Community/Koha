#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Serials;
use C4::Debug;
use Test::More tests => 5;

BEGIN {
    use_ok('C4::Serials');
}

my $subscriptionid = 1;
my $subscriptioninformation = GetSubscription( $subscriptionid );
$debug && warn Dump($subscriptioninformation);
my @subscriptions = GetSubscriptions( $$subscriptioninformation{bibliotitle} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
@subscriptions = GetSubscriptions( undef, $$subscriptioninformation{issn} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
@subscriptions = GetSubscriptions( undef,undef ,$$subscriptioninformation{bibnum} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
if ($subscriptioninformation->{periodicity} % 16==0){
	$subscriptioninformation->{periodicity}=7;
	ModSubscription(@$subscriptioninformation{qw(librarian,           branchcode,      aqbooksellerid,    cost,             aqbudgetid,    startdate,   periodicity,   firstacquidate,
        dow,             irregularity,    numberpattern,     numberlength,     weeklength,    monthlength, add1,          every1,
        whenmorethan1,   setto1,          lastvalue1,        innerloop1,       add2,          every2,      whenmorethan2, setto2,
        lastvalue2,      innerloop2,      add3,              every3,           whenmorethan3, setto3,      lastvalue3,    innerloop3,
        numberingmethod, status,          biblionumber,      callnumber,       notes,         letter,      hemisphere,    manualhistory,
        internalnotes,   serialsadditems, staffdisplaycount, opacdisplaycount, graceperiod,   location,    enddate,       subscriptionid
)});
}
my $expirationdate = GetExpirationDate(1) ;
ok( $expirationdate, "not NULL" );
$debug && warn "$expirationdate";
