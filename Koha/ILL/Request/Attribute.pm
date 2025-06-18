package Koha::ILL::Request::Attribute;

# Copyright PTFS Europe 2016
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

use base qw(Koha::Object);

=head1 NAME

Koha::ILL::Request::Attribute - Koha Illrequestattribute Object class

=head1 API

=head2 Class methods

=head3 store

Overloaded store method to ensure we have backend filled if not already passed

=cut

sub store {
    my ($self) = @_;

    if ( !$self->backend ) {
        $self->backend( $self->request->backend );
    }

    return $self->SUPER::store;
}

=head3 request

Returns a Koha::ILL::Request object representing the core request .

=cut

sub request {
    my ($self) = @_;
    return Koha::ILL::Request->_new_from_dbic( $self->_result->illrequest );
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [qw(backend illrequest_id readonly type value)];
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Illrequestattribute';
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::ILL::Request::Attribute object
on the API.

=cut

sub to_api_mapping {
    return {
        illrequest_id => 'ill_request_id',
        readonly      => 'read_only',
    };
}

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
