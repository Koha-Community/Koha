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

use Koha::RecordSource;

=head1 NAME

Koha::MarcModificationTemplate - Koha MarcModificationTemplate Object class

=head1 API

=head2 Class methods

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
