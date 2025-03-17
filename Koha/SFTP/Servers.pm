package Koha::SFTP::Servers;

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
use Koha::Exceptions;

use Koha::SFTP::Server;

use base qw(Koha::Objects);

=head1 NAME

Koha::SFTP::Servers - Koha SFTP Server Object set class

=head1 API

=head2 Internal methods

=head3 _type

Return type of object, relating to Schema ResultSet

=cut

sub _type {
    return 'SftpServer';
}

=head3 _polymorphic_field

Return the field in the table that defines the polymorphic class to be built

=cut

sub _polymorphic_field {
    return 'transport';    # This field defines which subclass to use
}

=head3 _polymorphic_map

Return the mapping for field value to class name for the polymorphic class

=cut

sub _polymorphic_map {
    return {
        sftp => 'Koha::File::Transport::SFTP',
        ftp  => 'Koha::File::Transport::FTP',
    };
}

=head3 object_class

Return object class

=cut

sub object_class {
    my ( $self, $object ) = @_;

    return 'Koha::File::Transport' unless $object;

    my $field = $self->_polymorphic_field;
    my $map   = $self->_polymorphic_map;

    return $map->{ lc( $object->$field ) } || 'Koha::File::Transport';
}

1;
