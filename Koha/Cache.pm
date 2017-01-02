package Koha::Cache;

# Copyright 2009 Chris Cormack and The Koha Dev Team
# Parts copyright 2012-2013 C & P Bibliography Services
#
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

=head1 NAME

Koha::Cache - Handling caching of html and Objects for Koha

=head1 SYNOPSIS

  use Koha::Cache;
  my $cache = Koha::Cache->new({cache_type => $cache_type, %params});

  # see also Koha::Caches->get_instance;

=head1 DESCRIPTION

Koha caching routines. This class provides two interfaces for cache access.
The first, traditional OO interface provides the following functions:

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Carp;
use Module::Load::Conditional qw(can_load);
use Sereal::Encoder;
use Sereal::Decoder;

use Koha::Cache::Object;
use Koha::Config;

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(
    qw( cache memcached_cache fastmmap_cache memory_cache ));

our %L1_cache;
our $L1_encoder = Sereal::Encoder->new;
our $L1_decoder = Sereal::Decoder->new;

=head2 new

Create a new Koha::Cache object. This is required for all cache-related functionality.

=cut

sub new {
    my ( $class, $self, $params ) = @_;
    $self->{'default_type'} =
         $self->{cache_type}
      || $ENV{CACHING_SYSTEM} # DELME What about this?
      || 'memcached';

    my $subnamespace = $params->{subnamespace} // '';

    $ENV{DEBUG} && carp "Default caching system: $self->{'default_type'}";

    $self->{'timeout'}   ||= 0;
    # Should we continue to support MEMCACHED ENV vars?
    $self->{'namespace'} ||= $ENV{MEMCACHED_NAMESPACE};
    my @servers = split /,/, $ENV{MEMCACHED_SERVERS} || '';
    unless ( $self->{namespace} and @servers ) {
        my $koha_config = Koha::Config->read_from_file( Koha::Config->guess_koha_conf() );
        $self->{namespace} ||= $koha_config->{config}{memcached_namespace} || 'koha';
        @servers = split /,/, $koha_config->{config}{memcached_servers} // ''
            unless @servers;
    }
    $self->{namespace} .= ":$subnamespace:";

    if ( $self->{'default_type'} eq 'memcached'
        && can_load( modules => { 'Cache::Memcached::Fast' => undef } )
        && _initialize_memcached($self, @servers)
        && defined( $self->{'memcached_cache'} ) )
    {
        $self->{'cache'} = $self->{'memcached_cache'};
    }

    if ( $self->{'default_type'} eq 'fastmmap'
      && defined( $ENV{GATEWAY_INTERFACE} )
      && can_load( modules => { 'Cache::FastMmap' => undef } )
      && _initialize_fastmmap($self)
      && defined( $self->{'fastmmap_cache'} ) )
    {
        $self->{'cache'} = $self->{'fastmmap_cache'};
    }

    # Unless memcache or fastmmap has already been picked, use memory_cache
    unless ( defined( $self->{'cache'} ) ) {
        if ( can_load( modules => { 'Cache::Memory' => undef } )
            && _initialize_memory($self) )
        {
                $self->{'cache'} = $self->{'memory_cache'};
        }
    }

    $ENV{DEBUG} && carp "Selected caching system: " . ($self->{'cache'} // 'none');

    return
      bless $self,
      $class;
}

sub _initialize_memcached {
    my ($self, @servers) = @_;

    return unless @servers;

    $ENV{DEBUG}
      && carp "Memcached server settings: "
      . join( ', ', @servers )
      . " with "
      . $self->{'namespace'};
    # Cache::Memcached::Fast doesn't allow a default expire time to be set
    # so we force it on setting.
    my $memcached = Cache::Memcached::Fast->new(
        {
            servers            => \@servers,
            compress_threshold => 10_000,
            namespace          => $self->{'namespace'},
            utf8               => 1,
        }
    );

    # Ensure we can actually talk to the memcached server
    my $ismemcached = $memcached->set('ismemcached','1');
    unless ($ismemcached) { #Value is undefined or False, so there was an error with the server, the connection to it, or a protocol error
        warn "Connection to the memcached servers '@servers' failed. Are the unix socket permissions set properly? Is the host reachable?";
        return $self;
    }
    $self->{'memcached_cache'} = $memcached;
    return $self;
}

sub _initialize_fastmmap {
    my ($self) = @_;
    my ($cache, $share_file);

    # Temporary workaround to catch fatal errors when: C4::Context module
    # is not loaded beforehand, or Cache::FastMmap init fails for whatever
    # other reason (e.g. due to permission issues - see Bug 13431)
    eval {
        $share_file = join( '-',
            "/tmp/sharefile-koha", $self->{'namespace'},
            C4::Context->config('hostname'), C4::Context->config('database') );

        $cache = Cache::FastMmap->new(
            'share_file'  => $share_file,
            'expire_time' => $self->{'timeout'},
            'unlink_on_exit' => 0,
        );
    };
    if ( $@ ) {
        warn "FastMmap cache initialization failed: $@";
        return;
    }
    return unless defined $cache;
    $self->{'fastmmap_cache'} = $cache;
    return $self;
}

sub _initialize_memory {
    my ($self) = @_;

    # Default cache time for memory is _always_ short unless it's specially
    # defined, to allow it to work reliably in a persistent environment.
    my $cache = Cache::Memory->new(
        'namespace'       => $self->{'namespace'},
        'default_expires' => "$self->{'timeout'} sec" || "10 sec",
    );
    $self->{'memory_cache'} = $cache;
    # Memory cache can't handle complex types for some reason, so we use its
    # freeze and thaw functions.
    $self->{ref($cache) . '_set'} = sub {
        my ($key, $val, $exp) = @_;
        # Refer to set_expiry in Cache::Entry for why we do this 'sec' thing.
        $exp = "$exp sec" if defined $exp;
        # Because we need to use freeze, it must be a reference type.
        $cache->freeze($key, [$val], $exp);
    };
    $self->{ref($cache) . '_get'} = sub {
        my $res = $cache->thaw(shift);
        return unless defined $res;
        return $res->[0];
    };
    return $self;
}

=head2 is_cache_active

Routine that checks whether or not a default caching method is active on this
object.

=cut

sub is_cache_active {
    my $self = shift;
    return $self->{'cache'} ? 1 : 0;
}

=head2 set_in_cache

    $cache->set_in_cache($key, $value, [$options]);

Save a value to the specified key in the cache. A hashref of options may be
specified.

The possible options are:

=over

=item expiry

Expiry time of this cached entry in seconds.

=item cache

The cache object to use if you want to provide your own. It should be an
instance of C<Cache::*> and follow the same interface as L<Cache::Memcache>.

=back

=cut

sub set_in_cache {
    my ( $self, $key, $value, $options ) = @_;

    my $unsafe = $options->{unsafe} || 0;

    # the key mustn't contain whitespace (or control characters) for memcache
    # but shouldn't be any harm in applying it globally.
    $key =~ s/[\x00-\x20]/_/g;

    my $cache = $options->{cache} || 'cache';
    croak "No key" unless $key;
    $ENV{DEBUG} && carp "set_in_cache for $key";

    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );
    my $expiry = $options->{expiry};
    $expiry //= $self->{timeout};
    my $set_sub = $self->{ref($self->{$cache}) . "_set"};

    my $flag = '-CF0'; # 0: scalar, 1: frozen data structure
    if (ref($value)) {
        # Set in L1 cache as a data structure
        # We only save the frozen form: we do want to save $value in L1
        # directly in order to protect it. And thawing now may not be
        # needed, so improves performance.
        $value = $L1_encoder->encode($value);
        $L1_cache{$self->{namespace}}{$key}->{frozen} = $value;
        $flag = '-CF1';
    } else {
        # Set in L1 cache as a scalar; exit if we are caching an undef
        $L1_cache{$self->{namespace}}{$key} = $value;
        return if !defined $value;
    }

    $value .= $flag;
    # We consider an expiry of 0 to be infinite
    if ( $expiry ) {
        return $set_sub
          ? $set_sub->( $key, $value, $expiry )
          : $self->{$cache}->set( $key, $value, $expiry );
    }
    else {
        return $set_sub
          ? $set_sub->( $key, $value )
          : $self->{$cache}->set( $key, $value );
    }
}

