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

use Koha::Patron::Categories;

sub all {
    my ( $self, $params ) = @_;
    return Koha::Patron::Categories->search_limited($params);
}

sub GetName {
    my ( $self, $categorycode ) = @_;

    return Koha::Patron::Categories->find( $categorycode )->description;
}

1;

=head1 NAME

Koha::Template::Plugin::Categories - TT Plugin for categories

=head1 SYNOPSIS

[% USE Categories %]

[% Categories.all() %]

=head1 ROUTINES

=head2 all

In a template, you can get the all categories with
the following TT code: [% Categories.all() %]

=head2 GetName

In a template, you can get the name of a patron category using
[% Categories.GetName( categorycode ) %].

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=cut
