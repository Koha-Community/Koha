package Koha::Illcomments;

# Copyright Magnus Enger Libriotech 2017
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Koha::Database;
use Koha::Illcomment;
use base qw(Koha::Objects);

=head1 NAME

Koha::Illcomments - Koha Illcomments Object class

=head2 Internal methods

=head3 _type

    my $type = Koha::IllComments->_type;

Return this object's type

=cut

sub _type {
    return 'Illcomments';
}

=head3 object_class

    my $class = Koha::IllComments->object_class;

Return this object's class name

=cut

sub object_class {
    return 'Koha::Illcomment';
}

=head1 AUTHOR

Magnus Enger <magnus@libriotech.no>

=cut

1;
