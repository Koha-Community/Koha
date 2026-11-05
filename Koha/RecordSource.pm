package Koha::RecordSource;

# This file is part of Koha.
#
# Copyright 2024 Koha Development Team
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <https://www.gnu.org/licenses>

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Exceptions;
use Koha::Library::Groups;
use Koha::Patrons;
use Koha::Token;

=head1 NAME

Koha::RecordSource - Koha RecordSource Object class

=head1 API

=head2 Class methods

=head3 usage_count

    my $count = $source->usage_count();

This method returns the count for records using this record source.

=cut

sub usage_count {
    my ($self) = @_;
    return $self->_result->biblio_metadatas->count();
}

=head3 library_groups

    my $library_groups = $source->library_groups;
    $source->library_groups( [ { library_group_id => $group_id }, ... ] );

Accessor for the library groups exempt from this source's lock.

=cut

sub library_groups {
    my ( $self, $library_groups ) = @_;

    return $self->_linked_library_groups unless $library_groups;

    my @group_ids      = map { $_->{library_group_id} } @$library_groups;
    my $eligible_count = Koha::Library::Groups->search(
        {
            id                       => \@group_ids,
            parent_id                => undef,
            ft_record_source_editing => 1,
        }
    )->count;
    Koha::Exceptions::BadParameter->throw( parameter => 'library_group_id' )
        unless $eligible_count == @group_ids;

    my $schema = $self->_result->result_source->schema;
    $schema->txn_do(
        sub {
            $self->_result->record_sources_library_groups->delete;

            for my $group_id (@group_ids) {
                $self->_result->add_to_record_sources_library_groups( { library_group_id => $group_id } );
            }
        }
    );

    return $self->_linked_library_groups;
}

=head3 _linked_library_groups

    my $library_groups = $source->_linked_library_groups;

Returns the library groups linked to this source as a I<Koha::Library::Groups> set.

=cut

sub _linked_library_groups {
    my ($self) = @_;

    my $library_groups_rs = $self->_result->library_groups;
    return Koha::Library::Groups->_new_from_dbic($library_groups_rs);
}

=head3 store

=cut

sub store {
    my ($self) = @_;
    Koha::Exceptions::BadParameter->throw('* not allowed') if $self->name eq '*';

    return $self->SUPER::store;
}

=head3 delete

Overridden delete method to prevent system default deletions

=cut

sub delete {
    my ($self) = @_;

    Koha::Exceptions::CannotDeleteDefault->throw if $self->is_system;

    return $self->SUPER::delete;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'RecordSource';
}

1;
