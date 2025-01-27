package Koha::Import::Record::Match;

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

use Carp;

use Koha::Database;
use Koha::Import::Record;

use base qw(Koha::Object);

=head1 NAME

Koha::Import::Record::Match - Koha Import Record Match Object class

=head1 API

=head2 Class methods

=head3 import_record

my $import_record = $match->import_record;

Return the import record of this match

=cut

sub import_record {
    my ($self) = @_;
    my $record_rs = $self->_result->import_record;
    return Koha::Import::Record->_new_from_dbic($record_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ImportRecordMatch';
}

1;
