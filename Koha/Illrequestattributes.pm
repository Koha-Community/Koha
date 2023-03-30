package Koha::Illrequestattributes;

# Copyright PTFS Europe 2016
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

use Modern::Perl;

use Koha::Database;
use Koha::Illrequestattribute;

use base qw(Koha::Objects);

=head1 NAME

Koha::Illrequestattributes - Koha Illrequestattributes Object class

=head1 API

=head2 Class Methods

=cut

=head3 search

my $attributes = Koha::Illrequestattributes->search( $params );

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    unless ( exists $attributes->{order_by} ) { $attributes->{order_by} = ['me.type', 'value'] }

    return $self->SUPER::search( $params, $attributes );
}

=head3 type

=cut

sub _type {
    return 'Illrequestattribute';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Illrequestattribute';
}

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
