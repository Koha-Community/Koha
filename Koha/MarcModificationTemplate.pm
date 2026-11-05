package Koha::MarcModificationTemplate;

# This file is part of Koha.
#
# Copyright 2026 Koha Development Team
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

use C4::Context;
use C4::Log qw( logaction );

use Koha::RecordSource;

=head1 NAME

Koha::MarcModificationTemplate - Koha MarcModificationTemplate Object class

=head1 API

=head2 Class methods

=head3 store

    $template->store;

Stores the template. Creations and modifications are recorded in the
action logs when the C<MarcModificationTemplatesLog> system preference
is enabled.

=cut

sub store {
    my ($self) = @_;

    my $log_enabled = C4::Context->preference('MarcModificationTemplatesLog');
    my $is_new      = !$self->in_storage;
    my $original    = $log_enabled && !$is_new ? $self->get_from_storage : undef;

    $self = $self->SUPER::store;

    if ($log_enabled) {
        if ($is_new) {
            logaction( 'MARC_MOD_TEMPLATES', 'CREATE', $self->id, $self );
        } else {
            logaction( 'MARC_MOD_TEMPLATES', 'MODIFY', $self->id, $self, undef, $original );
        }
    }

    return $self;
}

=head3 delete

    $template->delete;

Deletes the template. The deletion is recorded in the action logs when
the C<MarcModificationTemplatesLog> system preference is enabled.

=cut

sub delete {
    my ($self) = @_;

    my $template_id = $self->id;
    my $deleted     = $self->SUPER::delete;

    logaction( 'MARC_MOD_TEMPLATES', 'DELETE', $template_id, $self )
        if C4::Context->preference('MarcModificationTemplatesLog');

    return $deleted;
}

=head3 record_source

    my $record_source = $template->record_source;

Returns the I<Koha::RecordSource> the template sets on modified
bibliographic records, or I<undef> if none is set.

=cut

sub record_source {
    my ($self) = @_;
    my $rs = $self->_result->record_source;
    return unless $rs;
    return Koha::RecordSource->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'MarcModificationTemplate';
}

1;
