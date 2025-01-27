package Koha::ProblemReport;

# This file is part of Koha.
#
# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
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

use base qw(Koha::Object);

=head1 NAME

Koha::ProblemReport - Koha Problem Report Object class

=head1 API

=head2 Class Methods

=cut

=head3 patron

my $patron = $report->patron

Return the patron for who the report has been done

=cut

sub patron {
    my ($self) = @_;
    my $patron_rs = $self->_result->borrowernumber;
    return Koha::Patron->_new_from_dbic($patron_rs);
}

=head3 type

=cut

sub _type {
    return 'ProblemReport';
}

1;
