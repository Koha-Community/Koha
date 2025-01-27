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

=head2 get_instance

This gets a shared instance of the lite cache, set up in a very default
way. The lite cache is an in memory only cache that's automatically flushed
for every request.

=cut

sub get_instance {
    my ($class) = @_;
    $singleton_cache = $class->new() unless $singleton_cache;
    return $singleton_cache;
}

=head2 get_from_cache

    my $value = $cache->get_from_cache($key);

Retrieve the value stored under the specified key in the cache.

The retrieved value is a direct reference so should not be modified.

=cut

sub get_from_cache {
    my ( $self, $key ) = @_;
    return $L1_cache{$key};
}

=head2 set_in_cache

    $cache->set_in_cache($key, $value);

Save a value to the specified key in the cache.

=cut

sub set_in_cache {
    my ( $self, $key, $value ) = @_;
    $L1_cache{$key} = $value;
}

=head2 clear_from_cache

    $cache->clear_from_cache($key);

Remove the value identified by the specified key from the lite cache.

=cut

sub clear_from_cache {
    my ( $self, $key ) = @_;
    delete $L1_cache{$key};
}

=head2 all_keys

    my @keys = $cache->all_keys();

Returns an array of all keys currently in the lite cache.

=cut

sub all_keys {
    my ($self) = @_;
    return keys %L1_cache;
}

=head2 flush

    $cache->flush();

Clear the entire lite cache.

=cut

sub flush {
    my ($self) = @_;
    %L1_cache = ();
}

1;
