package Koha::Caches;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::Caches - Cache handling

=head1 SYNOPSIS

my $cache = Koha::Caches->get_instance();

=head1 DESCRIPTION

Description

=head1 CLASS METHODS

=cut

use Modern::Perl;

use Koha::Cache;

our $singleton_caches;

=head2 get_instance

This gets a shared instance of the cache, set up in a very default way. This is
the recommended way to fetch a cache object. If possible, it'll be
persistent across multiple instances.

=cut

sub get_instance {
    my ( $class, $subnamespace ) = @_;
    $subnamespace //= '';
    $singleton_caches->{$subnamespace} = Koha::Cache->new( {}, { subnamespace => $subnamespace } )
        unless $singleton_caches->{$subnamespace};
    return $singleton_caches->{$subnamespace};
}

=head2 flush_L1_caches

=cut

sub flush_L1_caches {
    return unless $singleton_caches;
    for my $cache ( values %$singleton_caches ) {
        $cache->flush_L1_cache;
    }
}

1;
