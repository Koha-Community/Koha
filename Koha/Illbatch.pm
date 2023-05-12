package Koha::Illbatch;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Koha::Database;
use Koha::Illrequest::Logger;
use Koha::IllbatchStatus;
use JSON qw( to_json );
use base qw(Koha::Object);

=head1 NAME

Koha::Illbatch - Koha Illbatch Object class

=head2 Class methods

=head3 status

    my $status = Koha::Illbatch->status;

Return the status object associated with this batch

=cut

sub status {
    my ( $self ) = @_;
    return Koha::IllbatchStatus->_new_from_dbic(
        scalar $self->_result->statuscode
    );
}

=head3 patron

    my $patron = Koha::Illbatch->patron;

Return the patron object associated with this batch

=cut

sub patron {
    my ( $self ) = @_;
    return Koha::Patron->_new_from_dbic(
        scalar $self->_result->borrowernumber
    );
}

=head3 branch

    my $branch = Koha::Illbatch->branch;

Return the branch object associated with this batch

=cut

sub branch {
    my ( $self ) = @_;
    return Koha::Library->_new_from_dbic(
        scalar $self->_result->branchcode
    );
}

=head3 requests_count

    my $requests_count = Koha::Illbatch->requests_count;

Return the number of requests associated with this batch

=cut

sub requests_count {
    my ( $self ) = @_;
    return Koha::Illrequests->search({
        batch_id => $self->id
    })->count;
}

=head3 create_and_log

    $batch->create_and_log;

Log batch creation following storage

=cut

sub create_and_log {
    my ( $self ) = @_;

    $self->store;

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname  => 'batch_create',
        objectnumber => $self->id,
        infos        => to_json({})
    });
}

=head3 update_and_log

    $batch->update_and_log;

Log batch update following storage

=cut

sub update_and_log {
    my ( $self, $params ) = @_;

    my $before = {
        name       => $self->name,
        branchcode => $self->branchcode
    };

    $self->set( $params );
    my $update = $self->store;

    my $after = {
        name       => $self->name,
        branchcode => $self->branchcode
    };

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname  => 'batch_update',
        objectnumber => $self->id,
        infos        => to_json({
            before => $before,
            after  => $after
        })
    });
}

=head3 delete_and_log

    $batch->delete_and_log;

Log batch delete

=cut

sub delete_and_log {
    my ( $self ) = @_;

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname  => 'batch_delete',
        objectnumber => $self->id,
        infos        => to_json({})
    });

    $self->delete;
}

=head2 Internal methods

=head3 _type

    my $type = Koha::Illbatch->_type;

Return this object's type

=cut

sub _type {
    return 'Illbatch';
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
