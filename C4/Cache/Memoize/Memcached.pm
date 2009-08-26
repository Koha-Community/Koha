package Koha::Cache::Memoize::Memcached;

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

use Memoize::Memcached;

use base qw(C4::Cache);

sub _cache_handle {
    my $class  = shift;
    my $params = shift;
    
    my @servers = split /,/, $params->{'cache_servers'};
    
    my $memcached = {
	servers    => \@servers,
	key_prefix => $params->{'namespace'} || 'koha',
    };
    my $cache = {};
    $cache->{memcache}=$memcached;
    return $cache;
}

sub memcached_memoize {
    my $self     = shift;
    my $function = shift;
    my $ttl      = shift;
    memoize_memcached($function, memcached => $self->{memcached}, expire_time => $ttl);
}

1;
__END__                                                                         
                                                                                  
=head1 NAME                                                                     
                                                                                
  C4::Cache::Memoize::Memcached - subclass of C4::Cache                
                                                                                  
=cut