=head2 get_from_cache

    my $value = $cache->get_from_cache($key, [ $options ]);

Retrieve the value stored under the specified key in the cache.

The possible options are:

=over

=item unsafe

If set, this will avoid performing a deep copy of the item. This
means that it won't be safe if something later modifies the result of the
function. It should be used with caution, and could save processing time
in some situations where is safe to use it. Make sure you know what you are doing!

=item cache

The cache object to use if you want to provide your own. It should be an
instance of C<Cache::*> and follow the same interface as L<Cache::Memcache>.

=back

=cut

sub get_from_cache {
    my ( $self, $key, $options ) = @_;
    my $cache  = $options->{cache}  || 'cache';
    my $unsafe = $options->{unsafe} || 0;
    $key =~ s/[\x00-\x20]/_/g;
    croak "No key" unless $key;
    $ENV{DEBUG} && carp "get_from_cache for $key";
    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );

    # Return L1 cache value if exists
    if ( exists $L1_cache{$self->{namespace}}{$key} ) {
        if (ref($L1_cache{$self->{namespace}}{$key})) {
            if ($unsafe) {
                # ONLY use thawed for unsafe calls !!!
                $L1_cache{$self->{namespace}}{$key}->{thawed} ||= $L1_decoder->decode($L1_cache{$self->{namespace}}{$key}->{frozen});
                return $L1_cache{$self->{namespace}}{$key}->{thawed};
            } else {
                return $L1_decoder->decode($L1_cache{$self->{namespace}}{$key}->{frozen});
            }
        } else {
            # No need to thaw if it's a scalar
            return $L1_cache{$self->{namespace}}{$key};
        }
    }

    my $get_sub = $self->{ref($self->{$cache}) . "_get"};
    my $L2_value = $get_sub ? $get_sub->($key) : $self->{$cache}->get($key);

    return if ref($L2_value);
    return unless (defined($L2_value) && length($L2_value) >= 4);

    my $flag = substr($L2_value, -4, 4, '');
    if ($flag eq '-CF0') {
        # it's a scalar
        $L1_cache{$self->{namespace}}{$key} = $L2_value;
        return $L2_value;
    } elsif ($flag eq '-CF1') {
        # it's a frozen data structure
        my $thawed;
        eval { $thawed = $L1_decoder->decode($L2_value); };
        return if $@;
        $L1_cache{$self->{namespace}}{$key}->{frozen} = $L2_value;
        # ONLY save thawed for unsafe calls !!!
        $L1_cache{$self->{namespace}}{$key}->{thawed} = $thawed if $unsafe;
        return $thawed;
    }

    # Unknown value / data type returned from L2 cache
    return;
}

