package Koha::Ticket::Update;

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

=head1 NAME

Koha::Ticket::Update - Koha Ticket Update Object class

=head1 API

=head2 Relations

=cut

=head3 ticket

Return the ticket this update relates to

=cut

sub ticket {
    my ($self) = @_;
    my $rs = $self->_result->ticket;
    return unless $rs;
    return Koha::Ticket->_new_from_dbic($rs);
}

=head3 user

Return the patron who submitted this update

=cut

sub user {
    my ($self) = @_;
    my $rs = $self->_result->user;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 assignee

Return the patron who is assigned at this update

=cut

sub assignee {
    my ($self) = @_;
    my $rs = $self->_result->assignee;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Ticket::Update object
on the API.

=cut

sub to_api_mapping {
    return { id => 'update_id', };
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
    return 'TicketUpdate';
}

1;
