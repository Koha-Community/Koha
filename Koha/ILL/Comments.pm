package Koha::ILL::Comments;

# Copyright Magnus Enger Libriotech 2017
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Koha::Database;
use Koha::ILL::Comment;
use base qw(Koha::Objects);

=head1 NAME

Koha::ILL::Comments - Koha Illcomments Object class

=head2 Internal methods

=head3 _type

    my $type = Koha::ILL::Comments->_type;

Return this object's type

=cut

sub _type {
    return 'Illcomment';
}

=head3 object_class

    my $class = Koha::ILL::Comments->object_class;

Return this object's class name

=cut

sub object_class {
    return 'Koha::ILL::Comment';
}

=head1 AUTHOR

Magnus Enger <magnus@libriotech.no>

=cut

1;
