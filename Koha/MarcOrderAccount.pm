package Koha::MarcOrderAccount;

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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::MarcOrderAccount - Koha Marc Ordering Account Object class

=head1 API

=head2 Class Methods

=cut

=head3 vendor

=cut

sub vendor {
    my ($self) = @_;
    my $vendor_rs = $self->_result->vendor;
    return unless $vendor_rs;
    return Koha::Acquisition::Bookseller->_new_from_dbic($vendor_rs);
}

=head3 budget

=cut

sub budget {
    my ($self) = @_;
    my $budget_rs = $self->_result->budget;
    return Koha::Acquisition::Fund->_new_from_dbic($budget_rs);
}

=head3 _type

=cut

sub _type {
    return 'MarcOrderAccount';
}

1;
