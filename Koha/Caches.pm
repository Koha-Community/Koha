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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Cache;

our $singleton_caches;
sub get_instance {
    my ($class, $subnamespace) = @_;
    $subnamespace //= '';
    $singleton_caches->{$subnamespace} = Koha::Cache->new({}, { subnamespace => $subnamespace } )
        unless $singleton_caches->{$subnamespace};
    return $singleton_caches->{$subnamespace};
}

sub flush_L1_caches {
    return unless $singleton_caches;
    for my $cache ( values %$singleton_caches ) {
        $cache->flush_L1_cache;
    }
}

1;
