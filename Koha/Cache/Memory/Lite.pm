package Koha::Cache::Memory::Lite;

# Copyright 2016 Koha Development Team
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

Koha::Cache::Memory::Lite - Handling caching of objects in memory *only* for Koha

=head1 SYNOPSIS

  use Koha::Cache::Memory::Lite;
  my $cache = Koha::Cache::Memory::Lite->get_instance();
  $cache->set($key, $value);
  my $retrieved_from_cache_value = $cache->get($key);
  $cache->clear_from_cache($key);
  $cache->flush();

=head1 DESCRIPTION

Koha in memory only caching routines.

=cut

use Modern::Perl;

use base qw(Class::Accessor);

our %L1_cache;

our $singleton_cache;
sub get_instance {
    my ($class) = @_;
    $singleton_cache = $class->new() unless $singleton_cache;
    return $singleton_cache;
}

sub get_from_cache {
    my ( $self, $key ) = @_;
    return $L1_cache{$key};
}

sub set_in_cache {
    my ( $self, $key, $value ) = @_;
    $L1_cache{$key} = $value;
}

sub clear_from_cache {
    my ( $self, $key ) = @_;
    delete $L1_cache{$key};
}

sub flush {
    my ( $self ) = @_;
    %L1_cache = ();
}

1;
