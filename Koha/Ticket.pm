package Koha::Ticket;

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

use base qw(Koha::Object);

use C4::Letters;

use Koha::Ticket::Update;
use Koha::Ticket::Updates;

=head1 NAME

Koha::Ticket - Koha Ticket Object class

=head1 API

=head2 Relations

=cut

=head3 reporter

Return the patron who submitted this ticket

=cut

sub reporter {
    my ($self) = @_;
    my $rs = $self->_result->reporter;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 resolver

Return the user who resolved this ticket

=cut

sub resolver {
    my ($self) = @_;
    my $rs = $self->_result->resolver;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs) if $rs;
}

=head3 biblio

Return the biblio linked to this ticket

=cut

sub biblio {
    my ($self) = @_;
    my $rs = $self->_result->biblio;
    return unless $rs;
    return Koha::Biblio->_new_from_dbic($rs);
}

=head3 updates

Return any updates attached to this ticket

=cut

sub updates {
    my ($self) = @_;
    my $rs = $self->_result->ticket_updates;
    return unless $rs;
    return Koha::Ticket::Updates->_new_from_dbic($rs) if $rs;
}

=head2 Actions

=head3 add_update

=cut

sub add_update {
    my ( $self, $params ) = @_;

    my $rs = $self->_result->add_to_ticket_updates($params)->discard_changes;
    return Koha::Ticket::Update->_new_from_dbic($rs);
}

=head2 Core methods

=head3 store

Overloaded I<store> method to trigger notices as required

=cut

sub store {
    my ($self) = @_;

    my $is_new = !$self->in_storage;
    $self = $self->SUPER::store;

    if ($is_new) {

        # Send patron acknowledgement
        my $acknowledgement_letter = C4::Letters::GetPreparedLetter(
            module      => 'catalog',
            letter_code => 'TICKET_ACKNOWLEDGEMENT',
            branchcode  => $self->reporter->branchcode,
            tables      => { tickets => $self->id }
        );

        if ($acknowledgement_letter) {
            my $acknowledgement_message_id = C4::Letters::EnqueueLetter(
                {
                    letter                 => $acknowledgement_letter,
                    message_transport_type => 'email',
                    borrowernumber         => $self->reporter_id,
                }
            );
            C4::Letters::SendQueuedMessages(
                { message_id => $acknowledgement_message_id } );
        }
    }

    return $self;
}

=head2 Internal methods

=cut

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Ticket object
on the API.

=cut

sub to_api_mapping {
    return { id => 'ticket_id', };
}

=head3 _type

=cut

sub _type {
    return 'Ticket';
}

1;
