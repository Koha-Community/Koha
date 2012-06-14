package Koha::Cache::Memory;

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
use Module::Load::Conditional qw(can_load);

use base qw(Koha::Cache);

sub _cache_handle {
    my $class  = shift;
    my $params = shift;
    if ( can_load( modules => { CHI => undef } ) ) {
        return CHI->new(
            driver    => 'Memory',
            namespace => $params->{'namespace'} || 'koha',
            expire_in => 600,
            max_size  => $params->{'max_size'} || 8192 * 1024,
            global    => 1,
        );
    } else {
        return;
    }
}

1;
__END__

=head1 NAME

Koha::Cache::Memory - in-process memory based cache for Koha

=cut
