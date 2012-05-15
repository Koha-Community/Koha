package Koha::Cache::Memcached;

# Copyright 2012 C & P Bibliography Services
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

use strict;
use warnings;
use Carp;
use Cache::Memcached::Fast;
use Module::Load::Conditional qw(can_load);

use base qw(Koha::Cache);

sub _cache_handle {
    my $class   = shift;
    my $params  = shift;
    my @servers = split /,/,
      $params->{'cache_servers'}
      ? $params->{'cache_servers'}
      : $ENV{MEMCACHED_SERVERS};
    my $namespace =
         $ENV{MEMCACHED_NAMESPACE}
      || $params->{'namespace'}
      || 'koha';
    $ENV{DEBUG}
      && warn "Caching server settings: "
      . join( ', ', @servers )
      . " with "
      . ( $ENV{MEMCACHED_NAMESPACE} || $params->{'namespace'} || 'koha' );
    if (
        $params->{have_chi}
        && can_load(
            modules =>
              { 'CHI' => undef, 'CHI::Driver::Memcached::Fast' => undef }
        )
      )
    {
        return CHI->new(
            driver             => 'Memcached::Fast',
            servers            => \@servers,
            namespace          => $namespace,
            compress_threshold => 10_000,
            l1_cache =>
              { driver => 'Memory', global => 1, max_size => 1024 * 1024 },
        );

        # We use a 1MB L1 memory cache for added efficiency
    }
    else {
        return Cache::Memcached::Fast->new(
            {
                servers            => \@servers,
                compress_threshold => 10_000,
                namespace          => $namespace,
            }
        );
    }
}

sub set_in_cache {
    my ( $self, $key, $value, $expiry ) = @_;
    return $self->SUPER::set_in_cache( $key, $value, $expiry )
      if ( $self->{have_chi} );

    # No CHI, we have to use Cache::Memcached::Fast directly
    if ( defined $expiry ) {
        return $self->cache->set( $key, $value, $expiry );
    }
    else {
        return $self->cache->set( $key, $value );
    }
}

sub get_from_cache {
    my ( $self, $key ) = @_;
    return $self->SUPER::get_from_cache($key) if ( $self->{have_chi} );

    # No CHI, we have to use Cache::Memcached::Fast directly
    return $self->cache->get($key);
}

sub clear_from_cache {
    my ( $self, $key ) = @_;
    return $self->SUPER::clear_from_cache($key) if ( $self->{have_chi} );

    # No CHI, we have to use Cache::Memcached::Fast directly
    return $self->cache->delete($key);
}

# We have to overload flush_all because CHI::Driver::Memcached::Fast does not
# support the clear() method
sub flush_all {
    my $self = shift;
    if ( $self->{have_chi} ) {
        $self->{cache}->l1_cache->clear();
        return $self->{cache}->memd->flush_all();
    }
    else {
        return $self->{cache}->flush_all;
    }
}

1;
__END__

=head1 NAME

Koha::Cache::Memcached - memcached subclass of Koha::Cache

=cut