=head2 clear_from_cache

    $cache->clear_from_cache($key);

Remove the value identified by the specified key from the default cache.

=cut

sub clear_from_cache {
    my ( $self, $key, $cache ) = @_;
    $key =~ s/[\x00-\x20]/_/g;
    $cache ||= 'cache';
    croak "No key" unless $key;
    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );

    # Clear from L1 cache
    delete $L1_cache{$self->{namespace}}{$key};

    return $self->{$cache}->delete($key)
      if ( ref( $self->{$cache} ) =~ m'^Cache::Memcached' );
    return $self->{$cache}->remove($key);
}

=head2 flush_all

    $cache->flush_all();

Clear the entire default cache.

=cut

sub flush_all {
    my ( $self, $cache ) = shift;
    $cache ||= 'cache';
    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );

    $self->flush_L1_cache();

    return $self->{$cache}->flush_all()
      if ( ref( $self->{$cache} ) =~ m'^Cache::Memcached' );
    return $self->{$cache}->clear();
}

sub flush_L1_cache {
    my( $self ) = @_;
    delete $L1_cache{$self->{namespace}};
}

=head1 TIED INTERFACE

Koha::Cache also provides a tied interface which enables users to provide a
constructor closure and (after creation) treat cached data like normal reference
variables and rely on the cache Just Working and getting updated when it
expires, etc.

    my $cache = Koha::Cache->new();
    my $data = 'whatever';
    my $scalar = Koha::Cache->create_scalar(
        {
            'key'         => 'whatever',
            'timeout'     => 2,
            'constructor' => sub { return $data; },
        }
    );
    print "$$scalar\n"; # Prints "whatever"
    $data = 'somethingelse';
    print "$$scalar\n"; # Prints "whatever" because it is cached
    sleep 2; # Wait until the cache entry has expired
    print "$$scalar\n"; # Prints "somethingelse"

    my $hash = Koha::Cache->create_hash(
        {
            'key'         => 'whatever',
            'timeout'     => 2,
            'constructor' => sub { return $data; },
        }
    );
    print "$$variable\n"; # Prints "whatever"

