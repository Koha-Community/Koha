#!/usr/bin/perl

# Tests Koha::Cache and whichever type of cache is enabled (through Koha::Cache)

use strict;
use warnings;

use Test::More tests => 29;

my $destructorcount = 0;

BEGIN {
    use_ok('Koha::Cache');
    use_ok('Koha::Cache::Object');
    use_ok('C4::Context');
}

SKIP: {
    my $cache = Koha::Cache->new();

    skip "Cache not enabled", 25
      unless ( Koha::Cache->is_cache_active() && defined $cache );

    # test fetching an item that isnt in the cache
    is( $cache->get_from_cache("not in here"),
        undef, "fetching item NOT in cache" );

    # test expiry time in cache
    $cache->set_in_cache( "timeout", "I AM DATA", 1 ); # expiry time of 1 second
    sleep 2;
    is( $cache->get_from_cache("timeout"),
        undef, "fetching expired item from cache" );

    # test fetching a valid, non expired, item from cache
    $cache->set_in_cache( "clear_me", "I AM MORE DATA", 1000 )
      ;    # overly large expiry time, clear below
    $cache->set_in_cache( "dont_clear_me", "I AM MORE DATA22", 1000 )
      ;    # overly large expiry time, clear below
    is(
        $cache->get_from_cache("clear_me"),
        "I AM MORE DATA",
        "fetching valid item from cache"
    );

    # test clearing from cache
    $cache->clear_from_cache("clear_me");
    is( $cache->get_from_cache("clear_me"),
        undef, "fetching cleared item from cache" );
    is(
        $cache->get_from_cache("dont_clear_me"),
        "I AM MORE DATA22",
        "fetching valid item from cache (after clearing another item)"
    );

    #test flushing from cache
    $cache->set_in_cache( "flush_me", "testing 1 data" );
    $cache->flush_all;
    is( $cache->get_from_cache("flush_me"),
        undef, "fetching flushed item from cache" );
    is( $cache->get_from_cache("dont_clear_me"),
        undef, "fetching flushed item from cache" );

    my $constructorcount = 0;
    my $myscalar         = $cache->create_scalar(
        {
            'key'         => 'myscalar',
            'timeout'     => 1,
            'allowupdate' => 1,
            'unset'       => 1,
            'constructor' => sub { return ++$constructorcount; },
            'destructor'  => sub { return ++$destructorcount; },
        }
    );
    ok( defined($myscalar), 'Created tied scalar' );
    is( $$myscalar, 1, 'Constructor called to first initialize' );
    is( $$myscalar, 1, 'Data retrieved from cache' );
    sleep 2;
    is( $$myscalar, 2, 'Constructor called again when timeout reached' );
    $$myscalar = 5;
    is( $$myscalar,        5, 'Stored new value to cache' );
    is( $constructorcount, 2, 'Constructor not called after storing value' );
    undef $myscalar;

    is( $cache->get_from_cache("myscalar"),
        undef, 'Item removed from cache on destruction' );

    my %hash = ( 'key' => 'value' );

    my $myhash         = $cache->create_hash(
        {
            'key'         => 'myhash',
            'timeout'     => 1,
            'allowupdate' => 1,
            'unset'       => 1,
            'constructor' => sub { return { %hash }; },
        }
    );

    ok(defined $myhash, 'Created tied hash');

    is($myhash->{'key'}, 'value', 'Found expected value in hash');
    ok(exists $myhash->{'key'}, 'Exists works');
    $myhash->{'key2'} = 'surprise';
    is($myhash->{'key2'}, 'surprise', 'Setting hash member worked');
    $hash{'key2'} = 'nosurprise';
    sleep 2;
    is($myhash->{'key2'}, 'nosurprise', 'Cache change caught');


    my $foundkeys = 0;
    foreach my $key (keys %{$myhash}) {
        $foundkeys++;
    }

    is($foundkeys, 2, 'Found expected 2 keys when iterating through hash');

    isnt(scalar %{$myhash}, undef, 'scalar knows the hash is not empty');

    $hash{'anotherkey'} = 'anothervalue';

    sleep 2;

    ok(exists $myhash->{'anotherkey'}, 'Cache reset properly');

    delete $hash{'anotherkey'};
    delete $myhash->{'anotherkey'};

    ok(!exists $myhash->{'anotherkey'}, 'Key successfully deleted');

    undef %hash;
    %{$myhash} = ();

    is(scalar %{$myhash}, 0, 'hash cleared');

    $hash{'key'} = 'value';
    is($myhash->{'key'}, 'value', 'retrieved value after clearing cache');
}

END {
  SKIP: {
        skip "Cache not enabled", 1
          unless ( Koha::Cache->is_cache_active() );
        is( $destructorcount, 1, 'Destructor run exactly once' );
    }
}
