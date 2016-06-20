package Koha::Template::Plugin::KohaSpan;

# Copyright ByWater Solutions 2016
# Author: Kyle M Hall <kyle@bywatersolutions.com>

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

use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

our $DYNAMIC = 1;

sub filter {
    my ( $self, $text, $args, $config ) = @_;

    $config->{with_hours} //= 0;
    my $id    = $config->{id};
    my $class = $config->{class};

    my $span = "<span";
    $span .= " id='$id'"       if $id;
    $span .= " class='$class'" if $class;
    $span .= ">$text</span>";

    return $span;
}

1;
