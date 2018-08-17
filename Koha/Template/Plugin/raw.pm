package Koha::Template::Plugin::raw;

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
    my ( $self, $text ) = @_;
    return $text;
}

1;

=head1 NAME

Koha::Template::Plugin::raw - TT Plugin for filtering variables as raw

=head1 SYNOPSIS

[% USE raw %]

[% my_var | $raw %]

The variable will not be modified and display at it.

It is required to use a filter to display any variables in .tt or .inc

In most of the case, you need to use the html filter instead.

=head1 METHODS

=head2 filter

Will return the variable as it. Nothing is changed.

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=cut
