package Koha::ActionLog;

# Copyright 2015 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;

# Avoid `use Koha::Patrons` here: Koha::ActionLog is loaded transitively by
# C4::Log very early in the dependency chain, before Koha::Patron has been
# fully defined. The accessors below reach for Koha::Patron at call time,
# by which point it is reliably available.

use base qw(Koha::Object);

=head1 NAME

Koha::ActionLog - Koha ActionLog Object class

=head1 API

=head2 Class methods

=head3 librarian

    my $librarian = $log->librarian;

Returns the related I<Koha::Patron> object for the librarian who performed
the action, or I<undef> if the C<user> column was not set (e.g. cron jobs).

=cut

sub librarian {
    my ($self) = @_;
    my $rs = $self->_result->librarian;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 patron

    my $patron = $log->patron;

Returns the related I<Koha::Patron> object joined on the C<object> column.
Only meaningful for rows where C<object> is a borrowernumber (MEMBERS,
CIRCULATION, FINES and APIKEYS modules); for other modules the join may
match an unrelated patron and the caller must filter by C<module>.

=cut

sub patron {
    my ($self) = @_;
    my $rs = $self->_result->patron;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ActionLog';
}

1;
