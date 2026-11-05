package Koha::MarcModificationTemplates;

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

use base qw(Koha::Objects);

use Koha::MarcModificationTemplate;

=head1 NAME

Koha::MarcModificationTemplates - Koha MarcModificationTemplates Object class

=head1 API

=head2 Class methods

=head3 record_source_id_for

    my $record_source_id = Koha::MarcModificationTemplates->record_source_id_for($template_id);

Returns the record source id set on the given template, or I<undef> when
the template does not exist or has no record source.

=cut

sub record_source_id_for {
    my ( $self, $template_id ) = @_;

    my $template = $self->find($template_id);
    return unless $template;
    return $template->record_source_id;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'MarcModificationTemplate';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::MarcModificationTemplate';
}

1;
