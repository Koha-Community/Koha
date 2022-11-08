package Koha::Patron::Message;

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


use C4::Context;
use C4::Log;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Message - Koha Message Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

=cut

sub store {
    my ($self) = @_;

    # This should be done at the DB level
    return unless $self->borrowernumber
              and $self->message
              and $self->message_type
              and $self->branchcode;

    unless ( defined $self->manager_id ) {
        my $userenv = C4::Context->userenv;
        $self->manager_id( $userenv ? $userenv->{number} : undef );
    }

    if ( C4::Context->preference("BorrowersLog") ) {
        if ( $self->in_storage ) {
            C4::Log::logaction( "MEMBERS", "MODCIRCMESSAGE", $self->borrowernumber, $self->message )
        } else {
            C4::Log::logaction( "MEMBERS", "ADDCIRCMESSAGE", $self->borrowernumber, $self->message )
        }
    }

    return $self->SUPER::store($self);
}

=head3 delete

=cut

sub delete {
    my ($self) = @_;

    C4::Log::logaction("MEMBERS", "DELCIRCMESSAGE", $self->borrowernumber, $self->message)
        if C4::Context->preference("BorrowersLog");

    return $self->SUPER::delete($self);
}

=head3 _type

=cut

sub _type {
    return 'Message';
}

1;
