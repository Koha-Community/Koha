package Koha::Template::Plugin::Price;

# This file is part of Koha.
#
# Copyright 2014 BibLibre
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

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

use Koha::Number::Price;
our $DYNAMIC = 1;

sub filter {
    my ( $self, $value, $args, $config ) = @_;
    $value ||= 0;
    $config->{on_editing} //= 0;
    return $config->{on_editing}
        ? Koha::Number::Price->new( $value )->format_for_editing
        : Koha::Number::Price->new( $value )->format( $config );
}

1;
