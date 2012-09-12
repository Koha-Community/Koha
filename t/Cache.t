#!/usr/bin/perl

# Tests Koha::Cache and whichever type of cache is enabled (through Koha::Cache)

use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
        use_ok('Koha::Cache');
        use_ok('C4::Context');
}

SKIP: {
    my $cache = Koha::Cache->new ();

    skip "Cache not enabled", 7 unless (Koha::Cache->is_cache_active() && defined $cache);

    # test fetching an item that isnt in the cache
    is( $cache->get_from_cache("not in here"), undef, "fetching item NOT in cache");

    # test expiry time in cache
    $cache->set_in_cache("timeout", "I AM DATA", 1); # expiry time of 1 second
    sleep 1;
    is( $cache->get_from_cache("timeout"), undef, "fetching expired item from cache");

    # test fetching a valid, non expired, item from cache
    $cache->set_in_cache("clear_me", "I AM MORE DATA", 1000); # overly large expiry time, clear below
    $cache->set_in_cache("dont_clear_me", "I AM MORE DATA22", 1000); # overly large expiry time, clear below
    is( $cache->get_from_cache("clear_me"), "I AM MORE DATA", "fetching valid item from cache");

    # test clearing from cache
    $cache->clear_from_cache("clear_me");
    is( $cache->get_from_cache("clear_me"), undef, "fetching cleared item from cache");
    is( $cache->get_from_cache("dont_clear_me"), "I AM MORE DATA22", "fetching valid item from cache (after clearing another item)");

    #test flushing from cache
    $cache->set_in_cache("flush_me", "testing 1 data");
    $cache->flush_all;
    is( $cache->get_from_cache("flush_me"), undef, "fetching flushed item from cache");
    is( $cache->get_from_cache("dont_clear_me"), undef, "fetching flushed item from cache");
}
