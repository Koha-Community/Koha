package Koha::IllbatchStatus;

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
use Koha::Illbatch;
use JSON qw( to_json );
use base qw(Koha::Object);

=head1 NAME

Koha::IllbatchStatus - Koha IllbatchStatus Object class

=head2 Class methods

=head3 create_and_log

    $status->create_and_log;

Log batch status creation following storage

=cut

sub create_and_log {
    my ( $self ) = @_;

    # Ensure code is uppercase and contains only word characters
    my $fixed_code = uc $self->code;
    $fixed_code =~ s/\W/_/;

    # Ensure this status doesn't already exist
    my $status = Koha::IllbatchStatuses->find({ code => $fixed_code });
    if ($status) {
        return {
            error => "Duplicate status found"
        };
    }

    # Ensure system statuses can't be created
    $self->set({
        code      => $fixed_code,
        is_system => 0
    })->store;

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname   => 'batch_status_create',
        objectnumber => $self->id,
        infos        => to_json({})
    });
}

=head3 update_and_log

    $status->update_and_log;

Log batch status update following storage

=cut

sub update_and_log {
    my ( $self, $params ) = @_;

    my $before = {
        name => $self->name
    };

    # Ensure only the name can be changed
    $self->set({
        name => $params->{name}
    });
    my $update = $self->store;

    my $after = {
        name => $self->name
    };

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname  => 'batch_status_update',
        objectnumber => $self->id,
        infos        => to_json({
            before => $before,
            after  => $after
        })
    });
}

=head3 delete_and_log

    $batch->delete_and_log;

Log batch status delete

=cut

sub delete_and_log {
    my ( $self ) = @_;

    # Don't permit deletion of system statuses
    if ($self->is_system) {
        return;
    }

    # Update all batches that use this status to have status UNKNOWN
    my $affected = Koha::Illbatches->search({ statuscode => $self->code });
    $affected->update({ statuscode => 'UNKNOWN'});

    my $logger = Koha::Illrequest::Logger->new;

    $logger->log_something({
        modulename   => 'ILL',
        actionname   => 'batch_status_delete',
        objectnumber => $self->id,
        infos        => to_json({})
    });

    $self->delete;
}

=head2 Internal methods

=head3 _type

    my $type = Koha::IllbatchStatus->_type;

Return this object's type

=cut

sub _type {
    return 'IllbatchStatus';
}

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
