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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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

=head3 assignee

Return the patron who submitted this ticket

=cut

sub assignee {
    my ($self) = @_;
    my $rs = $self->_result->assignee;
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

    my $assignee;
    if ( !$self->in_storage ) {

        # Store
        $self->SUPER::store;
        $self->discard_changes;
        $assignee = $self->assignee;

        # Send patron acknowledgement
        my $acknowledgement_letter = C4::Letters::GetPreparedLetter(
            module      => 'catalogue',
            letter_code => 'TICKET_ACKNOWLEDGE',
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
            C4::Letters::SendQueuedMessages( { message_id => $acknowledgement_message_id } )
                if $acknowledgement_message_id;
        }

        # Notify cataloger by email
        if ( $self->biblio_id && C4::Context->preference('CatalogerEmails') ) {

            # notify the library if a notice exists
            my $notify_letter = C4::Letters::GetPreparedLetter(
                module      => 'catalogue',
                letter_code => 'TICKET_NOTIFY',
                branchcode  => $self->reporter->branchcode,
                tables      => { tickets => $self->id }
            );

            if ($notify_letter) {
                my $message_id = C4::Letters::EnqueueLetter(
                    {
                        letter                 => $notify_letter,
                        message_transport_type => 'email',
                        to_address             => C4::Context->preference('CatalogerEmails'),
                        reply_address          => $self->reporter->notice_email_address,
                    }
                );
                C4::Letters::SendQueuedMessages( { message_id => $message_id } ) if $message_id;
            }
        }
    } else {
        my %updated_columns = $self->_result->get_dirty_columns;
        $self->SUPER::store;
        $self->discard_changes;

        $assignee = ( exists $updated_columns{assignee_id} ) ? $self->assignee : undef;
    }

    # Notify assignee
    if ( $assignee && ( $assignee->borrowernumber != C4::Context->userenv->{number} ) ) {
        my $assigned_letter = C4::Letters::GetPreparedLetter(
            module      => 'catalogue',
            letter_code => 'TICKET_ASSIGNED',
            branchcode  => $assignee->branchcode,
            tables      => { tickets => $self->id }
        );

        if ($assigned_letter) {
            my $message_id = C4::Letters::EnqueueLetter(
                {
                    letter                 => $assigned_letter,
                    borrowernumber         => $assignee->borrowernumber,
                    message_transport_type => 'email',
                }
            );
            C4::Letters::SendQueuedMessages( { message_id => $message_id } ) if $message_id;
        }
    }

    return $self;
}

=head2 Internal methods

=cut

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'ticket_id',   'title',         'body',
        'reporter_id', 'reported_date', 'resolved_date',
        'biblio_id',   'source'
    ];
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Ticket object
on the API.

=cut

sub to_api_mapping {
    return { id => 'ticket_id', };
}

=head3 strings_map

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $strings = {};

    if ( defined $self->status ) {
        my $av = Koha::AuthorisedValues->search(
            {
                category         => 'TICKET_STATUS',
                authorised_value => $self->status,
            }
        );

        # Fall back to TICKET_RESOLUTION as needed
        if ( !$av->count ) {
            $av = Koha::AuthorisedValues->search(
                {
                    category         => 'TICKET_RESOLUTION',
                    authorised_value => $self->status,
                }
            );
        }

        my $status_str =
              $av->count
            ? $params->{public}
                ? $av->next->opac_description
                : $av->next->lib
            : $self->status;

        $strings->{status} = {
            category => 'TICKET_STATUS',
            str      => $status_str,
            type     => 'av',
        };
    }

    return $strings;
}

=head3 _type

=cut

sub _type {
    return 'Ticket';
}

1;
