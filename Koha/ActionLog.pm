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

use JSON qw( decode_json );

use C4::Context;

# Avoid `use Koha::Patrons` here: Koha::ActionLog is loaded transitively by
# C4::Log very early in the dependency chain, before Koha::Patron has been
# fully defined. The accessors below reach for Koha::Patron (and Koha::Items)
# at call time, by which point they are reliably available.

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

=head3 item

    my $item = $log->item;

Returns the related I<Koha::Item> for a CIRCULATION log entry, or I<undef>.

The itemnumber is not stored in a dedicated column; it lives inside the
C<info> field, which for circulation is either a JSON payload carrying an
C<itemnumber> key (ISSUE, RENEWAL) or a bare itemnumber string (RETURN).
Returns I<undef> for non-circulation rows, when no itemnumber can be
derived, or when the item has since been deleted.

=cut

sub item {
    my ($self) = @_;

    return unless ( $self->module // q{} ) eq 'CIRCULATION';

    my $info = $self->info;
    return unless defined $info;

    my $itemnumber;
    my $decoded = eval { decode_json($info) };
    if ( ref($decoded) eq 'HASH' && $decoded->{itemnumber} ) {
        $itemnumber = $decoded->{itemnumber};
    } elsif ( $info =~ /^\s*(\d+)\s*$/ ) {
        $itemnumber = $1;
    }

    return unless $itemnumber;

    require Koha::Items;
    return Koha::Items->find($itemnumber);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ActionLog';
}

1;
