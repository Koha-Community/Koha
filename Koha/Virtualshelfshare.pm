package Koha::Virtualshelfshare;

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

use DateTime;
use DateTime::Duration;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Patron;

use base qw(Koha::Object);

use constant SHARE_INVITATION_EXPIRY_DAYS => 14; #two weeks to accept

=head1 NAME

Koha::Virtualshelfshare - Koha Virtualshelfshare Object class

=head1 API

=head2 Class Methods

=cut

=head3 accept

=cut

sub accept {
    my ( $self, $invitekey, $borrowernumber ) = @_;
    if ( $self->has_expired ) {
        Koha::Exceptions::Virtualshelf::ShareHasExpired->throw;
    }
    if ( $self->invitekey ne $invitekey ) {
        Koha::Exceptions::Virtualshelf::InvalidInviteKey->throw;
    }

    # If this borrower already has a share, there is no need to accept twice
    # We solve this by 'pretending' to reaccept, but delete instead
    my $search = Koha::Virtualshelfshares->search({ shelfnumber => $self->shelfnumber, borrowernumber => $borrowernumber, invitekey => undef });
    if( $search->count ) {
        $self->delete;
        return $search->next;
    } else {
        $self->invitekey(undef);
        $self->sharedate(dt_from_string);
        $self->borrowernumber($borrowernumber);
        $self->store;
        return $self;
    }
}

=head3 has_expired

=cut

sub has_expired {
    my ($self) = @_;
    my $dt_sharedate     = dt_from_string( $self->sharedate, 'sql' );
    my $today            = dt_from_string;
    my $expiration_delay = DateTime::Duration->new( days => SHARE_INVITATION_EXPIRY_DAYS );
    my $has_expired = DateTime->compare( $today, $dt_sharedate->add_duration($expiration_delay) );
    # Note: has_expired = 0 if the share expires today
    return $has_expired == 1 ? 1 : 0
}

=head3 sharee

    Returns related Koha::Patron object for the sharee (patron who got this share).

=cut

sub sharee {
    my $self = shift;
    my $rs = $self->_result->borrowernumber;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 _type

=cut

sub _type {
    return 'Virtualshelfshare';
}

1;
