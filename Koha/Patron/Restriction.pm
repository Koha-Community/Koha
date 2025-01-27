package Koha::Patron::Restriction;

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
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron::Restriction::Type;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Restriction - Koha Patron::Restriction Object class

=head1 API

=head2 Class methods

=head3 type

  my $restriction_type = $restriction->type;

Returns the restriction type

=cut

sub type {
    my ($self) = @_;
    my $type_rs = $self->_result->type;
    return Koha::Patron::Restriction::Type->_new_from_dbic($type_rs);
}

=head3 is_expired

my $is_expired = $restriction->is_expired;

Returns 1 if the restriction is expired or 0;

=cut

sub is_expired {
    my ($self) = @_;
    return 0 unless $self->expiration;

    # This condition must be consistent with Koha::Patron->is_debarred
    my $makes_patron_debarred = dt_from_string( $self->expiration ) > dt_from_string;
    return 1 unless $makes_patron_debarred;
    return 0;
}

=head2 Internal methods

=head3 _type

Corresponding DBIC resultset class name

=cut

sub _type {
    return 'BorrowerDebarment';
}

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
