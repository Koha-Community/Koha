package C4::Cache;

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

=head1 NAME

    C4::Cache - Handling caching of html and Objects for Koha

=head1 SYNOPSIS

  use C4::Cache (cache_type => $cache_type, %params );


=head1 DESCRIPTION

  Base class for C4::Cache::X. Subclasses need to provide the following methods

  B<_cache_handle  ($params_hr)> - cache handle creator                         
  B<set_in_cache   ($key, $value, $expiry)>                                     
  B<get_from_cache ($key)>                                                      
  B<clear_from_cache ($key)>                                                    
  B<flush_all      ()>  

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Carp;

use base qw(Class::Accessor);

use C4::Cache::Memcached;
use C4::Cache::FastMemcached;

__PACKAGE__->mk_ro_accessors( qw( cache ) );

sub new {
    my $class = shift;                                                          
    my %param = @_;                                                             
    
    my $cache_type = $param{cache_type} || 'memcached';
    my $subclass = __PACKAGE__."::".ucfirst($cache_type);
    my $cache    = $subclass->_cache_handle(\%param)
      or croak "Cannot create cache handle for '$cache_type'";
    return bless $class->SUPER::new({cache => $cache}), $subclass;              
}

=head2 EXPORT

  None by default.

=head1 SEE ALSO
  
  C4::Cache::Memcached

=head1 AUTHOR

Chris Cormack, E<lt>chris@bigballofwax.co.nzE<gt>

=cut

1;

__END__
