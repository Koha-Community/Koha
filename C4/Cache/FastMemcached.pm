package Koha::Cache::FastMemcached;

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
# You should have received a copy of the GNU General Public License along with                                                                 
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,                                                                  
# Suite 330, Boston, MA  02111-1307 USA    

use strict;
use warnings;
use Carp;

use Cache::Memcached::Fast;
use IO::Compress::Gzip;
use IO::Uncompress::Gunzip;
use Storable;

use base qw(C4::Cache);

sub _cache_handle {
    my $class  = shift;
    my $params = shift;

    my @servers = split /,/, $params->{'cache_servers'};

    return Cache::Memcached::Fast->new(
        {
            servers            => \@servers,
            namespace          => $params->{'namespace'} || 'KOHA',
            connect_timeout    => $params->{'connect_timeout'} || 2,
            io_timeout         => $params->{'io_timeout'} || 2,
            close_on_error     => 1,
            compress_threshold => 100_000,
            compress_ratio     => 0.9,
            compress_methods =>
              [ \&IO::Compress::Gzip::gzip, \&IO::Uncompress::Gunzip::gunzip ],
            max_failures      => 3,
            failure_timeout   => 2,
            ketama_points     => 150,
            nowait            => 1,
            hash_namespace    => 1,
            serialize_methods => [ \&Storable::freeze, \&Storable::thaw ],
            utf8              => 1,
        }
    );
}

sub set_in_cache {
    my ( $self, $key, $value, $expiry ) = @_;
    croak "No key" unless $key;

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
                                                                                
  C4::Cache::FastMemcached - memcached::fast subclass of C4::Cache                
                                                                                  
=cut
