package Koha::ERM::EUsage::CounterLog;

# Copyright 2023 PTFS Europe

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

use base qw(Koha::Object);

=head1 NAME

Koha::ERM::EUsage::CounterLog - Koha ErmCounterLog Object class

=head1 API

=head2 Class Methods

=cut

=head3 to_api_mapping

This method returns the mapping for representing a Koha::ERM::EUsage::CounterLog
on the API.

=cut

sub to_api_mapping {
    return {
        borrowernumber => 'patron_id',
    };
}

=head3 patron

Return the patron for this counter_file

=cut

sub patron {
    my ($self) = @_;
    my $patrons_rs = $self->_result->patron;
    return unless $patrons_rs;
    return Koha::Patron->_new_from_dbic($patrons_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmCounterLog';
}

1;
