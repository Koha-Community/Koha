#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Serials;
use C4::Debug;
use Test::More tests => 4;

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
