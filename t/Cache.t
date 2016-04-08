#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 40;

my $destructorcount = 0;

BEGIN {
    use_ok('Koha::Cache');
    use_ok('Koha::Cache::Object');
    use_ok('C4::Context');
}

SKIP: {
    # Set a special namespace for testing, to avoid breaking
    # if test is run with a different user than Apache's.
    $ENV{ MEMCACHED_NAMESPACE } = 'unit_tests';
    my $cache = Koha::Cache->get_instance();

    skip "Cache not enabled", 33
      unless ( $cache->is_cache_active() && defined $cache );

    # test fetching an item that isnt in the cache
    is( $cache->get_from_cache("not in here"),
        undef, "fetching item NOT in cache" );

    # test expiry time in cache
    $cache->set_in_cache( "timeout", "I AM DATA", 1 ); # expiry time of 1 second
    sleep 2;
    $cache->flush_L1_cache();
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
    $cache->flush_L1_cache();
    is( $$myscalar, 1, 'Data retrieved from cache' );
    $cache->flush_L1_cache();
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
    $cache->flush_L1_cache();
    is($myhash->{'key2'}, 'nosurprise', 'Cache change caught');


    my $foundkeys = 0;
    foreach my $key (keys %{$myhash}) {
        $foundkeys++;
    }

    is($foundkeys, 2, 'Found expected 2 keys when iterating through hash');

    isnt(scalar %{$myhash}, undef, 'scalar knows the hash is not empty');

    $hash{'anotherkey'} = 'anothervalue';

    sleep 2;
    $cache->flush_L1_cache();

    ok(exists $myhash->{'anotherkey'}, 'Cache reset properly');

    delete $hash{'anotherkey'};
    delete $myhash->{'anotherkey'};

    ok(!exists $myhash->{'anotherkey'}, 'Key successfully deleted');

    undef %hash;
    %{$myhash} = ();

    is(scalar %{$myhash}, 0, 'hash cleared');

    $hash{'key'} = 'value';
    is($myhash->{'key'}, 'value', 'retrieved value after clearing cache');

    # UTF8 testing
    my $utf8_str = "A Møøse once bit my sister";
    $cache->set_in_cache('utf8_1', $utf8_str);
    is($cache->get_from_cache('utf8_1'), $utf8_str, 'Simple 8-bit UTF8 correctly retrieved');
    $utf8_str = "\x{20ac}"; # €
    $cache->set_in_cache('utf8_1', $utf8_str);
    my $utf8_res = $cache->get_from_cache('utf8_1');
    # This'll ensure that we're getting a unicode string back, rather than
    # a couple of bytes.
    is(length($utf8_res), 1, 'UTF8 string length correct');
    # ...and that it's really the character we intend
    is(ord($utf8_res), 8364, 'UTF8 string value correct');

    # Make sure the item will be deep copied
    # Scalar
    my $item = "just a simple scalar";
    $cache->set_in_cache('test_deep_copy', $item);
    my $item_from_cache = $cache->get_from_cache('test_deep_copy');
    $item_from_cache = "a modified scalar";
    is( $cache->get_from_cache('test_deep_copy'), 'just a simple scalar', 'A scalar will not be modified in the cache if get from the cache' );
    # Array
    my @item = qw( an array ref );
    $cache->set_in_cache('test_deep_copy_array', \@item);
    $item_from_cache = $cache->get_from_cache('test_deep_copy_array');
    @$item_from_cache = qw( another array ref );
    is_deeply( $cache->get_from_cache('test_deep_copy_array'), [ qw ( an array ref ) ], 'An array will be deep copied');

    $cache->flush_L1_cache();
    $item_from_cache = $cache->get_from_cache('test_deep_copy_array');
    @$item_from_cache = qw( another array ref );
    is_deeply( $cache->get_from_cache('test_deep_copy_array'), [ qw ( an array ref ) ], 'An array will be deep copied even it is the first fetch from L2');

    $item_from_cache = $cache->get_from_cache('test_deep_copy_array', { unsafe => 1 });
    @$item_from_cache = qw( another array ref );
    is_deeply( $cache->get_from_cache('test_deep_copy_array'), [ qw ( another array ref ) ], 'An array will not be deep copied if the unsafe flag is set');
    # Hash
    my %item = ( a => 'hashref' );
    $cache->set_in_cache('test_deep_copy_hash', \%item);
    $item_from_cache = $cache->get_from_cache('test_deep_copy_hash');
    %$item_from_cache = ( another => 'hashref' );
    is_deeply( $cache->get_from_cache('test_deep_copy_hash'), { a => 'hashref' }, 'A hash will be deep copied');

    %item = ( a_modified => 'hashref' );
    is_deeply( $cache->get_from_cache('test_deep_copy_hash'), { a => 'hashref' }, 'A hash will be deep copied when set in cache');

    %item = ( a => 'hashref' );
    $cache->set_in_cache('test_deep_copy_hash', \%item, { unsafe => 1});
    %item = ( a_modified => 'hashref' );
    is_deeply( $cache->get_from_cache('test_deep_copy_hash'), { a_modified => 'hashref' }, 'A hash will not be deep copied when set in cache if the unsafe flag is set');

    $item_from_cache = $cache->get_from_cache('test_deep_copy_hash', { unsafe => 1});
    %$item_from_cache = ( another => 'hashref' );
    is_deeply( $cache->get_from_cache('test_deep_copy_hash'), { another => 'hashref' }, 'A hash will not be deep copied if the unsafe flag is set');
}

END {
  SKIP: {
        $ENV{ MEMCACHED_NAMESPACE } = 'unit_tests';
        my $cache = Koha::Cache->get_instance();
        skip "Cache not enabled", 1
          unless ( $cache->is_cache_active() );
        is( $destructorcount, 1, 'Destructor run exactly once' );
        # cleanup temporary file
        my $tmp_file = $cache->{ fastmmap_cache }->{ share_file };
        unlink $tmp_file if defined $tmp_file;

    }
}
