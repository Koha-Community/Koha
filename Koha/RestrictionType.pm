package Koha::RestrictionType;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use base qw(Koha::Object);

use Koha::RestrictionTypes;
use C4::Context;

=head1 NAME

Koha::RestrictionType - Koha RestrictionType Object class

=head1 API

=head2 Class Methods

=head3 delete

Overloaded delete method that does extra clean up:
- Reset all restrictions using the restriction type about to be deleted
  back to whichever restriction is marked as default

=cut

sub delete {
    my ( $self ) = @_;

    # Find out what the default is
    my $default = Koha::RestrictionTypes->find({ dflt => 1 })->code;
    # Ensure we're not trying to delete a readonly type (this includes
    # the default type)
    return 0 if $self->ronly == 1;
    # We can't use Koha objects here because Koha::Patron::Debarments
    # is not a Koha object. So we'll do it old skool
    my $rows = C4::Context->dbh->do(
        "UPDATE borrower_debarments SET type = ? WHERE type = ?",
        undef,
        ($default, $self->code)
    );

    # Now do the delete if the update was successful
    if ($rows) {
        my $deleted = $self->SUPER::delete($self);
        return $deleted
    }

    return 0;
}

=head2 Internal methods

=head3 type

=cut

sub _type {
    return 'DebarmentType';
}

1;
