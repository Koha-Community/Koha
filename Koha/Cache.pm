package Koha::Cache;

# Copyright 2009 Chris Cormack and The Koha Dev Team
# Parts copyright 2012-2013 C & P Bibliography Services
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::Cache - Handling caching of html and Objects for Koha

=head1 SYNOPSIS

  use Koha::Cache;
  my $cache = Koha::Cache->new({cache_type => $cache_type, %params});

=head1 DESCRIPTION

Koha caching routines. This class provides two interfaces for cache access.
The first, traditional interface provides the following functions:

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Carp;
use Module::Load::Conditional qw(can_load);
use Koha::Cache::Object;

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(
    qw( cache memcached_cache fastmmap_cache memory_cache ));

=head2 new

Create a new Koha::Cache object. This is required for all cache-related functionality.

=cut

sub new {
    my ( $class, $self ) = @_;
    $self->{'default_type'} =
         $self->{cache_type}
      || $ENV{CACHING_SYSTEM}
      || 'memcached';

    $ENV{DEBUG} && carp "Default caching system: $self->{'default_type'}";

    $self->{'timeout'}   ||= 0;
    $self->{'namespace'} ||= $ENV{MEMCACHED_NAMESPACE} || 'koha';

    if ( can_load( modules => { 'Cache::Memcached::Fast' => undef } ) ) {
        _initialize_memcached($self);
        if ( $self->{'default_type'} eq 'memcached'
            && defined( $self->{'memcached_cache'} ) )
        {
            $self->{'cache'} = $self->{'memcached_cache'};
        }
    }

    if ( can_load( modules => { 'Cache::FastMmap' => undef } ) ) {
        _initialize_fastmmap($self);
        if ( $self->{'default_type'} eq 'fastmmap'
            && defined( $self->{'fastmmap_cache'} ) )
        {
            $self->{'cache'} = $self->{'fastmmap_cache'};
        }
    }

    if ( can_load( modules => { 'Cache::Memory' => undef } ) ) {
        _initialize_memory($self);
        if ( $self->{'default_type'} eq 'memory'
            && defined( $self->{'memory_cache'} ) )
        {
            $self->{'cache'} = $self->{'memory_cache'};
        }
    }

# NOTE: The following five lines could be uncommented if we wanted to
#       fall back to any functioning cache. Commented out since this would
#       represent a change in behavior.
#
#unless (defined($self->{'cache'})) {
#    foreach my $cachemember (qw(memory_cache fastmmap_cache memcached_cache)) {
#        $self->{'cache'} = $self->{$cachemember} if (defined($self->{$cachemember}));
#    }
#}

    return
      bless $self,
      $class;
}

sub _initialize_memcached {
    my ($self) = @_;
    my @servers =
      split /,/, $self->{'cache_servers'}
      ? $self->{'cache_servers'}
      : $ENV{MEMCACHED_SERVERS};

    $ENV{DEBUG}
      && carp "Memcached server settings: "
      . join( ', ', @servers )
      . " with "
      . $self->{'namespace'};
    $self->{'memcached_cache'} = Cache::Memcached::Fast->new(
        {
            servers            => \@servers,
            compress_threshold => 10_000,
            namespace          => $self->{'namespace'},
        }
    );
    return $self;
}

sub _initialize_fastmmap {
    my ($self) = @_;

    $self->{'fastmmap_cache'} = Cache::FastMmap->new(
        'share_file'  => "/tmp/sharefile-koha-$self->{'namespace'}",
        'expire_time' => $self->{'timeout'},
        'unlink_on_exit' => 0,
    );
    return $self;
}

sub _initialize_memory {
    my ($self) = @_;

    $self->{'memory_cache'} = Cache::Memory->new(
        'namespace'       => $self->{'namespace'},
        'default_expires' => $self->{'timeout'}
    );
    return $self;
}

=head2 is_cache_active

Routine that checks whether or not a caching system has been selected. This is
not an instance method.

=cut

sub is_cache_active {
    return $ENV{CACHING_SYSTEM} ? '1' : '';
}

=head2 set_in_cache

    $cache->set_in_cache($key, $value, [$expiry]);

Save a value to the specified key in the default cache, optionally with a
particular expiry.

=cut

sub set_in_cache {
    my ( $self, $key, $value, $expiry, $cache ) = @_;
    $cache ||= 'cache';
    croak "No key" unless $key;
    $ENV{DEBUG} && carp "set_in_cache for $key";

    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );
    if ( defined $expiry ) {
        if ( ref( $self->{$cache} ) eq 'Cache::Memory' ) {
            $expiry = "$expiry sec";
        }
        return $self->{$cache}->set( $key, $value, $expiry );
    }
    else {
        return $self->{$cache}->set( $key, $value );
    }
}

=head2 get_from_cache

    my $value = $cache->get_from_cache($key);

Retrieve the value stored under the specified key in the default cache.

=cut

sub get_from_cache {
    my ( $self, $key, $cache ) = @_;
    $cache ||= 'cache';
    croak "No key" unless $key;
    $ENV{DEBUG} && carp "get_from_cache for $key";
    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );
    return $self->{$cache}->get($key);
}

=head2 clear_from_cache

    $cache->clear_from_cache($key);

Remove the value identified by the specified key from the default cache.

=cut

sub clear_from_cache {
    my ( $self, $key, $cache ) = @_;
    $cache ||= 'cache';
    croak "No key" unless $key;
    return unless ( $self->{$cache} && ref( $self->{$cache} ) =~ m/^Cache::/ );
    return $self->{$cache}->delete($key)
      if ( ref( $self->{$cache} ) eq 'Cache::Memcached::Fast' );
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
    return $self->{$cache}->flush_all()
      if ( ref( $self->{$cache} ) eq 'Cache::Memcached::Fast' );
    return $self->{$cache}->clear();
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
    unless ( lc( $args->{'cache_type'} ) eq 'null' ) {
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