The gotcha with this interface, of course, is that the variable returned by
create_scalar and create_hash is a I<reference> to a tied variable and not a
tied variable itself.

The tied variable is configured by means of a hashref passed in to the
create_scalar and create_hash methods. The following parameters are supported:

=over

=item I<key>

Required. The key to use for identifying the variable in the cache.

=item I<constructor>

Required. A closure (or reference to a function) that will return the value that
needs to be stored in the cache.

=item I<preload>

Optional. A closure (or reference to a function) that gets run to initialize
the cache when creating the tied variable.

=item I<arguments>

Optional. Array reference with the arguments that should be passed to the
constructor function.

=item I<timeout>

Optional. The cache timeout in seconds for the variable. Defaults to 600
(ten minutes).

=item I<cache_type>

Optional. Which type of cache to use for the variable. Defaults to whatever is
set in the environment variable CACHING_SYSTEM. If set to 'null', disables
caching for the tied variable.

=item I<allowupdate>

Optional. Boolean flag to allow the variable to be updated directly. When this
is set and the variable is used as an l-value, the cache will be updated
immediately with the new value. Using this is probably a bad idea on a
multi-threaded system. When I<allowupdate> is not set to true, using the
tied variable as an l-value will have no effect.

=item I<destructor>

Optional. A closure (or reference to a function) that should be called when the
tied variable is destroyed.

=item I<unset>

Optional. Boolean flag to tell the object to remove the variable from the cache
when it is destroyed or goes out of scope.

=item I<inprocess>

Optional. Boolean flag to tell the object not to refresh the variable from the
cache every time the value is desired, but rather only when the I<local> copy
of the variable is older than the timeout.

=back

=head2 create_scalar

    my $scalar = Koha::Cache->create_scalar(\%params);

Create scalar tied to the cache.

=cut

sub create_scalar {
    my ( $self, $args ) = @_;

    $self->_set_tied_defaults($args);

    tie my $scalar, 'Koha::Cache::Object', $args;
    return \$scalar;
}

sub create_hash {
    my ( $self, $args ) = @_;

    $self->_set_tied_defaults($args);

    tie my %hash, 'Koha::Cache::Object', $args;
    return \%hash;
}

sub _set_tied_defaults {
    my ( $self, $args ) = @_;

    $args->{'timeout'}   = '600' unless defined( $args->{'timeout'} );
    $args->{'inprocess'} = '0'   unless defined( $args->{'inprocess'} );
    unless ( $args->{cache_type} and lc( $args->{cache_type} ) eq 'null' ) {
        $args->{'cache'} = $self;
        $args->{'cache_type'} ||= $ENV{'CACHING_SYSTEM'};
    }

    return $args;
}

=head1 EXPORT

None by default.

=head1 SEE ALSO

Koha::Cache::Object

=head1 AUTHOR

Chris Cormack, E<lt>chris@bigballofwax.co.nzE<gt>
Paul Poulain, E<lt>paul.poulain@biblibre.comE<gt>
Jared Camins-Esakov, E<lt>jcamins@cpbibliography.comE<gt>

=cut

1;

__END__
