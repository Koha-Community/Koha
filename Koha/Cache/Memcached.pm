package Koha::Cache::Memcached;

# Copyright 2009 Chris Cormack and The Koha Dev Team
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

use Cache::Memcached;

use base qw(Koha::Cache);

sub _cache_handle {
    my $class  = shift;
    my $params = shift;
    my @servers = split /,/, $params->{'cache_servers'}?$params->{'cache_servers'}:$ENV{MEMCACHED_SERVERS};
    $ENV{DEBUG} && warn "Caching server settings: ".join(', ',@servers)." with ".($ENV{MEMCACHED_NAMESPACE} || $params->{'namespace'} || 'koha');
    return Cache::Memcached->new(
        servers   => \@servers,
        debug   => 0,
        compress_threshold => 10_000,
        expire_time => 600,
        namespace => $ENV{MEMCACHED_NAMESPACE} || $params->{'namespace'} || 'koha',
    );
}

sub set_in_cache {
    my ( $self, $key, $value, $expiry ) = @_;
    croak "No key" unless $key;
    $self->cache->set_debug;
    $ENV{DEBUG} && warn "set_in_cache for Memcache $key";

    if ( defined $expiry ) {
        return $self->cache->set( $key, $value, $expiry );
    }
    else {
        return $self->cache->set( $key, $value );
    }
}

sub get_from_cache {
    my ( $self, $key ) = @_;
    croak "No key" unless $key;
    $ENV{DEBUG} && warn "get_from_cache for Memcache $key";
    return $self->cache->get($key);
}

sub clear_from_cache {
    my ( $self, $key ) = @_;
    croak "No key" unless $key;
    return $self->cache->delete($key);
}

sub flush_all {
    my $self = shift;
    return $self->cache->flush_all;
}

1;
__END__

=head1 NAME

Koha::Cache::Memcached - memcached subclass of Koha::Cache

=cut
