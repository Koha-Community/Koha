#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;
use t::lib::Mocks;
use C4::Context;

BEGIN {
    use_ok('C4::External::Amazon');
}

my $context = C4::Context->new();

my $locale = $context->preference('AmazonLocale');

t::lib::Mocks::mock_preference('AmazonLocale','CA');
$context->clear_syspref_cache();
is(get_amazon_tld,'.ca','Changes locale to CA and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','DE');
$context->clear_syspref_cache();
is(get_amazon_tld,'.de','Changes locale to DE and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','FR');
$context->clear_syspref_cache();
is(get_amazon_tld,'.fr','Changes locale to FR and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','JP');
$context->clear_syspref_cache();
is(get_amazon_tld,'.jp','Changes locale to JP and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','UK');
$context->clear_syspref_cache();
is(get_amazon_tld,'.co.uk','Changes locale to UK and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','US');
$context->clear_syspref_cache();
is(get_amazon_tld,'.com','Changes locale to US and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale','NZ');
$context->clear_syspref_cache();
is(get_amazon_tld,'.com','Changes locale to one not in the array and tests get_amazon_tld');

t::lib::Mocks::mock_preference('AmazonLocale',$locale);
$context->clear_syspref_cache();
