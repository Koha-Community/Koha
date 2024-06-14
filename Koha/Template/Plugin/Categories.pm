package Koha::Template::Plugin::Categories;

# Copyright 2013-2014 BibLibre
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

use Template::Plugin;
use base qw( Template::Plugin );

use List::Util qw( any );
use Koha::Patron::Categories;

sub all {
    my ( $self, $params ) = @_;
    return Koha::Patron::Categories->search($params, { order_by => [ 'description' ] } );
}

sub limited {
    my ( $self, $params ) = @_;
    return Koha::Patron::Categories->search_with_library_limits($params, { order_by => [ 'description' ] } );
}

sub GetName {
    my ( $self, $categorycode ) = @_;

    return Koha::Patron::Categories->find( $categorycode )->description;
}

sub can_any_reset_password {
    return ( any { $_->effective_reset_password } @{ Koha::Patron::Categories->search->as_list } )
        ? 1
        : 0;
}

1;

=head1 NAME

Koha::Template::Plugin::Categories - TT Plugin for categories

=head1 SYNOPSIS

[% USE Categories %]

[% Categories.all() %]

=head1 ROUTINES

=head2 all

In a template, you can get all the categories with
the following TT code: [% Categories.all() %]

=head2 limited

In a template, you can get the categories with library limits applied with
the following TT code: [% Categories.limited() %]

=head2 GetName

In a template, you can get the name of a patron category using
[% Categories.GetName( categorycode ) %].

=head2 can_any_reset_password

Returns I<true> is any patron category has the I<effective_reset_password> evaluate to I<true>.
Returns I<false> otherwise.

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=cut
