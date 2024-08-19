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
# <http://www.gnu.org/licenses>

use Modern::Perl;

use base qw(Koha::Object);

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

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'RecordSource';
}

1;
