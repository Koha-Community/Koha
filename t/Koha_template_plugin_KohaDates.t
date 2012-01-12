#!/usr/bin/perl
#

use strict;
use warnings;
use C4::Context;
use C4::Dates;
use Test::More tests => 5;

BEGIN {
        use_ok('Koha::Template::Plugin::KohaDates');
}

my $date = "1973-05-21";
my $context = C4::Context->new();
my $dateobj = C4::Dates->new();

my $filter = Koha::Template::Plugin::KohaDates->new();
ok ($filter, "new()");


$context->set_preference( "dateformat", 'iso' );
$context->clear_syspref_cache();
$dateobj->reset_prefformat;

my $filtered_date = $filter->filter($date);
is ($filtered_date,$date, "iso conversion") or diag ("iso conversion fails");

#$filter = Koha::Template::Plugin::KohaDates->new();
$context->set_preference( "dateformat", 'us' );
$context->clear_syspref_cache();
$dateobj->reset_prefformat;

$filtered_date = $filter->filter($date);
is ($filtered_date,'05/21/1973', "us conversion") or diag ("us conversion fails $filtered_date");

$context->set_preference( "dateformat", 'metric' );
$context->clear_syspref_cache();
$dateobj->reset_prefformat;

$filtered_date = $filter->filter($date);
is ($filtered_date,'21/05/1973', "metric conversion") or diag ("metric conversion fails $filtered_date");
