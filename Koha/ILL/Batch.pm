package Koha::ILL::Batch;

# Copyright PTFS Europe 2022
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

use Koha::ILL::Requests;
use Koha::ILL::Request::Logger;
use Koha::ILL::Batch::Statuses;
use Koha::Libraries;
use Koha::Patrons;

use JSON qw( to_json );
use base qw(Koha::Object);

=head1 NAME

Koha::ILL::Batch - Koha Illbatch Object class

=head2 Class methods

=head3 status

    my $status = Koha::ILL::Batch > status;

Return the status object associated with this batch

=cut

sub status {
    my ($self) = @_;
    return Koha::ILL::Batch::Status->_new_from_dbic( scalar $self->_result->status_code );
}

=head3 patron

    my $patron = Koha::ILL::Batch->patron;

Return the I<Koha::Patron> object associated with this batch

=cut

sub patron {
    my ($self) = @_;
    my $patron = $self->_result->patron;
    return unless $patron;
    return Koha::Patron->_new_from_dbic($patron);
}

=head3 library

    my $library = Koha::ILL::Batch->library;

Return the I<Koha::Library> object associated with this batch

=cut

sub library {
    my ($self) = @_;
    my $library = $self->_result->library;
    return unless $library;
    return Koha::Library->_new_from_dbic($library);
}

=head3 requests

Return the I<Koha::ILL::Requests> for this batch

=cut

sub requests {
    my ($self) = @_;
    my $requests = $self->_result->requests;
    return Koha::ILL::Requests->_new_from_dbic($requests);
}

=head3 create_and_log

    $batch->create_and_log;

Log batch creation following storage

=cut

sub create_and_log {
    my ($self) = @_;

    $self->store;

    my $logger = Koha::ILL::Request::Logger->new;

    $logger->log_something(
        {
            modulename   => 'ILL',
            actionname   => 'batch_create',
            objectnumber => $self->id,
            infos        => to_json( {} )
        }
    );
}

=head3 update_and_log

    $batch->update_and_log;

Log batch update following storage

=cut

sub update_and_log {
    my ( $self, $params ) = @_;

    my $before = {
        name       => $self->name,
        library_id => $self->library_id,
    };

    $self->set($params);
    my $update = $self->store;

    my $after = {
        name       => $self->name,
        library_id => $self->library_id,
    };

    my $logger = Koha::ILL::Request::Logger->new;

    $logger->log_something(
        {
            modulename   => 'ILL',
            actionname   => 'batch_update',
            objectnumber => $self->id,
            infos        => to_json(
                {
                    before => $before,
                    after  => $after
                }
            )
        }
    );
}

=head3 delete_and_log

    $batch->delete_and_log;

Log batch delete

=cut

sub delete_and_log {
    my ($self) = @_;

    my $logger = Koha::ILL::Request::Logger->new;

    $logger->log_something(
        {
            modulename   => 'ILL',
            actionname   => 'batch_delete',
            objectnumber => $self->id,
            infos        => to_json( {} )
        }
    );

    $self->delete;
}

=head2 Internal methods


=head3 strings_map

Returns a map of column name to string representations including the string,
the mapping type and the mapping category where appropriate.

Currently handles library and ILL batch status expansions.
expansions.

Accepts a param hashref where the I<public> key denotes whether we want the public
or staff client strings.

Note: the I<public> parameter is not currently used.

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $strings = {};

    if ( defined $self->status_code ) {
        my $status = $self->status;

        if ($status) {
            $strings->{status_code} = {
                str  => $status->name,
                type => 'ill_batch_status',
            };
        }
    }

    if ( defined $self->library_id ) {
        my $library = $self->library;

        if ($library) {
            $strings->{library_id} = {
                str  => $library->branchname,
                type => 'library',
            };
        }
    }

    return $strings;
}

=head3 _type

    my $type = Koha::ILL::Batch->_type;

Return this object's type

=cut

sub _type {
    return 'Illbatch';
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
